local GameData = {};

local cardDeck = {
	["Blackjack"] = {
		{"ace_spades", nil},
		{"two_spades", 2},
		{"three_spades", 3},
		{"four_spades", 4},
		{"five_spades", 5},
		{"six_spades", 6},
		{"seven_spades", 7},
		{"eight_spades", 8},
		{"nine_spades", 9},
		{"ten_spades", 10},
		{"jack_spades", 10},
		{"queen_spades", 10},
		{"king_spades", 10},
		{"ace_hearts", nil},
		{"two_hearts", 2},
		{"three_hearts", 3},
		{"four_hearts", 4},
		{"five_hearts", 5},
		{"six_hearts", 6},
		{"seven_hearts", 7},
		{"eight_hearts", 8},
		{"nine_hearts", 9},
		{"ten_hearts", 10},
		{"jack_hearts", 10},
		{"queen_hearts", 10},
		{"king_hearts", 10},
		{"ace_diamonds", nil},
		{"two_diamonds", 2},
		{"three_diamonds", 3},
		{"four_diamonds", 4},
		{"five_diamonds", 5},
		{"six_diamonds", 6},
		{"seven_diamonds", 7},
		{"eight_diamonds", 8},
		{"nine_diamonds", 9},
		{"ten_diamonds", 10},
		{"jack_diamonds", 10},
		{"queen_diamonds", 10},
		{"king_diamonds", 10},
		{"ace_clubs", nil},
		{"two_clubs", 2},
		{"three_clubs", 3,},
		{"four_clubs", 4},
		{"five_clubs", 5},
		{"six_clubs", 6},
		{"seven_clubs", 7},
		{"eight_clubs", 8},
		{"nine_clubs", 9},
		{"ten_clubs", 10},
		{"jack_clubs", 10},
		{"queen_clubs", 10},
		{"king_clubs", 10}
	},
	["Baccarat"] = {
		{"ace_spades", 1},
		{"two_spades", 2},
		{"three_spades", 3},
		{"four_spades", 4},
		{"five_spades", 5},
		{"six_spades", 6},
		{"seven_spades", 7},
		{"eight_spades", 8},
		{"nine_spades", 9},
		{"ten_spades", 10},
		{"jack_spades", 10},
		{"queen_spades", 10},
		{"king_spades", 10},
		{"ace_hearts", 1},
		{"two_hearts", 2},
		{"three_hearts", 3},
		{"four_hearts", 4},
		{"five_hearts", 5},
		{"six_hearts", 6},
		{"seven_hearts", 7},
		{"eight_hearts", 8},
		{"nine_hearts", 9},
		{"ten_hearts", 10},
		{"jack_hearts", 10},
		{"queen_hearts", 10},
		{"king_hearts", 10},
		{"ace_diamonds", 1},
		{"two_diamonds", 2},
		{"three_diamonds", 3},
		{"four_diamonds", 4},
		{"five_diamonds", 5},
		{"six_diamonds", 6},
		{"seven_diamonds", 7},
		{"eight_diamonds", 8},
		{"nine_diamonds", 9},
		{"ten_diamonds", 10},
		{"jack_diamonds", 10},
		{"queen_diamonds", 10},
		{"king_diamonds", 10},
		{"ace_clubs", 1},
		{"two_clubs", 2},
		{"three_clubs", 3,},
		{"four_clubs", 4},
		{"five_clubs", 5},
		{"six_clubs", 6},
		{"seven_clubs", 7},
		{"eight_clubs", 8},
		{"nine_clubs", 9},
		{"ten_clubs", 10},
		{"jack_clubs", 10},
		{"queen_clubs", 10},
		{"king_clubs", 10}
	},
	["TexasHoldem"] = {
		--spades
		{2, 1, "rbxassetid://11619230982"},
		{3, 1, "rbxassetid://11619230091"},
		{4, 1, "rbxassetid://11619228727"},
		{5, 1, "rbxassetid://11619227478"},
		{6, 1, "rbxassetid://11619226378"},
		{7, 1, "rbxassetid://11619225291"},
		{8, 1, "rbxassetid://11619224290"},
		{9, 1, "rbxassetid://11619222786"},
		{10, 1, "rbxassetid://11619221565"},
		{11, 1, "rbxassetid://11619218487"},
		{12, 1, "rbxassetid://11619216320"},
		{13, 1, "rbxassetid://11619217510"},
		{14, 1, "rbxassetid://11619220345"},
		--hearts
		{2, 2, "rbxassetid://11619231234"},
		{3, 2, "rbxassetid://11619230291"},
		{4, 2, "rbxassetid://11619228994"},
		{5, 2, "rbxassetid://11619227750"},
		{6, 2, "rbxassetid://11619226586"},
		{7, 2, "rbxassetid://11619225523"},
		{8, 2, "rbxassetid://11619224573"},
		{9, 2, "rbxassetid://11619223077"},
		{10, 2, "rbxassetid://11619221828"},
		{11, 2, "rbxassetid://11619219443"},
		{12, 2, "rbxassetid://11619216669"},
		{13, 2, "rbxassetid://11619217701"},
		{14, 2, "rbxassetid://11619220688"},
		--diamonds
		{2, 3, "rbxassetid://11619231433"},
		{3, 3, "rbxassetid://11619230456"},
		{4, 3, "rbxassetid://11619229351"},
		{5, 3, "rbxassetid://11619228031"},
		{6, 3, "rbxassetid://11619226954"},
		{7, 3, "rbxassetid://11619225821"},
		{8, 3, "rbxassetid://11619224780"},
		{9, 3, "rbxassetid://11619223352"},
		{10, 3, "rbxassetid://11619222183"},
		{11, 3, "rbxassetid://11619219855"},
		{12, 3, "rbxassetid://11619216899"},
		{13, 3, "rbxassetid://11619217925"},
		{14, 3, "rbxassetid://11619220934"},
		--clubs
		{2, 4, "rbxassetid://11619231712"},
		{3, 4, "rbxassetid://11619230673"},
		{4, 4, "rbxassetid://11619229749"},
		{5, 4, "rbxassetid://11619228413"},
		{6, 4, "rbxassetid://11619227197"},
		{7, 4, "rbxassetid://11619226155"},
		{8, 4, "rbxassetid://11619224955"},
		{9, 4, "rbxassetid://11619223855"},
		{10, 4, "rbxassetid://11619222490"},
		{11, 4, "rbxassetid://11619220077"},
		{12, 4, "rbxassetid://11619217257"},
		{13, 4, "rbxassetid://11619218155"},
		{14, 4, "rbxassetid://11619221215"}
	},
	["TournamentHoldem"] = {
		--spades
		{2, 1, "rbxassetid://11619230982"},
		{3, 1, "rbxassetid://11619230091"},
		{4, 1, "rbxassetid://11619228727"},
		{5, 1, "rbxassetid://11619227478"},
		{6, 1, "rbxassetid://11619226378"},
		{7, 1, "rbxassetid://11619225291"},
		{8, 1, "rbxassetid://11619224290"},
		{9, 1, "rbxassetid://11619222786"},
		{10, 1, "rbxassetid://11619221565"},
		{11, 1, "rbxassetid://11619218487"},
		{12, 1, "rbxassetid://11619216320"},
		{13, 1, "rbxassetid://11619217510"},
		{14, 1, "rbxassetid://11619220345"},
		--hearts
		{2, 2, "rbxassetid://11619231234"},
		{3, 2, "rbxassetid://11619230291"},
		{4, 2, "rbxassetid://11619228994"},
		{5, 2, "rbxassetid://11619227750"},
		{6, 2, "rbxassetid://11619226586"},
		{7, 2, "rbxassetid://11619225523"},
		{8, 2, "rbxassetid://11619224573"},
		{9, 2, "rbxassetid://11619223077"},
		{10, 2, "rbxassetid://11619221828"},
		{11, 2, "rbxassetid://11619219443"},
		{12, 2, "rbxassetid://11619216669"},
		{13, 2, "rbxassetid://11619217701"},
		{14, 2, "rbxassetid://11619220688"},
		--diamonds
		{2, 3, "rbxassetid://11619231433"},
		{3, 3, "rbxassetid://11619230456"},
		{4, 3, "rbxassetid://11619229351"},
		{5, 3, "rbxassetid://11619228031"},
		{6, 3, "rbxassetid://11619226954"},
		{7, 3, "rbxassetid://11619225821"},
		{8, 3, "rbxassetid://11619224780"},
		{9, 3, "rbxassetid://11619223352"},
		{10, 3, "rbxassetid://11619222183"},
		{11, 3, "rbxassetid://11619219855"},
		{12, 3, "rbxassetid://11619216899"},
		{13, 3, "rbxassetid://11619217925"},
		{14, 3, "rbxassetid://11619220934"},
		--clubs
		{2, 4, "rbxassetid://11619231712"},
		{3, 4, "rbxassetid://11619230673"},
		{4, 4, "rbxassetid://11619229749"},
		{5, 4, "rbxassetid://11619228413"},
		{6, 4, "rbxassetid://11619227197"},
		{7, 4, "rbxassetid://11619226155"},
		{8, 4, "rbxassetid://11619224955"},
		{9, 4, "rbxassetid://11619223855"},
		{10, 4, "rbxassetid://11619222490"},
		{11, 4, "rbxassetid://11619220077"},
		{12, 4, "rbxassetid://11619217257"},
		{13, 4, "rbxassetid://11619218155"},
		{14, 4, "rbxassetid://11619221215"}
	},
	["ThreeCardPoker"] = {
		--spades
		{2, 1, "two_spades"},
		{3, 1, "three_spades"},
		{4, 1, "four_spades"},
		{5, 1, "five_spades"},
		{6, 1, "six_spades"},
		{7, 1, "seven_spades"},
		{8, 1, "eight_spades"},
		{9, 1, "nine_spades"},
		{10, 1, "ten_spades"},
		{11, 1, "jack_spades"},
		{12, 1, "queen_spades"},
		{13, 1, "king_spades"},
		{14, 1, "ace_spades"},
		--hearts
		{2, 2, "two_hearts"},
		{3, 2, "three_hearts"},
		{4, 2, "four_hearts"},
		{5, 2, "five_hearts"},
		{6, 2, "six_hearts"},
		{7, 2, "seven_hearts"},
		{8, 2, "eight_hearts"},
		{9, 2, "nine_hearts"},
		{10, 2, "ten_hearts"},
		{11, 2, "jack_hearts"},
		{12, 2, "queen_hearts"},
		{13, 2, "king_hearts"},
		{14, 2, "ace_hearts"},
		--diamonds
		{2, 3, "two_diamonds"},
		{3, 3, "three_diamonds"},
		{4, 3, "four_diamonds"},
		{5, 3, "five_diamonds"},
		{6, 3, "six_diamonds"},
		{7, 3, "seven_diamonds"},
		{8, 3, "eight_diamonds"},
		{9, 3, "nine_diamonds"},
		{10, 3, "ten_diamonds"},
		{11, 3, "jack_diamonds"},
		{12, 3, "queen_diamonds"},
		{13, 3, "king_diamonds"},
		{14, 3, "ace_diamonds"},
		--clubs
		{2, 4, "two_clubs"},
		{3, 4, "three_clubs"},
		{4, 4, "four_clubs"},
		{5, 4, "five_clubs"},
		{6, 4, "six_clubs"},
		{7, 4, "seven_clubs"},
		{8, 4, "eight_clubs"},
		{9, 4, "nine_clubs"},
		{10, 4, "ten_clubs"},
		{11, 4, "jack_clubs"},
		{12, 4, "queen_clubs"},
		{13, 4, "king_clubs"},
		{14, 4, "ace_clubs"},
	}
};

