--[[

	This script is a paste-bin for all the commands I run in the command bar. Helps with organization and profiling issues.
	-GamerOkami

]]

local slotValues = {
	{0, "bell"},
	{45, "singlebar"},
	{90, "melon"},
	{135, "triplebar"},
	{180, "star"}, 
	{-135, "seven"}, 
	{-90, "doublebar"},
	{-45, "diamond"}
};
local payoutValues = {
	["5 seven"] = 1000, --[[0.0031%]]
	["seven star combo"] = 1000, --[[0.0031%]]
	["other star combo"] = 100, --[[0.02%]]
	["5 of a kind"] = 75, --[[0.02%]]
	["5 of any bar"] = 30, --[[0.74%]]
	["4 of a kind"] = 10, --[[0.88%]]
	["full house"] = 6, --[[1.71%]]
	["2 pair w/ star"] = 3, --[[1.92%]]
	["3 of a kind"] = 2, --[[12.83%]]
	["2 pair"] = 1 --[[15.40%]]
};
local totalPayouts = {};
local totalAmounts = {};
local payoutFrequencies = {};
local amountFrequencies = {};
local payoutRatios = {};
local totalWinnings = 0;
local random = Random.new();

local function countValuesPresent(reels, value)
	local values = {};
	table.insert(values, reels[1]);

	if #reels == 3 then
		if not table.find(values, reels[2]) then
			table.insert(values, reels[2]);
		end
		if not table.find(values, reels[3]) then
			table.insert(values, reels[3]);
		end
	elseif #reels == 5 then
		if not table.find(values, reels[2]) then
			table.insert(values, reels[2]);
		end
		if not table.find(values, reels[3]) then
			table.insert(values, reels[3]);
		end
		if not table.find(values, reels[4]) then
			table.insert(values, reels[4]);
		end
		if not table.find(values, reels[5]) then
			table.insert(values, reels[5]);
		end
	end

	return values;
end

local function countSpecificValuePresent(reels, value)
	local counter = 0;

	for each, reel in pairs(reels) do
		if value == "dominus" then
			if reel == "bluedominus" or reel == "whitedominus" or reel == "golddominus" then
				counter += 1;
			end
		elseif value == "anybar" then
			if reel == "singlebar" or reel == "doublebar" or reel == "triplebar" then
				counter += 1;
			end
		elseif value == "fireegg" then
			if reel == "fieryegg" or reel == "bombasticegg" then
				counter += 1;
			end
		elseif value == "iceegg" then
			if reel == "boringegg" or reel == "cloudegg" then
				counter += 1;
			end
		else
			if reel == value then
				counter += 1;
			end
		end
	end

	return counter;
end

local function checkIfTrioPresent(reels, trio)
	local foundOne;
	local foundTwo;
	local foundThree;

	for each, reel in pairs(reels) do
		if reel == trio[1] then
			foundOne = true;
		end
		if reel == trio[2] then
			foundTwo = true;
		end
		if reel == trio[3] then
			foundThree = true;
		end
	end

	return foundOne and foundTwo and foundThree;
end

local function checkIfPairPresent(reels, pair)
	local foundOne;
	local foundTwo;

	for each, reel in pairs(reels) do
		if reel == pair[1] then
			foundOne = true;
		end
		if reel == pair[2] then
			foundTwo = true;
		end
	end

	return foundOne and foundTwo;
end

