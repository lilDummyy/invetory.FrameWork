--[=[
@Dummy, (Promise) , items du joueur converti dans l'inventaire.

Dernière maj: 10/09/23

@Information: 
Nouvel méthode de request ajoutée , bientôt finis le système principale d'ajout

@pour plus tard:
ajoutée une fonction pour récupérer des data [self.backpack] sera également utilisé pour ça.
ajoutée une fonction pour supprimer un objet définitivement de l'inventaire (self.backpack[item] également doit être remove).
@ajoutée une fonction pour remettre l'objet dans le Gui principale (nommé ScreenGui.coutainer.Items) avec les mêmes paramêtre d'avant.

@Exemple d'usage :

SaleButton.MouseButton1Down:Connect(function()
	--ItemModule doit faire un check si le jouer la oui ou non
	SoundService:PlayLocalSound(SoundService.ui_mission_tick)

end)

PurchaseButton.MouseButton1Down:Connect(function()
	--ajout de l'item
	SoundService:PlayLocalSound(SoundService.ui_mission_tick)
	local item = ItemsFrameWork.Knit:GetItemFromName("ClassicSword")
	print(item) -- "nom de l'item"
	local purchaseGrandedResult = ItemsFrameWork.Knit:_PurchaseGranded(item)
	print(purchaseGrandedResult) -- false car  il ne l'a pas encore acheté.
	
end)

@Résultât pour le moment:
pas de bug pour le moment a voir avec la suite des ajouts.
]=]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)
local Signal = require(Knit.Util.Signal)
local Option = require(Knit.Util.Option)
local Roact = require(Knit.Util.Roact)
local IsSavingModule = require(ReplicatedStorage.Packages:WaitForChild("IsSavingModule"))

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
	self._src = Signal.new()
	return self
end


function Item:OnPurchased(stgs)
	if (table.find(self.folderItem,stgs.obj)) then return warn("Item déjà acheté") end
	print(self)
	self.item = self.Knit:GetItemFromClient(stgs.obj)
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
							Image = self.textures.ImagesId[self.item.Name] or "",
							Size = UDim2.fromScale(.85,.85),
							AnchorPoint = Vector2.new(.5,.5),
							Position = UDim2.fromScale(.5,.5),
							BackgroundTransparency = 1,
							[Roact.Event.MouseButton1Down] = function(element)
								if (not situation)  then
									situation = self.item.Name
									print("Pendant la situation")
									PromiseToReview = self:GetSituation()
								elseif (situation ~= nil) then
									print("Fin de situation")
									situation = false
									PromiseToReview:cancel()
								end
							end,
						})
					})
				})
			end
		end
		
		local function changeToNewParent()
			local instance = self.item:Clone()
			if (instance) then 
				instance.Parent = backpack 
				self.folderItem[self.item.Name] = Roact.mount(Roact.createElement(createElement),stgs.GuiToParent,self.item.Name)
			end
		end	
		
		changeToNewParent()
	end)
end

function Item:GetSituation()
	local uiInventory = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("coutainer")
	local frameInventory = uiInventory:WaitForChild("Items")
	
	if (self.item.Name) then
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
						Text = "Voulez vous ajoutez l'item à votre inventaire : ("..tostring(self.item.Name)..") ?",
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
							Text = "Equipé ?",
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
								self:AddedToSpecificUser(self.item.Name)
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
							Text = "Supprimé ?",
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
				else
					return reject()
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

function Item:AddedToSpecificUser()
	print("Envoie de la fonction.")
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	if table.find(self.backpack,self.item.Name) ~= nil then return warn("Objet déjà trouvé dans la table d'inventaire, nouveau message envoié.") end
	table.insert(self.backpack,self.item.Name)
	self:CancelPromiseReview()
	
	local function screenOnPurchase()
		local ui = playerGui:FindFirstChild("RequestSend")
		if (ui) then
			return Promise.new(function(resolve,reject,OnCancel)
				local templateToMove = script:WaitForChild("template"):Clone()
				templateToMove.Parent = ui
				templateToMove.Name = self.item.Name
				templateToMove.ZIndex = 10
				templateToMove:WaitForChild("requestText").Text = "Item équipé".." ("..self.item.Name..")"
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
	return self.Knit:ReceivedAddedItems(self.item.Name)
end

function Item:RemovedFromUser()
	local uiInventory = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainRequirementUi"):WaitForChild("coutainer")
	local frameInventory = uiInventory:WaitForChild("Items")
	local itemsParent = frameInventory:WaitForChild("inventory"):WaitForChild("TitlesInventory")
	
	local player = Players.LocalPlayer
	local Character = player.Character or player.CharacterAdded:Wait()
	local backpack = player:WaitForChild("Backpack")	
	
	if (table.find(self.backpack,self.item.Name)) and table.find(self.folderItem,self.item) then 
		table.remove(self.backpack,table.find(self.backpack,self.item.Name)) 
		table.remove(self.folderItem,table.find(self.folderItem,self.item))
	elseif table.find(self.folderItem,self.item) then
		table.remove(self.folderItem,table.find(self.folderItem,self.item))
	end
	
	if (self.folderItem[self.item.Name]) then
		local roactMounted = self.folderItem[self.item.Name]
		Roact.unmount(roactMounted) 
		self.folderItem[self.item.Name] = nil
		roactMounted = nil
	end
	
	self.Knit:RemoveObject(self.item.Name)
	self:CancelPromiseReview()	
	return self
end



Item.Folder = script:WaitForChild("Items")

Item.textures = {ImagesId = {
	Flashlight = "rbxassetid://11697193612"	,
	ClassicSword = "rbxassetid://9695653110"
}}


return Item
