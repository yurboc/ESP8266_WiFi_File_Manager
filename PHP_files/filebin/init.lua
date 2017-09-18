-- Prepare Wi-Fi
wifi.setmode(wifi.STATION)
wifi.sta.config("SSID","password")   ---   SSID and Password for your LAN DHCP here

-- Prepare WS2812 buffer
numberOfLeds = 117
bytesPerLed = 3 -- Green,Red,Blue for RGB
buffer = ws2812.newBuffer(numberOfLeds, bytesPerLed)
buffer:fill(0, 0, 0)

-- prepare WS2812 LED strip
ws2812.init()
ws2812.write(buffer)

-- Get system info
majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info();
print("System Info:  ")
print("NodeMCU "..majorVer.."."..minorVer.."."..devVer.."\nFlashsize: "..flashsize.."\nChipID: "..chipid)
print("FlashID: "..flashid.."\n".."Flashmode: "..flashmode.."\nHeap: "..node.heap())

-- Get file system info
remaining, used, total=file.fsinfo()
print("\nFile system info:\nTotal : "..total.." Bytes\nUsed : "..used.." Bytes\nRemain: "..remaining.." Bytes")
print("\nReady (waiting 5000 ms to start server)")

-- Get RTC time
sntp_sync_done = false
sntp.sync("192.168.1.1",
  function(sec, usec, server, info)
    if sntp_sync_done then 
      return
    end
    file.open("_time.lua","w")
    sec = sec + 3*60*60 -- UTC+3
    tm = rtctime.epoch2cal(sec, usec)
    file.writeline(string.format("RTC sync: %04d/%02d/%02d %02d:%02d:%02d (UTC+3)", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"]))
    file.close()
    sntp_sync_done = true
  end,
  function(sec, usec, server, info)
    print('RTC sync failed!')
  end,
  1
)

-- Start HTTP server
tmr.create():alarm(5000, tmr.ALARM_SINGLE,  function() dofile("_srv.lua") end)
