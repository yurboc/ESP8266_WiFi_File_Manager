-- handle successfull connection
function handle_mqtt_connected(client)
  client:subscribe("/r/butovo/winled", 0)
  client:subscribe("/w/butovo/winled", 0)
  client:publish("/s/butovo/winled", "READY", 0, 0)
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
  
  collectgarbage()
end

-- create MQTT client
local m = mqtt.Client("mqtt_led_client", 120)
m:lwt("/s/butovo/winled", "OFFLINE", 0, 0)
m:on("message", handle_mqtt_message)
m:connect("rpi", handle_mqtt_connected)
--m:close()
collectgarbage()
