local assets =
{
	Asset("ANIM", "anim/tophat_magician.zip"),
	Asset("ANIM", "anim/tophat_magician_swap.zip"),
	
    Asset("ATLAS", "images/inventoryimages/tophat_magician.xml"),
	Asset("IMAGE", "images/inventoryimages/tophat_magician.tex"),
}

local prefabs = 
{
}

local function fn()

	local function OnEquip(inst, owner)
		owner.AnimState:OverrideSymbol("swap_hat", "tophat_magician_swap", "swap_hat")
		owner.AnimState:Show("HAT")
		owner.AnimState:Show("HAT_HAIR")
		owner.AnimState:Hide("HAIR_NOHAT")
		owner.AnimState:Hide("HAIR")
		
		if owner:HasTag("player") then
			owner.AnimState:Hide("HEAD")
			owner.AnimState:Show("HEAD_HAIR")
		end
		
		if inst.components.fueled then
			inst.components.fueled:StartConsuming()        
		end
	end

	local function OnUnequip(inst, owner)
		owner.AnimState:Hide("HAT")
		owner.AnimState:Hide("HAT_HAIR")
		owner.AnimState:Show("HAIR_NOHAT")
		owner.AnimState:Show("HAIR")
		
		if owner:HasTag("player") then
			owner.AnimState:Show("HEAD")
			owner.AnimState:Hide("HEAD_HAIR")
		end
		
		if inst.components.fueled then
			inst.components.fueled:StopConsuming()        
		end
	end

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	MakeInventoryPhysics(inst)
	
    anim:SetBank("tophat_magician")
    anim:SetBuild("tophat_magician")
	anim:PlayAnimation("idle")
	
    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "tophat_magician"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/tophat_magician.xml"
	
	inst:AddComponent("dapperness")
	inst.components.dapperness.dapperness = TUNING.DAPPERNESS_MED
	
	inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
	inst.components.fueled:InitializeFuelLevel(TUNING.TOPHAT_MAGICIAN)
    inst.components.fueled:SetDepletedFn( function(inst)
        inst:Remove()
    end)
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
	
    return inst
end

STRINGS.NAMES.TOPHAT_MAGICIAN = "Magician's Top Hat"
STRINGS.RECIPE_DESC.TOPHAT_MAGICIAN = "Black magic goes with everything."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TOPHAT_MAGICIAN = "Fits the suit!"

return Prefab('common/inventory/tophat_magician', fn, assets, prefabs)
