-- === Secure Access Code Prompt ===
local ACCESS_CODES = {
    ["root"] = true, -- Replace with your code
    ["root"] = true,  -- Add more codes for friends
    ["root"] = true
}
local function showAccessPrompt()
    local sg = Instance.new("ScreenGui")
    sg.Name = "ZukaAccessPrompt"
    sg.ResetOnSpawn = false
    sg.Parent = game.CoreGui
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 340, 0, 140)
    frame.Position = UDim2.new(0.5, -170, 0.5, -70)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,40)
    frame.BorderSizePixel = 0
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 10)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -24, 0, 36)
    label.Position = UDim2.new(0, 12, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = "Developer Key"
    label.Font = Enum.Font.Code
    label.TextSize = 18
    label.TextColor3 = Color3.fromRGB(200,220,255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(1, -24, 0, 36)
    box.Position = UDim2.new(0, 12, 0, 56)
    box.BackgroundColor3 = Color3.fromRGB(40,40,60)
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Font = Enum.Font.Code
    box.TextSize = 18
    box.PlaceholderText = "Enter Key.."
    box.Text = ""
    local okBtn = Instance.new("TextButton", frame)
    okBtn.Size = UDim2.new(0, 120, 0, 32)
    okBtn.Position = UDim2.new(1, -132, 1, -42)
    okBtn.BackgroundColor3 = Color3.fromRGB(60,120,200)
    okBtn.TextColor3 = Color3.fromRGB(255,255,255)
    okBtn.Font = Enum.Font.Code
    okBtn.TextSize = 16
    okBtn.Text = "Enter"
    local okCorner = Instance.new("UICorner", okBtn)
    okCorner.CornerRadius = UDim.new(0, 6)
    local result = Instance.new("TextLabel", frame)
    result.Size = UDim2.new(1, -24, 0, 20)
    result.Position = UDim2.new(0, 12, 1, -20)
    result.BackgroundTransparency = 1
    result.Text = ""
    result.Font = Enum.Font.Code
    result.TextSize = 14
    result.TextColor3 = Color3.fromRGB(255,80,80)
    result.TextXAlignment = Enum.TextXAlignment.Left
    local accessGranted = false
    local function tryAccess()
        local code = box.Text
        if ACCESS_CODES[code] then
            accessGranted = true
            sg:Destroy()
        else
            result.Text = "Wrong code. Try again."
        end
    end
    okBtn.MouseButton1Click:Connect(tryAccess)
    box.FocusLost:Connect(function(enter)
        if enter then tryAccess() end
    end)
    repeat wait() until accessGranted
end

showAccessPrompt()

if getgenv().ZukaLuaHub then
    pcall(function() getgenv().ZukaLuaHub:Destroy() end)
    getgenv().ZukaLuaHub = nil
end

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Simple notify helper
local function notify(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

-- Create ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "ZukaLuaHub"
screen.ResetOnSpawn = false
screen.Parent = game.CoreGui
getgenv().ZukaLuaHub = screen

-- Helpers: styling & tween
local function makeUICorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 6)
    return c
end
local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end
local function makeButton(parent, text, size, pos, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Code
    btn.TextSize = 14
    btn.Text = text
    makeUICorner(btn, 6)
    btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = Color3.fromRGB(65,65,65)}) end)
    btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = Color3.fromRGB(45,45,45)}) end)
    btn.MouseButton1Click:Connect(function() pcall(callback, btn) end)
    return btn
end

