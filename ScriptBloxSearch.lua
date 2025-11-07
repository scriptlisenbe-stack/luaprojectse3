
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local camera = workspace.CurrentCamera
local SCREEN_SIZE = camera.ViewportSize
local isSmallScreen = isMobile or SCREEN_SIZE.X < 800

local menuScale = 0.75
local minScale, maxScale = 0.5, 1.0
local scaleStep = 0.05

local scriptCache = {}

local function HttpGet(url)
    for i = 1, 5 do
        local s, r = pcall(game.HttpGet, game, url, true)
        if s and r and #r > 50 then return r end
        task.wait(1)
    end
    return nil
end

local function formatTime(utc)
    if not utc then return "Recent" end
    local y,m,d,h,min = utc:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+)")
    if y then
        local t = os.time{year=y, month=m, day=d, hour=h, min=min}
        return os.date("%m.%d %H:%M", t)
    end
    return utc:sub(1,16)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScriptBloxPro"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local function updateFrameSize()
    local w = SCREEN_SIZE.X * menuScale
    local h = SCREEN_SIZE.Y * menuScale
    mainFrame.Size = UDim2.new(0, w - 40, 0, h - 40)
end
updateFrameSize()
mainFrame.Position = UDim2.new(0.5, -mainFrame.Size.X.Offset/2, 0.5, -mainFrame.Size.Y.Offset/2)

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(55, 55, 70)
stroke.Thickness = 1.8
stroke.Parent = mainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundTransparency = 1
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -120, 1, 0)
title.BackgroundTransparency = 1
title.Text = "ScriptBlox"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = header

local dragging = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

header.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local resizeContainer = Instance.new("Frame")
resizeContainer.Size = UDim2.new(0, 100, 0, 35)
resizeContainer.Position = UDim2.new(1, -110, 0, 5)
resizeContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
resizeContainer.Parent = header

local rcCorner = Instance.new("UICorner")
rcCorner.CornerRadius = UDim.new(0, 12)
rcCorner.Parent = resizeContainer

local rcStroke = Instance.new("UIStroke")
rcStroke.Color = Color3.fromRGB(70, 70, 80)
rcStroke.Thickness = 1
rcStroke.Parent = resizeContainer

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 30, 1, 0)
minusBtn.BackgroundTransparency = 1
minusBtn.Text = "-"
minusBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minusBtn.TextScaled = true
minusBtn.Font = Enum.Font.GothamBold
minusBtn.Parent = resizeContainer

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 30, 1, 0)
plusBtn.Position = UDim2.new(1, -30, 0, 0)
plusBtn.BackgroundTransparency = 1
plusBtn.Text = "+"
plusBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
plusBtn.TextScaled = true
plusBtn.Font = Enum.Font.GothamBold
plusBtn.Parent = resizeContainer

local scaleLabel = Instance.new("TextLabel")
scaleLabel.Size = UDim2.new(0, 40, 1, 0)
scaleLabel.Position = UDim2.new(0, 30, 0, 0)
scaleLabel.BackgroundTransparency = 1
scaleLabel.Text = math.floor(menuScale * 100) .. "%"
scaleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
scaleLabel.TextScaled = true
scaleLabel.Font = Enum.Font.Gotham
scaleLabel.Parent = resizeContainer

minusBtn.MouseButton1Click:Connect(function()
    menuScale = math.max(minScale, menuScale - scaleStep)
    scaleLabel.Text = math.floor(menuScale * 100) .. "%"
    updateFrameSize()
end)

plusBtn.MouseButton1Click:Connect(function()
    menuScale = math.min(maxScale, menuScale + scaleStep)
    scaleLabel.Text = math.floor(menuScale * 100) .. "%"
    updateFrameSize()
end)

local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(1, -24, 0, 40)
searchFrame.Position = UDim2.new(0, 12, 0, 50)
searchFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
searchFrame.Parent = mainFrame

local sCorner = Instance.new("UICorner")
sCorner.CornerRadius = UDim.new(0, 14)
sCorner.Parent = searchFrame

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -50, 1, 0)
searchBox.Position = UDim2.new(0, 12, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.PlaceholderText = "Search..."
searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(220, 220, 220)
searchBox.PlaceholderColor3 = Color3.fromRGB(130, 130, 130)
searchBox.TextScaled = true
searchBox.Font = Enum.Font.Gotham
searchBox.Parent = searchFrame

local searchEmoji = Instance.new("TextLabel")
searchEmoji.Size = UDim2.new(0, 28, 0, 28)
searchEmoji.Position = UDim2.new(1, -38, 0.5, -14)
searchEmoji.BackgroundTransparency = 1
searchEmoji.Text = "🔎"
searchEmoji.TextColor3 = Color3.fromRGB(120, 120, 120)
searchEmoji.TextScaled = true
searchEmoji.Font = Enum.Font.Gotham
searchEmoji.Parent = searchFrame

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -24, 0, 40)
tabFrame.Position = UDim2.new(0, 12, 0, 95)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabs = {"all", "trending", "games"}
local tabButtons = {}
local tabNames = {all = "All", trending = "Trending", games = "Games"}

