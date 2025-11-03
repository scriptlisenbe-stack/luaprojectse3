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

--[[
    @Author: Zuka Tech
    @Date: 11/3/2025 (Final Version)
    @Description: A modular, client-sided chat command system for Zuka in Roblox.
]]

--==============================================================================
-- Services & Setup
--==============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Executor/Environment Dependencies
local function DoNotif(message, duration) print("NOTIFICATION: " .. tostring(message) .. " (for " .. tostring(duration) .. "s)") end
local function NaProtectUI(gui) if gui then gui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui") end; print("UI Protection applied to: " .. gui.Name) end
if not setclipboard then setclipboard = function(text) print("Clipboard (fallback): " .. text); DoNotif("setclipboard is not available. See console for output.", 5) end end

--==============================================================================
-- Configuration
--==============================================================================
local Prefix = ";"
local Commands = {}
local Modules = {}
local CommandInfo = {} -- For ;cmds UI

--==============================================================================
-- Core Modules (Condensed for brevity, no logic changed)
--==============================================================================
Modules.Fly = { State = { IsActive = false, Speed = 75, SprintMultiplier = 2.5, Connections = {}, BodyMovers = {} } }; function Modules.Fly:SetSpeed(s) local n = tonumber(s); if n and n > 0 then self.State.Speed = n; DoNotif("Fly speed set to: " .. n, 3) else DoNotif("Invalid speed.", 3) end end; function Modules.Fly:Disable() if not self.State.IsActive then return end; self.State.IsActive = false; local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand = false end; for _, m in pairs(self.State.BodyMovers) do if m.Parent then m:Destroy() end end; for _, c in ipairs(self.State.Connections) do c:Disconnect() end; table.clear(self.State.BodyMovers); table.clear(self.State.Connections); DoNotif("Fly disabled.", 3) end; function Modules.Fly:Enable() if self.State.IsActive then return end; local c = LocalPlayer.Character; if not c or not c.HumanoidRootPart or not c:FindFirstChildOfClass("Humanoid") then DoNotif("Character required.", 3); return end; self.State.IsActive = true; DoNotif("Fly Enabled.", 3); local h, hrp = c.Humanoid, c.HumanoidRootPart; h.PlatformStand = true; local g = Instance.new("BodyGyro", hrp); g.MaxTorque = Vector3.new(9e9, 9e9, 9e9); g.P = 20000; local v = Instance.new("BodyVelocity", hrp); v.MaxForce = Vector3.new(9e9, 9e9, 9e9); self.State.BodyMovers.Gyro, self.State.BodyMovers.Velocity = g, v; local k = {}; local function onInput(i, gp) if not gp then k[i.KeyCode] = (i.UserInputState == Enum.UserInputState.Begin) end end; table.insert(self.State.Connections, UserInputService.InputBegan:Connect(onInput)); table.insert(self.State.Connections, UserInputService.InputEnded:Connect(onInput)); local l = RunService.RenderStepped:Connect(function() if not self.State.IsActive or not hrp.Parent then return end; local cam = workspace.CurrentCamera; g.CFrame = cam.CFrame; local dir = Vector3.new(); if k[Enum.KeyCode.W] then dir += cam.CFrame.LookVector end; if k[Enum.KeyCode.S] then dir -= cam.CFrame.LookVector end; if k[Enum.KeyCode.D] then dir += cam.CFrame.RightVector end; if k[Enum.KeyCode.A] then dir -= cam.CFrame.RightVector end; if k[Enum.KeyCode.Space] or k[Enum.KeyCode.E] then dir += Vector3.yAxis end; if k[Enum.KeyCode.LeftControl] or k[Enum.KeyCode.Q] then dir -= Vector3.yAxis end; local s = k[Enum.KeyCode.LeftShift] and self.State.Speed * self.State.SprintMultiplier or self.State.Speed; v.Velocity = dir.Magnitude > 0 and dir.Unit * s or Vector3.zero end); table.insert(self.State.Connections, l) end; function Modules.Fly:Toggle() if self.State.IsActive then self:Disable() else self:Enable() end end
Modules.Noclip = { State = { IsActive = false, Connection = nil } }; function Modules.Noclip:Enable() if self.State.IsActive then return end; self.State.IsActive = true; self.State.Connection = RunService.Stepped:Connect(function() if LocalPlayer.Character then for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end); DoNotif("Noclip enabled.", 3) end; function Modules.Noclip:Disable() if not self.State.IsActive then return end; self.State.IsActive = false; if self.State.Connection then self.State.Connection:Disconnect(); self.State.Connection = nil end; DoNotif("Noclip disabled.", 3) end; function Modules.Noclip:Toggle() if self.State.IsActive then self:Disable() else self:Enable() end end
Modules.ClickFling = { State = { IsActive = false, Connection = nil, UI = nil } }; function Modules.ClickFling:Disable() self.State.IsActive = false; if self.State.UI then self.State.UI:Destroy() end; if self.State.Connection then self.State.Connection:Disconnect() end; self.State.UI, self.State.Connection = nil, nil; DoNotif("ClickFling Disabled.", 3) end; function Modules.ClickFling:Enable() self:Disable(); self.State.IsActive = true; local u = Instance.new("ScreenGui"); u.Name = "ClickFlingUI"; NaProtectUI(u); self.State.UI = u; local b = Instance.new("TextButton", u); b.Size = UDim2.fromOffset(120, 40); b.Text = "ClickFling: ON"; b.Position = UDim2.new(0.5, -60, 0, 10); b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamBold; b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8); b.MouseButton1Click:Connect(function() self.State.IsActive = not self.State.IsActive; b.Text = "ClickFling: " .. (self.State.IsActive and "ON" or "OFF") end); local function drag(o) local d, s, p; o.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d, s, p = true, i.Position, o.Position; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end) end end); o.InputChanged:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and d then local delta = i.Position - s; o.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end) end; drag(b); self.State.Connection = LocalPlayer:GetMouse().Button1Down:Connect(function() if not self.State.IsActive then return end; local t = LocalPlayer:GetMouse().Target; local p = t and t.Parent and Players:GetPlayerFromCharacter(t.Parent); if not p or p == LocalPlayer then return end; local oh = workspace.FallenPartsDestroyHeight; workspace.FallenPartsDestroyHeight = math.huge; local c, h, hrp, tc, th, thrp = LocalPlayer.Character, LocalPlayer.Character.Humanoid, LocalPlayer.Character.HumanoidRootPart, p.Character, p.Character.Humanoid, p.Character.HumanoidRootPart; if not (c and h and hrp and tc and th and thrp) then return end; local op = hrp.CFrame; local v = Instance.new("BodyVelocity", hrp); v.MaxForce = Vector3.new(math.huge, math.huge, math.huge); local st = tick(); repeat hrp.CFrame = thrp.CFrame * CFrame.new(0, 2, 0); task.wait() until (tick() - st) > 0.2 or not p.Parent; v:Destroy(); hrp.CFrame = op; workspace.FallenPartsDestroyHeight = oh; DoNotif("Flinging " .. p.Name, 2) end); DoNotif("ClickFling Enabled.", 5) end
Modules.Reach = { State = { UI = nil } }; function Modules.Reach:_getTool() return (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")) or (LocalPlayer:FindFirstChildOfClass("Backpack") and LocalPlayer.Backpack:FindFirstChildOfClass("Tool")) end; function Modules.Reach:Apply(reachType, size) if self.State.UI then self.State.UI:Destroy() end; local tool = self:_getTool(); if not tool then return DoNotif("No tool equipped.", 3) end; local parts = {}; for _, p in ipairs(tool:GetDescendants()) do if p:IsA("BasePart") then table.insert(parts, p) end end; if #parts == 0 then return DoNotif("Tool has no parts.", 3) end; local ui = Instance.new("ScreenGui"); ui.Name = "ReachPartSelector"; NaProtectUI(ui); self.State.UI = ui; local frame = Instance.new("Frame", ui); frame.Size = UDim2.fromOffset(250, 200); frame.Position = UDim2.new(0.5, -125, 0.5, -100); frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45); Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8); local title = Instance.new("TextLabel", frame); title.Size = UDim2.new(1, 0, 0, 30); title.BackgroundTransparency = 1; title.Font = Enum.Font.Code; title.Text = "Select a Part"; title.TextColor3 = Color3.fromRGB(200, 220, 255); title.TextSize = 16; local scroll = Instance.new("ScrollingFrame", frame); scroll.Size = UDim2.new(1, -20, 1, -40); scroll.Position = UDim2.fromOffset(10, 35); scroll.BackgroundColor3 = frame.BackgroundColor3; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 6; local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 5); for _, part in ipairs(parts) do local btn = Instance.new("TextButton", scroll); btn.Size = UDim2.new(1, 0, 0, 30); btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65); btn.TextColor3 = Color3.fromRGB(220, 220, 230); btn.Font = Enum.Font.Code; btn.Text = part.Name; btn.TextSize = 14; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4); btn.MouseButton1Click:Connect(function() if not part.Parent then ui:Destroy(); return DoNotif("Part gone.", 3) end; if not part:FindFirstChild("OGSize3") then local v = Instance.new("Vector3Value", part); v.Name = "OGSize3"; v.Value = part.Size end; if part:FindFirstChild("FunTIMES") then part.FunTIMES:Destroy() end; local sb = Instance.new("SelectionBox", part); sb.Adornee = part; sb.Name = "FunTIMES"; sb.LineThickness = 0.02; sb.Color3 = reachType == "box" and Color3.fromRGB(0,100,255) or Color3.fromRGB(255,0,0); if reachType == "box" then part.Size = Vector3.one * size else part.Size = Vector3.new(part.Size.X, part.Size.Y, size) end; part.Massless = true; ui:Destroy(); self.State.UI = nil; DoNotif("Applied reach.", 3) end) end end; function Modules.Reach:Reset() local tool = self:_getTool(); if not tool then return DoNotif("No tool to reset.", 3) end; for _, p in ipairs(tool:GetDescendants()) do if p:IsA("BasePart") then if p:FindFirstChild("OGSize3") then p.Size = p.OGSize3.Value; p.OGSize3:Destroy() end; if p:FindFirstChild("FunTIMES") then p.FunTIMES:Destroy() end end end; DoNotif("Tool reach reset.", 3) end
Modules.Aura = { State = { IsActive = false, Connection = nil, Visualizer = nil } }; function Modules.Aura:Disable() if not self.State.IsActive then return end; self.State.IsActive = false; if self.State.Connection then self.State.Connection:Disconnect() end; if self.State.Visualizer then self.State.Visualizer:Destroy() end; self.State.Connection, self.State.Visualizer = nil, nil; DoNotif("Aura disabled.", 3) end; function Modules.Aura:Enable(distance) if not firetouchinterest then return DoNotif("Aura unsupported.", 5) end; self:Disable(); self.State.IsActive = true; local dist = tonumber(distance) or 20; local viz = Instance.new("Part"); viz.Shape = Enum.PartType.Ball; viz.Size = Vector3.one * dist * 2; viz.Transparency = 0.8; viz.Color = Color3.fromRGB(255,0,0); viz.Material = Enum.Material.Neon; viz.Anchored = true; viz.CanCollide = false; viz.Parent = workspace; self.State.Visualizer = viz; local function getHandle() local c = LocalPlayer.Character; if not c then return end; local t = c:FindFirstChildOfClass("Tool"); return t and (t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart")) end; self.State.Connection = RunService.Heartbeat:Connect(function() local handle = getHandle(); local root = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart; if not handle or not root then viz.CFrame = CFrame.new(0, -1000, 0); return end; viz.CFrame = root.CFrame; for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer and plr.Character then local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart"); local targetHum = plr.Character:FindFirstChildOfClass("Humanoid"); if targetRoot and targetHum and targetHum.Health > 0 and (targetRoot.Position - root.Position).Magnitude <= dist then firetouchinterest(handle, targetRoot, 0); firetouchinterest(handle, targetRoot, 1) end end end end); DoNotif("Aura enabled.", 3) end
Modules.CommandsUI = { State = { UI = nil } }; function Modules.CommandsUI:Toggle() if self.State.UI then self.State.UI:Destroy(); self.State.UI = nil; return end; local u = Instance.new("ScreenGui"); u.Name = "CommandsUI"; NaProtectUI(u); self.State.UI = u; local f = Instance.new("Frame", u); f.Size = UDim2.fromOffset(450, 300); f.Position = UDim2.new(0.5, -225, 0.5, -150); f.BackgroundColor3 = Color3.fromRGB(35, 35, 45); Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8); local h = Instance.new("Frame", f); h.Size = UDim2.new(1, 0, 0, 32); h.BackgroundColor3 = Color3.fromRGB(25, 25, 35); local t = Instance.new("TextLabel", h); t.Size = UDim2.new(1, -30, 1, 0); t.Position = UDim2.fromOffset(10, 0); t.BackgroundTransparency = 1; t.Font = Enum.Font.Code; t.Text = "Zuka Commands"; t.TextColor3 = Color3.fromRGB(200, 220, 255); t.TextXAlignment = Enum.TextXAlignment.Left; t.TextSize = 16; local c = Instance.new("TextButton", h); c.Size = UDim2.fromOffset(32, 32); c.Position = UDim2.new(1, -32, 0, 0); c.BackgroundTransparency = 1; c.Font = Enum.Font.Code; c.Text = "X"; c.TextColor3 = Color3.fromRGB(200, 200, 220); c.TextSize = 20; c.MouseButton1Click:Connect(function() self:Toggle() end); local s = Instance.new("ScrollingFrame", f); s.Size = UDim2.new(1, -20, 1, -42); s.Position = UDim2.fromOffset(10, 37); s.BackgroundColor3 = f.BackgroundColor3; s.BorderSizePixel = 0; s.ScrollBarThickness = 6; local l = Instance.new("UIListLayout", s); l.Padding = UDim.new(0, 5); l.SortOrder = Enum.SortOrder.LayoutOrder; for _, info in ipairs(CommandInfo) do local text = Prefix .. info.Name; if #info.Aliases > 0 then text = text .. " (" .. table.concat(info.Aliases, ", ") .. ")" end; text = text .. " - " .. info.Description; local label = Instance.new("TextLabel", s); label.Size = UDim2.new(1, 0, 0, 20); label.BackgroundTransparency = 1; label.Font = Enum.Font.Code; label.Text = text; label.TextColor3 = Color3.fromRGB(220, 220, 230); label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left; label.TextWrapped = true; label.AutomaticSize = Enum.AutomaticSize.Y end; local function drag(o) local d, s, p; o.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d, s, p = true, i.Position, o.Position; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end) end end); o.InputChanged:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and d then local delta = i.Position - s; o.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end) end; drag(f) end
Modules.CommandBar = { State = { UI = nil } }; function Modules.CommandBar:Toggle() if self.State.UI then self.State.UI:Destroy(); self.State.UI = nil; return end; local u = Instance.new("ScreenGui"); u.Name = "CommandBarUI"; NaProtectUI(u); self.State.UI = u; local b = Instance.new("Frame", u); b.Size = UDim2.new(0, 450, 0, 32); b.Position = UDim2.new(0.5, -225, 0, 10); b.BackgroundColor3 = Color3.fromRGB(30, 30, 40); b.BackgroundTransparency = 0.2; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6); local p = Instance.new("TextLabel", b); p.Size = UDim2.new(0, 20, 1, 0); p.Position = UDim2.fromOffset(5, 0); p.BackgroundTransparency = 1; p.Font = Enum.Font.Code; p.Text = Prefix; p.TextColor3 = Color3.fromRGB(200, 220, 255); p.TextSize = 18; local t = Instance.new("TextBox", b); t.Size = UDim2.new(1, -30, 1, 0); t.Position = UDim2.fromOffset(25, 0); t.BackgroundTransparency = 1; t.Font = Enum.Font.Code; t.Text = ""; t.PlaceholderText = "Enter command..."; t.PlaceholderColor3 = Color3.fromRGB(150, 160, 180); t.TextColor3 = Color3.fromRGB(255, 255, 255); t.TextSize = 16; t.ClearTextOnFocus = false; t.FocusLost:Connect(function(e) if e and t.Text:len() > 0 then processCommand(Prefix .. t.Text); t.Text = "" end end); local function drag(o) local d, s, p; o.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d, s, p = true, i.Position, o.Position; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end) end end); o.InputChanged:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and d then local delta = i.Position - s; o.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end) end; drag(b); DoNotif("Command bar enabled.", 3) end

