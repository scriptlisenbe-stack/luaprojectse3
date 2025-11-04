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
    @Date: 11/3/2025 (Definitive Version)
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
-- Core Modules (Condensed for brevity)
--==============================================================================
Modules.Fly = { State = { IsActive = false, Speed = 75, SprintMultiplier = 2.5, Connections = {}, BodyMovers = {} } }; function Modules.Fly:SetSpeed(s) local n = tonumber(s); if n and n > 0 then self.State.Speed = n; DoNotif("Fly speed set to: " .. n, 3) else DoNotif("Invalid speed.", 3) end end; function Modules.Fly:Disable() if not self.State.IsActive then return end; self.State.IsActive = false; local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand = false end; for _, m in pairs(self.State.BodyMovers) do if m.Parent then m:Destroy() end end; for _, c in ipairs(self.State.Connections) do c:Disconnect() end; table.clear(self.State.BodyMovers); table.clear(self.State.Connections); DoNotif("Fly disabled.", 3) end; function Modules.Fly:Enable() if self.State.IsActive then return end; local c = LocalPlayer.Character; if not c or not c.HumanoidRootPart or not c:FindFirstChildOfClass("Humanoid") then DoNotif("Character required.", 3); return end; self.State.IsActive = true; DoNotif("Fly Enabled.", 3); local h, hrp = c.Humanoid, c.HumanoidRootPart; h.PlatformStand = true; local g = Instance.new("BodyGyro", hrp); g.MaxTorque = Vector3.new(9e9, 9e9, 9e9); g.P = 20000; local v = Instance.new("BodyVelocity", hrp); v.MaxForce = Vector3.new(9e9, 9e9, 9e9); self.State.BodyMovers.Gyro, self.State.BodyMovers.Velocity = g, v; local k = {}; local function onInput(i, gp) if not gp then k[i.KeyCode] = (i.UserInputState == Enum.UserInputState.Begin) end end; table.insert(self.State.Connections, UserInputService.InputBegan:Connect(onInput)); table.insert(self.State.Connections, UserInputService.InputEnded:Connect(onInput)); local l = RunService.RenderStepped:Connect(function() if not self.State.IsActive or not hrp.Parent then return end; local cam = workspace.CurrentCamera; g.CFrame = cam.CFrame; local dir = Vector3.new(); if k[Enum.KeyCode.W] then dir += cam.CFrame.LookVector end; if k[Enum.KeyCode.S] then dir -= cam.CFrame.LookVector end; if k[Enum.KeyCode.D] then dir += cam.CFrame.RightVector end; if k[Enum.KeyCode.A] then dir -= cam.CFrame.RightVector end; if k[Enum.KeyCode.Space] or k[Enum.KeyCode.E] then dir += Vector3.yAxis end; if k[Enum.KeyCode.LeftControl] or k[Enum.KeyCode.Q] then dir -= Vector3.yAxis end; local s = k[Enum.KeyCode.LeftShift] and self.State.Speed * self.State.SprintMultiplier or self.State.Speed; v.Velocity = dir.Magnitude > 0 and dir.Unit * s or Vector3.zero end); table.insert(self.State.Connections, l) end; function Modules.Fly:Toggle() if self.State.IsActive then self:Disable() else self:Enable() end end
Modules.Noclip = { State = { IsActive = false, Connection = nil } }; function Modules.Noclip:Enable() if self.State.IsActive then return end; self.State.IsActive = true; self.State.Connection = RunService.Stepped:Connect(function() if LocalPlayer.Character then for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end); DoNotif("Noclip enabled.", 3) end; function Modules.Noclip:Disable() if not self.State.IsActive then return end; self.State.IsActive = false; if self.State.Connection then self.State.Connection:Disconnect(); self.State.Connection = nil end; DoNotif("Noclip disabled.", 3) end; function Modules.Noclip:Toggle() if self.State.IsActive then self:Disable() else self:Enable() end end
Modules.ClickFling = { State = { IsActive = false, Connection = nil, UI = nil } }; function Modules.ClickFling:Disable() self.State.IsActive = false; if self.State.UI then self.State.UI:Destroy() end; if self.State.Connection then self.State.Connection:Disconnect() end; self.State.UI, self.State.Connection = nil, nil; DoNotif("ClickFling Disabled.", 3) end; function Modules.ClickFling:Enable() self:Disable(); self.State.IsActive = true; local u = Instance.new("ScreenGui"); u.Name = "ClickFlingUI"; NaProtectUI(u); self.State.UI = u; local b = Instance.new("TextButton", u); b.Size = UDim2.fromOffset(120, 40); b.Text = "ClickFling: ON"; b.Position = UDim2.new(0.5, -60, 0, 10); b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamBold; b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8); b.MouseButton1Click:Connect(function() self.State.IsActive = not self.State.IsActive; b.Text = "ClickFling: " .. (self.State.IsActive and "ON" or "OFF") end); local function drag(o) local d, s, p; o.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d, s, p = true, i.Position, o.Position; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end) end end); o.InputChanged:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and d then local delta = i.Position - s; o.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end) end; drag(b); self.State.Connection = LocalPlayer:GetMouse().Button1Down:Connect(function() if not self.State.IsActive then return end; local t = LocalPlayer:GetMouse().Target; local p = t and t.Parent and Players:GetPlayerFromCharacter(t.Parent); if not p or p == LocalPlayer then return end; local oh = workspace.FallenPartsDestroyHeight; workspace.FallenPartsDestroyHeight = math.huge; local c, h, hrp, tc, th, thrp = LocalPlayer.Character, LocalPlayer.Character.Humanoid, LocalPlayer.Character.HumanoidRootPart, p.Character, p.Character.Humanoid, p.Character.HumanoidRootPart; if not (c and h and hrp and tc and th and thrp) then return end; local op = hrp.CFrame; local v = Instance.new("BodyVelocity", hrp); v.MaxForce = Vector3.new(math.huge, math.huge, math.huge); local st = tick(); repeat hrp.CFrame = thrp.CFrame * CFrame.new(0, 2, 0); task.wait() until (tick() - st) > 0.2 or not p.Parent; v:Destroy(); hrp.CFrame = op; workspace.FallenPartsDestroyHeight = oh; DoNotif("Flinging " .. p.Name, 2) end); DoNotif("ClickFling Enabled.", 5) end
Modules.Reach = { State = { UI = nil } }; function Modules.Reach:_getTool() return (LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")) or (LocalPlayer:FindFirstChildOfClass("Backpack") and LocalPlayer.Backpack:FindFirstChildOfClass("Tool")) end; function Modules.Reach:Apply(reachType, size) if self.State.UI then self.State.UI:Destroy() end; local tool = self:_getTool(); if not tool then return DoNotif("No tool equipped.", 3) end; local parts = {}; for _, p in ipairs(tool:GetDescendants()) do if p:IsA("BasePart") then table.insert(parts, p) end end; if #parts == 0 then return DoNotif("Tool has no parts.", 3) end; local ui = Instance.new("ScreenGui"); ui.Name = "ReachPartSelector"; NaProtectUI(ui); self.State.UI = ui; local frame = Instance.new("Frame", ui); frame.Size = UDim2.fromOffset(250, 200); frame.Position = UDim2.new(0.5, -125, 0.5, -100); frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45); Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8); local title = Instance.new("TextLabel", frame); title.Size = UDim2.new(1, 0, 0, 30); title.BackgroundTransparency = 1; title.Font = Enum.Font.Code; title.Text = "Select a Part"; title.TextColor3 = Color3.fromRGB(200, 220, 255); title.TextSize = 16; local scroll = Instance.new("ScrollingFrame", frame); scroll.Size = UDim2.new(1, -20, 1, -40); scroll.Position = UDim2.fromOffset(10, 35); scroll.BackgroundColor3 = frame.BackgroundColor3; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 6; local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 5); for _, part in ipairs(parts) do local btn = Instance.new("TextButton", scroll); btn.Size = UDim2.new(1, 0, 0, 30); btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65); btn.TextColor3 = Color3.fromRGB(220, 220, 230); btn.Font = Enum.Font.Code; btn.Text = part.Name; btn.TextSize = 14; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4); btn.MouseButton1Click:Connect(function() if not part.Parent then ui:Destroy(); return DoNotif("Part gone.", 3) end; if not part:FindFirstChild("OGSize3") then local v = Instance.new("Vector3Value", part); v.Name = "OGSize3"; v.Value = part.Size end; if part:FindFirstChild("FunTIMES") then part.FunTIMES:Destroy() end; local sb = Instance.new("SelectionBox", part); sb.Adornee = part; sb.Name = "FunTIMES"; sb.LineThickness = 0.02; sb.Color3 = reachType == "box" and Color3.fromRGB(0,100,255) or Color3.fromRGB(255,0,0); if reachType == "box" then part.Size = Vector3.one * size else part.Size = Vector3.new(part.Size.X, part.Size.Y, size) end; part.Massless = true; ui:Destroy(); self.State.UI = nil; DoNotif("Applied reach.", 3) end) end end; function Modules.Reach:Reset() local tool = self:_getTool(); if not tool then return DoNotif("No tool to reset.", 3) end; for _, p in ipairs(tool:GetDescendants()) do if p:IsA("BasePart") then if p:FindFirstChild("OGSize3") then p.Size = p.OGSize3.Value; p.OGSize3:Destroy() end; if p:FindFirstChild("FunTIMES") then p.FUNTIMES:Destroy() end end end; DoNotif("Tool reach reset.", 3) end
Modules.CommandsUI = { State = { UI = nil } }; function Modules.CommandsUI:Toggle() if self.State.UI then self.State.UI:Destroy(); self.State.UI = nil; return end; local u = Instance.new("ScreenGui"); u.Name = "CommandsUI"; NaProtectUI(u); self.State.UI = u; local f = Instance.new("Frame", u); f.Size = UDim2.fromOffset(450, 300); f.Position = UDim2.new(0.5, -225, 0.5, -150); f.BackgroundColor3 = Color3.fromRGB(35, 35, 45); Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8); local h = Instance.new("Frame", f); h.Size = UDim2.new(1, 0, 0, 32); h.BackgroundColor3 = Color3.fromRGB(25, 25, 35); local t = Instance.new("TextLabel", h); t.Size = UDim2.new(1, -30, 1, 0); t.Position = UDim2.fromOffset(10, 0); t.BackgroundTransparency = 1; t.Font = Enum.Font.Code; t.Text = "Zuka Commands"; t.TextColor3 = Color3.fromRGB(200, 220, 255); t.TextXAlignment = Enum.TextXAlignment.Left; t.TextSize = 16; local c = Instance.new("TextButton", h); c.Size = UDim2.fromOffset(32, 32); c.Position = UDim2.new(1, -32, 0, 0); c.BackgroundTransparency = 1; c.Font = Enum.Font.Code; c.Text = "X"; c.TextColor3 = Color3.fromRGB(200, 200, 220); c.TextSize = 20; c.MouseButton1Click:Connect(function() self:Toggle() end); local s = Instance.new("ScrollingFrame", f); s.Size = UDim2.new(1, -20, 1, -42); s.Position = UDim2.fromOffset(10, 37); s.BackgroundColor3 = f.BackgroundColor3; s.BorderSizePixel = 0; s.ScrollBarThickness = 6; local l = Instance.new("UIListLayout", s); l.Padding = UDim.new(0, 5); l.SortOrder = Enum.SortOrder.LayoutOrder; for _, info in ipairs(CommandInfo) do local text = Prefix .. info.Name; if #info.Aliases > 0 then text = text .. " (" .. table.concat(info.Aliases, ", ") .. ")" end; text = text .. " - " .. info.Description; local label = Instance.new("TextLabel", s); label.Size = UDim2.new(1, 0, 0, 20); label.BackgroundTransparency = 1; label.Font = Enum.Font.Code; label.Text = text; label.TextColor3 = Color3.fromRGB(220, 220, 230); label.TextSize = 14; label.TextXAlignment = Enum.TextXAlignment.Left; label.TextWrapped = true; label.AutomaticSize = Enum.AutomaticSize.Y end; local function drag(o) local d, s, p; o.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d, s, p = true, i.Position, o.Position; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end) end end); o.InputChanged:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and d then local delta = i.Position - s; o.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end) end; drag(f) end
Modules.CommandBar = { State = { UI = nil } }; function Modules.CommandBar:Toggle() if self.State.UI then self.State.UI:Destroy(); self.State.UI = nil; return end; local u = Instance.new("ScreenGui"); u.Name = "CommandBarUI"; NaProtectUI(u); self.State.UI = u; local b = Instance.new("Frame", u); b.Size = UDim2.new(0, 450, 0, 32); b.Position = UDim2.new(0.5, -225, 0, 10); b.BackgroundColor3 = Color3.fromRGB(30, 30, 40); b.BackgroundTransparency = 0.2; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6); local p = Instance.new("TextLabel", b); p.Size = UDim2.new(0, 20, 1, 0); p.Position = UDim2.fromOffset(5, 0); p.BackgroundTransparency = 1; p.Font = Enum.Font.Code; p.Text = Prefix; p.TextColor3 = Color3.fromRGB(200, 220, 255); p.TextSize = 18; local t = Instance.new("TextBox", b); t.Size = UDim2.new(1, -30, 1, 0); t.Position = UDim2.fromOffset(25, 0); t.BackgroundTransparency = 1; t.Font = Enum.Font.Code; t.Text = ""; t.PlaceholderText = "Enter command..."; t.PlaceholderColor3 = Color3.fromRGB(150, 160, 180); t.TextColor3 = Color3.fromRGB(255, 255, 255); t.TextSize = 16; t.ClearTextOnFocus = false; t.FocusLost:Connect(function(e) if e and t.Text:len() > 0 then processCommand(Prefix .. t.Text); t.Text = "" end end); local function drag(o) local d, s, p; o.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d, s, p = true, i.Position, o.Position; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end) end end); o.InputChanged:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and d then local delta = i.Position - s; o.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end) end; drag(b); DoNotif("Command bar enabled.", 3) end
Modules.IDE = { State = { UI = nil } }; function Modules.IDE:Toggle() if self.State.UI then self.State.UI:Destroy(); self.State.UI = nil; return end; local u = Instance.new("ScreenGui"); u.Name = "IDE_UI"; NaProtectUI(u); self.State.UI = u; local f = Instance.new("Frame", u); f.Size = UDim2.fromOffset(550, 400); f.Position = UDim2.new(0.5, -275, 0.5, -200); f.BackgroundColor3 = Color3.fromRGB(35, 35, 45); Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8); local h = Instance.new("Frame", f); h.Size = UDim2.new(1, 0, 0, 32); h.BackgroundColor3 = Color3.fromRGB(25, 25, 35); local t = Instance.new("TextLabel", h); t.Size = UDim2.new(1, -30, 1, 0); t.Position = UDim2.fromOffset(10, 0); t.BackgroundTransparency = 1; t.Font = Enum.Font.Code; t.Text = "Zuka IDE"; t.TextColor3 = Color3.fromRGB(200, 220, 255); t.TextXAlignment = Enum.TextXAlignment.Left; t.TextSize = 16; local c = Instance.new("TextButton", h); c.Size = UDim2.fromOffset(32, 32); c.Position = UDim2.new(1, -32, 0, 0); c.BackgroundTransparency = 1; c.Font = Enum.Font.Code; c.Text = "X"; c.TextColor3 = Color3.fromRGB(200, 200, 220); c.TextSize = 20; c.MouseButton1Click:Connect(function() self:Toggle() end); local sf = Instance.new("ScrollingFrame", f); sf.Size = UDim2.new(1, -20, 1, -82); sf.Position = UDim2.fromOffset(10, 37); sf.BackgroundColor3 = Color3.fromRGB(25, 25, 35); sf.BorderSizePixel = 0; sf.ScrollBarThickness = 8; local tb = Instance.new("TextBox", sf); tb.Size = UDim2.new(1, 0, 0, 0); tb.AutomaticSize = Enum.AutomaticSize.Y; tb.BackgroundColor3 = Color3.fromRGB(25, 25, 35); tb.MultiLine = true; tb.Font = Enum.Font.Code; tb.TextColor3 = Color3.fromRGB(220, 220, 230); tb.TextSize = 14; tb.TextXAlignment = Enum.TextXAlignment.Left; tb.TextYAlignment = Enum.TextYAlignment.Top; tb.ClearTextOnFocus = false; local eb = Instance.new("TextButton", f); eb.Size = UDim2.fromOffset(100, 30); eb.Position = UDim2.new(1, -120, 1, -40); eb.BackgroundColor3 = Color3.fromRGB(80, 160, 80); eb.Font = Enum.Font.Code; eb.Text = "Execute"; eb.TextColor3 = Color3.white; eb.TextSize = 16; Instance.new("UICorner", eb).CornerRadius = UDim.new(0, 5); local cb = Instance.new("TextButton", f); cb.Size = UDim2.fromOffset(80, 30); cb.Position = UDim2.new(1, -210, 1, -40); cb.BackgroundColor3 = Color3.fromRGB(180, 80, 80); cb.Font = Enum.Font.Code; cb.Text = "Clear"; cb.TextColor3 = Color3.white; cb.TextSize = 16; Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 5); eb.MouseButton1Click:Connect(function() local code = tb.Text; if #code > 0 then local s, r = pcall(function() local f, e = loadstring(code); if typeof(f) ~= "function" then error("Syntax error: " .. tostring(e or f)) end; setfenv(f, getfenv()); f() end); if s then DoNotif("Script executed.", 3) else DoNotif("Error: " .. tostring(r), 6) end end end); cb.MouseButton1Click:Connect(function() tb.Text = "" end); local function drag(o) local d, s, p; o.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d, s, p = true, i.Position, o.Position; i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then d = false end end) end end); o.InputChanged:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) and d then local delta = i.Position - s; o.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y) end end) end; drag(f) end
Modules.ESP = { State = { IsActive = false, Connection = nil, TrackedPlayers = {} } }; function Modules.ESP:Toggle() self.State.IsActive = not self.State.IsActive; if self.State.IsActive then self.State.Connection = RunService.RenderStepped:Connect(function() local currentPlayerSet = {}; for _, player in ipairs(Players:GetPlayers()) do if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then currentPlayerSet[player] = true; if not self.State.TrackedPlayers[player] then local char = player.Character; local head = char.Head; local highlight = Instance.new("Highlight"); highlight.FillColor = Color3.fromRGB(255, 60, 60); highlight.OutlineColor = Color3.fromRGB(255, 255, 255); highlight.FillTransparency = 0.8; highlight.OutlineTransparency = 0.3; highlight.Parent = char; local billboard = Instance.new("BillboardGui"); billboard.Adornee = head; billboard.AlwaysOnTop = true; billboard.Size = UDim2.new(0, 200, 0, 50); billboard.StudsOffset = Vector3.new(0, 2.5, 0); billboard.Parent = head; local nameLabel = Instance.new("TextLabel", billboard); nameLabel.Size = UDim2.new(1, 0, 0.5, 0); nameLabel.Text = player.Name; nameLabel.BackgroundTransparency = 1; nameLabel.Font = Enum.Font.Code; nameLabel.TextSize = 18; nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255); local teamLabel = Instance.new("TextLabel", billboard); teamLabel.Size = UDim2.new(1, 0, 0.5, 0); teamLabel.Position = UDim2.new(0, 0, 0.5, 0); teamLabel.BackgroundTransparency = 1; teamLabel.Font = Enum.Font.Code; teamLabel.TextSize = 14; if player.Team then teamLabel.Text = player.Team.Name; teamLabel.TextColor3 = player.Team.TeamColor.Color else teamLabel.Text = "No Team"; teamLabel.TextColor3 = Color3.fromRGB(200, 200, 200) end; self.State.TrackedPlayers[player] = {Highlight = highlight, Billboard = billboard} end end end; for player, data in pairs(self.State.TrackedPlayers) do if not currentPlayerSet[player] then data.Highlight:Destroy(); data.Billboard:Destroy(); self.State.TrackedPlayers[player] = nil end end end) else if self.State.Connection then self.State.Connection:Disconnect(); self.State.Connection = nil end; for _, data in pairs(self.State.TrackedPlayers) do data.Highlight:Destroy(); data.Billboard:Destroy() end; self.State.TrackedPlayers = {} end; DoNotif("ESP " .. (self.State.IsActive and "Enabled" or "Disabled"), 3) end
Modules.ClickTP = { State = { IsActive = false, Connection = nil } }; function Modules.ClickTP:Toggle() self.State.IsActive = not self.State.IsActive; if self.State.IsActive then local mouse = LocalPlayer:GetMouse(); self.State.Connection = UserInputService.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode == Enum.KeyCode.LeftControl then local hrp = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart; if hrp then hrp.CFrame = mouse.Hit end end end) else if self.State.Connection then self.State.Connection:Disconnect(); self.State.Connection = nil end end; DoNotif("Click TP " .. (self.State.IsActive and "Enabled" or "Disabled"), 3) end
Modules.GrabTools = { State = { IsActive = false, Connection = nil } }; function Modules.GrabTools:Toggle() self.State.IsActive = not self.State.IsActive; if self.State.IsActive then self.State.Connection = workspace.ChildAdded:Connect(function(c) if c:IsA("Tool") then local bp = LocalPlayer:FindFirstChildOfClass("Backpack"); if bp then c:Clone().Parent = bp; DoNotif("Grabbed " .. c.Name, 2) end end end) else if self.State.Connection then self.State.Connection:Disconnect(); self.State.Connection = nil end end; DoNotif("Grab Tools " .. (self.State.IsActive and "Enabled" or "Disabled"), 3) end