-- Main window
local MainFrame = Instance.new("Frame", screen)
MainFrame.Size = UDim2.new(0, 740, 0, 420)
MainFrame.Position = UDim2.new(0.5, -370, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.BackgroundTransparency = 0.13
MainFrame.BorderSizePixel = 0
makeUICorner(MainFrame, 10)

-- Titlebar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(35,35,35)
TitleBar.BackgroundTransparency = 0.16
makeUICorner(TitleBar, 10)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, -160, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Zuka's Hub"
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextSize = 16
TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = makeButton(TitleBar, "Close", UDim2.new(0,70,0,24), UDim2.new(1, -80, 0, 6), function()
    if getgenv().ZukaLuaHub then
        pcall(function() getgenv().ZukaLuaHub:Destroy() end)
        getgenv().ZukaLuaHub = nil
    end
end)
local MinBtn = makeButton(TitleBar, "—", UDim2.new(0,30,0,24), UDim2.new(1, -120, 0, 6), nil)

-- Manual dragging (robust)
do
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Tabs area + pages
local TabsColumn = Instance.new("Frame", MainFrame)
TabsColumn.Size = UDim2.new(0, 120, 1, -36)
TabsColumn.Position = UDim2.new(0, 0, 0, 36)
TabsColumn.BackgroundColor3 = Color3.fromRGB(28,28,28)
TabsColumn.BackgroundTransparency = 0.18
makeUICorner(TabsColumn, 8)

local PagesArea = Instance.new("Frame", MainFrame)
PagesArea.Size = UDim2.new(1, -120, 1, -36)
PagesArea.Position = UDim2.new(0, 120, 0, 36)
PagesArea.BackgroundTransparency = 1

local pages = {}
local function createPage(name)
    local p = Instance.new("Frame", PagesArea)
    p.Name = name .. "Page"
    p.Size = UDim2.new(1,0,1,0)
    p.BackgroundTransparency = 1
    p.Visible = false
    pages[name] = p
    return p
end

local EditorPage = createPage("Editor")
local CommandsPage = createPage("Commands")
local SpecialPage = createPage("Special")
local InfoPage = createPage("Info")
local AimbotPage = createPage("Aimbot")
local RageBotPage = createPage("Rage Bot")
local ZukaBotPage = createPage("Zuka Bot")

-- Tab helper
local function switchPage(name)
    for k,v in pairs(pages) do v.Visible = (k == name) end
    for _, child in pairs(TabsColumn:GetChildren()) do
        if child:IsA("TextButton") then child.BackgroundColor3 = Color3.fromRGB(45,45,45) end
    end
    local tabBtn = TabsColumn:FindFirstChild(name .. "_Tab")
    if tabBtn then tabBtn.BackgroundColor3 = Color3.fromRGB(80,80,80) end
end

local function makeTab(name, y)
    local btn = makeButton(TabsColumn, name, UDim2.new(1, -16, 0, 44), UDim2.new(0, 8, 0, y), function() switchPage(name) end)
    btn.Name = name .. "_Tab"
    return btn
end

makeTab("Editor", 12)
makeTab("Commands", 12 + 44 + 6)
makeTab("Special", 12 + 2 * (44 + 6))
makeTab("Info", 12 + 3 * (44 + 6))
makeTab("Aimbot", 12 + 4 * (44 + 6))
makeTab("Rage Bot", 12 + 5 * (44 + 6))
makeTab("Zuka Bot", 12 + 6 * (44 + 6))


-- ========== Zuka Bot Page (V2 - Annoy Edition) ========== 
do
    -- Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    -- Bot State
    local currentMode = "None" -- "None", "Follow", "Attach", "Mimic"
    local currentTarget = nil -- The selected Player object
    local activeConnections = {}
    local activeWeld = nil
    
    local page = ZukaBotPage -- Use the already created page
    
    -- Cleanup function to stop all active processes
    local function cleanup()
        for _, conn in ipairs(activeConnections) do conn:Disconnect() end
        table.clear(activeConnections)
        
        if activeWeld then
            activeWeld:Destroy()
            activeWeld = nil
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.AutoRotate = true
        end
    end
    
    -- UI Elements
    local title = Instance.new("TextLabel", page); title.Size = UDim2.new(1, -20, 0, 36); title.Position = UDim2.new(0, 10, 0, 10); title.BackgroundTransparency = 1; title.TextColor3 = Color3.fromRGB(120,200,255); title.Font = Enum.Font.Code; title.TextSize = 22; title.Text = "Zuka's Annoy Bot"; title.TextXAlignment = Enum.TextXAlignment.Left
    local statusLabel = Instance.new("TextLabel", page); statusLabel.Size = UDim2.new(1, -20, 0, 22); statusLabel.Position = UDim2.new(0, 10, 0, 50); statusLabel.BackgroundTransparency = 1; statusLabel.TextColor3 = Color3.fromRGB(180,220,255); statusLabel.Font = Enum.Font.Code; statusLabel.TextSize = 15; statusLabel.Text = "Target: None | Mode: None"; statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    local leftColumn = Instance.new("Frame", page); leftColumn.Size = UDim2.new(0.5, -15, 1, -80); leftColumn.Position = UDim2.new(0, 10, 0, 80); leftColumn.BackgroundTransparency = 1
    local rightColumn = Instance.new("Frame", page); rightColumn.Size = UDim2.new(0.5, -15, 1, -80); rightColumn.Position = UDim2.new(0.5, 5, 0, 80); rightColumn.BackgroundTransparency = 1
    local controlsHolder = Instance.new("Frame", leftColumn); controlsHolder.Size = UDim2.new(1,0,1,0); controlsHolder.BackgroundTransparency = 1
    local controlsLayout = Instance.new("UIListLayout", controlsHolder); controlsLayout.Padding = UDim.new(0, 8)
    local playerListTitle = Instance.new("TextLabel", rightColumn); playerListTitle.Size = UDim2.new(1, 0, 0, 20); playerListTitle.BackgroundTransparency = 1; playerListTitle.Font = Enum.Font.Code; playerListTitle.TextColor3 = Color3.fromRGB(220, 220, 230); playerListTitle.Text = "Select a Player:"; playerListTitle.TextSize = 14; playerListTitle.TextXAlignment = Enum.TextXAlignment.Left
    local playerListFrame = Instance.new("ScrollingFrame", rightColumn); playerListFrame.Size = UDim2.new(1, 0, 1, -55); playerListFrame.Position = UDim2.new(0, 0, 0, 25); playerListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40); playerListFrame.BorderSizePixel = 0; playerListFrame.ScrollBarThickness = 6; makeUICorner(playerListFrame, 6)
    local playerListLayout = Instance.new("UIListLayout", playerListFrame); playerListLayout.Padding = UDim.new(0, 5); playerListLayout.SortOrder = Enum.SortOrder.Name
    local refreshBtn = Instance.new("TextButton", rightColumn); refreshBtn.Size = UDim2.new(1, 0, 0, 25); refreshBtn.Position = UDim2.new(0, 0, 1, -25); refreshBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100); refreshBtn.TextColor3 = Color3.white; refreshBtn.Font = Enum.Font.Code; refreshBtn.Text = "Refresh List"; refreshBtn.TextSize = 14; makeUICorner(refreshBtn, 6)
    
    local function setMode(newMode)
        cleanup()
        if newMode ~= "None" and not currentTarget then
            notify("Zuka Bot", "Please select a target first!", 3)
            return
        end
        currentMode = newMode
        statusLabel.Text = "Target: " .. (currentTarget and currentTarget.Name or "None") .. " | Mode: " .. currentMode
        if newMode == "Follow" then
            local followDist = 7.5
            table.insert(activeConnections, RunService.RenderStepped:Connect(function()
                if not (currentTarget and currentTarget.Character) then return setMode("None") end
                local myChar = LocalPlayer.Character
                local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
                if myHumanoid and myHumanoid.Health > 0 then
                    local targetHRP = currentTarget.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP and (targetHRP.Position - myChar.HumanoidRootPart.Position).Magnitude > followDist then
                        myHumanoid:MoveTo(targetHRP.Position)
                    end
                end
            end))
        elseif newMode == "Attach" then
            local myChar = LocalPlayer.Character
            local targetChar = currentTarget.Character
            if not (myChar and targetChar and myChar:FindFirstChild("HumanoidRootPart") and targetChar:FindFirstChild("HumanoidRootPart")) then
                notify("Zuka Bot", "Characters not ready for attachment.", 3)
                return setMode("None")
            end
            local myHRP = myChar.HumanoidRootPart
            local targetHRP = targetChar.HumanoidRootPart
            myChar.Humanoid.AutoRotate = false
            activeWeld = Instance.new("Weld"); activeWeld.Part0 = myHRP; activeWeld.Part1 = targetHRP; activeWeld.C1 = CFrame.new(0, 0, -3); activeWeld.Parent = myHRP
            notify("Zuka Bot", "Attached to " .. currentTarget.Name, 3)
        elseif newMode == "Mimic" then
            if currentTarget.Character and currentTarget.Character:FindFirstChildOfClass("Humanoid") then
                table.insert(activeConnections, currentTarget.Character.Humanoid.AnimationPlayed:Connect(function(animTrack)
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                        local myAnim = LocalPlayer.Character.Humanoid:LoadAnimation(animTrack.Animation)
                        myAnim:Play(nil, nil, animTrack.Speed)
                    end
                end))
            end
            table.insert(activeConnections, Players.PlayerChatted:Connect(function(player, message)
                if player == currentTarget then
                    task.wait(0.5)
                    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
                end
            end))
            notify("Zuka Bot", "Now mimicking " .. currentTarget.Name, 3)
        end
    end

    local function updateSelectionVisuals()
        for _, button in ipairs(playerListFrame:GetChildren()) do
            if button:IsA("TextButton") then
                button.BackgroundColor3 = (currentTarget and button.Name == currentTarget.Name) and Color3.fromRGB(80, 140, 220) or Color3.fromRGB(50, 50, 65)
            end
        end
    end
    local function populatePlayerList()
        for _, child in ipairs(playerListFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local playerBtn = Instance.new("TextButton"); playerBtn.Name = player.Name; playerBtn.Parent = playerListFrame; playerBtn.Size = UDim2.new(1, -10, 0, 28); playerBtn.LayoutOrder = player.Name; playerBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65); playerBtn.TextColor3 = Color3.white; playerBtn.Font = Enum.Font.Code; playerBtn.TextSize = 14; playerBtn.Text = player.DisplayName .. " (@" .. player.Name .. ")"; makeUICorner(playerBtn, 4)
                playerBtn.MouseButton1Click:Connect(function()
                    currentTarget = player; statusLabel.Text = "Target: " .. player.Name .. " | Mode: " .. currentMode; updateSelectionVisuals(); notify("Zuka Bot", "Target set to " .. player.Name, 2)
                end)
            end
        end
        updateSelectionVisuals()
    end
    refreshBtn.MouseButton1Click:Connect(populatePlayerList)
    local function createModeButton(text, mode, color)
        local btn = Instance.new("TextButton", controlsHolder); btn.Size = UDim2.new(1, 0, 0, 32); btn.BackgroundColor3 = color; btn.TextColor3 = Color3.white; btn.Font = Enum.Font.Code; btn.TextSize = 16; btn.Text = text; makeUICorner(btn, 6); btn.MouseButton1Click:Connect(function() setMode(mode) end)
    end
    createModeButton("Follow Target", "Follow", Color3.fromRGB(60,120,200)); createModeButton("Attach to Target", "Attach", Color3.fromRGB(200, 100, 40)); createModeButton("Mimic Target", "Mimic", Color3.fromRGB(150, 60, 200)); createModeButton("Stop Action", "None", Color3.fromRGB(200, 50, 50))
    Players.PlayerAdded:Connect(populatePlayerList)
    Players.PlayerRemoving:Connect(function(player)
        if player == currentTarget then
            currentTarget = nil; setMode("None"); notify("Zuka Bot", "Target left, all actions stopped.", 3)
        end
        task.wait(0.1); populatePlayerList()
    end)
    populatePlayerList()
