if getgenv().ZukaLuaHub then
    pcall(function() getgenv().ZukaLuaHub:Destroy() end)
    getgenv().ZukaLuaHub = nil
end

--==============================================================================
-- Services & Setup
--==============================================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local LocalPlayer = Players.LocalPlayer

-- Global state and connections table for proper cleanup
local Connections = {}

--==============================================================================
-- Theme & Style
--==============================================================================
local THEME = {
    Background = Color3.fromRGB(20, 20, 24),
    Window = Color3.fromRGB(28, 28, 30),
    Panel = Color3.fromRGB(30, 30, 34),
    Accent = Color3.fromRGB(75, 145, 255),
    AccentMuted = Color3.fromRGB(70, 110, 210),
    Button = Color3.fromRGB(36, 36, 40),
    ButtonHover = Color3.fromRGB(56, 56, 60),
    Text = Color3.fromRGB(235, 240, 255),
    MutedText = Color3.fromRGB(150, 160, 180),
    Corner = 8,
}

--==============================================================================
-- UI Construction & Helpers
--==============================================================================
local screen = Instance.new("ScreenGui")
screen.Name = "ZukaLuaHub"
screen.ResetOnSpawn = false
getgenv().ZukaLuaHub = screen -- Set global reference

local function notify(title, text, duration)
    pcall(function() game.StarterGui:SetCore("SendNotification", { Title = title, Text = text, Duration = duration or 3 }) end)
end

local function makeUICorner(parent, radius)
    local c = Instance.new("UICorner", parent); c.CornerRadius = UDim.new(0, radius or 6); return c
end

local function makeButton(parent, text, size, pos, callback, isAccent)
    local btn = Instance.new("TextButton", parent)
    btn.Size = size; btn.Position = pos; btn.AutoButtonColor = false
    btn.BackgroundColor3 = isAccent and THEME.Accent or THEME.Button
    btn.TextColor3 = THEME.Text; btn.Font = Enum.Font.Code; btn.TextSize = 14; btn.Text = text
    makeUICorner(btn, math.max(4, THEME.Corner - 2))

    table.insert(Connections, btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = THEME.ButtonHover}):Play() end))
    table.insert(Connections, btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = isAccent and THEME.Accent or THEME.Button}):Play() end))
    table.insert(Connections, btn.MouseButton1Click:Connect(function() pcall(callback, btn) end))
    return btn
end

--==============================================================================
-- Main Window
--==============================================================================
local MainFrame = Instance.new("Frame", screen)
MainFrame.Size = UDim2.new(0, 760, 0, 440)
MainFrame.Position = UDim2.new(0.5, -380, 0.5, -220)
MainFrame.BackgroundColor3 = THEME.Window
MainFrame.BorderSizePixel = 0
makeUICorner(MainFrame, THEME.Corner)
local mainStroke = Instance.new("UIStroke", MainFrame); mainStroke.Color = Color3.fromRGB(10,10,12); mainStroke.Transparency = 0.6

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40); TitleBar.BackgroundColor3 = THEME.Panel; makeUICorner(TitleBar, THEME.Corner)
local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, -180, 1, 0); TitleLabel.Position = UDim2.new(0, 44, 0, 0); TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "ZukaTech v13.3.7"; TitleLabel.Font = Enum.Font.Code; TitleLabel.TextSize = 16; TitleLabel.TextColor3 = THEME.Text; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
local TitleIcon = Instance.new("ImageLabel", TitleBar)
TitleIcon.Size = UDim2.new(0,28,0,28); TitleIcon.Position = UDim2.new(0, 8, 0, 6); TitleIcon.BackgroundTransparency = 1; TitleIcon.Image = "rbxassetid://7072711062"

