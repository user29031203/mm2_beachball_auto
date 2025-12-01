-- Dweet Simpel Read/Write Latest Lib For Luau

local HttpService = game:GetService("HttpService")

local DweetLib = {}
DweetLib.__index = DweetLib

-- 1. HTTP Request Compatibility (Executors have different names for this)
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- 2. Constructor
-- 3. WRITE: Send Data (Mimics PowerShell GET)
function DweetLib:Send(content)
    if not httpRequest then
        return false, "Executor does not support HTTP requests"
    end
    
    -- 1. Build Query String (e.g. ?JobId=123&Status=Host)
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

    local url = self.BaseUrl .. "/dweet/for/" .. self.ThingName .. queryString
    
    -- 2. Send Request mimicking PowerShell
    local response = httpRequest({
        Url = url,
        Method = "GET", -- Force GET since you said curl worked without -d
        Headers = {
            ["User-Agent"] = "Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.1023",
            ["Cache-Control"] = "no-cache"
        }
    })

    if response.StatusCode == 200 then
        return true, "Sent"
    else
        warn("Dweet Failed: " .. tostring(response.StatusCode))
        if response.Body then print("Response: " .. tostring(response.Body)) end
        return false, "Error: " .. tostring(response.StatusCode)
    end
end

-- 4. READ: Get Latest Data
-- @return: The content table (or nil if failed/empty)
function DweetLib:GetLatest()
    local url = self.BaseUrl .. "/get/latest/dweet/for/" .. self.ThingName
    
    -- We use pcall because HttpGet can error on connection loss
    local success, result = pcall(function()
        -- Add a random cache buster just in case
        return game:HttpGet(url .. "?_nocache=" .. os.time(), true)
    end)

    if not success then return nil, "Connection Error" end

    local decoded = HttpService:JSONDecode(result)
    
    -- Navigate Dweet's JSON structure: { "with": [ { "content": { ... } } ] }
    if decoded and decoded.with and decoded.with[1] then
        return decoded.with[1].content, decoded.with[1].created
    end
    
    return nil, "No dweets found"
end

return DweetLib
