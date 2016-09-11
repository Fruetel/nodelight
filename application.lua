-- file : application.lua
local module = {}  
m = nil
pin = 4

light=0

-- Sends a simple ping to the broker
local function send_ping()
    print("Sending ping to MQ")
    m:publish(config.ENDPOINT .. "ping","id=" .. config.ID,0,0)
end

-- Sends my id to the broker for registration
local function register_myself()  
    m:subscribe(config.ENDPOINT .. config.ID,0,function(conn)
        print("Successfully subscribed to data endpoint")
    end)
end

local function mqtt_start()  
    m = mqtt.Client(config.ID, 120)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data) 
      if data ~= nil then
        print(topic .. ": " .. data)
        -- do something, we have received a message
        if light==0 then
            gpio.write(pin,gpio.HIGH)
            light=1
        else
            gpio.write(pin,gpio.LOW)
            light=0
        end
      end
    end)
    -- Connect to broker
    print("Establishing broker connection to " .. config.HOST .. ":" .. config.PORT)
    m:connect(config.HOST, config.PORT, 0, 1, function(con)
        print("Connected to " .. config.HOST .. " message queue") 
        register_myself()
        -- And then pings each 1000 milliseconds
        tmr.stop(6)
        tmr.alarm(6, 1000, 1, send_ping)
    end) 

end

function module.start()  
  print("Starting App!")  
  gpio.mode(pin,gpio.OUTPUT)
  gpio.write(pin,gpio.LOW)
  mqtt_start()
end

return module  