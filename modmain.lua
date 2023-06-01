_G = GLOBAL
local require = _G.require
local STRINGS = _G.STRINGS
local RECIPETABS = _G.RECIPETABS
local Recipe = _G.Recipe
local Ingredient = _G.Ingredient
local TECH = _G.TECH
local TUNING = _G.TUNING
local GetPlayer = _G.GetPlayer
local RECIPE_GAME_TYPE = _G.RECIPE_GAME_TYPE
local Vector3 = _G.Vector3
local Transform = _G.Transform
local SpawnPrefab = _G.SpawnPrefab
local TheSim = _G.TheSim
local Action = _G.Action
local ActionHandler = _G.ActionHandler

local seg_time = 30 --each segment of the clock is 30 seconds
local total_day_time = seg_time*16

TUNING.TOPHAT_MAGICIAN = total_day_time * 8

PrefabFiles =
{
	"tophat_magician",
	"magician_chest",
	"waxwell", 
	"world",
}

Assets =
{
	Asset("ATLAS", "images/inventoryimages/tophat_magician.xml"),
	Asset("ATLAS", "images/inventoryimages/storeroom.xml"),
	Asset("ATLAS", "images/inventoryimages/magician_chest.xml"),
	Asset("ATLAS", "minimap/magician_chest.xml"),
}

AddMinimapAtlas("minimap/magician_chest.xml")

-- Unlock characters
local unlock_character = GetModConfigData('CharacterUnlock')
if unlock_character == 1 then
	function unlockwaxwell(self)
		
	end
elseif unlock_character == 2 then
	function unlockwaxwell(self)
		function _G.PlayerProfile:IsCharacterUnlocked(character)
		if character == "wilson" or character == "waxwell" then
			return true
		end
		if self.persistdata.unlocked_characters[character] then
			return true
		end
		if not table.contains({'willow', 'wendy', 'wolfgang', 'wilton', 'wx78',
							   'wickerbottom', 'wes', 'waxwell', 'woodie',
							   'wagstaff','wathgrithr', 'webber','walani',
							   'warly', 'wilbur', 'woodlegs','warbucks','wilba',
							   'wormwood', 'wheeler'}, character) then
			return true
		end
		return false
		end
	end
elseif unlock_character == 3 then
	function unlockwaxwell(self) 
		function _G.PlayerProfile:IsCharacterUnlocked(character)
			return true
		end
	end
end
AddGamePostInit(unlockwaxwell)

-- Magician's chest
local function updatestoreroom(inst)
	inst.components.container.widgetpos = _G.Vector3(360 - (12 * 4.5), 170, 0)

	inst.components.container.widgetanimbank = "ui_chest_4x5"
	inst.components.container.widgetanimbuild = "ui_chest_4x5"
end
AddPrefabPostInit("magician_chest", updatestoreroom)
