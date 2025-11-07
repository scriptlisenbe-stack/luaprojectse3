--// LocalScript - Item Giver (Client-side, multiple ID compatible)

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ItemGiver"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 160)
Frame.Position = UDim2.new(0.5, -130, 0.5, -80)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Draggable
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		update(input)
	end
end)

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "Item Giver"
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 22
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Frame

-- Close button
local Close = Instance.new("TextButton")
Close.Text = "X"
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 20
Close.Parent = Frame

Close.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Text box
local TextBox = Instance.new("TextBox")
TextBox.PlaceholderText = "Enter one or more IDs (use : to separate)"
TextBox.Size = UDim2.new(1, -20, 0, 35)
TextBox.Position = UDim2.new(0, 10, 0, 50)
TextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Font = Enum.Font.SourceSans
TextBox.TextSize = 18
TextBox.Parent = Frame

-- Get button
local Button = Instance.new("TextButton")
Button.Text = "Get"
Button.Size = UDim2.new(1, -20, 0, 35)
Button.Position = UDim2.new(0, 10, 0, 95)
Button.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 20
Button.Parent = Frame

-- Function to split text by :
local function split(str, sep)
	local result = {}
	for s in string.gmatch(str, "([^"..sep.."]+)") do
		table.insert(result, s)
	end
	return result
end

-- Load items by ID
Button.MouseButton1Click:Connect(function()
	local text = TextBox.Text
	if text == "" then return end
	
	local ids = split(text, ":") -- split by :

	for _, idText in ipairs(ids) do
		local id = tonumber(idText)
		if id then
			local success, model = pcall(function()
				return game:GetObjects("rbxassetid://" .. id)[1]
			end)
			
			if success and model then
				model.Parent = player.Backpack
				print("Added item with ID:", id)
			else
				warn("Could not load item with ID: " .. idText)
			end
		else
			warn("Invalid ID: " .. tostring(idText))
		end
	end
end)