--==============================================================================
-- IDE Module (NEW)
--==============================================================================
Modules.IDE = { State = { UI = nil } }

function Modules.IDE:Toggle()
    if self.State.UI then
        self.State.UI:Destroy()
        self.State.UI = nil
        return
    end

    local ui = Instance.new("ScreenGui"); ui.Name = "IDE_UI"; NaProtectUI(ui)
    self.State.UI = ui

    local frame = Instance.new("Frame", ui)
    frame.Size = UDim2.fromOffset(500, 350); frame.Position = UDim2.new(0.5, -250, 0.5, -175)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45); Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local header = Instance.new("Frame", frame); header.Size = UDim2.new(1, 0, 0, 32); header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    local title = Instance.new("TextLabel", header); title.Size = UDim2.new(1, -30, 1, 0); title.Position = UDim2.fromOffset(10, 0); title.BackgroundTransparency = 1; title.Font = Enum.Font.Code; title.Text = "Zuka IDE"; title.TextColor3 = Color3.fromRGB(200, 220, 255); title.TextXAlignment = Enum.TextXAlignment.Left; title.TextSize = 16
    local closeBtn = Instance.new("TextButton", header); closeBtn.Size = UDim2.fromOffset(32, 32); closeBtn.Position = UDim2.new(1, -32, 0, 0); closeBtn.BackgroundTransparency = 1; closeBtn.Font = Enum.Font.Code; closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(200, 200, 220); closeBtn.TextSize = 20; closeBtn.MouseButton1Click:Connect(function() self:Toggle() end)

    local textBox = Instance.new("TextBox", frame)
    textBox.Size = UDim2.new(1, -20, 1, -82); textBox.Position = UDim2.fromOffset(10, 37)
    textBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35); textBox.MultiLine = true
    textBox.Font = Enum.Font.Code; textBox.TextColor3 = Color3.fromRGB(220, 220, 230); textBox.TextSize = 14
    textBox.TextXAlignment = Enum.TextXAlignment.Left; textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.PlaceholderText = "-- Paste your Lua code here\n-- Example: print('Hello from the IDE!')"

    local executeBtn = Instance.new("TextButton", frame)
    executeBtn.Size = UDim2.fromOffset(100, 30); executeBtn.Position = UDim2.new(1, -120, 1, -40)
    executeBtn.BackgroundColor3 = Color3.fromRGB(80, 160, 80); executeBtn.Font = Enum.Font.Code; executeBtn.Text = "Execute"; executeBtn.TextColor3 = Color3.white; executeBtn.TextSize = 16; Instance.new("UICorner", executeBtn).CornerRadius = UDim.new(0, 5)
    
    local clearBtn = Instance.new("TextButton", frame)
    clearBtn.Size = UDim2.fromOffset(80, 30); clearBtn.Position = UDim2.new(1, -210, 1, -40)
    clearBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 80); clearBtn.Font = Enum.Font.Code; clearBtn.Text = "Clear"; clearBtn.TextColor3 = Color3.white; clearBtn.TextSize = 16; Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 5)

    executeBtn.MouseButton1Click:Connect(function()
        local code = textBox.Text
        if #code > 0 then
            local success, err = pcall(function() loadstring(code)() end)
            if success then
                DoNotif("Script executed successfully.", 2)
            else
                DoNotif("Execution Error: " .. tostring(err), 5)
            end
        end
    end)
    
    clearBtn.MouseButton1Click:Connect(function() textBox.Text = "" end)

    local function drag(o) local d, s, p; o.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d, s, p = true, i.Position, o.Position; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end) end end); o.InputChanged:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and d then local delta = i.Position - s; o.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end) end
    drag(frame)
