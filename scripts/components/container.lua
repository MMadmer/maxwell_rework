require "class"
local GLOBAL_UTILS = require "utils"

local Container = Class(function(self, inst)
    self.inst = inst
    self.slots = {}
    self.numslots = 0
    self.canbeopened = true
    self.acceptsstacks = true
    self.side_widget = false
    self.type = "chest"
	
	self.wasOpened = false
end)


function Container:NumItems()
    local num = 0
    for k,v in pairs(self.slots) do
        num = num + 1
    end
    
    return num
end

function Container:IsShared()
	return self.inst:HasTag("shared")
end

function Container:GetDimension()
	for i, dim in pairs(GLOBAL_UTILS.DIMENSIONS) do
		if self.inst:HasTag(dim) then
			return dim
		end
	end

	print("Dimension not found:", self.inst.prefab)
	return nil
end

function Container:FindDimAnalog()
	-- Get all spawned entities
	local entities = TheSim:FindEntities(0, 0, 0, 10000, {})
	
	for i, entity in ipairs(entities) do
		-- Access to every found entity
		if entity:HasTag("shared") and entity.components.container:GetDimension() == self:GetDimension() and entity ~= self.inst then
			return entity
		end
	end
	
	return nil
end

function Container:OpenedCount()
	-- Get all spawned entities
	local entities = TheSim:FindEntities(0, 0, 0, 10000, {})
	local counter = 0
	
	for i, entity in ipairs(entities) do
		-- Access to every found entity
		if entity:HasTag("shared") and entity.components.container:GetDimension() == self:GetDimension() and entity ~= self.inst then
			if entity.components.container.wasOpened then
				counter = counter + 1
			end
		end
	end
	
	return counter
end