local rouletteResults = {
	["0"] = {"0", "Split1", "FiveNumber"}, --0
	["00"] = {"00", "Split1", "FiveNumber"}, --00
	["1"] = {"1", "Red", "Odd", "1stRow", "1st12", "1-18", "FiveNumber", "Split4", "Corner1", "Split2", "Street1", "DoubleStreet1"}, --1
	["2"] = {"2", "Black", "Even", "2ndRow", "1st12", "1-18", "FiveNumber", "Split2", "Corner1", "Split5", "Corner2", "Split3", "Street1", "DoubleStreet1"}, --2
	["3"] = {"3", "Red", "Odd", "3rdRow", "1st12", "1-18", "FiveNumber", "Split3", "Corner2", "Split6", "Street1", "DoubleStreet1"}, --3
	["4"] = {"4", "Black", "Even", "1stRow", "1st12", "1-18", "Split4", "Corner1", "Split7", "Corner3", "Split9", "Street2", "DoubleStreet1", "DoubleStreet2"}, --4
	["5"] = {"5", "Red", "Odd", "2ndRow", "1st12", "1-18", "Corner1", "Split5", "Corner2", "Split8", "Corner4", "Split10", "Corner3", "Split7", "Street2", "DoubleStreet1", "DoubleStreet2"}, --5
	["6"] = {"6", "Black", "Even", "3rdRow", "1st12", "1-18", "Split6", "Corner2", "Split8", "Corner4", "Split11", "Street2", "DoubleStreet1", "DoubleStreet2"}, --6
	["7"] = {"7", "Red", "Odd", "1stRow", "1st12", "1-18", "Split9", "Corner3", "Split12", "Corner5", "Split14", "Street3", "DoubleStreet2", "DoubleStreet3"}, --7
	["8"] = {"8", "Black", "Even", "2ndRow", "1st12", "1-18", "Corner3", "Split10", "Corner4", "Split13", "Corner6", "Split15", "Corner5", "Split12", "Street3", "DoubleStreet2", "DoubleStreet3"}, --8
	["9"] = {"9", "Red", "Odd", "3rdRow", "1st12", "1-18", "Split11", "Corner4", "Split13", "Corner6", "Split16", "Street3", "DoubleStreet2", "DoubleStreet3"}, --9
	["10"] = {"10", "Black", "Even", "1stRow", "1st12", "1-18", "Split14", "Corner5", "Split17", "Corner7", "Split19", "Street4", "DoubleStreet3", "DoubleStreet4"}, --10
	["11"] = {"11", "Black", "Odd", "2ndRow", "1st12", "1-18", "Corner5", "Split15", "Corner6", "Split18", "Corner8", "Split20", "Corner7", "Split17", "Street4", "DoubleStreet3", "DoubleStreet4"}, --11
	["12"] = {"12", "Red", "Even", "3rdRow", "1st12", "1-18", "Split16", "Corner6", "Split18", "Corner8", "Split21", "Street4", "DoubleStreet3", "DoubleStreet4"}, --12
	["13"] = {"13", "Black", "Odd", "1stRow", "2nd12", "1-18", "Split19", "Corner7", "Split22", "Corner9", "Split24", "Street5", "DoubleStreet4", "DoubleStreet5"}, --13
	["14"] = {"14", "Red", "Even", "2ndRow", "2nd12", "1-18", "Corner7", "Split20", "Corner8", "Split23", "Corner10", "Split25", "Corner9", "Split22", "Street5", "DoubleStreet4", "DoubleStreet5"}, --14
	["15"] = {"15", "Black", "Odd", "3rdRow", "2nd12", "1-18", "Split21", "Corner8", "Split23", "Corner10", "Split26", "Street5", "DoubleStreet4", "DoubleStreet5"}, --15
	["16"] = {"16", "Red", "Even", "1stRow", "2nd12", "1-18", "Split24", "Corner9", "Split27", "Corner11", "Split29", "Street6", "DoubleStreet5", "DoubleStreet6"}, --16
	["17"] = {"17", "Black", "Odd", "2ndRow", "2nd12", "1-18", "Corner9", "Split25", "Corner10", "Split28", "Corner12", "Split30", "Corner11", "Split27", "Street6", "DoubleStreet5", "DoubleStreet6"}, --17
	["18"] = {"18", "Red", "Even", "3rdRow", "2nd12", "1-18", "Split26", "Corner10", "Split28", "Corner12", "Split31", "Street6", "DoubleStreet5", "DoubleStreet6"}, --18
	["19"] = {"19", "Red", "Odd", "1stRow", "2nd12", "19-36", "Split29", "Corner11", "Split32", "Corner13", "Split34", "Street7", "DoubleStreet6", "DoubleStreet7"}, --19
	["20"] = {"20", "Black", "Even", "2ndRow", "2nd12", "19-36", "Corner11", "Split30", "Corner12", "Split33", "Corner14", "Split35", "Corner13", "Split32", "Street7", "DoubleStreet6", "DoubleStreet7"}, --20
	["21"] = {"21", "Red", "Odd", "3rdRow", "2nd12", "19-36", "Split31", "Corner12", "Split33", "Corner14", "Split36", "Street7", "DoubleStreet6", "DoubleStreet7"}, --21
	["22"] = {"22", "Black", "Even", "1stRow", "2nd12", "19-36", "Split34", "Corner13", "Split37", "Corner15", "Split39", "Street8", "DoubleStreet7", "DoubleStreet8"}, --22
	["23"] = {"23", "Red", "Odd", "2ndRow", "2nd12", "19-36", "Corner13", "Split35", "Corner14", "Split38", "Corner16", "Split40", "Corner15", "Split37", "Street8", "DoubleStreet7", "DoubleStreet8"}, --23
	["24"] = {"24", "Black", "Even", "3rdRow", "2nd12", "19-36", "Split36", "Corner14", "Split38", "Corner16", "Split41", "Street8", "DoubleStreet7", "DoubleStreet8"}, --24
	["25"] = {"25", "Red", "Odd", "1stRow", "3rd12", "19-36", "Split39", "Corner15", "Split42", "Corner17", "Split44", "Street9", "DoubleStreet8", "DoubleStreet9"}, --25
	["26"] = {"26", "Black", "Even", "2ndRow", "3rd12", "19-36", "Corner15", "Split40", "Corner16", "Split43", "Corner18", "Split45", "Corner17", "Split42", "Street9", "DoubleStreet8", "DoubleStreet9"}, --26
	["27"] = {"27", "Red", "Odd", "3rdRow", "3rd12", "19-36", "Split41", "Corner16", "Split43", "Corner18", "Split46", "Street9", "DoubleStreet8", "DoubleStreet9"}, --27
	["28"] = {"28", "Black", "Even", "1stRow", "3rd12", "19-36", "Split44", "Corner17", "Split47", "Corner19", "Split49", "Street10", "DoubleStreet9", "DoubleStreet10"}, --28
	["29"] = {"29", "Black", "Odd", "2ndRow", "3rd12", "19-36", "Corner17", "Split45", "Corner18", "Split48", "Corner20", "Split50", "Corner19", "Split47", "Street10", "DoubleStreet9", "DoubleStreet10"}, --29
	["30"] = {"30", "Red", "Even", "3rdRow", "3rd12", "19-36", "Split46", "Corner18", "Split48", "Corner20", "Split51", "Street10", "DoubleStreet9", "DoubleStreet10"}, --30
	["31"] = {"31", "Black", "Odd", "1stRow", "3rd12", "19-36", "Split49", "Corner19", "Split52", "Corner21", "Split54", "Street11", "DoubleStreet10", "DoubleStreet11"}, --31
	["32"] = {"32", "Red", "Even", "2ndRow", "3rd12", "19-36", "Corner19", "Split50", "Corner20", "Split53", "Corner22", "Split55", "Corner21", "Split52", "Street11", "DoubleStreet10", "DoubleStreet11"}, --32
	["33"] = {"33", "Black", "Odd", "3rdRow", "3rd12", "19-36", "Split51", "Corner20", "Split53", "Corner22", "Split56", "Street11", "DoubleStreet10", "DoubleStreet11"}, --33
	["34"] = {"34", "Red", "Even", "1stRow", "3rd12", "19-36", "Split54", "Corner21", "Split57", "Street12", "DoubleStreet11"}, --34
	["35"] = {"35", "Black", "Odd", "2ndRow", "3rd12", "19-36", "Corner21", "Split55", "Corner22", "Split58", "Split57", "Street12", "DoubleStreet11"}, --35
	["36"] = {"36", "Red", "Even", "3rdRow", "3rd12", "19-36", "Split56", "Corner22", "Split58", "Street12", "DoubleStreet11"}, --36
};

function GameData:AddCommasToNumber(number)
	local formatted = number;

	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2');
		if k == 0 then
			break;
		end
	end

	return formatted;
end

function GameData:GetPlayingCards(gameName)
	return cardDeck[gameName];
end

function GameData:GetAllAceCards(gameName)
	local aceCards = {};
	
	for each, cardData in pairs(cardDeck[gameName]) do
		if string.sub(cardData[1], 1, 3) == "ace" then
			table.insert(aceCards, cardData);
		end
	end
	
	return aceCards
end

function GameData:GetRouletteResult(number)
	return rouletteResults[number];
end

return GameData;