end

--==============================================================================
-- Command Definitions
--==============================================================================
table.insert(CommandInfo, { Name = "cmds", Aliases = {"help"}, Description = "Shows this command list."}); table.insert(CommandInfo, { Name = "cmdbar", Aliases = {"cbar"}, Description = "Toggles the private command bar."}); table.insert(CommandInfo, { Name = "ide", Aliases = {}, Description = "Opens a script execution window."}); table.insert(CommandInfo, { Name = "speed", Aliases = {}, Description = "Sets walkspeed. Usage: ;speed [num]"}); table.insert(CommandInfo, { Name = "fly", Aliases = {}, Description = "Toggles smooth flight mode."}); table.insert(CommandInfo, { Name = "flyspeed", Aliases = {}, Description = "Sets flight speed. Usage: ;flyspeed [num]"}); table.insert(CommandInfo, { Name = "noclip", Aliases = {}, Description = "Toggles walking through walls."}); table.insert(CommandInfo, { Name = "clickfling", Aliases = {"mousefling"}, Description = "Enables click to fling."}); table.insert(CommandInfo, { Name = "unclickfling", Aliases = {"unmousefling"}, Description = "Disables click to fling."}); table.insert(CommandInfo, { Name = "reach", Aliases = {"swordreach"}, Description = "Extends sword reach. Usage: ;reach [num]"}); table.insert(CommandInfo, { Name = "boxreach", Aliases = {}, Description = "Creates a box hitbox. Usage: ;boxreach [num]"}); table.insert(CommandInfo, { Name = "resetreach", Aliases = {"unreach"}, Description = "Resets tool reach to normal."}); table.insert(CommandInfo, { Name = "aura", Aliases = {}, Description = "Auto-hits nearby players. Usage: ;aura [dist]"}); table.insert(CommandInfo, { Name = "unaura", Aliases = {}, Description = "Disables aura."}); table.insert(CommandInfo, { Name = "iy", Aliases = {}, Description = "Loads the Infinite Yield admin panel."}); table.insert(CommandInfo, { Name = "cmdx", Aliases = {}, Description = "Loads the CMD-X admin panel."}); table.insert(CommandInfo, { Name = "remotespy", Aliases = {}, Description = "Opens a GUI for viewing game events."}); table.insert(CommandInfo, { Name = "dex", Aliases = {}, Description = "Opens the Dark Dex explorer for developers."})