--==============================================================================
-- iBTools Module
--==============================================================================
Modules.iBTools = { State = { IsActive = false, Tool = nil, UI = nil, Highlight = nil, Connections = {}, History = {}, SaveHistory = {}, CurrentPart = nil, CurrentMode = "delete" } }
function Modules.iBTools:_CleanupUI() if self.State.UI then self.State.UI:Destroy() end; if self.State.Highlight then self.State.Highlight:Destroy() end; for _, conn in ipairs(self.State.Connections) do conn:Disconnect() end; self.State.UI, self.State.Highlight = nil, nil; table.clear(self.State.Connections) end
function Modules.iBTools:Disable() if not self.State.IsActive then return end; self:_CleanupUI(); if self.State.Tool then self.State.Tool:Destroy() end; self.State = { IsActive = false, Tool = nil, UI = nil, Highlight = nil, Connections = {}, History = {}, SaveHistory = {}, CurrentPart = nil, CurrentMode = "delete" }; DoNotif("iBTools unloaded.", 3) end
function Modules.iBTools:Enable() if self.State.IsActive then return DoNotif("iBTools is already active.", 3) end; local backpack = LocalPlayer:FindFirstChildOfClass("Backpack"); if not backpack then return DoNotif("Backpack not found.", 3) end; self.State.IsActive = true; self.State.Tool = Instance.new("Tool", backpack); self.State.Tool.Name = "iBTools"; self.State.Tool.RequiresHandle = false; self.State.Tool.Equipped:Connect(function(mouse) local state = self.State; state.Highlight = Instance.new("SelectionBox"); state.Highlight.Name = "iBToolsSelection"; state.Highlight.LineThickness = 0.04; state.Highlight.Color3 = Color3.fromRGB(0, 170, 255); state.Highlight.Parent = workspace.CurrentCamera; local function formatVectorString(vec) return string.format("Vector3.new(%s,%s,%s)", tostring(vec.X), tostring(vec.Y), tostring(vec.Z)) end; local function updateStatus(part) if not state.UI then return end; local statusLabel = state.UI:FindFirstChild("Panel", true) and state.UI.Panel:FindFirstChild("Status"); if not statusLabel then return end; local targetText = "none"; if part then targetText = part:GetFullName() end; statusLabel.Text = string.format("Mode: %s | Target: %s", state.CurrentMode:upper(), targetText) end; local function setTarget(part) if part and not part:IsA("BasePart") then part = nil end; state.CurrentPart = part; if state.Highlight then state.Highlight.Adornee = part end; updateStatus(part) end; local modeHandlers = { delete = function(part) table.insert(state.History, {part = part, parent = part.Parent, cframe = part.CFrame}); table.insert(state.SaveHistory, {name = part.Name, position = part.Position}); part.Parent = nil; setTarget(nil); DoNotif("Deleted '"..part.Name.."'", 2) end, anchor = function(part) part.Anchored = not part.Anchored; updateStatus(part); DoNotif(string.format("%s anchored %s", part.Name, part.Anchored and "enabled" or "disabled"), 2) end, collide = function(part) part.CanCollide = not part.CanCollide; updateStatus(part); DoNotif(string.format("%s CanCollide %s", part.Name, part.CanCollide and "enabled" or "disabled"), 2) end }; local uiActions = { setMode = function(mode) state.CurrentMode = mode; updateStatus(state.CurrentPart) end, getMode = function() return state.CurrentMode end, undo = function() local record = table.remove(state.History); if not record then return DoNotif("Nothing to undo.", 2) end; record.part.Parent = record.parent; pcall(function() record.part.CFrame = record.cframe end); setTarget(record.part); DoNotif("Restored '"..record.part.Name.."'", 2) end, copy = function() if #state.SaveHistory == 0 then return DoNotif("No deleted parts to export.", 3) end; local lines = {}; for _, data in ipairs(state.SaveHistory) do local vec = formatVectorString(data.position); table.insert(lines, string.format("for _,v in ipairs(workspace:FindPartsInRegion3(Region3.new(%s, %s), nil, math.huge)) do if v.Name == %q then v:Destroy() end end", vec, vec, data.name)) end; setclipboard(table.concat(lines, "\n")); DoNotif("Copied delete script to clipboard.", 3) end }; local gui = Instance.new("ScreenGui"); gui.Name = "iBToolsUI"; NaProtectUI(gui); self.State.UI = gui; local frame = Instance.new("Frame", gui); frame.Name = "Panel"; frame.Size = UDim2.new(0, 240, 0, 260); frame.Position = UDim2.new(0.05, 0, 0.4, 0); frame.BackgroundColor3 = Color3.fromRGB(26, 26, 26); Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8); local header = Instance.new("Frame", frame); header.Name = "Header"; header.Size = UDim2.new(1, 0, 0, 36); header.BackgroundColor3 = Color3.fromRGB(38, 38, 38); header.Active = true; local title = Instance.new("TextLabel", header); title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamSemibold; title.TextSize = 16; title.TextXAlignment = Enum.TextXAlignment.Left; title.TextColor3 = Color3.fromRGB(255, 255, 255); title.Text = "iBuild Tools"; title.Size = UDim2.new(1, -40, 1, 0); title.Position = UDim2.new(0, 10, 0, 0); local statusLabel = Instance.new("TextLabel", frame); statusLabel.Name = "Status"; statusLabel.BackgroundTransparency = 1; statusLabel.Font = Enum.Font.Gotham; statusLabel.TextSize = 14; statusLabel.TextXAlignment = Enum.TextXAlignment.Left; statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200); statusLabel.Position = UDim2.new(0, 12, 0, 46); statusLabel.Size = UDim2.new(1, -24, 0, 20); statusLabel.Text = "Target: none"; local buttonHolder = Instance.new("Frame", frame); buttonHolder.BackgroundTransparency = 1; buttonHolder.Position = UDim2.new(0, 12, 0, 72); buttonHolder.Size = UDim2.new(1, -24, 1, -84); local layout = Instance.new("UIListLayout", buttonHolder); layout.Padding = UDim.new(0, 6); local modeButtons = {}; local function makeButton(text, parent) local btn=Instance.new("TextButton",parent or buttonHolder); btn.Name=text; btn.Size=UDim2.new(1,0,0,34); btn.BackgroundColor3=Color3.fromRGB(52,52,52); btn.Font=Enum.Font.GothamSemibold; btn.TextSize=14; btn.TextColor3=Color3.fromRGB(255,255,255); btn.Text=text; Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6); return btn end; local function refreshModeButtons() for mode,btn in pairs(modeButtons) do btn.BackgroundColor3 = (state.CurrentMode == mode and Color3.fromRGB(80,110,255) or Color3.fromRGB(52,52,52)) end end; for mode, label in pairs({delete="Delete", anchor="Toggle Anchor", collide="Toggle CanCollide"}) do local btn = makeButton(label); modeButtons[mode] = btn; btn.MouseButton1Click:Connect(function() uiActions.setMode(mode); refreshModeButtons() end) end; makeButton("Undo Delete").MouseButton1Click:Connect(uiActions.undo); makeButton("Copy Delete Script").MouseButton1Click:Connect(uiActions.copy); local function drag(o,h) local d,s,p; h.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then d,s,p=true,i.Position,o.Position;i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then d=false end end)end end); h.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement and d then o.Position=UDim2.new(p.X.Scale,p.X.Offset+i.Position.X-s.X,p.Y.Scale,p.Y.Offset+i.Position.Y-s.Y)end end)end; drag(frame,header); refreshModeButtons(); table.insert(state.Connections, mouse.Move:Connect(function() setTarget(mouse.Target) end)); table.insert(state.Connections, mouse.Button1Down:Connect(function() if state.CurrentPart then modeHandlers[state.CurrentMode](state.CurrentPart) end end)) end); self.State.Tool.Unequipped:Connect(function() self:_CleanupUI() end); self.State.Tool.AncestryChanged:Connect(function(_, parent) if not parent then self:Disable() end end); DoNotif("iBTools loaded. Equip the tool to use it.", 3) end
function Modules.iBTools:Toggle() if self.State.IsActive then self:Disable() else self:Enable() end end

--==============================================================================
-- Command Definitions
--==============================================================================
table.insert(CommandInfo, { Name = "cmds", Aliases = {"help"}, Description = "Shows this command list."}); table.insert(CommandInfo, { Name = "cmdbar", Aliases = {"cbar"}, Description = "Toggles the private command bar."}); table.insert(CommandInfo, { Name = "ide", Aliases = {}, Description = "Opens a script execution window."}); table.insert(CommandInfo, { Name = "ibtools", Aliases = {}, Description = "Loads a building helper tool for deleting/modifying parts."}); table.insert(CommandInfo, { Name = "speed", Aliases = {}, Description = "Sets walkspeed. ;speed [num]"}); table.insert(CommandInfo, { Name = "fly", Aliases = {}, Description = "Toggles smooth flight mode."}); table.insert(CommandInfo, { Name = "noclip", Aliases = {}, Description = "Toggles walking through walls."}); table.insert(CommandInfo, { Name = "clicktp", Aliases = {}, Description = "Hold Left CTRL to teleport to cursor."}); table.insert(CommandInfo, { Name = "esp", Aliases = {}, Description = "Toggles player outline, name, and team."}); table.insert(CommandInfo, { Name = "grabtools", Aliases = {}, Description = "Auto-grabs tools that appear."}); table.insert(CommandInfo, { Name = "goto", Aliases = {}, Description = "Teleports to a player. ;goto [player]"}); table.insert(CommandInfo, { Name = "reverse", Aliases = {}, Description = "Reverses your character direction."}); table.insert(CommandInfo, { Name = "reach", Aliases = {"swordreach"}, Description = "Extends sword reach. ;reach [num]"}); table.insert(CommandInfo, { Name = "boxreach", Aliases = {}, Description = "Creates a box hitbox. ;boxreach [num]"}); table.insert(CommandInfo, { Name = "resetreach", Aliases = {"unreach"}, Description = "Resets tool reach to normal."}); table.insert(CommandInfo, { Name = "wallwalk", Aliases = {"ww"}, Description = "Toggles the ability to walk on walls."}); -- ADDED THIS LINE
table.insert(CommandInfo, { Name = "iy", Aliases = {"zgui"}, Description = "Loads Zuka's personal executor/admin panel."}); table.insert(CommandInfo, { Name = "dex", Aliases = {"aimbot"}, Description = "Opens an Aimbot Gui."}); table.insert(CommandInfo, { Name = "scripthub", Aliases = {"hub"}, Description = "Opens a versatile script hub GUI."}); table.insert(CommandInfo, { Name = "teleportgui", Aliases = {"tpui", "uviewer"}, Description = "Opens a GUI to teleport to other game places."})

-- Simple and Loadstring Commands
Commands.speed = function(args) local s = tonumber(args[1]); local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if not h then DoNotif("Humanoid not found!", 3) return end; if s and s > 0 then h.WalkSpeed = s; DoNotif("WalkSpeed set to: " .. s, 3) else DoNotif("Invalid speed.", 3) end end
Commands.goto = function(args) local name = tostring(args[1]):lower(); if not name then return DoNotif("Specify a player.", 3) end; for _, plr in ipairs(Players:GetPlayers()) do if plr.Name:lower():sub(1, #name) == name then local hrp = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart; local thrp = plr.Character and plr.Character.HumanoidRootPart; if hrp and thrp then hrp.CFrame = thrp.CFrame + Vector3.new(0,3,0); DoNotif("Teleported to "..plr.Name, 3) else DoNotif("Target has no character.",3) end; return end end; DoNotif("Player not found.", 3) end
Commands.reverse = function() local hrp = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart; if hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.pi, 0) end end
Commands.iy = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptlisenbe-stack/luaprojectse3/refs/heads/main/ZukasExecutor.lua"))() end); DoNotif("Loading Zuka's Executor...", 3) end
Commands.dex = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/scriptlisenbe-stack/luaprojectse3/refs/heads/main/trashaimbot.lua"))() end); DoNotif("Loading AimGui", 3) end
Commands.scripthub = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/ScriptHubNA.lua"))() end); DoNotif("Loading Script Hub...", 2) end
Commands.teleportgui = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Universe%20Viewer"))() end); DoNotif("Loading Teleport GUI...", 2) end
Commands.wallwalk = function() pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/WallWalk.lua"))() end); DoNotif("Loading WallWalk...", 2) end -- ADDED THIS LINE

-- Command wrappers for modules
Commands.fly = function() Modules.Fly:Toggle() end; Commands.flyspeed = function(args) Modules.Fly:SetSpeed(args[1]) end; Commands.noclip = function() Modules.Noclip:Toggle() end; Commands.clickfling = function() Modules.ClickFling:Enable() end; Commands.unclickfling = function() Modules.ClickFling:Disable() end; Commands.cmds = function() Modules.CommandsUI:Toggle() end; Commands.reach = function(args) Modules.Reach:Apply("directional", tonumber(args[1]) or 15) end; Commands.boxreach = function(args) Modules.Reach:Apply("box", tonumber(args[1]) or 15) end; Commands.resetreach = function() Modules.Reach:Reset() end; Commands.cmdbar = function() Modules.CommandBar:Toggle() end; Commands.ide = function() Modules.IDE:Toggle() end; Commands.esp = function() Modules.ESP:Toggle() end; Commands.clicktp = function() Modules.ClickTP:Toggle() end; Commands.grabtools = function() Modules.GrabTools:Toggle() end; Commands.ibtools = function() Modules.iBTools:Toggle() end

-- Command Aliases
Commands.help = Commands.cmds; Commands.cbar = Commands.cmdbar; Commands.swordreach = Commands.reach; Commands.unreach = Commands.resetreach; Commands.hub = Commands.scripthub; Commands.tpui = Commands.teleportgui; Commands.uviewer = Commands.teleportgui; Commands.ww = Commands.wallwalk -- ADDED THIS LINE

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
DoNotif("Zuka Command Handler v13 (Definitive) | Prefix: '" .. Prefix .. "' | ;cmds for help", 6)

local debugX = true

-- prevent double-loading
if getgenv().ZukaLuaHub then
    warn("Zuka Hub is already loaded. (You can comment this guard for testing.)")
    -- For testing, do NOT return here. Comment out the return so you can debug loader issues.
    -- return
end
getgenv().ZukaLuaHub = true

-- load Rayfield safely
local _ok, _ray = pcall(function()
    print("[ZukaHub] Fetching Rayfield...")
    local src = game:HttpGet('https://sirius.menu/rayfield')
    print("[ZukaHub] Rayfield script length:", src and #src or "nil")
    local loader, err = loadstring(src)
    if not loader then error("Rayfield loadstring failed: " .. tostring(err)) end
    local lib = loader()
    print("[ZukaHub] Rayfield loaded:", lib and typeof(lib))
    return lib
end)
if not _ok or not _ray then
    warn("Failed to load Rayfield library; Zuka Hub cannot continue.")
    print("Rayfield load error:", tostring(_ray))
    return
end
local Rayfield = _ray

print("[ZukaHub] Creating Rayfield window...")
local Window = Rayfield:CreateWindow({
    Name = "Zuka Hub",
    LoadingTitle = "- Zuka Tech Internal -",
    LoadingSubtitle = "(Where skill meets ambition.)",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "ZukaHub"
    },
    KeySystem = false
})
print("[ZukaHub] Rayfield window created.")

-- === Commands Tab ===
local CommandsTab = Window:CreateTab("Commands", 4483362458)

-- === External Addons Section ===
local ExternalSection = CommandsTab:CreateSection("Main Addons")

-- helper for quick button creation
local function normalizeUrl(url)
    if not url or type(url) ~= "string" then return url end
    -- fix common GitHub blob/refs/heads patterns
    if url:find("raw.githubusercontent.com") then
        return url
    end
    if url:find("github.com") then
        url = url:gsub("https://github.com/", "https://raw.githubusercontent.com/")
        url = url:gsub("/blob/", "/")
        url = url:gsub("/tree/", "/")
        url = url:gsub("/refs/heads/", "/")
        return url
    end
    -- convert pastebin short links to raw
    if url:find("pastebin.com/") and not url:find("pastebin.com/raw/") then
        return url:gsub("pastebin.com/", "pastebin.com/raw/")
    end
    return url
end

local function safeButton(name, url, successMsg)
    CommandsTab:CreateButton({
        Name = name,
        Callback = function()
            local finalUrl = normalizeUrl(url)
            local fetchOk, src = pcall(function()
                return game:HttpGet(finalUrl)
            end)
            if not fetchOk or not src then
                warn("Failed to fetch " .. tostring(name) .. " from " .. tostring(finalUrl))
                return
            end
            local func, loadErr = loadstring(src)
            if not func then
                warn("Failed to load string for " .. tostring(name) .. ": " .. tostring(loadErr))
                return
            end
            local ranOk, runErr = pcall(func)
            if ranOk then
                print(successMsg or (name .. " Loaded"))
            else
                warn("Error running " .. tostring(name) .. ": " .. tostring(runErr))
            end
        end
    })
end

-- External command buttons
safeButton("Dex", "https://raw.githubusercontent.com/scriptlisenbe-stack/luaprojectse3/refs/heads/main/CustomDex.lua", "Dex+ Started")
safeButton("Fly GUI", "https://raw.githubusercontent.com/396abc/Script/refs/heads/main/FlyR15.lua", "Fly GUI Started")
safeButton("Admin UI", "https://raw.githubusercontent.com/bloxtech1/luaprojects2/refs/heads/main/zukaadminnameless.lua", "Admin Activated")
safeButton("Pentesting Remotes", "https://raw.githubusercontent.com/scriptlisenbe-stack/luaprojectse3/refs/heads/main/RemoteEvent_Pentester_OP.txt", "Sigma Loaded")
safeButton("Zenith Hub +", "https://raw.githubusercontent.com/Zenith-Devs/Zenith-Hub/main/loader", "Ui Activated")
safeButton("Wall-Walking", "https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/WallWalk.lua", "Swag Started")
safeButton("Script-Blox API", "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/ScriptHubNA.lua", "Server Searcher Loaded")
safeButton("Universe Explorer", "https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Universe%20Viewer", "Explorer Loaded")
safeButton("Server Hopper", "https://raw.githubusercontent.com/Pnsdgsa/Script-kids/refs/heads/main/Advanced%20Server%20Hop.lua", "Gui Started..")
safeButton("Fling GUI", "https://raw.githubusercontent.com/miso517/scirpt/refs/heads/main/main.lua", "Fling GUI Loaded")
safeButton("Blox Fruits", "https://rawscripts.net/raw/Arise-Crossover-Speed-Hub-X-33730", "Blox Fruits")
safeButton("Copy Console", "https://raw.githubusercontent.com/scriptlisenbe-stack/luaprojectse3/refs/heads/main/consolecopy.lua", "Loaded")
safeButton("Player Attach + Follower", "https://raw.githubusercontent.com/zukatech1/customluascripts/refs/heads/main/flingaddon.lua", "Follower GUI Loaded")
safeButton("Chams (ESP)", "https://raw.githubusercontent.com/zukatech1/customluascripts/refs/heads/main/esp.lua", "ESP Loaded")
safeButton("Working Chat Bypass", "https://raw.githubusercontent.com/shadow62x/catbypass/main/upfix", "Bypass Activated")
safeButton("Ketamine/Spy", "https://raw.githubusercontent.com/InfernusScripts/Ketamine/refs/heads/main/Ketamine.lua", "Cherry Activated")
safeButton("ZukaBot AI V1", "https://raw.githubusercontent.com/zukatech1/customluascripts/refs/heads/main/Broken.lua", "Bot v1 Loaded")
safeButton("ZukaBot AI V2", "https://raw.githubusercontent.com/theogcheater2020-pixel/luaprojects2/refs/heads/main/chat.lua", "Bot v2 Loaded")
safeButton("Zombie Game Upd3", "https://raw.githubusercontent.com/osukfcdays/zlfucker/refs/heads/main/.luau", "Zombie GUI Started")
safeButton("Zombie Attack Auto", "https://raw.githubusercontent.com/evelynnscripts/Evelynn-Hub/refs/heads/main/zombie-attack.lua", "Hub Loaded")


-- === Utilities Section ===
local UtilityTab = Window:CreateTab("Utilities", 4483362458)
local UtilitySection = UtilityTab:CreateSection("Utilities")

UtilityTab:CreateButton({
    Name = "Rejoin Game",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})

UtilityTab:CreateButton({
    Name = "Exploit Creator",
    Callback = function()
        loadstring(game:HttpGet("https://e-vil.com/anbu/rem.lua"))()
    end
})





-- === Cleanup Section ===
local CleanupTab = Window:CreateTab("Hub Settings", 4483362458)
local CleanupSection = CleanupTab:CreateSection("Hub Settings")

CleanupTab:CreateButton({
    Name = "Exit Zuka Hub",
    Callback = function()
        pcall(function() Rayfield:Destroy() end)
        getgenv().ZukaLuaHub = nil
        print("Zuka Hub unloaded and cleaned up.")
    end
})

-- === Load configuration last ===
print("[ZukaHub] Loading Rayfield configuration...")
Rayfield:LoadConfiguration()
print("[ZukaHub] Rayfield configuration loaded.")
