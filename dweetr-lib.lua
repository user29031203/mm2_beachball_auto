local HttpService = game:GetService("HttpService")

local DweetLib = {}
DweetLib.__index = DweetLib

-- external libs
local CONS_INFO_URL = "https://raw.githubusercontent.com/user29031203/LegendZero/refs/heads/main/constants.lua" 
local CONS_INFO = loadstring(game:HttpGet(CONS_INFO_URL))()

-- 1. HTTP Request Compatibility
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- 2. Constructor
function DweetLib.new(thingName)
    if not thingName then
        warn("DweetLib Error: You must provide a secret key/name in .new()!")
        return nil
    end

    local self = setmetatable({}, DweetLib)
    self.ThingName = thingName
    self.BaseUrl = CONS_INFO.BackendBaseEndpointUrl 
    
    return self
end

-- 3. WRITE: Send Data
-- Uses GET request + Query Params (Fixed for dweetr.io)
function DweetLib:Send(content)
    if not httpRequest then
        return false, "Executor does not support HTTP requests"
    end
    
    -- A. Build the Query String (e.g. ?JobId=123&Status=Host)
    local queryString = ""
    for key, value in pairs(content) do
        local cleanKey = HttpService:UrlEncode(tostring(key))
        local cleanValue = HttpService:UrlEncode(tostring(value))
        
        if queryString == "" then
            queryString = "?" .. cleanKey .. "=" .. cleanValue
        else
            queryString = queryString .. "&" .. cleanKey .. "=" .. cleanValue
        end
    end

    -- B. Construct Full URL
    -- API Path: https://dweetr.io/dweet/for/ThingName?param=value
    local url = self.BaseUrl .. "/dweet/for/" .. self.ThingName .. queryString
    
    -- C. Send via GET
    local response = httpRequest({
        Url = url,
        Method = "GET", 
        Headers = {
            ["Cache-Control"] = "no-cache",
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" -- Standard User Agent
        }
    })

    if response.StatusCode == 200 then
        return true, "Sent"
    else
        warn("Dweetr Failed: " .. tostring(response.StatusCode))
        return false, "Error: " .. tostring(response.StatusCode)
    end
end

-- 4. READ: Get Latest Data
function DweetLib:GetLatest()
    print("DEBUGGER B1")
    local url = self.BaseUrl .. "/get/latest/dweet/for/" .. self.ThingName
    
    local success, result = pcall(function()
        -- Add _nocache to force fresh data
        --game:HttpGet(url .. "?_nocache=" .. os.time(), true) 
        return game:HttpGet(url, true) 
    end)

    print("DEBUGGER B2")

    if not success then return nil, "Connection Error" end
    
    local decoded = HttpService:JSONDecode(result)
    
    print(type(decoded))
    print("DEBUGGER B3")
    
    -- dweetr.io follows the same JSON structure: { "with": [ { "content": { ... } } ] }
    if decoded and decoded.with and decoded.with[1] then
        return decoded.with[1].content, decoded.with[1].created
    end
    
    return nil, "No dweets found"
end

return DweetLib
