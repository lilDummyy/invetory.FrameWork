--[[
@Dummy, (Promise/Roact/Knit/Component)

Dernière maj: 25/09/23

@Information: 
98% du système terminé

@ajouts:
DataStore terminé, autoCancel terminé,autoRecovery terminé , Keyboard Touch , pas encore fait

@Résultât pour le moment:
pas de bug pour le moment a voir avec la suite des ajouts.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)
local Signal = require(Knit.Util.Signal)
local Option = require(Knit.Util.Option)
local Roact = require(Knit.Util.Roact)
local Maid = require(Knit.Util.Maid)
local IsSavingModule = require(ReplicatedStorage.Packages:WaitForChild("IsSavingModule"))
local Component = require(script:WaitForChild("Component"))
local RemoteClientComponent = require(Knit.Util.RemoteClientComponent)

local loadAllRemoteFunctions = RemoteClientComponent.new()
local loadSavingModuleFunctions = IsSavingModule.new("InventoryClass")
loadSavingModuleFunctions:Enable("InventoryClass")
	
local PromiseToReview
local situation = false
local purchased = false
local cancelled = false

local Item = {}
Item.__index = Item

function Item.new()
	local self = setmetatable({},Item)
	self.Knit = Knit.GetService("InventoryKnitMain")
	self.backpack = {}
	self.folderItem = {}
	self.db = false
	self._Component = Component.new()
	return self
end


function Item:OnPurchased(stgs)
	if (table.find(self.folderItem,stgs.obj)) then return warn("Item déjà acheté") end
	self.item = self.Knit:GetItemFromName(stgs.obj)
	self._maid = Maid.new()
	table.insert(self.folderItem,self.item)
	
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")	
	
	return Promise.new(function(resolve,reject,OnCancel)
		local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
		local backpack = Players.LocalPlayer:WaitForChild("Backpack")
		if (not backpack)  or (not character) then resolve() end
		local function createElement()
			local ui = stgs.GuiToParent
			if (ui) then
				return Roact.createElement("Frame",{
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(0.0525,0.12),
					BackgroundColor3 = Color3.new(0,0,0)
				},{
					Main = Roact.createElement("Frame",{
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(.5,.5),
						Position = UDim2.fromScale(.5,.5),
						Size = UDim2.fromScale(.8,.8),
						[Roact.Event.MouseEnter] = function(element)
							TweenService:Create(element.UIStroke,TweenInfo.new(.15),{Color = Color3.new(0,0,0)}):Play()
							TweenService:Create(element.ImageButton,TweenInfo.new(.15),{ImageColor3 = Color3.new(0,0,0)}):Play()
							TweenService:Create(element,TweenInfo.new(.15),{BackgroundTransparency = 0,BackgroundColor3 = Color3.new(1,1,1),Size = UDim2.fromScale(.78,.78)}):Play()
						end,
						[Roact.Event.MouseLeave] = function(element)
							TweenService:Create(element.ImageButton,TweenInfo.new(.15),{ImageColor3 = Color3.new(1,1,1)}):Play()
							TweenService:Create(element,TweenInfo.new(.15),{BackgroundTransparency = 1,BackgroundColor3 = Color3.new(0,0,0),Size = UDim2.fromScale(.8,.8)}):Play()
							TweenService:Create(element.UIStroke,TweenInfo.new(.15),{Color = Color3.new(1,1,1)}):Play()
						end,
					},{
						UICorner = Roact.createElement("UICorner",{}),
						UIStroke = Roact.createElement("UIStroke",{Thickness = 2,Color = Color3.new(1,1,1)}),
						ImageButton = Roact.createElement("ImageButton",{
							Image = self.textures.ImagesId[self.item] or "",
							Size = UDim2.fromScale(.85,.85),
							AnchorPoint = Vector2.new(.5,.5),
							Position = UDim2.fromScale(.5,.5),
							BackgroundTransparency = 1,
							[Roact.Event.MouseButton1Down] = function(element)
								if (not situation)  then
									situation = self.item
									PromiseToReview = self:GetSituation()
								elseif (situation ~= nil) then
									situation = false
									self:CancelPromiseReview()
								end
							end,
						})
					})
				})
			end
		end
		self.folderItem[self.item] = Roact.mount(Roact.createElement(createElement),stgs.GuiToParent,self.item)
		loadAllRemoteFunctions:Fire(Knit.Util.Remotes._remote.InventoryLoaded,
			{
				p = Players.LocalPlayer,
				SavingMode = loadSavingModuleFunctions:GetState("InventoryClass"),
				GetAll = {
					InventoryName = `InventoryClass[<Component[<({self.item})>]>]`,
					item = self.item
				},
			})
		return self
	end)
end

function Item:Load(str)
	local ui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainRequirementUi").coutainer.Items.inventory.TitlesInventory
	local function createElement()
		if (ui) then
			return Roact.createElement("Frame",{
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.0525,0.12),
				BackgroundColor3 = Color3.new(0,0,0)
			},{
				Main = Roact.createElement("Frame",{
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(.5,.5),
					Position = UDim2.fromScale(.5,.5),
					Size = UDim2.fromScale(.8,.8),
					[Roact.Event.MouseEnter] = function(element)
						TweenService:Create(element.UIStroke,TweenInfo.new(.15),{Color = Color3.new(0,0,0)}):Play()
						TweenService:Create(element.ImageButton,TweenInfo.new(.15),{ImageColor3 = Color3.new(0,0,0)}):Play()
						TweenService:Create(element,TweenInfo.new(.15),{BackgroundTransparency = 0,BackgroundColor3 = Color3.new(1,1,1),Size = UDim2.fromScale(.78,.78)}):Play()
					end,
					[Roact.Event.MouseLeave] = function(element)
						TweenService:Create(element.ImageButton,TweenInfo.new(.15),{ImageColor3 = Color3.new(1,1,1)}):Play()
						TweenService:Create(element,TweenInfo.new(.15),{BackgroundTransparency = 1,BackgroundColor3 = Color3.new(0,0,0),Size = UDim2.fromScale(.8,.8)}):Play()
						TweenService:Create(element.UIStroke,TweenInfo.new(.15),{Color = Color3.new(1,1,1)}):Play()
					end,
				},{
					UICorner = Roact.createElement("UICorner",{}),
					UIStroke = Roact.createElement("UIStroke",{Thickness = 2,Color = Color3.new(1,1,1)}),
					ImageButton = Roact.createElement("ImageButton",{
						Image = self.textures.ImagesId[str] or "",
						Size = UDim2.fromScale(.85,.85),
						AnchorPoint = Vector2.new(.5,.5),
						Position = UDim2.fromScale(.5,.5),
						BackgroundTransparency = 1,
						[Roact.Event.MouseButton1Down] = function(element)
							if (not situation) then
								situation = str or self.item
								PromiseToReview = self:GetSituation(str)
							elseif (situation ~= nil) then
								situation = false
								self:CancelPromiseReview()
							end
						end,
					})
				})
			})
		end
	end
	if (self.folderItem) then
		self.folderItem[self.item or str] = Roact.mount(Roact.createElement(createElement),ui,self.item)
	else
		self[str] = Roact.mount(Roact.createElement(createElement),ui,str or self.item)
	end
	return self
