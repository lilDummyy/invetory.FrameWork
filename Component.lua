--[[
@Dummy
Crée le 25/09/23

Component , inventaire + dataStorageKey (client side)
]] 

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)
local Signal = require(Knit.Util.Signal)
local Option = require(Knit.Util.Option)
local Roact = require(Knit.Util.Roact)
local RunService = game:GetService("RunService")


local Component = {}
Component.__index = Component

function Component.new()
	local self = setmetatable({},Component)
	self._Comms = {}
	return self
end

function Component:AddTopBar(tbl : {},obj)
	if type(tbl) ~= "table" then return end
	if tbl["item"] == nil then
		tbl["item"] = obj
	end
	local function updateTbl()
		if (table.find(self._Comms,tbl["item"])) then
			return warn("not updated")
		end	
		table.insert(self._Comms,tbl["item"])
		return self._Comms
	end
	local function addRoact_barElement()
		return Roact.createElement("Frame",{
			Size = UDim2.fromScale(0.1,0.8),
			AnchorPoint = Vector2.new(.5,.5),
			BackgroundTransparency = 0.15,
			[Roact.Event.MouseEnter] = function(element)
				if (Players.LocalPlayer:WaitForChild("PlayerGui").InventoryScreen.Selectable.Value) == "" then 
					TweenService:Create(element.UIStroke,TweenInfo.new(.15),{Transparency = 0,Thickness = 2.5}):Play()
					TweenService:Create(element.UIScale,TweenInfo.new(.15),{Scale = .95}):Play()
					TweenService:Create(element.CurrentItem.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
				end
			end,
			[Roact.Event.MouseLeave] = function(element)
				if (Players.LocalPlayer:WaitForChild("PlayerGui").InventoryScreen.Selectable.Value) == "" then 
					TweenService:Create(element.UIStroke,TweenInfo.new(.15),{Transparency = 1,Thickness = 1}):Play()
					TweenService:Create(element.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
					TweenService:Create(element.CurrentItem.UIScale,TweenInfo.new(.15),{Scale = 0}):Play()
				end
			end,
			BackgroundColor3 = Color3.fromRGB(22,22,22)
		},{
			UICorner = Roact.createElement("UICorner"),
			UIScale = Roact.createElement("UIScale"),
			CurrentItem = Roact.createElement("Frame",{
				AnchorPoint = Vector2.new(.5,.5),
				Size = UDim2.fromScale(1.2,.35),
				BackgroundTransparency = .15,
				Position = UDim2.fromScale(.5,-.35),
				BackgroundColor3 = Color3.fromRGB(22,22,22)
			},{
				itemName = Roact.createElement("TextLabel",{
					Size = UDim2.fromScale(.8,.8),
					Text = tostring(tbl["item"]),
					AnchorPoint = Vector2.new(.5,.5),
					TextScaled = true,
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(.5,.5),
					TextColor3 = Color3.fromRGB(255,255,255),
				}),
				UIScale = Roact.createElement("UIScale",{Scale = 0}),
				UICorner = Roact.createElement("UICorner")
			}),
			UIStroke  = Roact.createElement("UIStroke",{Transparency = 1,Color = Color3.fromRGB(85, 170, 255)}),
			_index = Roact.createElement("TextLabel",{
				AnchorPoint = Vector2.new(.5,.5),
				Size = UDim2.fromScale(0.35,0.25),
				TextScaled = true,
				TextColor3 = Color3.fromRGB(255,255,255),
				Text = `{table.find(self._Comms,tbl["item"])}`,
				Position = UDim2.fromScale(0.2,0.15),
				BackgroundTransparency = 1
			},{ UIStroke = Roact.createElement("UIStroke",{Color = Color3.fromRGB(255,255,255)})}),
			_interaction = Roact.createElement("ImageButton",{
				AnchorPoint = Vector2.new(.5,.5),
				Size = UDim2.fromScale(.6,.6),
				Position = UDim2.fromScale(.5,.5),
				BackgroundTransparency = 1,
				Image = tostring(tbl["textures"].ImagesId[tbl["item"]]),
				[Roact.Event.MouseButton1Down] = function(element)
					if (Players.LocalPlayer:WaitForChild("PlayerGui").InventoryScreen.Selectable.Value) == "" then
						TweenService:Create(element.Parent.UIStroke,TweenInfo.new(.15),{Transparency = 0,Thickness = 2.5}):Play()
						TweenService:Create(element.Parent.UIScale,TweenInfo.new(.15),{Scale = .95}):Play()
						Players.LocalPlayer:WaitForChild("PlayerGui").InventoryScreen.Selectable.Value = tostring(tbl["item"])
						script.Parent.__bindable.event:Fire(tostring(tbl["item"]),"Equip")
					else
						TweenService:Create(element.Parent.UIStroke,TweenInfo.new(.15),{Transparency = 1,Thickness = 1}):Play()
						TweenService:Create(element.Parent.UIScale,TweenInfo.new(.15),{Scale = 1}):Play()
						Players.LocalPlayer:WaitForChild("PlayerGui").InventoryScreen.Selectable.Value = ""
						script.Parent.__bindable.event:Fire(tostring(tbl["item"]),"UnEquip")
					end
				end,
			})
		})
	end
	local update_Tbl = updateTbl()
	self._Comms = if type(update_Tbl) == "table" then update_Tbl else "Error"
	script.Parent.__bindable.refreshItem_bar:Fire(Players.LocalPlayer,self._Comms)
	self[tbl["item"]] = Roact.mount(Roact.createElement(addRoact_barElement),Players.LocalPlayer:WaitForChild("PlayerGui").InventoryScreen.coutainer,tostring(tbl["item"]))
	return self
end

function Component:RemoveTopBar(value:string)
	assert(type(value) == "string","passed value must be a stringValue")
	if table.find(self._Comms,value) ~= nil then
		table.remove(self._Comms,table.find(self._Comms,value))
		script.Parent.__bindable.refreshItem_bar:Fire(Players.LocalPlayer,self._Comms,value)
		Roact.unmount(self[value])
		self[value] = nil
	else
		warn("item non trouvé")
	end
	return self
end

return Component
