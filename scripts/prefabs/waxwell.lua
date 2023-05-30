local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
    Asset("ANIM", "anim/waxwell.zip"),
	Asset("SOUND", "sound/maxwell.fsb")    
}

local prefabs = 
{
	"shadowwaxwell",	
}

local function self_tab()
	-- Maxwell's recipes tab
	RECIPETABS['WAXWELL'] = {str = "WAXWELL", sort=999, icon = "images/inventoryimages/storeroom.tex", icon_atlas = "images/inventoryimages/storeroom.xml"}STRINGS.TABS.WAXWELL = "Maxwell"

	-- Maxwell's recipes
	-------------------------------------------------------
	local wax_panel_0 = Recipe("tophat_magician",
		{ 
			Ingredient("tophat", 1),
			Ingredient("nightmarefuel", 2)
		},
		RECIPETABS.WAXWELL, 
		{ SCIENCE = 0 }
	)
	wax_panel_0.atlas = "images/inventoryimages/tophat_magician.xml"

	-------------------------------------------------------
	local wax_panel_1 = Recipe("magician_chest",
		{ 
			Ingredient("silk", 1), 
			Ingredient("boards", 4), 
			Ingredient("nightmarefuel", 9) 
		}, 
		RECIPETABS.WAXWELL, 
		TECH.NONE, 
		"magician_chest_placer"
	)
	wax_panel_1.atlas = "images/inventoryimages/magician_chest.xml"
	-------------------------------------------------------
	local wax_panel_2 = Recipe("waxwelljournal",
		{ 
			Ingredient("papyrus", 2), 
			Ingredient("nightmarefuel", 2),
		}, 
		RECIPETABS.WAXWELL, 
		{ SCIENCE = 0 }
	)
	wax_panel_2.atlas = "images/inventoryimages/storeroom.xml"
	STRINGS.RECIPE_DESC.WAXWELLJOURNAL = "-50 health on craft"
	-------------------------------------------------------
end

local start_inv = 
{
	"waxwelljournal",
	"purplegem",
	"nightmarefuel",
	"nightmarefuel",
	"nightmarefuel",
	"nightmarefuel",
	"nightmarefuel",
	"nightmarefuel",
}

local function custom_init(inst)
	--inst:AddComponent("reader")
	--inst:AddTag("bookreader")

	inst.components.sanity.dapperness = TUNING.DAPPERNESS_LARGE
	inst.components.health:SetMaxHealth(75)
	inst.soundsname = "maxwell"

	inst.components.inventory:GuaranteeItems({"waxwelljournal"})
	
	self_tab()
end

return MakePlayerCharacter("waxwell", prefabs, assets, custom_init, start_inv) 
