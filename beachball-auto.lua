-- Dweet Simpel Read/Write Latest Lib For Luau

local HttpService = game:GetService("HttpService")

local DweetLib = {}
DweetLib.__index = DweetLib

-- 1. HTTP Request Compatibility (Executors have different names for this)
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- 2. Constructor
-- 3. WRITE: Send Data (Mimicking Curl)
function DweetLib:Send(content)
    if not httpRequest then
        return false, "Executor does not support HTTP requests"
    end
    
    local url = self.BaseUrl .. "/dweet/for/" .. self.ThingName

    -- CONVERT TABLE TO FORM DATA STRING (Key=Value&Key2=Value2)
    -- This matches how 'curl -d' sends data by default
    local formBody = ""
    for key, value in pairs(content) do
        local cleanKey = HttpService:UrlEncode(tostring(key))
        local cleanValue = HttpService:UrlEncode(tostring(value))
        formBody = formBody .. cleanKey .. "=" .. cleanValue .. "&"
    end
    -- Remove the trailing "&"
    formBody = formBody:sub(1, -2)

    local response = httpRequest({
        Url = url,
        Method = "POST",
        Headers = {
            -- Tell Dweet we are sending Form Data, just like Curl
            ["Content-Type"] = "application/x-www-form-urlencoded",
            
            -- Spoof the User-Agent to look like Curl (Bypasses some filters)
            ["User-Agent"] = "curl/7.68.0" 
        },
        Body = formBody
    })

    if response.StatusCode == 200 then
        return true, "Sent"
    else
        -- Print the actual error message from Dweet to help debug
        warn("Dweet Error Body: " .. tostring(response.Body))
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
