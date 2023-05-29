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
	"papyrus",
	"papyrus",
	"tophat",
	"tophat",
}

local function custom_init(inst)
	--inst:AddComponent("reader")
	--inst:AddTag("bookreader")

	inst.components.sanity.dapperness = TUNING.DAPPERNESS_LARGE
	inst.components.health:SetMaxHealth(75)
	inst.soundsname = "maxwell"

	inst.components.inventory:GuaranteeItems({"waxwelljournal"})
end

return MakePlayerCharacter("waxwell", prefabs, assets, custom_init, start_inv) 