end

function Item:GetSituation(str)
	local uiInventory = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainRequirementUi"):WaitForChild("coutainer")
	local frameInventory = uiInventory:WaitForChild("Items")
	
	
	if (self.item) then
		return Promise.new(function(resolve,reject,OnCancel)
			local elementGrandedScreenUi = nil
			
			local function onDecide()
				return Roact.createElement("Frame",{
					BackgroundTransparency = 0.35,
					Size = UDim2.fromScale(0.45,0.55),
					Position = UDim2.fromScale(.5,.45),
					AnchorPoint = Vector2.new(.5,.5),
					BackgroundColor3 = Color3.fromRGB(25,25,25),	
				},{
					UIStroke = Roact.createElement("UIStroke",{Color = Color3.new(1,1,1),Thickness = 1}),
					UICorner = Roact.createElement("UICorner"),
					CurrentItemLabel = Roact.createElement("TextLabel",{
						Text = "Voulez vous ajoutez l'item à votre inventaire : ("..tostring(self.item)..") ?",
						TextScaled = true,
						TextColor3 = Color3.fromRGB(255,255,255),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(.85,0.1),
						AnchorPoint = Vector2.new(.5,.5),
						Position = UDim2.fromScale(.5,.15),
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
					}),
					EquiperFrame = Roact.createElement("Frame",{
						Size = UDim2.fromScale(.2,.125),
						Position = UDim2.fromScale(0.2,0.85),
						AnchorPoint = Vector2.new(.5,.5),
						BackgroundTransparency = 1,
						BackgroundColor3 = Color3.fromRGB(25,25,25),	
					},{
						UICorner = Roact.createElement("UICorner"),
						UIScale = Roact.createElement("UIScale",{Scale = 1}),
						UIStroke = Roact.createElement("UIStroke",{Color = Color3.new(1,1,1),Thickness = 1}),
						EquipButton = Roact.createElement("TextButton",{
							BackgroundTransparency = 1,
							BackgroundColor3 = Color3.fromRGB(25,25,25),
							AnchorPoint = Vector2.new(.5,.5),
							Size = UDim2.fromScale(0.8,0.8),
							Text = "Equipé ",
							TextColor3 = Color3.new(1,1,1),
							FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal),
							TextScaled = true,
							Position = UDim2.fromScale(.5,.5),
							[Roact.Event.MouseEnter] = function(element)
								TweenService:Create(element.Parent,TweenInfo.new(.15),{BackgroundColor3 = Color3.new(1,1,1),BackgroundTransparency = 0}):Play()
								TweenService:Create(element,TweenInfo.new(.15),{TextColor3 = Color3.new(0,0,0)}):Play()
								TweenService:Create(element.Parent.UIScale,TweenInfo.new(.15),{Scale = .95}):Play()
								TweenService:Create(element.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(0,0,0)}):Play()
							end,
							[Roact.Event.MouseLeave] = function(element)
								TweenService:Create(element.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(1,1,1)}):Play()
								TweenService:Create(element,TweenInfo.new(.15),{TextColor3 = Color3.new(1,1,1)}):Play()
								TweenService:Create(element.Parent.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
								TweenService:Create(element.Parent,TweenInfo.new(.15),{BackgroundColor3 = Color3.fromRGB(25,25,25),BackgroundTransparency = 1}):Play()
							end,
							[Roact.Event.MouseButton1Down] = function(element)
								TweenService:Create(element.Parent,TweenInfo.new(.15),{BackgroundColor3 = Color3.new(1,1,1),BackgroundTransparency = 0}):Play()
								TweenService:Create(element,TweenInfo.new(.15),{TextColor3 = Color3.new(0,0,0)}):Play()
								TweenService:Create(element.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(0,0,0)}):Play()	
								if #Players.LocalPlayer:WaitForChild("PlayerGui").InventoryScreen.coutainer:GetChildren()>=5 then return end
								self:AddedToSpecificUser(self.item or str)
							end,
						}),
					}),
					SuppFrame = Roact.createElement("Frame",{
						Size = UDim2.fromScale(.2,.125),
						Position = UDim2.fromScale(0.5,0.85),
						AnchorPoint = Vector2.new(.5,.5),
						BackgroundTransparency = 1,
						BackgroundColor3 = Color3.fromRGB(25,25,25),
					},{
						UICorner = Roact.createElement("UICorner"),
						UIScale = Roact.createElement("UIScale",{Scale = 1}),
						UIStroke = Roact.createElement("UIStroke",{Color = Color3.new(1,1,1),Thickness = 1}),
						DeleteButton = Roact.createElement("TextButton",{
							BackgroundTransparency = 1,
							BackgroundColor3 = Color3.fromRGB(25,25,25),
							AnchorPoint = Vector2.new(.5,.5),
							Size = UDim2.fromScale(0.8,0.8),
							Text = "Supprimé ",
							TextColor3 = Color3.new(1,1,1),
							TextScaled = true,
							FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal),
							Position = UDim2.fromScale(.5,.5),
							[Roact.Event.MouseEnter] = function(element)
								TweenService:Create(element.Parent,TweenInfo.new(.15),{BackgroundColor3 = Color3.new(1,1,1),BackgroundTransparency = 0}):Play()
								TweenService:Create(element,TweenInfo.new(.15),{TextColor3 = Color3.new(0,0,0)}):Play()
								TweenService:Create(element.Parent.UIScale,TweenInfo.new(.15),{Scale = .95}):Play()
								TweenService:Create(element.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(0,0,0)}):Play()
							end,
							[Roact.Event.MouseLeave] = function(element)
								TweenService:Create(element.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(1,1,1)}):Play()
								TweenService:Create(element,TweenInfo.new(.15),{TextColor3 = Color3.new(1,1,1)}):Play()
								TweenService:Create(element.Parent.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
								TweenService:Create(element.Parent,TweenInfo.new(.15),{BackgroundColor3 = Color3.fromRGB(25,25,25),BackgroundTransparency = 1}):Play()
							end,
							[Roact.Event.MouseButton1Down] = function(element)
								TweenService:Create(element.Parent,TweenInfo.new(.15),{BackgroundColor3 = Color3.new(1,1,1),BackgroundTransparency = 0}):Play()
								TweenService:Create(element,TweenInfo.new(.15),{TextColor3 = Color3.new(0,0,0)}):Play()
								TweenService:Create(element.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(0,0,0)}):Play()	
								self:RemovedFromUser()
							end,
						})
					})
				})
			end
			if (not elementGrandedScreenUi) then
				warn(self.GetSituation, "commencé avec succès")
				elementGrandedScreenUi = Roact.mount(Roact.createElement(onDecide),frameInventory,"frameInventory")
			end
			OnCancel(function()
				warn("PromiseReview à était Cancel")
				if (elementGrandedScreenUi) then
					Roact.unmount(elementGrandedScreenUi)
					for i,frame in frameInventory:GetChildren() do
						if (frame.ClassName == "Frame") and (frame.Name == "frameInventory") then
							print("Autres frames pendants le cancel à était trouvé", frame:GetFullName())
							frame:Remove()
						end
					end
				end
			end)
		end):catch(warn)
	elseif (str ~= nil) then
		return Promise.new(function(resolve,reject,OnCancel)
			local elementGrandedScreenUi = nil

			local function onDecide()
				return Roact.createElement("Frame",{
					BackgroundTransparency = 0.35,
					Size = UDim2.fromScale(0.45,0.55),
					Position = UDim2.fromScale(.5,.45),
					AnchorPoint = Vector2.new(.5,.5),
					BackgroundColor3 = Color3.fromRGB(25,25,25),	
				},{
					UIStroke = Roact.createElement("UIStroke",{Color = Color3.new(1,1,1),Thickness = 1}),
					UICorner = Roact.createElement("UICorner"),
					CurrentItemLabel = Roact.createElement("TextLabel",{
						Text = "Voulez vous ajoutez l'item à votre inventaire : ("..tostring(self.item or str)..") ?",
						TextScaled = true,
						TextColor3 = Color3.fromRGB(255,255,255),
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(.85,0.1),
						AnchorPoint = Vector2.new(.5,.5),
						Position = UDim2.fromScale(.5,.15),
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
					}),
					EquiperFrame = Roact.createElement("Frame",{
						Size = UDim2.fromScale(.2,.125),
						Position = UDim2.fromScale(0.2,0.85),
						AnchorPoint = Vector2.new(.5,.5),
						BackgroundTransparency = 1,
						BackgroundColor3 = Color3.fromRGB(25,25,25),	
					},{
						UICorner = Roact.createElement("UICorner"),
						UIScale = Roact.createElement("UIScale",{Scale = 1}),
						UIStroke = Roact.createElement("UIStroke",{Color = Color3.new(1,1,1),Thickness = 1}),
						EquipButton = Roact.createElement("TextButton",{
							BackgroundTransparency = 1,
							BackgroundColor3 = Color3.fromRGB(25,25,25),
							AnchorPoint = Vector2.new(.5,.5),
							Size = UDim2.fromScale(0.8,0.8),
							Text = "Equipé ",
							TextColor3 = Color3.new(1,1,1),
							FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal),
							TextScaled = true,
							Position = UDim2.fromScale(.5,.5),
							[Roact.Event.MouseEnter] = function(element)
								TweenService:Create(element.Parent,TweenInfo.new(.15),{BackgroundColor3 = Color3.new(1,1,1),BackgroundTransparency = 0}):Play()
								TweenService:Create(element,TweenInfo.new(.15),{TextColor3 = Color3.new(0,0,0)}):Play()
								TweenService:Create(element.Parent.UIScale,TweenInfo.new(.15),{Scale = .95}):Play()
								TweenService:Create(element.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(0,0,0)}):Play()
							end,
							[Roact.Event.MouseLeave] = function(element)
								TweenService:Create(element.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(1,1,1)}):Play()
								TweenService:Create(element,TweenInfo.new(.15),{TextColor3 = Color3.new(1,1,1)}):Play()
								TweenService:Create(element.Parent.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
								TweenService:Create(element.Parent,TweenInfo.new(.15),{BackgroundColor3 = Color3.fromRGB(25,25,25),BackgroundTransparency = 1}):Play()
							end,
							[Roact.Event.MouseButton1Down] = function(element)
								TweenService:Create(element.Parent,TweenInfo.new(.15),{BackgroundColor3 = Color3.new(1,1,1),BackgroundTransparency = 0}):Play()
								TweenService:Create(element,TweenInfo.new(.15),{TextColor3 = Color3.new(0,0,0)}):Play()
								TweenService:Create(element.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(0,0,0)}):Play()	
								if #Players.LocalPlayer:WaitForChild("PlayerGui").InventoryScreen.coutainer:GetChildren()>=5 then return end
								self:AddedToSpecificUser(self.item or str)
							end,
						}),
					}),
					SuppFrame = Roact.createElement("Frame",{
						Size = UDim2.fromScale(.2,.125),
						Position = UDim2.fromScale(0.5,0.85),
						AnchorPoint = Vector2.new(.5,.5),
						BackgroundTransparency = 1,
						BackgroundColor3 = Color3.fromRGB(25,25,25),
					},{
						UICorner = Roact.createElement("UICorner"),
						UIScale = Roact.createElement("UIScale",{Scale = 1}),
						UIStroke = Roact.createElement("UIStroke",{Color = Color3.new(1,1,1),Thickness = 1}),
						DeleteButton = Roact.createElement("TextButton",{
							BackgroundTransparency = 1,
							BackgroundColor3 = Color3.fromRGB(25,25,25),
							AnchorPoint = Vector2.new(.5,.5),
							Size = UDim2.fromScale(0.8,0.8),
							Text = "Supprimé ",
							TextColor3 = Color3.new(1,1,1),
							TextScaled = true,
							FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal),
							Position = UDim2.fromScale(.5,.5),
							[Roact.Event.MouseEnter] = function(element)
								TweenService:Create(element.Parent,TweenInfo.new(.15),{BackgroundColor3 = Color3.new(1,1,1),BackgroundTransparency = 0}):Play()
								TweenService:Create(element,TweenInfo.new(.15),{TextColor3 = Color3.new(0,0,0)}):Play()
								TweenService:Create(element.Parent.UIScale,TweenInfo.new(.15),{Scale = .95}):Play()
								TweenService:Create(element.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(0,0,0)}):Play()
							end,
							[Roact.Event.MouseLeave] = function(element)
								TweenService:Create(element.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(1,1,1)}):Play()
								TweenService:Create(element,TweenInfo.new(.15),{TextColor3 = Color3.new(1,1,1)}):Play()
								TweenService:Create(element.Parent.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
								TweenService:Create(element.Parent,TweenInfo.new(.15),{BackgroundColor3 = Color3.fromRGB(25,25,25),BackgroundTransparency = 1}):Play()
							end,
							[Roact.Event.MouseButton1Down] = function(element)
								TweenService:Create(element.Parent,TweenInfo.new(.15),{BackgroundColor3 = Color3.new(1,1,1),BackgroundTransparency = 0}):Play()
								TweenService:Create(element,TweenInfo.new(.15),{TextColor3 = Color3.new(0,0,0)}):Play()
								TweenService:Create(element.Parent.UIStroke,TweenInfo.new(.15),{Color = Color3.new(0,0,0)}):Play()	
								self:RemovedFromUser(str or self.item)
							end,
						})
					})
				})
			end
			if (not elementGrandedScreenUi) then
				warn(self.GetSituation, "commencé avec succès")
				elementGrandedScreenUi = Roact.mount(Roact.createElement(onDecide),frameInventory,"frameInventory")
			end
			OnCancel(function()
				warn("PromiseReview à était Cancel")
				if (elementGrandedScreenUi) then
					Roact.unmount(elementGrandedScreenUi)
					for i,frame in frameInventory:GetChildren() do
						if (frame.ClassName == "Frame") and (frame.Name == "frameInventory") then
							print("Autres frames pendants le cancel à était trouvé", frame:GetFullName())
							frame:Remove()
						end
					end
				end
			end)
		end):catch(warn)
	end
