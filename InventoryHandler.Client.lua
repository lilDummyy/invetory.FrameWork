local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local ContentProvider = game:GetService("ContentProvider")

ContentProvider:PreloadAsync({game})
task.wait(2)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)

local Signal = require(ReplicatedStorage:WaitForChild("Packages").Signal)
local Maid = require(ReplicatedStorage:WaitForChild("Packages").Maid)
local Knit = require(ReplicatedStorage:WaitForChild("Packages").Knit)
local RemoteClientComponent = require(ReplicatedStorage:WaitForChild("Packages").RemoteClientComponent)

local function get(parent,name :string)
	if parent:FindFirstChild(name) then
		return parent:FindFirstChild(name)
	else
		return warn(debug.traceback(`{parent:WaitForChild(name)} ne doit pas être nil`,2))
	end
end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local playerScript = player:WaitForChild("PlayerScripts")
local MainRequirementUi = playerGui:WaitForChild("MainRequirementUi")
local coutainer = MainRequirementUi:WaitForChild("coutainer")
local Items = coutainer:WaitForChild("Items")
local Boutique = Items:WaitForChild("Boutique")
local EffectFrame = Boutique:WaitForChild("EffectFrame")
local ItemsFrame = Boutique:WaitForChild("ItemsFrame")

--Modules
local ItemComponent = require(playerScript:WaitForChild("Mains").Knit_Installation.Component:WaitForChild("inventory.Component.Client"))
local ItemsFrameWork = require(ReplicatedStorage:WaitForChild("Packages").Menu["InventoryModule.all"]).Items.new()

--obtien primary Instance
local getEffectButton = get(EffectFrame,"TextButton")
local getItemsFrameButton = get(ItemsFrame,"TextButton")
local getMainGroup = get(Boutique,"MainGroup")

--Respective Tween Frame
local ScrollingFrame = getMainGroup:WaitForChild("ScrollingFrame")
local SwordUnCommunFrame = get(ScrollingFrame,"SwordUmcommunFrame")
local SwordFrame = SwordUnCommunFrame:WaitForChild("SwordFrame")
local PurchaseFrame = get(SwordFrame,"PurchaseFrame")
local PurchaseButtonFrame = PurchaseFrame:WaitForChild("PurchaseButtonFrame")
local SaleItemFrame = PurchaseFrame:WaitForChild("SaleItemFrame")
local RarityFrame = SwordFrame:WaitForChild("RarityFrame")
local SwordImageFrame = SwordFrame:WaitForChild("SwordImage")

local PurchaseButton = get(PurchaseButtonFrame,"TextButton")
local SaleButton = get(SaleItemFrame,"TextButton")

--FlaslightItem ui
local FlashlightRareFrame = ScrollingFrame:WaitForChild("FlashlightRareFrame")
local FlashlightFrame = FlashlightRareFrame.FlashlightFrame
local FlashlightPurchaseFrame = FlashlightFrame.PurchaseFrame
local FlashlightPurchaseButtonFrame = FlashlightPurchaseFrame.PurchaseButtonFrame
local FlashlightSaleFrame = FlashlightPurchaseFrame.SaleItemFrame

--InvetoryFrame References
local InventoryFrame = get(Items,"inventory")
local InventoryCoutainer = InventoryFrame:WaitForChild("TitlesInventory")
local InventoryScreen = get(Players.LocalPlayer:WaitForChild("PlayerGui"),"InventoryScreen")


local function CheckIfAlreadyExist(i)
	if InventoryCoutainer:FindFirstChild(i) then
		return "Refusé"
	else
		return "Succès"
	end
end

--items/detectables_keys
local keys = {}
local items = {}


--[ui-render handler]
--refresh ui_bar

