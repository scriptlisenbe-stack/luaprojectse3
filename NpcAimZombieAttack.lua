-- Drawing ESP + Aimbot Script - Pro Refactor by Zuka Tech
-- Fixes camera conflict by synchronizing character rotation to mimic Shift Lock,
-- providing a smooth and responsive lock-on experience.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ESP Settings
local ESP_ENABLED = true
local ESP_COLOR = Color3.fromRGB(255, 255, 255)

-- Aimbot Settings
local AIMBOT_ENABLED = true
local AIMBOT_SMOOTHNESS = 15 -- Higher value = stronger/faster lock-on. (Recommended: 10-25)
local AIMBOT_FOV = 90
local AIMBOT_KEY = Enum.UserInputType.MouseButton2

-- Internal State
local aiming = false
local espObjects = {}
local originalCameraType = Camera.CameraType

-- Create Drawing ESP for a target
local function createESP(target)
    if not target or not target.Parent or espObjects[target] then return end
    
    local esp = {}
    if Drawing then
        esp.box = Drawing.new("Square"); esp.box.Visible = false; esp.box.Color = ESP_COLOR;
        esp.box.Thickness = 2; esp.box.Transparency = 1; esp.box.Filled = false
        
        esp.name = Drawing.new("Text"); esp.name.Visible = false; esp.name.Color = ESP_COLOR;
        esp.name.Size = 16; esp.name.Center = true; esp.name.Outline = true; esp.name.Font = 2
        esp.name.Text = target.Name
        
        espObjects[target] = esp
    end
end

-- Remove Drawing ESP
local function removeESP(target)
    if espObjects[target] then
        for _, obj in pairs(espObjects[target]) do obj:Remove() end
        espObjects[target] = nil
    end
end

-- Get all valid targets from the workspace
local function getAllTargets()
    local targets = {}
    local function addTargetsFrom(folder)
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                if child:IsA("Model") and child ~= LocalPlayer.Character and child:FindFirstChild("HumanoidRootPart") then
                    table.insert(targets, child)
                end
            end
        end
    end
    addTargetsFrom(workspace:FindFirstChild("enemies"))
    addTargetsFrom(workspace:FindFirstChild("BossFolder"))
    return targets
end

-- Get the best part to aim at from a model
local function getAimPart(target)
    if not target or not target:IsA("Model") then return nil end
    -- Prioritize Head, then HumanoidRootPart, then Torso for effective aiming.
    return target:FindFirstChild("Head") 
        or target:FindFirstChild("HumanoidRootPart") 
        or target:FindFirstChild("Torso")
        or target.PrimaryPart
end

-- Find the closest valid target within the FOV circle
local function getClosestTarget()
    local closestTarget, shortestDistance = nil, AIMBOT_FOV
    local mousePosition = UserInputService:GetMouseLocation()

    for _, target in ipairs(getAllTargets()) do
        local part = getAimPart(target)
        if part then
            local vector, onScreen = Camera:WorldToScreenPoint(part.Position)
            if onScreen then
                local distance = (Vector2.new(vector.X, vector.Y) - mousePosition).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestTarget = part
                end
            end
        end
    end
    return closestTarget
end

-- Update Drawing ESP positions on the screen
local function updateESP()
    if not ESP_ENABLED then return end
    
    local validTargets, targetMap = getAllTargets(), {}
    for _, target in ipairs(validTargets) do
        targetMap[target] = true
        if not espObjects[target] then createESP(target) end
    end

    for target in pairs(espObjects) do
        if not targetMap[target] then removeESP(target) end
    end

    for target, esp in pairs(espObjects) do
        local part = getAimPart(target)
        if part and part.Parent then
            local vector, onScreen = Camera:WorldToScreenPoint(part.Position)
            if onScreen then
                local headPos, footPos = part.Position + Vector3.new(0, 2.5, 0), part.Position - Vector3.new(0, 3, 0)
                local headVec, footVec = Camera:WorldToScreenPoint(headPos), Camera:WorldToScreenPoint(footPos)
                local boxHeight, boxWidth = math.abs(headVec.Y - footVec.Y), math.abs(headVec.Y - footVec.Y) * 0.6
                
                if esp.box then
                    esp.box.Size, esp.box.Position = Vector2.new(boxWidth, boxHeight), Vector2.new(vector.X - boxWidth / 2, vector.Y - boxHeight / 2)
                    esp.box.Visible = true
                end
                if esp.name then
                    esp.name.Position, esp.name.Visible = Vector2.new(vector.X, footVec.Y - 5), true
                end
            else
                if esp.box then esp.box.Visible = false end
                if esp.name then esp.name.Visible = false end
            end
        else
            removeESP(target)
        end
    end
end

-- Input handling to manage camera control state
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == AIMBOT_KEY and AIMBOT_ENABLED then
        aiming = true
        originalCameraType = Camera.CameraType
        Camera.CameraType = Enum.CameraType.Scriptable
    elseif input.KeyCode == Enum.KeyCode.F then
        ESP_ENABLED = not ESP_ENABLED
        print("ESP:", ESP_ENABLED and "ON" or "OFF")
        if not ESP_ENABLED then
            for target in pairs(espObjects) do removeESP(target) end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AIMBOT_KEY and AIMBOT_ENABLED then
        aiming = false
        Camera.CameraType = originalCameraType
    end
end)

-- Main loop for aiming and ESP updates
RunService.RenderStepped:Connect(function(deltaTime)
    updateESP()
    
    if aiming then
        local targetPart = getClosestTarget()
        if targetPart then
            -- Aim the camera
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            local smoothingAlpha = 1 - math.exp(-AIMBOT_SMOOTHNESS * deltaTime)
            local newCameraCFrame = Camera.CFrame:Lerp(targetCFrame, smoothingAlpha)
            Camera.CFrame = newCameraCFrame
            
            -- [CRITICAL FIX] Synchronize character rotation with the camera to replicate Shift Lock
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local cameraLookVector = newCameraCFrame.LookVector
                -- We only want to affect horizontal rotation, so we zero out the Y component.
                local lookAtPosition = hrp.Position + Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z)
                hrp.CFrame = CFrame.new(hrp.Position, lookAtPosition)
            end
        end
    end
end)

-- Initial setup
local function setupTargetListeners()
    local function listen(folder)
        if folder then folder.ChildAdded:Connect(createESP) end
    end
    listen(workspace:FindFirstChild("enemies"))
    listen(workspace:FindFirstChild("BossFolder"))
end

setupTargetListeners()
print("Zuka Aimbot/ESP v3 (Shift Lock Fix) loaded successfully!")
print("Hold RMB to aim, Press F to toggle ESP")