end

function Item:CancelPromiseReview()
	if (not PromiseToReview) then return end
	situation = false
	return PromiseToReview:cancel()
end

function Item:AddedToSpecificUser(str)
	print("Envoie de la fonction.")
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	if table.find(self.backpack,self.item or str) ~= nil then return warn("Objet déjà trouvé dans la table d'inventaire, nouveau message envoié.") end
	table.insert(self.backpack,self.item or str)
	self:CancelPromiseReview()
	self._Component:AddTopBar(self,str)
	
	local function screenOnPurchase()
		local ui = playerGui:FindFirstChild("RequestSend")
		if (ui) then
			return Promise.new(function(resolve,reject,OnCancel)
				local templateToMove = script:WaitForChild("template"):Clone()
				templateToMove.Parent = ui
				templateToMove.Name = self.item or str
				templateToMove.ZIndex = 10
				templateToMove:WaitForChild("requestText").Text = "Item équipé".." ("..self.item..")"
				TweenService:Create(templateToMove:FindFirstChild("requestText"),TweenInfo.new(.15),{TextTransparency = 0}):Play()
				TweenService:Create(templateToMove:FindFirstChild("bar").UIScale,TweenInfo.new(.15,Enum.EasingStyle.Back),{Scale = 1}):Play()
				task.wait(1.7)
				TweenService:Create(templateToMove:FindFirstChild("requestText"),TweenInfo.new(.15),{TextTransparency = 1}):Play()
				TweenService:Create(templateToMove:FindFirstChild("bar").UIScale,TweenInfo.new(.15,Enum.EasingStyle.Back),{Scale = 0}):Play()
				task.wait(.5)
				templateToMove:Destroy()
			end):catch(warn)	
		end
	end
	local promiseScreen = screenOnPurchase()
	return self.Knit:ReceivedAddedItems(self.item or str)