for i, tab in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.31, 0, 1, 0)
    btn.Position = UDim2.new((i-1)*0.345, 0, 0, 0)
    btn.BackgroundColor3 = (tab == "all") and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(50, 50, 60)
    btn.Text = tabNames[tab]
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tabFrame
    tabButtons[tab] = btn

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = btn
end

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -24, 1, -150)
content.Position = UDim2.new(0, 12, 0, 140)
content.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
content.Parent = mainFrame

local cCorner = Instance.new("UICorner")
cCorner.CornerRadius = UDim.new(0, 16)
cCorner.Parent = content

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -16)
scroll.Position = UDim2.new(0, 8, 0, 8)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 8
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = content

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.FillDirection = Enum.FillDirection.Vertical
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local currentTab = "all"
local loading = false

local function clear()
    for _, v in pairs(scroll:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
end

local function fetchScriptCode(scriptId, callback)
    if scriptCache[scriptId] then
        callback(scriptCache[scriptId])
        return
    end

    local url = "https://scriptblox.com/api/script/fetch?script_id=" .. scriptId
    spawn(function()
        local res = HttpGet(url)
        if res then
            local s, data = pcall(HttpService.JSONDecode, HttpService, res)
            if s and data and data.result and data.result.script then
                scriptCache[scriptId] = data.result.script
                callback(data.result.script)
                return
            end
        end
        callback(nil)
    end)
end

local function createCard(data)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 115)
    card.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    card.BorderSizePixel = 0
    card.Parent = scroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.Parent = card

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -210, 0, 26)
    title.BackgroundTransparency = 1
    title.Text = data.title or "Untitled"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local game = Instance.new("TextLabel")
    game.Size = UDim2.new(1, -210, 0, 20)
    game.Position = UDim2.new(0, 0, 0, 30)
    game.BackgroundTransparency = 1
    game.Text = "Game: " .. (data.game and data.game.name or "Universal")
    game.TextColor3 = Color3.fromRGB(130, 200, 255)
    game.TextScaled = true
    game.Font = Enum.Font.Gotham
    game.TextXAlignment = Enum.TextXAlignment.Left
    game.Parent = card

    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(1, -210, 0, 22)
    statsFrame.Position = UDim2.new(0, 0, 0, 54)
    statsFrame.BackgroundTransparency = 1
    statsFrame.Parent = card

    local likesEmoji = Instance.new("TextLabel")
    likesEmoji.Size = UDim2.new(0, 22, 0, 22)
    likesEmoji.Position = UDim2.new(0, 0, 0, 0)
    likesEmoji.BackgroundTransparency = 1
    likesEmoji.Text = "👍"
    likesEmoji.TextColor3 = Color3.fromRGB(255, 200, 0)
    likesEmoji.TextScaled = true
    likesEmoji.Font = Enum.Font.Gotham
    likesEmoji.Parent = statsFrame

    local likesText = Instance.new("TextLabel")
    likesText.Size = UDim2.new(0, 50, 1, 0)
    likesText.Position = UDim2.new(0, 24, 0, 0)
    likesText.BackgroundTransparency = 1
    likesText.Text = tostring(data.likeCount or 0)
    likesText.TextColor3 = Color3.fromRGB(220, 220, 220)
    likesText.TextScaled = true
    likesText.Font = Enum.Font.Gotham
    likesText.TextXAlignment = Enum.TextXAlignment.Left
    likesText.Parent = statsFrame

    local viewsEmoji = Instance.new("TextLabel")
    viewsEmoji.Size = UDim2.new(0, 22, 0, 22)
    viewsEmoji.Position = UDim2.new(0, 80, 0, 0)
    viewsEmoji.BackgroundTransparency = 1
    viewsEmoji.Text = "👁️"
    viewsEmoji.TextColor3 = Color3.fromRGB(100, 200, 255)
    viewsEmoji.TextScaled = true
    viewsEmoji.Font = Enum.Font.Gotham
    viewsEmoji.Parent = statsFrame

    local viewsText = Instance.new("TextLabel")
    viewsText.Size = UDim2.new(0, 60, 1, 0)
    viewsText.Position = UDim2.new(0, 104, 0, 0)
    viewsText.BackgroundTransparency = 1
    viewsText.Text = tostring(data.views or 0)
    viewsText.TextColor3 = Color3.fromRGB(220, 220, 220)
    viewsText.TextScaled = true
    viewsText.Font = Enum.Font.Gotham
    viewsText.TextXAlignment = Enum.TextXAlignment.Left
    viewsText.Parent = statsFrame

    local timeText = Instance.new("TextLabel")
    timeText.Size = UDim2.new(0, 100, 1, 0)
    timeText.Position = UDim2.new(0, 170, 0, 0)
    timeText.BackgroundTransparency = 1
    timeText.Text = formatTime(data.createdAt)
    timeText.TextColor3 = Color3.fromRGB(150, 150, 150)
    timeText.TextScaled = true
    timeText.Font = Enum.Font.Gotham
    timeText.TextXAlignment = Enum.TextXAlignment.Left
    timeText.Parent = statsFrame

    local titleBtn = Instance.new("TextButton")
    titleBtn.Size = UDim2.new(0, 60, 0, 32)
    titleBtn.Position = UDim2.new(1, -210, 0.5, -16)
    titleBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    titleBtn.Text = "TITLE"
    titleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleBtn.TextScaled = true
    titleBtn.Font = Enum.Font.GothamBold
    titleBtn.Parent = card
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 10)
    tc.Parent = titleBtn

    local run = Instance.new("TextButton")
    run.Size = UDim2.new(0, 65, 0, 32)
    run.Position = UDim2.new(1, -140, 0.5, -16)
    run.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    run.Text = "RUN"
    run.TextColor3 = Color3.fromRGB(255, 255, 255)
    run.TextScaled = true
    run.Font = Enum.Font.GothamBold
    run.Parent = card
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 10)
    rc.Parent = run

    local copy = Instance.new("TextButton")
    copy.Size = UDim2.new(0, 65, 0, 32)
    copy.Position = UDim2.new(1, -70, 0.5, -16)
    copy.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    copy.Text = "COPY"
    copy.TextColor3 = Color3.fromRGB(255, 255, 255)
    copy.TextScaled = true
    copy.Font = Enum.Font.GothamBold
    copy.Parent = card
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 10)
    cc.Parent = copy

    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
    end)

    titleBtn.MouseButton1Click:Connect(function()
        pcall(setclipboard, data.title or "Untitled")
        titleBtn.Text = "OK"
        titleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        task.delay(1, function()
            if titleBtn and titleBtn.Parent then
                titleBtn.Text = "TITLE"
                titleBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            end
        end)
    end)

    run.MouseButton1Click:Connect(function()
        local function execute(code)
            if code then
                local s, f = pcall(loadstring, code)
                if s and f then pcall(f) end
            end
        end

        if data.script then
            execute(data.script)
        else
            run.Text = "Loading..."
            fetchScriptCode(data._id, function(code)
                if code then execute(code) end
                run.Text = "RUN"
            end)
        end
    end)

    copy.MouseButton1Click:Connect(function()
        copy.Text = "Loading..."
        copy.BackgroundColor3 = Color3.fromRGB(180, 120, 0)

        local function tryCopy(code)
            if code and code ~= "" then
                pcall(setclipboard, code)
                copy.Text = "OK"
                copy.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            else
                copy.Text = "Error"
                copy.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            end
            task.delay(1.2, function()
                if copy and copy.Parent then
                    copy.Text = "COPY"
                    copy.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
                end
            end)
        end

        if data.script then
            tryCopy(data.script)
        else
            fetchScriptCode(data._id, tryCopy)
        end
    end)
