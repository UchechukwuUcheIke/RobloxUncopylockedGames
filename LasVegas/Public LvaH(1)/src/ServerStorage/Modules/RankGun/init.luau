-- Compiled with roblox-ts v2.2.0
-- Module for ranking @rankgun (https://rankgun.works/).
local HttpService = game:GetService("HttpService")
local BaseUrl = "https://api.rankgun.works/"

-- Creates a URL and calls it based on endpoint,method and data.
local function URLGenerator(Endpoint, Method, Bot, Data)
	local result = { pcall(function()
		return HttpService:RequestAsync({
			Url = BaseUrl .. Endpoint,
			Method = Method,
			Headers = {
				["api-token"] = Bot.ApiKey,
				["Content-Type"] = "application/json",
			},
			Body = HttpService:JSONEncode(Data),
		})
	end) }
	local success = result[1]
	local response = result[2]
	local body = HttpService:JSONDecode(response.Body)
	if not success then
		warn("Request failed")
		return {
			status_code = 404,
			detail = "Request failed",
		}
	end
	return body
end
local Bot
do
	Bot = setmetatable({}, {
		__tostring = function()
			return "Bot"
		end,
	})
	Bot.__index = Bot
	function Bot.new(...)
		local self = setmetatable({}, Bot)
		return self:constructor(...) or self
	end
	function Bot:constructor(ApiKey, WorkspaceId)
		local _apiKey = ApiKey
		local _condition = not (type(_apiKey) == "string")
		if not _condition then
			local _workspaceId = WorkspaceId
			_condition = not (type(_workspaceId) == "number")
		end
		if _condition then
			error("ApiKey should be string and WorkspaceId should be number") --Secret data type not supported, good luck reverse engineering all this mess :(
		end
		self.ApiKey = ApiKey
		self.WorkspaceId = WorkspaceId
	end
	function Bot:promote(userId)
		local _userId = userId
		if not (type(_userId) == "number") then
			warn("UserId must be number")
			return {
				status_code = 400,
				detail = "UserId must be number",
			}
		end
		return URLGenerator("roblox/promote", "POST", self, {
			workspace_id = self.WorkspaceId,
			user_id = userId,
		})
	end
	function Bot:demote(userId)
		local _userId = userId
		if not (type(_userId) == "number") then
			warn("UserId must be number")
			return {
				status_code = 400,
				detail = "UserId must be number",
			}
		end
		return URLGenerator("roblox/demote", "POST", self, {
			workspace_id = self.WorkspaceId,
			user_id = userId,
		})
	end
	function Bot:setRank(userId, rank)
		local _userId = userId
		local _condition = not (type(_userId) == "number")
		if not _condition then
			local _rank = rank
			_condition = not (type(_rank) == "number")
		end
		if _condition then
			warn("UserId & rank must be number")
			return {
				status_code = 400,
				detail = "UserId must be number",
			}
		end
		return URLGenerator("roblox/set-rank", "POST", self, {
			workspace_id = self.WorkspaceId,
			user_id = userId,
			rank = rank,
		})
	end
end
return {
	Bot = Bot,
}