end

-- ========== Rage Bot Page ========== 
do
    local page = RageBotPage
    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1, -20, 0, 36); title.Position = UDim2.new(0, 10, 0, 10); title.BackgroundTransparency = 1; title.TextColor3 = Color3.fromRGB(255,80,80); title.Font = Enum.Font.Code; title.TextSize = 22; title.Text = "Rage Bot"; title.TextXAlignment = Enum.TextXAlignment.Left
    local desc = Instance.new("TextLabel", page)
    desc.Size = UDim2.new(1, -20, 0, 22); desc.Position = UDim2.new(0, 10, 0, 50); desc.BackgroundTransparency = 1; desc.TextColor3 = Color3.fromRGB(220,180,180); desc.Font = Enum.Font.Code; desc.TextSize = 15; desc.Text = "Automatically hovers behind and attacks the noob selected."; desc.TextXAlignment = Enum.TextXAlignment.Left

    local playerListLabel = Instance.new("TextLabel", page); playerListLabel.Size = UDim2.new(0, 120, 0, 22); playerListLabel.Position = UDim2.new(0, 20, 0, 90); playerListLabel.BackgroundTransparency = 1; playerListLabel.Text = "Player List:"; playerListLabel.TextColor3 = Color3.fromRGB(255,180,180); playerListLabel.Font = Enum.Font.Code; playerListLabel.TextSize = 15; playerListLabel.TextXAlignment = Enum.TextXAlignment.Left
    local playerDropdown = Instance.new("TextButton", page); playerDropdown.Size = UDim2.new(0, 180, 0, 28); playerDropdown.Position = UDim2.new(0, 140, 0, 90); playerDropdown.BackgroundColor3 = Color3.fromRGB(40,40,40); playerDropdown.TextColor3 = Color3.fromRGB(255,255,255); playerDropdown.Font = Enum.Font.Code; playerDropdown.TextSize = 15; playerDropdown.Text = "Select Player"; makeUICorner(playerDropdown, 6)
    local selectedPlayer = nil
    local function refreshPlayerList()
        local names = {}
        for _,plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then table.insert(names, plr.Name) end end
        playerDropdown.Text = #names > 0 and ("Select Player: "..names[1]) or "No Players"
        selectedPlayer = #names > 0 and Players:FindFirstChild(names[1]) or nil
        if not playerDropdown.MouseButton1Click:is_a("RBXScriptConnection") then
            playerDropdown.MouseButton1Click:Connect(function()
                local idx = table.find(names, selectedPlayer and selectedPlayer.Name or "") or 1
                idx = idx + 1; if idx > #names then idx = 1 end
                selectedPlayer = Players:FindFirstChild(names[idx])
                playerDropdown.Text = selectedPlayer and ("Select Player: "..selectedPlayer.Name) or "No Players"
            end)
        end
    end
    refreshPlayerList(); Players.PlayerAdded:Connect(refreshPlayerList); Players.PlayerRemoving:Connect(refreshPlayerList)

    local rageToggle = Instance.new("TextButton", page); rageToggle.Size = UDim2.new(0, 160, 0, 32); rageToggle.Position = UDim2.new(0, 20, 0, 130); rageToggle.BackgroundColor3 = Color3.fromRGB(40,40,40); rageToggle.TextColor3 = Color3.fromRGB(255,255,255); rageToggle.Font = Enum.Font.Code; rageToggle.TextSize = 16; rageToggle.Text = "Rage Bot: OFF"; makeUICorner(rageToggle, 6)
    local rageEnabled = false
    rageToggle.MouseButton1Click:Connect(function() rageEnabled = not rageEnabled; rageToggle.Text = "Rage Bot: " .. (rageEnabled and "ON" or "OFF") end)

    local hoverLabel = Instance.new("TextLabel", page); hoverLabel.Size = UDim2.new(0, 120, 0, 22); hoverLabel.Position = UDim2.new(0, 20, 0, 170); hoverLabel.BackgroundTransparency = 1; hoverLabel.Text = "Hover Distance:"; hoverLabel.TextColor3 = Color3.fromRGB(255,180,180); hoverLabel.Font = Enum.Font.Code; hoverLabel.TextSize = 15; hoverLabel.TextXAlignment = Enum.TextXAlignment.Left
    local hoverBox = Instance.new("TextBox", page); hoverBox.Size = UDim2.new(0, 80, 0, 22); hoverBox.Position = UDim2.new(0, 140, 0, 170); hoverBox.BackgroundColor3 = Color3.fromRGB(40,40,40); hoverBox.TextColor3 = Color3.fromRGB(255,255,255); hoverBox.Font = Enum.Font.Code; hoverBox.TextSize = 15; hoverBox.Text = "6"; makeUICorner(hoverBox, 6)
    local hoverDist = 6
    hoverBox.FocusLost:Connect(function() local val = tonumber(hoverBox.Text); if val and val >= 2 and val <= 20 then hoverDist = val end; hoverBox.Text = tostring(hoverDist) end)

    RunService.RenderStepped:Connect(function()
        if rageEnabled and selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("Humanoid") and myChar.Humanoid.Health > 0 then
                local targetHRP = selectedPlayer.Character.HumanoidRootPart
                local myHRP = myChar.HumanoidRootPart
                local backVec = -targetHRP.CFrame.LookVector * hoverDist
                myHRP.CFrame = CFrame.new(targetHRP.Position + backVec, targetHRP.Position)
                myHRP.CFrame = CFrame.new(myHRP.Position, targetHRP.Position)
                local tool = myChar:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then pcall(function() tool:Activate() end) end
            end
        end
    end)
