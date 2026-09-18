local module = {}

local suffixes = {'','K','M','B','T','Qd','Qn','sx','Sp','O','N','de','Ud','DD','tdD','qdD','QnD','sxD','SpD','OcD','NvD','Vgn','UVg','DVg','TVg','qtV','QnV','SeV','SPG','OVG','NVG','TGN','UTG','DTG','tsTG','qtTG','QnTG','ssTG','SpTG','OcTG','NoAG','UnAG','DuAG','TeAG','QdAG','QnAG','SxAG','SpAG','OcAG','NvAG','CT'}

function module.abbreviateNumber(val)
	
	if typeof(val) ~= "number" then
		return val
	end
	
	if val == math.huge then
		return "inf"
	end
	local negative = 1
	if val < 0 then
		negative = -1
	end
	
	val = math.abs(val)
	
	for i=1, #suffixes do
		if tonumber(val) < 10^(i*3) then
			return (math.floor(val/((10^((i-1)*3))/100))/(100)) * negative .. suffixes[i]
		end
	end
	return ""
end

return module