end

function Item:RemovedFromUser(str)
	local uiInventory = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainRequirementUi"):WaitForChild("coutainer")
	local frameInventory = uiInventory:WaitForChild("Items")
	local itemsParent = frameInventory:WaitForChild("inventory"):WaitForChild("TitlesInventory")
	
	local player = Players.LocalPlayer
	local Character = player.Character or player.CharacterAdded:Wait()
	local backpack = player:WaitForChild("Backpack")	
	
	if (table.find(self.backpack,self.item or str)) and table.find(self.folderItem,self.item or str) then 
		table.remove(self.backpack,table.find(self.backpack,self.item or str)) 
		table.remove(self.folderItem,table.find(self.folderItem,self.item or str))
	elseif table.find(self.folderItem,self.item) then
		table.remove(self.folderItem,table.find(self.folderItem,self.item or str))
	end
	
	if (self.folderItem[self.item]) then
		local roactMounted = self.folderItem[self.item or str]
		Roact.unmount(roactMounted) 
		if (self._maid) then
			self._maid:Destroy()
			self._maid = nil
		end
		self.folderItem[self.item] = nil
		roactMounted = nil
	end
	
	self._Component:RemoveTopBar(tostring(self.item) or str)
	self.Knit:RemoveObject(self.item or str)
	self:CancelPromiseReview()	
	return self
end



Item.Folder = script:WaitForChild("Items")

Item.textures = {ImagesId = {
	Flashlight = "rbxassetid://11697193612"	,
	ClassicSword = "rbxassetid://9695653110"
}}


return Item