Knit.Util.Menu["InventoryModule.all"]["Inventory.Items"].__bindable.refreshItem_bar.Event:Connect(function(plr,args,i)
	assert(type(args) == "table",`{type(args)} must be a table Value {debug.traceback("__index error",2)}`)
	local function refresh()
		for i,v in ipairs(args) do
			if not (table.find(keys,v)) then table.insert(keys,v) end
			if not (table.find(items,v)) then table.insert(items,v) end
		end
		if (i ~= nil) then
			if table.find(items,i) then
				table.remove(items,table.find(items,i))
				print("removed from table", i)
				for _i,item in ipairs(items) do
					if (InventoryScreen.Selectable.Value == tostring(item) or InventoryScreen.Selectable.Value == tostring(i) or InventoryScreen.Selectable.Value ~= "") then
						InventoryScreen.Selectable.Value = ""
						InventoryScreen.coutainer:WaitForChild(tostring(item)):WaitForChild("UIScale").Scale = 1
						InventoryScreen.coutainer:WaitForChild(tostring(item)):WaitForChild("UIStroke").Thickness = 1
						InventoryScreen.coutainer:WaitForChild(tostring(item)):WaitForChild("UIStroke").Transparency = 1
					end
				end
				if #items <=0 then
					InventoryScreen.Selectable.Value = ""
				end
			end
		end
		task.wait(.25)
		for i,item in ipairs(items) do
			if (InventoryScreen.coutainer:WaitForChild(tostring(item))) then
				InventoryScreen.coutainer:WaitForChild(tostring(item)):WaitForChild("_index").Text = tostring(i)
			end
		end
		warn("refresh initialized")
	end
	task.spawn(refresh)
end)

Knit.Util.Menu["InventoryModule.all"]["Inventory.Items"].__bindable.event.Event:Connect(function(item,fn)
	if (not item) or not fn then return end
	if (fn == "Equip") then
		return ItemComponent:Equip(item)
	elseif (fn == "UnEquip") then
		return ItemComponent:UnEquip(item)
	end
	error("fn is not longer [Equip] or UnEquip]"..`{debug.traceback("__",2)}`)
end)

--[ReceiveServerFunction]

Knit.Util.Menu["InventoryModule.all"]["Inventory.Items"].__bindable.ClientService.__ReceiveServer.OnClientInvoke = function(t,b)
	if (type(t) == "table") then
		for i,str in ipairs(t.Item) do
			local item = ItemsFrameWork.Knit:GetItemFromName(str)
			if (item) then
				ItemComponent:Items(item,"Purchase")
			end
		end
	end
end

--task/tables

local _maid = nil
local _instances = {}

getEffectButton.MouseButton1Down:Connect(function()
	TweenService:Create(ScrollingFrame,TweenInfo.new(.15),{Position = UDim2.fromScale(1,0)}):Play()
	SoundService:PlayLocalSound(SoundService["UI Click"])
end)

getItemsFrameButton.MouseButton1Down:Connect(function()
	TweenService:Create(ScrollingFrame,TweenInfo.new(.15),{Position = UDim2.fromScale(0,0)}):Play()
	SoundService:PlayLocalSound(SoundService["UI Click"])
end)

SaleButton.MouseButton1Down:Connect(function()
	--ItemModule doit faire un check si le jouer la oui ou non
	SoundService:PlayLocalSound(SoundService.ui_mission_tick)
	
end)

PurchaseButton.MouseButton1Down:Connect(function()
	SoundService:PlayLocalSound(SoundService.ui_mission_tick)
	
	local item = ItemsFrameWork.Knit:GetItemFromName("ClassicSword")
	local purchaseGrandedResult = ItemsFrameWork.Knit:_PurchaseGranded(item)
	
	if (purchaseGrandedResult == false) and ((item ~= nil)) and (CheckIfAlreadyExist(item) == "Succès") then
		return ItemComponent:Items(item,"Purchase")
	elseif (item) and (CheckIfAlreadyExist(item) == "Refusé") or (purchaseGrandedResult == true) then
		return warn("failed cause its already purchase.")
	end
end)

FlashlightPurchaseButtonFrame.TextButton.MouseButton1Down:Connect(function()
	SoundService:PlayLocalSound(SoundService.ui_mission_tick)
	
	local item = ItemsFrameWork.Knit:GetItemFromName("Flashlight")
	local purchaseGrandedResult = ItemsFrameWork.Knit:_PurchaseGranded(item)

	if (purchaseGrandedResult == false) and ((item ~= nil)) and (CheckIfAlreadyExist(item) == "Succès") then
		return ItemComponent:Items(item,"Purchase")
	elseif (item) and (CheckIfAlreadyExist(item) == "Refusé") or (purchaseGrandedResult == true) then
		return warn("failed cause its already purchase.")
	end
end)

--Mouse detecing Connection  (Mouse.Enter,Mouse.Leave)

