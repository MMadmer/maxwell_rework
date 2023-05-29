name = "(local)Maxwell rework"
description = [[
Test
]]
author = "Madmer"
version = "1.0"
forumthread = ""
api_version = 6

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
hamlet_compatible = true

--icon_atlas = "modicon.xml"
--icon = "modicon.tex"

local alpha = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local KEY_A = 97
local keyslist = {}
for i = 1,#alpha do keyslist[i] = {description = alpha[i],data = i + KEY_A - 1} end

configuration_options = 
{
	{
		name = "CharacterUnlock",
		label = "Unlock characters", 
        hover = "Do not unlock/unlock Maxwell/unlock all characters",
		options = 
		{
			{description = "Not unlocked", data = 1,},
			{description = "Unlock Maxwell (default)", data = 2,},
			{description = "Unlock all characters", data = 3,},
		},
		default = 2
	},
}