function Container:OnRemoveEntity()
	if self.open then
		local old_opener = self.opener
		if self.opener and self.opener.HUD then
			local opener = self.opener
			self.opener = nil
			opener.HUD:CloseContainer(self.inst, self.side_widget)
		end
		self:OnClose(old_opener)
	end
	
	if self:IsShared() then
		local entity = self:FindDimAnalog()
		-- print(#GetWorld().PocketDimensionContainers[self:GetDimension()])
		
		-- if entity ~= nil then
			-- entity.components.container.slots = GetWorld().PocketDimensionContainers[self:GetDimension()]
		-- else
			-- local x, y, z = 0, 0, -100
			-- local spawnedPrefab  = SpawnPrefab(self.inst.prefab)
			
			-- spawnedPrefab.Transform:SetPosition(x, y, z)
            -- spawnedPrefab.Physics:Teleport(x, y, z)
			-- spawnedPrefab.components.container.slots = GetWorld().PocketDimensionContainers[self:GetDimension()]
		-- end
		
		-- Drop loot if last dimension container
		if entity == nil or self:OpenedCount() == 0 then
			self:DropEverything()
		end
	end
end

function Container:IsFull()
	local items = 0
	for k,v in pairs(self.slots) do
		items = items + 1
end
	
	return items >= self.numslots

end

function Container:IsEmpty()
	for k,v in pairs(self.slots) do
		return false
	end
	
	return true
end


function Container:SetNumSlots(numslots)
    assert(numslots >= self.numslots)
    self.numslots = numslots
end


function Container:DropEverything()    
    for k = 1,self.numslots do
		local item = self:RemoveItemBySlot(k)
        if item then
			local pos = Vector3(self.inst.Transform:GetWorldPosition())
			item.Transform:SetPosition(pos:Get())
			if item.components.inventoryitem then
				item.components.inventoryitem:OnDropped(true)
			end
			self.inst:PushEvent("dropitem", {item = item})
        end
    end
end

function Container:DropItem(itemtodrop, wholestack)
    local item = self:RemoveItem(itemtodrop, wholestack)
    if item then 
        local pos = Vector3(self.inst.Transform:GetWorldPosition())
        item.Transform:SetPosition(pos:Get())
        if item.components.inventoryitem then
            item.components.inventoryitem:OnDropped(true)
        end
        self.inst:PushEvent("dropitem", {item = item})                  
    end
end

function Container:CanTakeItemInSlot(item, slot)
	if not (item and item.components.inventoryitem and item.components.inventoryitem.cangoincontainer) then
		return false
	end
	
	if self.itemtestfn then
		return self.itemtestfn(self.inst, item, slot)
	end

	return true
end

function Container:DestroyContents()
	for k = 1,self.numslots do
		local item = self:RemoveItemBySlot(k)
		if item then
			item:Remove()
		end		
	end
end

function Container:GiveItem(item, slot, src_pos, drop_on_fail, skipsound)
    drop_on_fail = drop_on_fail == nil and true or drop_on_fail
    --print("Container:GiveItem", item.prefab)
    if item and item.components.inventoryitem and self:CanTakeItemInSlot(item, slot) then
		
		--try to burn off stacks if we're just dumping it in there
		if item.components.stackable and slot == nil and self.acceptsstacks then
            for k = 1,self.numslots do
				local other_item = self.slots[k]
				if other_item and other_item.prefab == item.prefab and not other_item.components.stackable:IsFull() then
					
					if self.inst.components.inventoryitem and self.inst.components.inventoryitem.owner and not skipsound then
						self.inst.components.inventoryitem.owner:PushEvent("containergotitem", {item = item, src_pos = src_pos})
					end
					
		            item = other_item.components.stackable:Put(item, src_pos)
		            if not item then
						return true
		            end
				end
            end
		end
		
        local use_slot = slot and slot <= self.numslots and not self.slots[slot]
        local in_slot = nil
        if use_slot then
            in_slot = slot
        elseif self.numslots > 0 then
            for k = 1,self.numslots do
                if not self.slots[k] then
                    in_slot = k
                    break
                end
            end
        end
        
        if in_slot then

			--weird case where we are trying to force a stack into a non-stacking container. this should probably have been handled earlier, but this is a failsafe        
			if item.components.stackable and item.components.stackable:StackSize() > 1 and not self.acceptsstacks then
				item = item.components.stackable:Get()
				self.slots[in_slot] = item
				item.components.inventoryitem:OnPutInInventory(self.inst)
				self.inst:PushEvent("itemget", {slot = in_slot, item = item, src_pos = src_pos})	
				return false
			end
			
			self.slots[in_slot] = item
			item.components.inventoryitem:OnPutInInventory(self.inst)
			self.inst:PushEvent("itemget", {slot = in_slot, item = item, src_pos = src_pos})
			
			if self.inst.components.inventoryitem and self.inst.components.inventoryitem.owner and not skipsound then
				self.inst.components.inventoryitem.owner:PushEvent("containergotitem", {item = item, src_pos = src_pos})
			end
			
			return true
        else
            if drop_on_fail then
				item.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
				if item.components.inventoryitem then
	                item.components.inventoryitem:OnDropped(true)
				end
			end				
            return false
        end
        
    end
end


function Container:RemoveItemBySlot(slot)
    if slot and self.slots[slot] then
        local item = self.slots[slot]
        if item then
			self.slots[slot] = nil
			if item.components.inventoryitem then
				item.components.inventoryitem:OnRemoved()
			end
			
			self.inst:PushEvent("itemlose", {slot = slot})
		end
        item.prevcontainer = self
        item.prevslot = slot
        return item
        
    end
end

function Container:GetNumSlots()
    return self.numslots
end

function Container:GetItemInSlot(slot)
    if slot and self.slots[slot] then
        return self.slots[slot]
    end
end

function Container:GetItemSlot(item)
    for k,v in pairs(self.slots) do
        if item == v then
            return k
        end
    end
end

function Container:Close()
	
	if self.open then
		local old_opener = self.opener
		if self.opener and self.opener.HUD then
			local opener = self.opener
			self.opener = nil
			opener.HUD:CloseContainer(self.inst, self.side_widget)
		end
		
		if self:IsShared() then
			GetWorld().PocketDimensionContainers[self:GetDimension()] = self.slots
			print(#GetWorld().PocketDimensionContainers[self:GetDimension(self.inst)])
		end
		
		self:OnClose(old_opener)
	end
end

function Container:Open(doer)
	self.wasOpened = true

	self.opener = doer
	if not self.open then	
		if self:IsShared() then
			--print("Is shared")
			print(#GetWorld().PocketDimensionContainers[self:GetDimension()])
			self.slots = GetWorld().PocketDimensionContainers[self:GetDimension()]
			if #GetWorld().PocketDimensionContainers[self:GetDimension(self.inst)] > 0 then
				for key, dim in pairs(GetWorld().PocketDimensionContainers[self:GetDimension()]) do
					print(key)
					print(dim)
				end
				--print(GetWorld().PocketDimensionContainers)
			end
		end
		
		if doer and doer.HUD then
			doer.HUD:OpenContainer(self.inst, self.side_widget)
		end

		self:OnOpen()
	end
end

function Container:OnOpen()
    self.open = true
    
	if self.opener and self.opener.components.inventory then
		self.opener.components.inventory.opencontainers[self.inst] = true
        self.opener:PushEvent("refreshcrafting")
	end
    
    self.inst:PushEvent("onopen", {doer = self.opener})    
    if self.onopenfn then
        self.onopenfn(self.inst)
    end
end

function Container:IsOpen()
	return self.open
end

function Container:OnClose(old_opener)
   	if old_opener and old_opener.components.inventory then
   		old_opener.components.inventory.opencontainers[self.inst] = nil
        old_opener:PushEvent("refreshcrafting")
   	end
        
    if self.open then
        self.open = false
        if self.onclosefn then
            self.onclosefn(self.inst)
        end

        self.inst:PushEvent("onclose")
    end
end

function Container:CollectSceneActions(doer, actions, right)
    if self.inst:HasTag("bundle") then
        if right and self:IsOpenedBy(doer) then
	        table.insert(actions, ACTIONS.WRAPBUNDLE)
		end
	elseif doer.components.inventory and self.canbeopened then
        table.insert(actions, ACTIONS.RUMMAGE)
    end
end

function Container:CollectInventoryActions(doer, actions)
    if doer.components.inventory and self.canbeopened then
        if not (self.side_widget and TheInput:ControllerAttached()) then
            table.insert(actions, ACTIONS.RUMMAGE)
        end
    end
end

function Container:FindItem(fn)
    for k,v in pairs(self.slots) do
        if fn(v) then
            return v
        end
    end
end

function Container:FindItems(fn)
    local items = {}
    
    for k,v in pairs(self.slots) do
        if fn(v) then
            table.insert(items, v)
        end
    end

    return items
end

function Container:Count(item)
    local num_found = 0
    for k,v in pairs(self.slots) do
        if v and v.prefab == item then
            if v.components.stackable ~= nil then
                num_found = num_found + v.components.stackable:StackSize()
            else
                num_found = num_found + 1
            end
        end
    end

    return num_found
end

function Container:Has(item, amount)
    local num_found = self:Count(item)
    return num_found >= amount, num_found
end

local function GetStackSize(inst)
    if inst.components.stackable == nil then
        return 1
    end

    return inst.components.stackable:StackSize()
end

local function crafting_priority_fn(a, b)
    if a.stacksize == b.stacksize then
        return a.slot < b.slot
    end
    return a.stacksize < b.stacksize --smaller stacks first
end

function Container:GetCraftingIngredient(item, amount, reverse_search_order)
    local items = {}
    for i = 1, self.numslots do
        local v = self.slots[i]
		if v ~= nil and v.prefab == item then
            table.insert(items, {
                item = v,
                stacksize = GetStackSize(v),
                slot = reverse_search_order and (self.numslots - (i - 1)) or i,
            })
        end
    end

    table.sort(items, crafting_priority_fn)

    local crafting_items = {}
    local total_num_found = 0
    for i, v in ipairs(items) do
        local stacksize = math.min(v.stacksize, amount - total_num_found)
        crafting_items[v.item] = stacksize
        total_num_found = total_num_found + stacksize
        if total_num_found >= amount then
            break
        end
    end

    return crafting_items
end

function Container:ConsumeByName(item, amount)
    
    local total_num_found = 0
    
    local function tryconsume(v)
		local num_found = 0
        if v and v.prefab == item then
            local num_left_to_find = amount - total_num_found
            
            if v.components.stackable then
                if v.components.stackable.stacksize > num_left_to_find then
                    v.components.stackable:SetStackSize(v.components.stackable.stacksize - num_left_to_find)
                    num_found = amount
                else
                    num_found = num_found + v.components.stackable.stacksize
                    self:RemoveItem(v, true):Remove()
                end
            else
                num_found = num_found + 1
                self:RemoveItem(v):Remove()
            end
        end
        return num_found
    end
    

    for k,v in pairs(self.slots) do
        total_num_found = total_num_found + tryconsume(v)
        
        if total_num_found >= amount then
            break
        end
    end

    return total_num_found
end

function Container:OnSave()
    local data = {items= {}}
    for k,v in pairs(self.slots) do
        if v:IsValid() then --only save the valid items
			data.items[k] = v:GetSaveRecord()
		end
    end
    
    return data
end   

function Container:OnLoad(data, newents)
    if data.items then
        for k,v in pairs(data.items) do
            local inst = SpawnSaveRecord(v, newents)
            if inst then
                self:GiveItem(inst, k)
            end
        end
    end
	
	-- Access to every spawned inst
	if self:IsShared("shared") then
		print("Shared")
		print(self.inst.prefab)
		print(self:IsEmpty())
		if not self:IsEmpty() then
			GetWorld().PocketDimensionContainers[self:GetDimension()] = self.slots
			print("Not empty:", self.prefab)
		end
	end
	
	self.wasOpened = false
end



function Container:RemoveItem(item, wholestack)
    local dec_stack = not wholestack and item and item.components.stackable and item.components.stackable:IsStack() and item.components.stackable:StackSize() > 1
	local slot = self:GetItemSlot(item)
    if dec_stack then
        local dec = item.components.stackable:Get()
        dec.components.inventoryitem:OnRemoved()
        dec.prevslot = slot
        dec.prevcontainer = self
        return dec
    else
        for k,v in pairs(self.slots) do
            if v == item then
                self.slots[k] = nil
                self.inst:PushEvent("itemlose", {slot = k})
                
                if item.components.inventoryitem then
                    item.components.inventoryitem:OnRemoved()
                end
                
		        item.prevslot = slot
		        item.prevcontainer = self
                return item
            end
        end
    end
    
    return item

end

function Container:IsOpenedBy(guy)
    return self.opener == guy
end


return Container