EffectFrame.MouseEnter:Connect(function()
	SoundService:PlayLocalSound(SoundService["RBLX UI Hover 03 (SFX)"])
	TweenService:Create(getEffectButton.Parent.UIScale,TweenInfo.new(.15),{Scale = .95}):Play()
	TweenService:Create(getEffectButton,TweenInfo.new(.15),{TextColor3 = Color3.new(0,0,0)}):Play()
	TweenService:Create(getEffectButton.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(0,0,0)}):Play()
	TweenService:Create(getEffectButton.Parent,TweenInfo.new(.15),{BackgroundTransparency = 0, BackgroundColor3 = Color3.new(1,1,1)}):Play()
end)

PurchaseButtonFrame.MouseEnter:Connect(function()
	SoundService:PlayLocalSound(SoundService["RBLX UI Hover 03 (SFX)"])
	TweenService:Create(PurchaseButtonFrame.UIScale,TweenInfo.new(.15),{Scale = 1.05}):Play()
end)

FlashlightPurchaseButtonFrame.MouseEnter:Connect(function()
	SoundService:PlayLocalSound(SoundService["RBLX UI Hover 03 (SFX)"])
	TweenService:Create(FlashlightPurchaseButtonFrame.UIScale,TweenInfo.new(.15),{Scale = 1.05}):Play()
end)

FlashlightPurchaseButtonFrame.MouseLeave:Connect(function()
	TweenService:Create(FlashlightPurchaseButtonFrame.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
end)

PurchaseButtonFrame.MouseLeave:Connect(function()
	TweenService:Create(PurchaseButtonFrame.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
end)

SaleItemFrame.MouseEnter:Connect(function()
	SoundService:PlayLocalSound(SoundService["RBLX UI Hover 03 (SFX)"])
	TweenService:Create(SaleItemFrame.UIScale,TweenInfo.new(.15),{Scale = 1.05}):Play()
end)

SaleItemFrame.MouseLeave:Connect(function()
	TweenService:Create(SaleItemFrame.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
end)

FlashlightSaleFrame.TextButton.MouseEnter:Connect(function()
	SoundService:PlayLocalSound(SoundService["RBLX UI Hover 03 (SFX)"])
	TweenService:Create(FlashlightSaleFrame.UIScale,TweenInfo.new(.15),{Scale = 1.05}):Play()
end)

FlashlightSaleFrame.TextButton.MouseLeave:Connect(function()
	TweenService:Create(FlashlightSaleFrame.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
end)

EffectFrame.MouseLeave:Connect(function()
	TweenService:Create(getEffectButton.Parent.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
	TweenService:Create(getEffectButton.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(1,1,1)}):Play()
	TweenService:Create(getEffectButton,TweenInfo.new(.15),{TextColor3 = Color3.new(1,1,1)}):Play()
	TweenService:Create(getEffectButton.Parent,TweenInfo.new(.15),{BackgroundTransparency = 1, BackgroundColor3 = Color3.new(0,0,0)}):Play()
end)

ItemsFrame.MouseEnter:Connect(function()
	SoundService:PlayLocalSound(SoundService["RBLX UI Hover 03 (SFX)"])
	TweenService:Create(getItemsFrameButton.Parent.UIScale,TweenInfo.new(.15),{Scale = .95}):Play()
	TweenService:Create(getItemsFrameButton,TweenInfo.new(.15),{TextColor3 = Color3.new(0,0,0)}):Play()
	TweenService:Create(getItemsFrameButton.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(0,0,0)}):Play()
	TweenService:Create(getItemsFrameButton.Parent,TweenInfo.new(.15),{BackgroundTransparency = 0, BackgroundColor3 = Color3.new(1,1,1)}):Play()
end)

ItemsFrame.MouseLeave:Connect(function()
	TweenService:Create(getItemsFrameButton.Parent.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
	TweenService:Create(getItemsFrameButton.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(1,1,1)}):Play()
	TweenService:Create(getItemsFrameButton,TweenInfo.new(.15),{TextColor3 = Color3.new(1,1,1)}):Play()
	TweenService:Create(getItemsFrameButton.Parent,TweenInfo.new(.15),{BackgroundTransparency = 1, BackgroundColor3 = Color3.new(0,0,0)}):Play()
end)