-- Simple and Loadstring Commands
Commands.speed = function(args) local s = tonumber(args[1]); local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if not h then DoNotif("Humanoid not found!", 3) return end; if s and s > 0 then h.WalkSpeed = s; DoNotif("WalkSpeed set to: " .. s, 3) else DoNotif("Invalid speed.", 3) end end
Commands.iy = function() pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end); DoNotif("Loading Infinite Yield...", 3) end
Commands.cmdx = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source"))() end); DoNotif("Loading CMD-X...", 3) end
Commands.remotespy = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ex-ploi-ter/custom-remote-spy/main/source.lua"))() end); DoNotif("Loading Remote Spy...", 3) end
Commands.dex = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/Bypassed_Dark_Dex.lua"))() end); DoNotif("Loading Dark Dex...", 3) end

-- Command wrappers for modules
Commands.fly = function() Modules.Fly:Toggle() end; Commands.flyspeed = function(args) Modules.Fly:SetSpeed(args[1]) end; Commands.noclip = function() Modules.Noclip:Toggle() end; Commands.clickfling = function() Modules.ClickFling:Enable() end; Commands.unclickfling = function() Modules.ClickFling:Disable() end; Commands.cmds = function() Modules.CommandsUI:Toggle() end; Commands.reach = function(args) Modules.Reach:Apply("directional", tonumber(args[1]) or 15) end; Commands.boxreach = function(args) Modules.Reach:Apply("box", tonumber(args[1]) or 15) end; Commands.resetreach = function() Modules.Reach:Reset() end; Commands.aura = function(args) Modules.Aura:Enable(args[1]) end; Commands.unaura = function() Modules.Aura:Disable() end; Commands.cmdbar = function() Modules.CommandBar:Toggle() end; Commands.ide = function() Modules.IDE:Toggle() end

-- Command Aliases
Commands.help = Commands.cmds; Commands.mousefling = Commands.clickfling; Commands.unmousefling = Commands.unclickfling; Commands.swordreach = Commands.reach; Commands.unreach = Commands.resetreach; Commands.cbar = Commands.cmdbar

--==============================================================================
-- Centralized Command Processor
--==============================================================================
function processCommand(message)
    if not message:sub(1, #Prefix) == Prefix then return end
    local args = {}; for word in message:sub(#Prefix + 1):gmatch("%S+") do table.insert(args, word) end
    if #args == 0 then return end
    local cmdName = table.remove(args, 1):lower()
    local cmdFunc = Commands[cmdName]
    if cmdFunc then pcall(cmdFunc, args) else DoNotif("Unknown command: " .. cmdName, 3) end
end

--==============================================================================
-- Input Handlers
--==============================================================================
LocalPlayer.Chatted:Connect(processCommand)
Modules.CommandBar:Toggle() -- Start with the command bar open by default
DoNotif("Zuka Command Handler v6 (IDE Loaded) | Prefix: '" .. Prefix .. "' | ;cmds for help", 6)