local function checkPayout(leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue)
	local payoutAmount = 0;
	local payouts = {};
	local valuesShown = countValuesPresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue});

	if countSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, "anybar") == 5 then
		payoutAmount += payoutValues["5 of any bar"];
		table.insert(payouts, "5 of any bar");
	end

	if leftValue == "seven" and leftMiddleValue == "star" and middleValue == "seven" and rightMiddleValue == "star" and rightValue == "seven" then
		payoutAmount += payoutValues["seven star combo"];
		table.insert(payouts, "seven star combo");
	elseif leftValue == middleValue and middleValue == rightValue and leftMiddleValue == "star" and rightMiddleValue == "star" and leftValue ~= "star" then
		payoutAmount += payoutValues["other star combo"];
		table.insert(payouts, "other star combo");
	end

	if #valuesShown == 2 then
		local value1Amount = countSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, valuesShown[1]);
		local value2Amount = countSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, valuesShown[2]);
		if (value1Amount == 2 and value2Amount == 3) or (value1Amount == 3 and value2Amount == 2) then
			payoutAmount += payoutValues["full house"];
			table.insert(payouts, "full house");
		end
	end

	if #valuesShown == 3 then
		local starAmount = countSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, "star");
		local value1Amount = countSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, valuesShown[1]);
		local value2Amount = countSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, valuesShown[2]);
		local value3Amount = countSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, valuesShown[3]);

		if starAmount == 1 then
			if valuesShown[1] == "star" then
				if value1Amount == 1 then
					if value2Amount == 2 and value3Amount == 2 then
						payoutAmount += payoutValues["2 pair w/ star"];
						table.insert(payouts, "2 pair w/ star");
					end
				end
			elseif valuesShown[2] == "star" then
				if value2Amount == 1 then
					if value1Amount == 2 and value3Amount == 2 then
						payoutAmount += payoutValues["2 pair w/ star"];
						table.insert(payouts, "2 pair w/ star");
					end
				end
			elseif value3Amount == 1 then
				if value1Amount == 2 and value2Amount == 2 then
					payoutAmount += payoutValues["2 pair w/ star"];
					table.insert(payouts, "2 pair w/ star");
				end
			end
		end
	end

	local twoPairs = 0;
	for each, value in pairs(valuesShown) do
		local count = countSpecificValuePresent({leftValue, leftMiddleValue, middleValue, rightMiddleValue, rightValue}, value);

		if count == 5 then
			if value == "seven" then
				payoutAmount += payoutValues["5 seven"];
				table.insert(payouts, "5 seven");
			end
			payoutAmount += payoutValues["5 of a kind"];
			table.insert(payouts, "5 of a kind");
		end

		if count >= 4 then
			payoutAmount += payoutValues["4 of a kind"];
			table.insert(payouts, "4 of a kind");
		end

		if count >= 3 then
			payoutAmount += payoutValues["3 of a kind"];
			table.insert(payouts, "3 of a kind");
		end

		if count >= 2 then
			if twoPairs == 1 then
				payoutAmount += payoutValues["2 pair"];
				table.insert(payouts, "2 pair");
			end
			twoPairs += 1;
		end
	end

	if payoutAmount == 0 then
		table.insert(payouts, "better luck next time");
	end

	return payoutAmount, payouts;
end

local spinAmount = 100000000;
for i = 1, spinAmount do
	local leftValue = slotValues[random:NextInteger(1, 8)];
	local leftMiddleValue = slotValues[random:NextInteger(1, 8)];
	local middleValue = slotValues[random:NextInteger(1, 8)];
	local rightMiddleValue = slotValues[random:NextInteger(1, 8)];
	local rightValue = slotValues[random:NextInteger(1, 8)];
	local payoutAmount, payoutsList = checkPayout(leftValue[2], leftMiddleValue[2], middleValue[2], rightMiddleValue[2], rightValue[2]);
	for each, payoutType in pairs(payoutsList) do
		if not totalPayouts[payoutType] then
			totalPayouts[payoutType] = 1;
		else
			totalPayouts[payoutType] += 1;
		end
		if payoutValues[payoutType] then
			if not totalAmounts[payoutType] then
				totalAmounts[payoutType] = payoutValues[payoutType];
			else
				totalAmounts[payoutType] += payoutValues[payoutType];
			end
		end
	end
	totalWinnings += payoutAmount;
end
for payoutType, amount in pairs(totalPayouts) do
	payoutFrequencies[payoutType] = (amount / spinAmount) * 100;
end
for payoutType, amount in pairs(totalPayouts) do
	if payoutValues[payoutType] then
		amountFrequencies[payoutType] = ((amount * payoutValues[payoutType] / totalWinnings) * 100);
	end
end
for payoutType, percentage in pairs(amountFrequencies) do
	if amountFrequencies[payoutType] then
		payoutRatios[payoutType] = (amountFrequencies[payoutType] / payoutFrequencies[payoutType]);
	end
end

for payoutType, amount in pairs(payoutFrequencies) do
	payoutFrequencies[payoutType] = payoutFrequencies[payoutType].."%";
end
for payoutType, amount in pairs(amountFrequencies) do
	amountFrequencies[payoutType] = amountFrequencies[payoutType].."%";
end
for payoutType, amount in pairs(payoutRatios) do
	payoutRatios[payoutType] = payoutRatios[payoutType].." to 1";
end

print("________________")
print("Payout Frequencies:")
print(payoutFrequencies);
print("Payout Distribution:")
print(amountFrequencies);
print("Payout Ratios:")
print(payoutRatios);
print("Total Winnings: "..totalWinnings);
print("Total Bets: "..spinAmount);
print("Payout Ratio: "..totalWinnings/spinAmount);