end

-- ========== Aimbot Page ========== 
do
    local page = AimbotPage
    local title = Instance.new("TextLabel", page); title.Size = UDim2.new(1, -20, 0, 36); title.Position = UDim2.new(0, 10, 0, 10); title.BackgroundTransparency = 1; title.TextColor3 = Color3.fromRGB(200,220,255); title.Font = Enum.Font.Code; title.TextSize = 22; title.Text = "Aimbot Options"; title.TextXAlignment = Enum.TextXAlignment.Left
    -- Omitted rest of Aimbot for brevity, no changes were needed here. It's the same as your version.
end

-- ========== Editor Page (Optimized) ==========
do
    local Editor = {}
    Editor.lastLineCount = 0
    Editor.needsLayoutUpdate = false
    function Editor:Initialize(parent)
        self.editorBack = Instance.new("Frame", parent); self.editorBack.Size = UDim2.new(1, -20, 1, -20); self.editorBack.Position = UDim2.new(0, 10, 0, 10); self.editorBack.BackgroundColor3 = Color3.fromRGB(18, 18, 22); self.editorBack.ClipsDescendants = true; makeUICorner(self.editorBack, 10)
        self.gutter = Instance.new("TextLabel", self.editorBack); self.gutter.Size = UDim2.new(0, 44, 1, -60); self.gutter.Position = UDim2.new(0, 0, 0, 0); self.gutter.BackgroundColor3 = Color3.fromRGB(24, 24, 32); self.gutter.TextColor3 = Color3.fromRGB(120, 140, 180); self.gutter.Font = Enum.Font.Code; self.gutter.TextSize = 14; self.gutter.TextXAlignment = Enum.TextXAlignment.Right; self.gutter.TextYAlignment = Enum.TextYAlignment.Top; self.gutter.Text = "1"; self.gutter.ClipsDescendants = true; makeUICorner(self.gutter, 6)
        self.scroller = Instance.new("ScrollingFrame", self.editorBack); self.scroller.Size = UDim2.new(1, -58, 1, -60); self.scroller.Position = UDim2.new(0, 50, 0, 0); self.scroller.BackgroundColor3 = Color3.fromRGB(22, 22, 28); self.scroller.BorderSizePixel = 0; self.scroller.ScrollBarThickness = 8
        self.textBox = Instance.new("TextBox", self.scroller); self.textBox.Size = UDim2.new(1, -16, 0, 0); self.textBox.Position = UDim2.new(0, 8, 0, 8); self.textBox.MultiLine = true; self.textBox.ClearTextOnFocus = false; self.textBox.TextXAlignment = Enum.TextXAlignment.Left; self.textBox.TextYAlignment = Enum.TextYAlignment.Top; self.textBox.Font = Enum.Font.Code; self.textBox.TextSize = 15; self.textBox.TextColor3 = Color3.fromRGB(235, 240, 255); self.textBox.PlaceholderText = "paste your epik script here..."; self.textBox.BackgroundTransparency = 1; self.textBox.AutomaticSize = Enum.AutomaticSize.Y; self.textBox.Text = "-- Welcome to Zuka Hub! Optimized Edition."
        
        --[[ BUG FIX: Make the textbox accessible to other pages via the main screen object ]]--
        screen.EditorTextBox = self.textBox

        self.bottomBar = Instance.new("Frame", self.editorBack); self.bottomBar.Size = UDim2.new(1, 0, 0, 50); self.bottomBar.Position = UDim2.new(0, 0, 1, -50); self.bottomBar.BackgroundColor3 = Color3.fromRGB(10, 10, 18); makeUICorner(self.bottomBar, 8)
        self:InitializeButtons(); self:InitializeConnections(); self:InitializeURLPopup(); self:UpdateLayout()
    end
    function Editor:UpdateLayout()
        local lineCount = select(2, self.textBox.Text:gsub("\n", "")) + 1
        if lineCount ~= self.lastLineCount then
            local lineNumbers = table.create(lineCount)
            for i = 1, lineCount do lineNumbers[i] = tostring(i) end
            self.gutter.Text = table.concat(lineNumbers, "\n"); self.lastLineCount = lineCount
        end
        self.scroller.CanvasSize = UDim2.new(0, 0, 0, self.textBox.TextBounds.Y + 28); self.needsLayoutUpdate = false
    end
    function Editor:InitializeConnections()
        self.textBox:GetPropertyChangedSignal("Text"):Connect(function() self.needsLayoutUpdate = true end)
        RunService.RenderStepped:Connect(function() if self.needsLayoutUpdate then self:UpdateLayout() end end)
        self.scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(function() self.gutter.Position = UDim2.new(0, 0, 0, -self.scroller.CanvasPosition.Y) end)
    end
    function Editor:InitializeButtons()
        makeButton(self.bottomBar, "Execute", UDim2.new(0,100,0,34), UDim2.new(0,10,0,8), function() local s,r = pcall(loadstring(self.textBox.Text)); if not s then notify("Zuka Hub","Error: "..tostring(r),4) else local s2,r2=pcall(r); if not s2 then notify("Zuka Hub","Error: "..tostring(r2),4) else notify("Zuka Hub","Executed",2) end end end)
        makeButton(self.bottomBar, "Clear", UDim2.new(0,100,0,34), UDim2.new(0,120,0,8), function() self.textBox.Text = "" end)
    end
    -- Omitted rest of Editor for brevity, no other changes needed.
    Editor:Initialize(EditorPage)
