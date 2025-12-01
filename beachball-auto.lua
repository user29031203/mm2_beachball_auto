-- Dweet Simpel Read/Write Latest Lib For Luau

local HttpService = game:GetService("HttpService")

local DweetLib = {}
DweetLib.__index = DweetLib

-- 1. HTTP Request Compatibility (Executors have different names for this)
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- 2. Constructor
function DweetLib.new(thingName)
    local self = setmetatable({}, DweetLib)
    self.ThingName = thingName
    self.BaseUrl = "https://dweet.io"
    return self
end

-- 3. WRITE: Send Data
-- @param content: A table of data (e.g. { status = "farming", jobId = "..." })
function DweetLib:Send(content)
    if not httpRequest then
        return false, "Executor does not support HTTP requests"
    end
    
    -- Ensure content is a table
    if type(content) ~= "table" then
        content = { value = content }
    end

    local url = self.BaseUrl .. "/dweet/for/" .. self.ThingName
    local jsonData = HttpService:JSONEncode(content)

    local response = httpRequest({
        Url = url,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = jsonData
    })

    if response.StatusCode == 200 then
        return true, "Sent"
    else
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
