-- handle successfull connection
function handle_mqtt_connected(client)
  client:subscribe("/r/butovo/winled", 0)
  client:subscribe("/w/butovo/winled", 0)
  client:publish("/s/butovo/winled", "READY", 0, 0)

  client:subscribe("domoticz/out", 0)

  collectgarbage()
end

-- handle incoming message
function handle_mqtt_message(client, topic, data)

  -- read from internal variable
  if topic == "/r/butovo/winled" and data ~= nil then
    local index = tonumber(data)
    local g, r, b = buffer:get(index)
    local values = {R=r, G=g, B=b, ID=index}
    ok, json = pcall(cjson.encode, values)
    if ok then
      client:publish("/s/butovo/winled", json, 0, 0)
    else
      print("Failed to encode result as JSON")
    end
  end
  
  -- write to internal variable
  if topic == "/w/butovo/winled" and data ~= nil then
    local r = tonumber(string.sub(data, 1, 2), 16)
    local g = tonumber(string.sub(data, 3, 4), 16)
    local b = tonumber(string.sub(data, 5, 6), 16)
    buffer:fill(g, r, b)
    ws2812.write(buffer)
    
    local values = {R=r, G=g, B=b, ID=index}
    ok, json = pcall(cjson.encode, values)
    if ok then
      client:publish("/s/butovo/winled", json, 0, 0)
    else
      print("Failed to encode result as JSON")
    end
  end

  -- handle Domoticz
  if topic == "domoticz/out" and data ~= nil then
    local ctrl_mode, n_value = 0, 0
    local r, g, b, s = 0, 0, 0, 0
    local t = cjson.decode(data)
    for tk,tv in pairs(t) do
      if tk == "Color" and tv ~= nil then
        for ck,cv in pairs(tv) do
          if ck == "r" and cv ~= nil then r = cv end
          if ck == "g" and cv ~= nil then g = cv end
          if ck == "b" and cv ~= nil then b = cv end
        end
      end
      if tk == "svalue1" and tv ~= nil then s = tonumber(tv, 10) end
      if tk == "nvalue" and tv ~= nil then n_value = tv end
      if tk == "idx" and tv == 8 then ctrl_mode = 1 end
      if tk == "idx" and tv == 15 then ctrl_mode = 2 end
    end
    if ctrl_mode == 1 then
      if n_value == 0 then buffer:fill(0, 0, 0)
      else buffer:fill(255, 255, 255) end
    elseif ctrl_mode == 2 then
      if n_value == 0 then buffer:fill(0, 0, 0)
      else buffer:fill(g*s/100, r*s/100, b*s/100) end
    end
    if ctrl_mode ~= 0 then
      ws2812.write(buffer)
      --local values = {idx=8, nvalue=n_value}
      --ok, json = pcall(cjson.encode, values)
      --if ok then client:publish("domoticz/in", json, 0, 0) end
      --values = {idx=15, svalue1=s, n_value=nvalue}
      --ok, json = pcall(cjson.encode, values)
      --if ok then client:publish("domoticz/in", json, 0, 0) end
    end
  end
  collectgarbage()
end

-- create MQTT client
local m = mqtt.Client("mqtt_led_client", 120)
m:lwt("/s/butovo/winled", "OFFLINE", 0, 0)
m:on("message", handle_mqtt_message)
m:connect("rpi", handle_mqtt_connected)
--m:close()
collectgarbage()
