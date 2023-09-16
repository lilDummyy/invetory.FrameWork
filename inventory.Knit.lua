local Players = game:GetService("Players")
local runService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)
local Signal = require(Knit.Util.Signal)
local Option = require(Knit.Util.Option)
local Roact = require(Knit.Util.Roact)
local Symbol = require(Knit.Util.Symbol)

local ToolsComponent = ServerStorage:WaitForChild("ToolsComponent")

local module = Knit.CreateService{
	Name = "InventoryKnitMain",
	Client = {
		ItemsAddedToClient = Knit.CreateSignal(),
		ItemsRemoveClient = Knit.CreateSignal(),
	}
}

function module:ItemsAddedForClient(plr,item : string | Tool? | Instance? )
	if ToolsComponent:FindFirstChild(item) then
		if ToolsComponent:FindFirstChild(item):IsA("Tool") then			
			local clone = ToolsComponent:FindFirstChild(item):Clone()
			clone.Parent = plr:WaitForChild("Backpack")
			self.Client.ItemsAddedToClient:Fire(plr,{Add_result = "Item added : "..clone.Name.." !" ,added_Message = "Tool .. "..clone.Name.." ajoutée",tool_Owner = plr})
			warn("Changement en cours de traitement")
			return "Succès"
		end
	else
		return warn("Changement annulé une erreur détecter pendant la recherche de l'objet")
	end
	return warn("Fonction non valable !")
end

function module:GetPurchaseState(plr : Player,name)
	assert(type(name) == "string","argument n doit être une string.")
	if plr:IsDescendantOf(Players) then
		local character = plr.Character or plr.CharacterAdded:Wait()
		local backpack = plr:WaitForChild("Backpack")
		if not character then return end
		if not backpack then return end
		local obj = character:FindFirstChild(name)
		local inBackpack = backpack:FindFirstChild(name)
		if (not obj) or (not inBackpack) then
			return false
		elseif (obj) or (inBackpack) then
			return true
		end
	else
		return warn("argument plr n'est pas un enfant du Service Players")
	end
end

function module:GetItemFromName(n)
	assert(type(n) == "string","argument n doit être une string.")
	local item = ServerStorage.ToolsComponent:WaitForChild(n)
	if (item) then
		return item.Name
	end
	error(`{self.GetItemFromName} , echoué: item non reçu {n} `)
end

function module:PurchaseItem(player,n)
	if not (player) then return end
	local itemName = self:GetItemFromName(n)
	if (itemName) then
		local item = ServerStorage.ToolsComponent:WaitForChild(itemName)
		if (item) then
			return "Succès"
		end
	end
	error("Erreur pendant l'achat de cette objet, auriez vous fait une erreur volontaire?"..`{debug.traceback("Current Execution Line",2)}`)
end

function module.Client:_PurchaseGranded(plr,name)
	return self.Server:GetPurchaseState(plr,name)
end

function module.Client:PurchaseResult(player,n)
	return self.Server:PurchaseItem(player,n)
end

function module.Client:GetItemFromName(player,n)
	return self.Server:GetItemFromName(n)
end

function module:ItemsRemovedForClient(plr,item)
	local backpack = plr:WaitForChild("Backpack")
	local character = plr.Character or plr.CharacterAdded:Wait()
	if character:FindFirstChild(item) then
		self.Client.ItemsRemovedClient:Fire(plr,{Remove_result = "Item removed : "..item.." !" ,removeMessage = "Tool .. "..item.." retiré" ,oldTool_Owner = plr})
		character:FindFirstChild(item):Destroy()
		return true
	elseif backpack:FindFirstChild(item) then
		self.Client.ItemsRemovedClient:Fire(plr,{Remove_result = "Item removed : "..item.." !" ,removeMessage = "Tool .."..item.." retiré" ,oldTool_Owner = plr})
		backpack:FindFirstChild(item):Destroy()
		return true
	else
		warn("Bug trouvé pendant la suppression de l'objet ("..item..")")
		return false
	end
end

function module.Client:RemoveObject(plr,item)
	return self.Server:ItemsRemovedForClient(plr,item)
end

function module.Client:ReceivedAddedItems(plr,item)
	return self.Server:ItemsAddedForClient(plr,item)
end

return module