-- Dragging Logic
do
    local dragging, dragStart, startPos
    table.insert(Connections, TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragStart, startPos = true, input.Position, MainFrame.Position
            local conn; conn = input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false; conn:Disconnect() end end)
        end
    end))
    table.insert(Connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
end

--==============================================================================
-- Tabs & Pages
--==============================================================================
local TabsColumn = Instance.new("Frame", MainFrame)
TabsColumn.Size = UDim2.new(0, 140, 1, -48); TabsColumn.Position = UDim2.new(0, 8, 0, 44); TabsColumn.BackgroundColor3 = THEME.Panel; makeUICorner(TabsColumn, THEME.Corner)
local tabsLayout = Instance.new("UIListLayout", TabsColumn); tabsLayout.Padding = UDim.new(0, 8); tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local PagesArea = Instance.new("Frame", MainFrame)
PagesArea.Size = UDim2.new(1, -164, 1, -48); PagesArea.Position = UDim2.new(0, 156, 0, 44); PagesArea.BackgroundTransparency = 1

local pages = {}
local function createPage(name)
    local p = Instance.new("Frame", PagesArea); p.Name = name; p.Size = UDim2.new(1,0,1,0); p.BackgroundTransparency = 1; p.Visible = false
    pages[name] = p; return p
end

local EditorPage = createPage("Editor")
local RageBotPage = createPage("Rage Bot")

local function switchPage(name)
    for k,v in pairs(pages) do v.Visible = (k == name) end
    for _, child in pairs(TabsColumn:GetChildren()) do
        if child:IsA("TextButton") then
            local isTarget = child.Name == (name .. "_Tab")
            TweenService:Create(child, TweenInfo.new(0.2), {BackgroundColor3 = isTarget and THEME.AccentMuted or THEME.Button}):Play()
        end
    end
end

local function makeTab(name)
    local btn = makeButton(TabsColumn, name, UDim2.new(1, -16, 0, 40), UDim2.new(), function() switchPage(name) end)
    btn.Name = name .. "_Tab"; btn.LayoutOrder = #TabsColumn:GetChildren()
    return btn
end

makeTab("Editor")
makeTab("Rage Bot")

--==============================================================================
-- Editor Page
--==============================================================================
do
    local editorBack = Instance.new("Frame", EditorPage); editorBack.Size = UDim2.new(1, 0, 1, 0); editorBack.BackgroundColor3 = THEME.Background; makeUICorner(editorBack, THEME.Corner)
    local gutter = Instance.new("TextLabel", editorBack); gutter.Size = UDim2.new(0,44,1,-50); gutter.BackgroundColor3 = THEME.Panel; gutter.TextColor3 = THEME.MutedText; gutter.Font = Enum.Font.Code; gutter.TextSize = 14; gutter.TextXAlignment = Enum.TextXAlignment.Right; gutter.TextYAlignment = Enum.TextYAlignment.Top; gutter.Text = "1"; gutter.ClipsDescendants = true
    local scroller = Instance.new("ScrollingFrame", editorBack); scroller.Size = UDim2.new(1, -44, 1, -50); scroller.Position = UDim2.new(0, 44, 0, 0); scroller.CanvasSize = UDim2.new(0,0,0,0); scroller.ScrollBarThickness = 6; scroller.BackgroundColor3 = THEME.Background; scroller.BorderSizePixel = 0; scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local textBox = Instance.new("TextBox", scroller); textBox.Size = UDim2.new(1, 0, 1, 0); textBox.MultiLine = true; textBox.ClearTextOnFocus = false; textBox.TextXAlignment = Enum.TextXAlignment.Left; textBox.TextYAlignment = Enum.TextYAlignment.Top; textBox.Font = Enum.Font.Code; textBox.TextSize = 15; textBox.TextColor3 = THEME.Text; textBox.Text = "-- ZukaTech Editor --\n"; textBox.BackgroundTransparency = 1
    
    table.insert(Connections, scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(function() gutter.Position = UDim2.new(0,0,0,-scroller.CanvasPosition.Y) end))
    table.insert(Connections, textBox:GetPropertyChangedSignal("Text"):Connect(function()
        local lines = select(2, textBox.Text:gsub("\n","")) + 1
        local lineNumbers = {}; for i = 1, lines do table.insert(lineNumbers, tostring(i)) end
        gutter.Text = table.concat(lineNumbers, "\n")
    end))
    
    local bar = Instance.new("Frame", editorBack); bar.Size = UDim2.new(1,0,0,50); bar.Position = UDim2.new(0,0,1,-50); bar.BackgroundColor3 = THEME.Panel
    makeButton(bar, "Run", UDim2.new(0,120,0,34), UDim2.new(0,10,0,8), function()
        local func, err = pcall(loadstring, textBox.Text)
        if func and not err then pcall(func) else notify("Editor", "Compile error: "..tostring(err), 4) end
    end, true)
    makeButton(bar, "Clear", UDim2.new(0,120,0,34), UDim2.new(0,140,0,8), function() textBox.Text = "" end)
    makeButton(bar, "Save", UDim2.new(0,120,0,34), UDim2.new(0,270,0,8), function()
        if writefile then pcall(writefile, "ZukaHubScript.lua", textBox.Text); notify("Editor", "Saved", 2) else notify("Editor", "writefile not supported", 3) end
    end)
    makeButton(bar, "Load", UDim2.new(0,120,0,34), UDim2.new(0,400,0,8), function()
        if readfile and isfile and isfile("ZukaHubScript.lua") then local ok,c = pcall(readfile, "ZukaHubScript.lua"); if ok then textBox.Text = c; notify("Editor","Loaded",2) end else notify("Editor","No saved file",3) end
    end)
end

--==============================================================================
-- Rage Bot Page
--==============================================================================
do
    local page = RageBotPage; local selectedPlayer = nil; local rageEnabled = false; local autoCycleEnabled = false; local ignoreSpawnForce = false; local cycleInterval = 4; local hoverDist = 6; local cycleElapsed = 0
    local title = Instance.new("TextLabel", page); title.Size = UDim2.new(1, -20, 0, 36); title.Position = UDim2.new(0, 10, 0, 10); title.BackgroundTransparency = 1; title.TextColor3 = Color3.fromRGB(255,90,90); title.Font = Enum.Font.Code; title.TextSize = 22; title.Text = "Rage Bot (PvP Autofarm)"; title.TextXAlignment = Enum.TextXAlignment.Left
    
    local playerDropdown = makeButton(page, "Select Player", UDim2.new(0, 180, 0, 28), UDim2.new(0, 20, 0, 90), function()
        local players = {}; for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(players, p) end end
        if #players == 0 then return end
        local currentIdx = 0; for i,p in ipairs(players) do if p == selectedPlayer then currentIdx = i end end
        local nextIdx = currentIdx + 1; if nextIdx > #players then nextIdx = 1 end
        selectedPlayer = players[nextIdx]; playerDropdown.Text = selectedPlayer.Name
    end)
    
    local rageToggle = makeButton(page, "Rage Bot: OFF", UDim2.new(0, 160, 0, 32), UDim2.new(0, 20, 0, 130), function(btn)
        rageEnabled = not rageEnabled; btn.Text = "Rage Bot: " .. (rageEnabled and "ON" or "OFF")
    end, rageEnabled)

    local autoCycleToggle = makeButton(page, "Auto Cycle: OFF", UDim2.new(0, 160, 0, 32), UDim2.new(0, 200, 0, 130), function(btn)
        autoCycleEnabled = not autoCycleEnabled; btn.Text = "Auto Cycle: " .. (autoCycleEnabled and "ON" or "OFF")
    end, autoCycleEnabled)

    local function playerHasSpawnForce(plr)
        if not plr or not plr.Character then return false end
        if plr.Character:FindFirstChildOfClass("ForceField") then return true end
        return false -- simplified check
    end

    table.insert(Connections, RunService.Heartbeat:Connect(function(dt)
        if autoCycleEnabled then
            cycleElapsed = cycleElapsed + dt
            if cycleElapsed >= cycleInterval then
                cycleElapsed = 0
                local validTargets = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and (not ignoreSpawnForce or not playerHasSpawnForce(p)) then table.insert(validTargets, p) end
                end
                if #validTargets > 0 then
                    local currentIdx = 0; for i,p in ipairs(validTargets) do if p == selectedPlayer then currentIdx = i end end
                    local nextIdx = currentIdx + 1; if nextIdx > #validTargets then nextIdx = 1 end
                    selectedPlayer = validTargets[nextIdx]; playerDropdown.Text = selectedPlayer.Name
                end
            end
        end
        if rageEnabled and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChildOfClass("Humanoid").Health > 0 then
                local targetHRP = selectedPlayer.Character.HumanoidRootPart; local myHRP = myChar.HumanoidRootPart
                local backVec = targetHRP.CFrame.LookVector * -hoverDist
                myHRP.CFrame = CFrame.new(targetHRP.Position + backVec, targetHRP.Position)
                local tool = myChar:FindFirstChildOfClass("Tool"); if tool and tool:FindFirstChild("Handle") then pcall(function() tool:Activate() end) end
            end
        end
    end))
end

--==============================================================================
-- Window Controls & Cleanup
--==============================================================================
local function cleanupAll()
    for _, conn in ipairs(Connections) do pcall(function() conn:Disconnect() end) end
    Connections = {}
end

local CloseBtn = makeButton(TitleBar, "X", UDim2.new(0,40,1,-12), UDim2.new(1,-50,0,6), function()
    cleanupAll()
    if getgenv().ZukaLuaHub then pcall(function() getgenv().ZukaLuaHub:Destroy() end); getgenv().ZukaLuaHub = nil end
end)

local minimized = false; local originalSize
local MinBtn = makeButton(TitleBar, "-", UDim2.new(0,40,1,-12), UDim2.new(1,-95,0,6), function()
    minimized = not minimized
    if minimized then
        originalSize = MainFrame.Size
        PagesArea.Visible = false; TabsColumn.Visible = false; MinBtn.Text = "+"
        TweenService:Create(MainFrame, TweenInfo.new(0.22), {Size = UDim2.new(0, 320, 0, 40)}):Play()
    else
        PagesArea.Visible = true; TabsColumn.Visible = true; MinBtn.Text = "-"
        TweenService:Create(MainFrame, TweenInfo.new(0.22), {Size = originalSize}):Play()
    end
end)

--==============================================================================
-- Finalization
--==============================================================================
screen.Parent = CoreGui
switchPage("Editor")
notify("Executor", "Loaded - We're So Back.", 3)
