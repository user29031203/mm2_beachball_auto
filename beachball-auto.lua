local HttpService = game:GetService("HttpService")

local DweetLib = {}
DweetLib.__index = DweetLib

-- 1. HTTP Request Compatibility
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- 2. Constructor (RESTORED THIS PART)
function DweetLib.new(thingName)
    local self = setmetatable({}, DweetLib)
    self.ThingName = thingName
    
    -- CHANGE THIS if you really meant "dweetr.io", but "dweet.io" is the standard one.
    self.BaseUrl = "https://dweet.io" 
    
    return self
end

-- 3. WRITE: Send Data
-- Uses URL Query Strings (GET) which mimics basic Curl/Browser requests.
-- This bypasses complex Header/JSON issues in some executors.
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
    local url = self.BaseUrl .. "/dweet/for/" .. self.ThingName .. queryString
    
    -- C. Send via GET
    local response = httpRequest({
        Url = url,
        Method = "GET", 
        Headers = {
            ["Cache-Control"] = "no-cache"
        }
    })

    if response.StatusCode == 200 then
        return true, "Sent"
    else
        -- Debugging info if it fails
        warn("Dweet Failed: " .. tostring(response.StatusCode))
        return false, "Error: " .. tostring(response.StatusCode)
    end
end

-- 4. READ: Get Latest Data
function DweetLib:GetLatest()
    local url = self.BaseUrl .. "/get/latest/dweet/for/" .. self.ThingName
    
    local success, result = pcall(function()
        -- Add _nocache to force fresh data
        return game:HttpGet(url .. "?_nocache=" .. os.time(), true)
    end)

    if not success then return nil, "Connection Error" end

    local decoded = HttpService:JSONDecode(result)
    
    -- Navigate structure: { "with": [ { "content": { ... } } ] }
    if decoded and decoded.with and decoded.with[1] then
        return decoded.with[1].content, decoded.with[1].created
    end
    
    return nil, "No dweets found"
end

return DweetLib
