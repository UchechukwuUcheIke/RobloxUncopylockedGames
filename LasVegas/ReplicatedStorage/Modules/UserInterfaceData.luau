local UserInterfaceData = {}

local NormalScaleLabels = {
	["CashIcon"] = {
		Position = UDim2.new(0.01, 0, 0.657, 0),
		Size = UDim2.new(0.028, 0, 0.053, 0),
	},
	["Cash"] = {
		Position = UDim2.new(0.045, 0, 0.7, 0),
		Size = UDim2.new(0.1, 0, 0.03, 0),
	},
	["CashStroke"] = {
		Position = UDim2.new(0.045, 0, 0.7, 3),
		Size = UDim2.new(0.1, 0, 0.03, 0),
	},
	["PlaytimeLimitIcon"] = {
		Position = UDim2.new(0.01, 0, 0.539, 0),
		Size = UDim2.new(0.028, 0, 0.053, 0),
	},
	["PlaytimeLimit"] = {
		Position = UDim2.new(0.045, 0, 0.582, 0),
		Size = UDim2.new(0.124, 0, 0.028, 0),
	},
	["PlaytimeLimitStroke"] = {
		Position = UDim2.new(0.045, 0, 0.582, 3),
		Size = UDim2.new(0.124, 0, 0.028, 0),
	},
	["TokensIcon"] = {
		Position = UDim2.new(0.01, 0, 0.475, 0),
		Size = UDim2.new(0.028, 0, 0.053, 0),
	},
	["Tokens"] = {
		Position = UDim2.new(0.045, 0, 0.517, 0),
		Size = UDim2.new(0.1, 0, 0.03, 0),
	},
	["TokensStroke"] = {
		Position = UDim2.new(0.045, 0, 0.517, 3),
		Size = UDim2.new(0.1, 0, 0.03, 0),
	},
	["TotalPlaytimeIcon"] = {
		Position = UDim2.new(0.01, 0, 0.601, 0),
		Size = UDim2.new(0.028, 0, 0.053, 0),
	},
	["TotalPlaytime"] = {
		Position = UDim2.new(0.045, 0, 0.646, 0),
		Size = UDim2.new(0.1, 0, 0.03, 0),
	},
	["TotalPlaytimeStroke"] = {
		Position = UDim2.new(0.045, 0, 0.646, 3),
		Size = UDim2.new(0.1, 0, 0.03, 0),
	},
};
local NormalScaleButtons = {
	["Options"] = {
		Position = UDim2.new(0.01, 0, 0.8, 0),
		Size = UDim2.new(0.098, 0, 0.051, 0),
	},
	["Store"] = {
		Position = UDim2.new(0.01, 0, 0.725, 0),
		Size = UDim2.new(0.098, 0, 0.051, 0),
	},
	["Tutorial"] = {
		Position = UDim2.new(0.01, 0, 0.875, 0),
		Size = UDim2.new(0.098, 0, 0.051, 0),
	},
	["GuideBack"] = {
		Position = UDim2.new(0.25, 0, 0.5, 0),
		Size = UDim2.new(0.039, 0, 0.077, 0),
	},
	["GuideForward"] = {
		Position = UDim2.new(0.75, 0, 0.5, 0),
		Size = UDim2.new(0.039, 0, 0.077, 0),
	},
	["PayoutsBack"] = {
		Position = UDim2.new(0.25, 0, 0.5, 0),
		Size = UDim2.new(0.039, 0, 0.077, 0),
	},
	["PayoutsForward"] = {
		Position = UDim2.new(0.75, 0, 0.5, 0),
		Size = UDim2.new(0.039, 0, 0.077, 0),
	},
};
local NormalScaleFrames = {
	["Options"] = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.344, 0, 0.646, 0),
	},
	["Store"] = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.379, 0, 0.355, 0),
	},
	["Tutorial0"] = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.278, 0, 0.261, 0),
	},
	["Tutorial1"] = {
		Position = UDim2.new(0.3, 0, 0.75, 0),
		Size = UDim2.new(0.278, 0, 0.261, 0),
	},
	["Tutorial2"] = {
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.new(0.278, 0, 0.261, 0),
	},
	["Tutorial3"] = {
		Position = UDim2.new(0.65, 0, 0.2, 0),
		Size = UDim2.new(0.278, 0, 0.261, 0),
	},
	["Tutorial4"] = {
		Position = UDim2.new(0.4, 0, 0.2, 0),
		Size = UDim2.new(0.278, 0, 0.261, 0),
	},
	["Tutorial5"] = {
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.new(0.278, 0, 0.261, 0),
	},
	["Tutorial6"] = {
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.new(0.278, 0, 0.261, 0),
	},
	["Tutorial7"] = {
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.new(0.278, 0, 0.261, 0),
	},
	["Tutorial8"] = {
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.new(0.278, 0, 0.261, 0),
	},
	["Tutorial9"] = {
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.new(0.278, 0, 0.261, 0),
	},
	["Tutorial10"] = {
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.new(0.278, 0, 0.261, 0),
	},
	["Tutorial11"] = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.278, 0, 0.261, 0),
	},
	["Tutorial12"] = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.278, 0, 0.261, 0),
	},
	["Guide"] = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.211, 0, 0.657, 0),
	},
	["Payouts"] = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.211, 0, 0.657, 0),
	},
	["Blackjack"] = {
		Position = UDim2.new(0.5, 0, 0.75, 0),
		Size = UDim2.new(0.335, 0, 0.263, 0),
	},
	["Baccarat"] = {
		Position = UDim2.new(0.5, 0, 0.75, 0),
		Size = UDim2.new(0.335, 0, 0.263, 0),
	},
	["CashWheel"] = {
		Position = UDim2.new(0.5, 0, 0.75, 0),
		Size = UDim2.new(0.335, 0, 0.263, 0),
	},
	["Plinko"] = {
		Position = UDim2.new(0.5, 0, 0.75, 0),
		Size = UDim2.new(0.335, 0, 0.263, 0),
	},
	["Roulette"] = {
		Position = UDim2.new(0.5, 0, 0.75, 0),
		Size = UDim2.new(0.335, 0, 0.263, 0),
	},
	["TexasHoldem"] = {
		Position = UDim2.new(0.5, 0, 0.75, 0),
		Size = UDim2.new(0.335, 0, 0.263, 0),
	},
	["TournamentHoldem"] = {
		Position = UDim2.new(0.5, 0, 0.75, 0),
		Size = UDim2.new(0.335, 0, 0.263, 0),
	},
	["ThreeCardPoker"] = {
		Position = UDim2.new(0.5, 0, 0.75, 0),
		Size = UDim2.new(0.335, 0, 0.263, 0),
	},
	["Slots"] = {
		Position = UDim2.new(0.5, 0, 0.75, 0),
		Size = UDim2.new(0.335, 0, 0.263, 0),
	},
};

