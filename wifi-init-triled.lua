triled = require "triled"
triled.pin_red = 2
triled.pin_green = 1
triled.pin_blue = 8
triled.init()
triled.blink_red(BLINK_WIFI_FAILURE, true)
_WIFI_CURRENT_AP = 1
_WIFI_FAIL_COUNTER = 0
wifi.setmode(wifi.STATION)
NET_AP,NET_PASSWORD =  next(_WIFI_APS[_WIFI_CURRENT_AP])
wifi.sta.config(NET_AP, NET_PASSWORD)
_wifi_keepalive_timer = tmr.create()
_wifi_keepalive_timer:register(5000, tmr.ALARM_AUTO, function()
    if wifi.sta.status() ~= 5 then
        if _WIFI_FAIL_COUNTER == 0 then 
            triled.blink_red(BLINK_WIFI_FAILURE, true) 
        end
        _WIFI_FAIL_COUNTER = _WIFI_FAIL_COUNTER + 1       
    else
        if _WIFI_FAIL_COUNTER > 0 then
            triled.clear()
        end            
        _WIFI_FAIL_COUNTER = 0
        
    end
    if _WIFI_FAIL_COUNTER > 10 then        
        print "Node reboot..."
        node.restart()
    end       
end)

if wifi.sta.getip() == nil then
    local _boot_wifi_counter = 0
    local _boot_wifi_timer = tmr.create()
    _boot_wifi_timer:alarm(2000, tmr.ALARM_AUTO, function()
        if _boot_wifi_counter == 0 then
            NET_AP,NET_PASSWORD =  next(_WIFI_APS[_WIFI_CURRENT_AP])
            wifi.sta.config(NET_AP, NET_PASSWORD)
            print("Connecting to: "..NET_AP)
        end
        if wifi.sta.getip() == nil then     
            print(" Wait for IP --> "..wifi.sta.status()) 
            _boot_wifi_counter = _boot_wifi_counter + 1
            if _boot_wifi_counter == 6 then
                _boot_wifi_counter = 0
                _WIFI_CURRENT_AP = _WIFI_CURRENT_AP + 1
                if _WIFI_CURRENT_AP > #_WIFI_APS then
                    _WIFI_CURRENT_AP = 1
                end
             end   
        else             
            _boot_wifi_timer:stop()
            triled.clear()
            _wifi_keepalive_timer:start()
            if file.exists('main.lc') then  
                dofile("main.lc")        
            else
                dofile("main.lua")        
            end
        end

    end)
end