end

-- ========== Info Page (FIXED ScriptBlox Searcher) ==========
do
    local page = InfoPage
    local HttpService = game:GetService("HttpService")

    -- Top section with game info remains the same...
    do
        local infoFrame = Instance.new("Frame", page); infoFrame.Size = UDim2.new(1, -20, 0, 140); infoFrame.Position = UDim2.new(0, 10, 0, 10); infoFrame.BackgroundTransparency = 1
        local title = Instance.new("TextLabel", infoFrame); title.Size = UDim2.new(1, 0, 0, 36); title.BackgroundTransparency = 1; title.TextColor3 = Color3.fromRGB(200, 220, 255); title.Font = Enum.Font.Code; title.TextSize = 22; title.Text = "Game & User Info"; title.TextXAlignment = Enum.TextXAlignment.Left
        local profileLabel = Instance.new("TextLabel", infoFrame); profileLabel.Size = UDim2.new(1, 0, 0, 28); profileLabel.Position = UDim2.new(0, 0, 0, 46); profileLabel.BackgroundTransparency = 1; profileLabel.TextColor3 = Color3.fromRGB(180, 255, 180); profileLabel.Font = Enum.Font.Code; profileLabel.TextSize = 15; profileLabel.TextXAlignment = Enum.TextXAlignment.Left; profileLabel.Text = string.format("User: %s (%s)", LocalPlayer.DisplayName, LocalPlayer.Name)
        local gameLabel = Instance.new("TextLabel", infoFrame); gameLabel.Size = UDim2.new(1, 0, 0, 24); gameLabel.Position = UDim2.new(0, 0, 0, 78); gameLabel.BackgroundTransparency = 1; gameLabel.TextColor3 = Color3.fromRGB(200, 200, 200); gameLabel.Font = Enum.Font.Code; gameLabel.TextSize = 14; gameLabel.TextXAlignment = Enum.TextXAlignment.Left; gameLabel.Text = "PlaceId: " .. tostring(game.PlaceId)
        local jobLabel = Instance.new("TextLabel", infoFrame); jobLabel.Size = UDim2.new(1, 0, 0, 24); jobLabel.Position = UDim2.new(0, 0, 0, 102); jobLabel.BackgroundTransparency = 1; jobLabel.TextColor3 = Color3.fromRGB(200, 200, 200); jobLabel.Font = Enum.Font.Code; jobLabel.TextSize = 14; jobLabel.TextXAlignment = Enum.TextXAlignment.Left; jobLabel.Text = "JobId: " .. tostring(game.JobId):sub(1, 36)
    end

    -- Bottom section with the repaired searcher
    do
        local searchFrame = Instance.new("Frame", page); searchFrame.Size = UDim2.new(1, -20, 1, -160); searchFrame.Position = UDim2.new(0, 10, 0, 150); searchFrame.BackgroundTransparency = 1
        local searchBox = Instance.new("TextBox", searchFrame); searchBox.Size = UDim2.new(1, -130, 0, 34); searchBox.Position = UDim2.new(0, 0, 0, 0); searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60); searchBox.TextColor3 = Color3.fromRGB(255, 255, 255); searchBox.Font = Enum.Font.Code; searchBox.TextSize = 15; searchBox.PlaceholderText = "Search ScriptBlox..."; makeUICorner(searchBox, 6)
        local searchBtn = makeButton(searchFrame, "Search", UDim2.new(0, 120, 0, 34), UDim2.new(1, -120, 0, 0))
        local resultsScroller = Instance.new("ScrollingFrame", searchFrame); resultsScroller.Size = UDim2.new(1, 0, 1, -44); resultsScroller.Position = UDim2.new(0, 0, 0, 44); resultsScroller.BackgroundColor3 = Color3.fromRGB(18, 18, 22); resultsScroller.BorderSizePixel = 0; resultsScroller.ScrollBarThickness = 6; resultsScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y; makeUICorner(resultsScroller, 8)
        local listLayout = Instance.new("UIListLayout", resultsScroller); listLayout.Padding = UDim.new(0, 5)
        local statusLabel = Instance.new("TextLabel", resultsScroller); statusLabel.Size = UDim2.new(1, -20, 0, 30); statusLabel.Position = UDim2.new(0, 10, 0, 10); statusLabel.BackgroundTransparency = 1; statusLabel.Font = Enum.Font.Code; statusLabel.TextSize = 16; statusLabel.TextColor3 = Color3.fromRGB(150, 160, 180); statusLabel.Text = "Search for scripts from ScriptBlox."; statusLabel.TextWrapped = true

        local function executeScript(scriptPath)
            notify("Searcher", "Fetching script...", 2)
            local rawUrl = "https://scriptblox.com" .. scriptPath:gsub("/script/", "/raw/")
            task.spawn(function()
                local success, response = pcall(syn.request, { Url = rawUrl, Method = "GET" })
                if success and response and response.Success and response.Body and response.Body ~= "" then
                    --[[ BUG FIX: Access the textbox through the shared screen object ]]--
                    if screen.EditorTextBox then
                        screen.EditorTextBox.Text = response.Body
                        notify("Searcher", "Script loaded into Editor!", 3)
                        switchPage("Editor")
                    else
                        notify("Searcher", "Error: Editor textbox not found.", 4)
                    end
                else
                    notify("Searcher", "Failed to fetch script content.", 5)
                end
            end)
        end
        
        local function handleSearch()
            local query = searchBox.Text
            if query:gsub("%s*", "") == "" then return notify("Searcher", "Please enter a search term.", 3) end
            
            for _, child in ipairs(resultsScroller:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
            statusLabel.Visible = true; statusLabel.Text = "Searching for '" .. query .. "'..."
            searchBtn.Text = "..."; searchBtn.Active = false

            task.spawn(function()
                local success, response = pcall(syn.request, { Url = "https://scriptblox.com/search?q=" .. HttpService:UrlEncode(query), Method = "GET" })
                searchBtn.Text = "Search"; searchBtn.Active = true

                if not success or not response or not response.Success then
                    statusLabel.Text = "Search failed. Could not contact ScriptBlox."
                    return
                end

                statusLabel.Visible = false
                local resultsFound = 0
                
                --[[ PARSER FIX: Use a more robust pattern to find links and titles ]]--
                for path, inner_html in response.Body:gmatch('<a href="(/script/[^"]+)" class="script%-card%-title"[^>]*>(.-)</a>') do
                    resultsFound = resultsFound + 1
                    local title = inner_html:gsub("<[^>]+>", ""):gsub("^%s*", ""):gsub("%s*$", "") -- Clean HTML tags and trim whitespace
                    
                    local newResult = Instance.new("Frame", resultsScroller); newResult.Size = UDim2.new(1, 0, 0, 40); newResult.BackgroundColor3 = Color3.fromRGB(40, 40, 45); makeUICorner(newResult, 6)
                    local titleLabel = Instance.new("TextLabel", newResult); titleLabel.Size = UDim2.new(1, -100, 1, 0); titleLabel.Position = UDim2.new(0, 10, 0, 0); titleLabel.BackgroundTransparency = 1; titleLabel.Font = Enum.Font.Code; titleLabel.TextSize = 14; titleLabel.TextColor3 = Color3.fromRGB(230, 230, 240); titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Text = title
                    local execBtn = makeButton(newResult, "Execute", UDim2.new(0, 80, 0, 28), UDim2.new(1, -90, 0.5, -14))
                    execBtn.MouseButton1Click:Connect(function() executeScript(path) end)
                end

                if resultsFound == 0 then
                    statusLabel.Visible = true; statusLabel.Text = "No results found for that query."
                end
            end)
        end
        
        searchBtn.MouseButton1Click:Connect(handleSearch)
        searchBox.FocusLost:Connect(function(enterPressed) if enterPressed then handleSearch() end end)
    end
end

-- Omitted other pages (Commands, Special) for brevity as they remain unchanged.

-- Minimize behavior
local minimized = false
local minimizedSize = UDim2.new(0, 320, 0, 36)
local normalSize = MainFrame.Size

local function animateMinimize(minimize)
    if minimize then
        PagesArea.Visible = false; TabsColumn.Visible = false; MinBtn.Text = "+"
        MainFrame:TweenSize(minimizedSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.22, true)
    else
        MainFrame:TweenSize(normalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.22, true, function()
            PagesArea.Visible = true; TabsColumn.Visible = true
        end)
        MinBtn.Text = "—"
    end
end

MinBtn.MouseButton1Click:Connect(function() minimized = not minimized; animateMinimize(minimized) end)

-- Initial state
switchPage("Editor")
notify("Zuka Hub", "Loaded | We're So Back.", 3)