local BigScaleLabels = {
	["CashIcon"] = {
		Position = UDim2.new(0.01, 0, 0.448, 0),
		Size = UDim2.new(0.05, 0, 0.094, 0),
	},
	["Cash"] = {
		Position = UDim2.new(0.072, 0, 0.525, 0),
		Size = UDim2.new(0.117, 0, 0.053, 0),
	},
	["CashStroke"] = {
		Position = UDim2.new(0.072, 0, 0.525, 3),
		Size = UDim2.new(0.117, 0, 0.053, 0),
	},
	["PlaytimeLimitIcon"] = {
		Position = UDim2.new(0.01, 0, 0.239, 0),
		Size = UDim2.new(0.058, 0, 0.094, 0),
	},
	["PlaytimeLimit"] = {
		Position = UDim2.new(0.072, 0, 0.316, 0),
		Size = UDim2.new(0.22, 0, 0.049, 0),
	},
	["PlaytimeLimitStroke"] = {
		Position = UDim2.new(0.072, 0, 0.316, 3),
		Size = UDim2.new(0.22, 0, 0.049, 0),
	},
	["TokensIcon"] = {
		Position = UDim2.new(0.01, 0, 0.126, 0),
		Size = UDim2.new(0.05, 0, 0.094, 0),
	},
	["Tokens"] = {
		Position = UDim2.new(0.072, 0, 0.2, 0),
		Size = UDim2.new(0.177, 0, 0.053, 0),
	},
	["TokensStroke"] = {
		Position = UDim2.new(0.072, 0, 0.2, 3),
		Size = UDim2.new(.177, 0, 0.053, 0),
	},
	["TotalPlaytimeIcon"] = {
		Position = UDim2.new(0.01, 0, 0.35, 0),
		Size = UDim2.new(0.05, 0, 0.094, 0),
	},
	["TotalPlaytime"] = {
		Position = UDim2.new(0.072, 0, 0.429, 0),
		Size = UDim2.new(0.117, 0, 0.053, 0),
	},
	["TotalPlaytimeStroke"] = {
		Position = UDim2.new(0.072, 0, 0.429, 3),
		Size = UDim2.new(0.117, 0, 0.053, 0),
	},
};
local BigScaleButtons = {
	["Options"] = {
		Position = UDim2.new(0.01, 0, 0.702, 0),
		Size = UDim2.new(0.174, 0, 0.091, 0),
	},
	["Store"] = {
		Position = UDim2.new(0.01, 0, 0.569, 0),
		Size = UDim2.new(0.174, 0, 0.091, 0),
	},
	["Tutorial"] = {
		Position = UDim2.new(0.01, 0, 0.835, 0),
		Size = UDim2.new(0.174, 0, 0.091, 0),
	},
	["GuideBack"] = {
		Position = UDim2.new(0.127, 0, 0.2, 0),
		Size = UDim2.new(0.058, 0, 0.114, 0),
	},
	["GuideForward"] = {
		Position = UDim2.new(0.87, 0, 0.2, 0),
		Size = UDim2.new(0.058, 0, 0.114, 0),
	},
	["PayoutsBack"] = {
		Position = UDim2.new(0.127, 0, 0.2, 0),
		Size = UDim2.new(0.058, 0, 0.114, 0),
	},
	["PayoutsForward"] = {
		Position = UDim2.new(0.87, 0, 0.2, 0),
		Size = UDim2.new(0.058, 0, 0.114, 0),
	},
};
local BigScaleFrames = {
	["Options"] = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.674, 0, 0.983, 0),
	},
	["Store"] = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.634, 0, 0.594, 0),
	},
	["Tutorial0"] = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.5, 0, 0.5, 0),
	},
	["Tutorial1"] = {
		Position = UDim2.new(0.405, 0, 0.651, 0),
		Size = UDim2.new(0.5, 0, 0.5, 0),
	},
	["Tutorial2"] = {
		Position = UDim2.new(0.5, 0, 0.59, 0),
		Size = UDim2.new(0.5, 0, 0.5, 0),
	},
	["Tutorial3"] = {
		Position = UDim2.new(0.65, 0, 0.4, 0),
		Size = UDim2.new(0.5, 0, 0.5, 0),
	},
	["Tutorial4"] = {
		Position = UDim2.new(0.4, 0, 0.4, 0),
		Size = UDim2.new(0.5, 0, 0.5, 0),
	},
	["Tutorial5"] = {
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.new(0.5, 0, 0.5, 0),
	},
	["Tutorial6"] = {
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.new(0.5, 0, 0.5, 0),
	},
	["Tutorial7"] = {
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.new(0.5, 0, 0.5, 0),
	},
	["Tutorial8"] = {
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.new(0.5, 0, 0.5, 0),
	},
	["Tutorial9"] = {
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.new(0.5, 0, 0.5, 0),
	},
	["Tutorial10"] = {
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.new(0.5, 0, 0.5, 0),
	},
	["Tutorial11"] = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.5, 0, 0.5, 0),
	},
	["Tutorial12"] = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.5, 0, 0.5, 0),
	},
	["Guide"] = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.314, 0, 0.977, 0),
	},
	["Payouts"] = {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.314, 0, 0.977, 0),
	},
	["Blackjack"] = {
		Position = UDim2.new(0.5, 0, 0.55, 0),
		Size = UDim2.new(0.534, 0, 0.419, 0),
	},
	["Baccarat"] = {
		Position = UDim2.new(0.5, 0, 0.55, 0),
		Size = UDim2.new(0.534, 0, 0.419, 0),
	},
	["CashWheel"] = {
		Position = UDim2.new(0.5, 0, 0.55, 0),
		Size = UDim2.new(0.534, 0, 0.419, 0),
	},
	["Plinko"] = {
		Position = UDim2.new(0.5, 0, 0.55, 0),
		Size = UDim2.new(0.534, 0, 0.419, 0),
	},
	["Roulette"] = {
		Position = UDim2.new(0.5, 0, 0.55, 0),
		Size = UDim2.new(0.534, 0, 0.419, 0),
	},
	["TexasHoldem"] = {
		Position = UDim2.new(0.5, 0, 0.55, 0),
		Size = UDim2.new(0.534, 0, 0.419, 0),
	},
	["TournamentHoldem"] = {
		Position = UDim2.new(0.5, 0, 0.55, 0),
		Size = UDim2.new(0.534, 0, 0.419, 0),
	},
	["ThreeCardPoker"] = {
		Position = UDim2.new(0.5, 0, 0.55, 0),
		Size = UDim2.new(0.534, 0, 0.419, 0),
	},
	["Slots"] = {
		Position = UDim2.new(0.5, 0, 0.55, 0),
		Size = UDim2.new(0.534, 0, 0.419, 0),
	},
};


function UserInterfaceData:GetScaling(scaling)
	if scaling == "Normal" then
		return NormalScaleLabels, NormalScaleButtons, NormalScaleFrames;
	end
	return BigScaleLabels, BigScaleButtons, BigScaleFrames;
end

return UserInterfaceData;