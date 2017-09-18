-- Handle HTTP GET parameters

-- color=[000000..FFFFFF] (solid color RRGGBB)
-- values=[1..117] (get LED value)
-- mode=[html] (show HTML page)
-- anim=sr (sr = shift right; sl = shift left)
---- color=[000000..FFFFFF] (new color RRGGBB)
---- delay=100 (N ms before next LED)

local cmd_found = false

-- Use animation
if _GET.anim ~= nil then
  cmd_found = true

  dofile("_anim.lua")

  ok, json = pcall(cjson.encode, {res="OK"})
  if ok then
    buf = json
  else
    print("Failed to encode result as JSON")
  end
end

-- Set solid color (if no animation)
if _GET.color ~= nil and not cmd_found then
  cmd_found = true
  
  local r = 0
  local g = 0
  local b = 0
  r = tonumber(string.sub(_GET.color, 1, 2), 16)
  g = tonumber(string.sub(_GET.color, 3, 4), 16)
  b = tonumber(string.sub(_GET.color, 5, 6), 16)
  
  if _GET.id == nil then
    buffer:fill(g, r, b)
  else
    buffer:set(tonumber(_GET.id), g, r, b)
  end
  
  ws2812.write(buffer)
  
  print("Set WS2812 strip color: R="..r..", G="..g..", B="..b)
  
  ok, json = pcall(cjson.encode, {res="OK"})
  if ok then
    buf = json
  else
    print("Failed to encode result as JSON")
  end
end

-- Get LED values
if _GET.values ~= nil then
  cmd_found = true
  
  local index = tonumber(_GET.values)
  local values = {}
  g, r, b = buffer:get(index)
  values = {R=r, G=g, B=b, ID=index}

  ok, json = pcall(cjson.encode, values)
  if ok then
    buf = json
  else
    print("Failed to encode result as JSON")
  end
  
end

-- Show controls as HTML page
if _GET.mode ~= nil then
  cmd_found = true

  if _GET.mode == "html" then
    outfile = "_led.html"
  end
end

-- Wrong command
if not cmd_found then
   
  ok, json = pcall(cjson.encode, {res="WRONG_PARAM"})
  if ok then
    buf = json
  else
    print("Failed to encode result as JSON")
  end
   
end