end

local function loadScripts(urlBase, query)
    local all = {}
    local page = 1
    local max = 12

    repeat
        local url = urlBase
        if query and query ~= "" then
            url = url .. (url:find("?") and "&" or "?") .. "q=" .. HttpService:UrlEncode(query) .. "&page=" .. page
        else
            url = url .. (url:find("?") and "&" or "?") .. "page=" .. page
        end

        local res = HttpGet(url)
        if not res then break end

        local s, data = pcall(HttpService.JSONDecode, HttpService, res)
        if not s or not data.result or not data.result.scripts then break end

        for _, s in ipairs(data.result.scripts) do
            if #all >= 100 then break end
            table.insert(all, s)
        end

        if #data.result.scripts == 0 then break end
        page += 1
        task.wait(0.25)
    until page > max or #all >= 100

    return all
end

local function showTab(tab)
    if loading then return end
    loading = true
    currentTab = tab
    clear()

    for t, b in pairs(tabButtons) do
        b.BackgroundColor3 = (t == tab) and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(50, 50, 60)
    end

    local url = ""
    if tab == "all" then url = "https://scriptblox.com/api/script/fetch"
    elseif tab == "trending" then url = "https://scriptblox.com/api/script/trending"
    elseif tab == "games" then url = "https://scriptblox.com/api/script/search"
    end

    local query = searchBox.Text ~= "" and searchBox.Text or nil
    local scripts = loadScripts(url, query)

    if #scripts > 0 then
        for _, s in ipairs(scripts) do
            createCard(s)
        end
    else
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 50)
        lbl.BackgroundTransparency = 1
        lbl.Text = query and "Nothing found" or "Empty"
        lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
        lbl.TextScaled = true
        lbl.Font = Enum.Font.Gotham
        lbl.Parent = scroll
    end

    loading = false
end

for tab, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function() showTab(tab) end)
end

searchBox.FocusLost:Connect(function(enter)
    if enter then
        showTab(currentTab)
    end
end)

RunService.Heartbeat:Connect(function()
    local newSize = camera.ViewportSize
    if newSize.X ~= SCREEN_SIZE.X or newSize.Y ~= SCREEN_SIZE.Y then
        SCREEN_SIZE = newSize
        updateFrameSize()
        mainFrame.Position = UDim2.new(0.5, -mainFrame.Size.X.Offset/2, 0.5, -mainFrame.Size.Y.Offset/2)
    end
end)

task.wait(1)
showTab("all")