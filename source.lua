local Library = {}

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")

local Mobile      = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local function ShowImage(config)
    config = config or {}
    if getgenv().ShowImage and getgenv().ShowImage ~= ShowImage then return end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ImageDisplay_" .. HttpService:GenerateGUID(false)
    screenGui.DisplayOrder = 999
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.ScreenInsets = Enum.ScreenInsets.None
    screenGui.Parent = CoreGui
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Size = UDim2.new(0, config.size or 400, 0, config.size or 400)
    imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = config.url or ""
    imageLabel.Parent = screenGui
    if config.duration then
        task.delay(config.duration, function() screenGui:Destroy() end)
    end
    return screenGui
end
if not getgenv().ShowImage then getgenv().ShowImage = ShowImage end

local LucideLoaded = false
local Lucide = {}

local function LoadLucide()
    if LucideLoaded then return end
    LucideLoaded = true
    local ok, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ArchIsDead/Arch-Vault/refs/heads/main/lucide-icons.lua"))()
    end)
    if ok and type(result) == "table" then
        for k, v in pairs(result) do
            Lucide[k] = v
        end
    end
    local fallback = {
        ["lucide-mouse-2"] = "rbxassetid://10088146939",
        ["lucide-internet"] = "rbxassetid://12785195438",
        ["lucide-earth"] = "rbxassetid://115986292591138",
        ["lucide-settings-3"] = "rbxassetid://14007344336",
        ["lucide-accessibility"] = "rbxassetid://10709751939",
        ["lucide-activity"] = "rbxassetid://10709752035",
        ["lucide-alert-circle"] = "rbxassetid://10709752996",
        ["lucide-alert-triangle"] = "rbxassetid://10709753149",
        ["lucide-arrow-down"] = "rbxassetid://10709767827",
        ["lucide-arrow-left"] = "rbxassetid://10709768114",
        ["lucide-arrow-right"] = "rbxassetid://10709768347",
        ["lucide-arrow-up"] = "rbxassetid://10709768939",
        ["lucide-award"] = "rbxassetid://10709769406",
        ["lucide-bell"] = "rbxassetid://10709775704",
        ["lucide-bolt"] = "rbxassetid://10747813908",
        ["lucide-bookmark"] = "rbxassetid://10709782154",
        ["lucide-box"] = "rbxassetid://10709782497",
        ["lucide-bug"] = "rbxassetid://10709782845",
        ["lucide-calendar"] = "rbxassetid://10709789505",
        ["lucide-camera"] = "rbxassetid://10709789686",
        ["lucide-check"] = "rbxassetid://10709790644",
        ["lucide-check-circle"] = "rbxassetid://10709790387",
        ["lucide-chevron-down"] = "rbxassetid://10709790948",
        ["lucide-chevron-left"] = "rbxassetid://10709791015",
        ["lucide-chevron-right"] = "rbxassetid://10709791130",
        ["lucide-chevron-up"] = "rbxassetid://10709791280",
        ["lucide-clock"] = "rbxassetid://10709805144",
        ["lucide-code"] = "rbxassetid://10709810463",
        ["lucide-cog"] = "rbxassetid://10709810948",
        ["lucide-copy"] = "rbxassetid://10709812159",
        ["lucide-cpu"] = "rbxassetid://10709813383",
        ["lucide-database"] = "rbxassetid://10709818996",
        ["lucide-download"] = "rbxassetid://10723344270",
        ["lucide-edit"] = "rbxassetid://10734883598",
        ["lucide-eye"] = "rbxassetid://10723346518",
        ["lucide-eye-off"] = "rbxassetid://10723346411",
        ["lucide-file"] = "rbxassetid://10723374641",
        ["lucide-filter"] = "rbxassetid://10723374641",
        ["lucide-flag"] = "rbxassetid://10723374641",
        ["lucide-folder"] = "rbxassetid://10723374641",
        ["lucide-globe"] = "rbxassetid://12785195438",
        ["lucide-heart"] = "rbxassetid://10723374641",
        ["lucide-home"] = "rbxassetid://10723374641",
        ["lucide-image"] = "rbxassetid://10723374641",
        ["lucide-info"] = "rbxassetid://10723374641",
        ["lucide-keyboard"] = "rbxassetid://10723374641",
        ["lucide-layers"] = "rbxassetid://10723374641",
        ["lucide-layout"] = "rbxassetid://10723374641",
        ["lucide-link"] = "rbxassetid://10723374641",
        ["lucide-list"] = "rbxassetid://10723374641",
        ["lucide-lock"] = "rbxassetid://10723374641",
        ["lucide-map"] = "rbxassetid://10723374641",
        ["lucide-maximize"] = "rbxassetid://10723374641",
        ["lucide-menu"] = "rbxassetid://10723374641",
        ["lucide-message-circle"] = "rbxassetid://10723374641",
        ["lucide-mic"] = "rbxassetid://10723374641",
        ["lucide-minimize"] = "rbxassetid://10723374641",
        ["lucide-minus"] = "rbxassetid://10723374641",
        ["lucide-moon"] = "rbxassetid://10723374641",
        ["lucide-more-horizontal"] = "rbxassetid://10723374641",
        ["lucide-more-vertical"] = "rbxassetid://10723374641",
        ["lucide-music"] = "rbxassetid://10723374641",
        ["lucide-package"] = "rbxassetid://10723374641",
        ["lucide-pause"] = "rbxassetid://10723374641",
        ["lucide-percent"] = "rbxassetid://10723374641",
        ["lucide-play"] = "rbxassetid://10723374641",
        ["lucide-plus"] = "rbxassetid://10723374641",
        ["lucide-power"] = "rbxassetid://10723374641",
        ["lucide-refresh-cw"] = "rbxassetid://10734940654",
        ["lucide-save"] = "rbxassetid://10734943366",
        ["lucide-search"] = "rbxassetid://10734944879",
        ["lucide-send"] = "rbxassetid://10734945571",
        ["lucide-settings"] = "rbxassetid://10734950309",
        ["lucide-settings-2"] = "rbxassetid://10734946495",
        ["lucide-share"] = "rbxassetid://10734950813",
        ["lucide-shield"] = "rbxassetid://10734951847",
        ["lucide-shield-check"] = "rbxassetid://10734951367",
        ["lucide-sliders"] = "rbxassetid://10734963400",
        ["lucide-smartphone"] = "rbxassetid://10734963940",
        ["lucide-star"] = "rbxassetid://10734966248",
        ["lucide-sun"] = "rbxassetid://10734974297",
        ["lucide-tag"] = "rbxassetid://10734976528",
        ["lucide-target"] = "rbxassetid://10734977012",
        ["lucide-terminal"] = "rbxassetid://10734982144",
        ["lucide-toggle-left"] = "rbxassetid://10734984834",
        ["lucide-toggle-right"] = "rbxassetid://10734985040",
        ["lucide-trash"] = "rbxassetid://10747362393",
        ["lucide-trash-2"] = "rbxassetid://10747362241",
        ["lucide-trending-up"] = "rbxassetid://10747363465",
        ["lucide-trophy"] = "rbxassetid://10747363809",
        ["lucide-upload"] = "rbxassetid://10747366434",
        ["lucide-user"] = "rbxassetid://10747373176",
        ["lucide-users"] = "rbxassetid://10747373426",
        ["lucide-wifi"] = "rbxassetid://10747382504",
        ["lucide-wrench"] = "rbxassetid://10747383470",
        ["lucide-x"] = "rbxassetid://10747384394",
        ["lucide-x-circle"] = "rbxassetid://10747383819",
        ["lucide-zoom-in"] = "rbxassetid://10747384552",
        ["lucide-zoom-out"] = "rbxassetid://10747384679",
    }
    for k, v in pairs(fallback) do
        if not Lucide[k] then Lucide[k] = v end
    end
end

task.spawn(LoadLucide)

local ConfigSystem = {}
do
    local _configs = {}
    local _activeConfig = nil

    function ConfigSystem:List()
        local list = {}
        for name in pairs(_configs) do
            table.insert(list, name)
        end
        table.sort(list)
        return list
    end

    function ConfigSystem:Create(name, data)
        if not name or name == "" then return false, "Name required" end
        _configs[name] = {
            name    = name,
            data    = data or {},
            created = os.time(),
            updated = os.time(),
        }
        return true, _configs[name]
    end

    function ConfigSystem:Load(name)
        if not _configs[name] then return false, "Config not found: " .. tostring(name) end
        _activeConfig = name
        return true, _configs[name]
    end

    function ConfigSystem:Save(name, data)
        name = name or _activeConfig
        if not name then return false, "No config specified or active" end
        if not _configs[name] then
            ConfigSystem:Create(name, data)
        else
            _configs[name].data    = data or _configs[name].data
            _configs[name].updated = os.time()
        end
        return true, _configs[name]
    end

    function ConfigSystem:Get(name)
        name = name or _activeConfig
        if not name or not _configs[name] then return nil end
        return _configs[name]
    end

    function ConfigSystem:GetData(name)
        local cfg = ConfigSystem:Get(name)
        return cfg and cfg.data or nil
    end

    function ConfigSystem:SetValue(key, value, name)
        name = name or _activeConfig
        if not name then return false, "No active config" end
        if not _configs[name] then ConfigSystem:Create(name) end
        _configs[name].data[key]  = value
        _configs[name].updated     = os.time()
        return true
    end

    function ConfigSystem:GetValue(key, name)
        name = name or _activeConfig
        if not name or not _configs[name] then return nil end
        return _configs[name].data[key]
    end

    function ConfigSystem:Delete(name)
        if not _configs[name] then return false, "Config not found" end
        _configs[name] = nil
        if _activeConfig == name then _activeConfig = nil end
        return true
    end

    function ConfigSystem:Rename(oldName, newName)
        if not _configs[oldName] then return false, "Config not found" end
        if _configs[newName] then return false, "Config already exists with new name" end
        _configs[newName] = _configs[oldName]
        _configs[newName].name = newName
        _configs[oldName] = nil
        if _activeConfig == oldName then _activeConfig = newName end
        return true
    end

    function ConfigSystem:Duplicate(name, newName)
        if not _configs[name] then return false, "Config not found" end
        newName = newName or (name .. "_copy")
        local copy = {}
        for k, v in pairs(_configs[name].data) do copy[k] = v end
        return ConfigSystem:Create(newName, copy)
    end

    function ConfigSystem:Export(name)
        name = name or _activeConfig
        if not name or not _configs[name] then return nil, "Config not found" end
        return HttpService:JSONEncode(_configs[name].data)
    end

    function ConfigSystem:Import(name, json)
        local ok, data = pcall(HttpService.JSONDecode, HttpService, json)
        if not ok then return false, "Invalid JSON" end
        return ConfigSystem:Save(name, data)
    end

    function ConfigSystem:Active()
        return _activeConfig
    end

    function ConfigSystem:SetActive(name)
        if not _configs[name] then return false, "Config not found" end
        _activeConfig = name
        return true
    end

    function ConfigSystem:Clear(name)
        name = name or _activeConfig
        if not name or not _configs[name] then return false end
        _configs[name].data    = {}
        _configs[name].updated = os.time()
        return true
    end

    function ConfigSystem:Exists(name)
        return _configs[name] ~= nil
    end

    function ConfigSystem:Count()
        local n = 0
        for _ in pairs(_configs) do n = n + 1 end
        return n
    end
end

Library.Config = ConfigSystem

function Library:Parent()
    if not RunService:IsStudio() then
        return (gethui and gethui()) or PlayerGui
    end
    return PlayerGui
end

function Library:Hex(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) or 0
    local g = tonumber(hex:sub(3, 4), 16) or 0
    local b = tonumber(hex:sub(5, 6), 16) or 0
    return Color3.fromRGB(r, g, b)
end

local function ResolveColor(v)
    if typeof(v) == "Color3" then return v end
    if type(v) == "string"   then return Library:Hex(v) end
    return v
end

local function GetExecutorName()
    if getexecutorname then
        local ok, name = pcall(getexecutorname)
        if ok and name and name ~= "" then return name end
    end
    if identifyexecutor then
        local ok, name = pcall(identifyexecutor)
        if ok and name and name ~= "" then return name end
    end
    return "Unknown Executor"
end

function Library:Create(Class, Props)
    local inst = Instance.new(Class)
    for k, v in Props do
        inst[k] = v
    end
    return inst
end

function Library:Draggable(frame)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TweenInfo.new(0.3), {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)
end

function Library:Button(parent)
    return Library:Create("TextButton", {
        Name                   = "Click",
        Parent                 = parent,
        BackgroundColor3       = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0),
        Font                   = Enum.Font.SourceSans,
        Text                   = "",
        TextColor3             = Color3.fromRGB(0, 0, 0),
        TextSize               = 14,
        ZIndex                 = parent.ZIndex + 3
    })
end

function Library:Tween(info)
    return TweenService:Create(
        info.v,
        TweenInfo.new(info.t, Enum.EasingStyle[info.s], Enum.EasingDirection[info.d]),
        info.g
    )
end

function Library.Effect(c, p)
    p.ClipsDescendants = true
    local mouse = Players.LocalPlayer:GetMouse()
    local rx = mouse.X - c.AbsolutePosition.X
    local ry = mouse.Y - c.AbsolutePosition.Y
    if rx < 0 or ry < 0 or rx > c.AbsoluteSize.X or ry > c.AbsoluteSize.Y then return end
    local circle = Library:Create("Frame", {
        Parent               = p,
        BackgroundColor3     = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.75,
        BorderSizePixel      = 0,
        AnchorPoint          = Vector2.new(0.5, 0.5),
        Position             = UDim2.new(0, rx, 0, ry),
        Size                 = UDim2.new(0, 0, 0, 0),
        ZIndex               = p.ZIndex
    })
    Library:Create("UICorner", { Parent = circle, CornerRadius = UDim.new(1, 0) })
    local t = TweenService:Create(circle, TweenInfo.new(2.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size                 = UDim2.new(0, c.AbsoluteSize.X * 1.5, 0, c.AbsoluteSize.X * 1.5),
        BackgroundTransparency = 1
    })
    t.Completed:Once(function() circle:Destroy() end)
    t:Play()
end

function Library:Asset(rbx)
    if rbx == nil then return "" end
    if typeof(rbx) == "number" then
        return "rbxassetid://" .. rbx
    end
    if typeof(rbx) == "string" then
        if rbx:match("^https?://") then
            return rbx
        end
        if rbx:find("rbxassetid://") then
            return rbx
        end
        if Lucide[rbx] then return Lucide[rbx] end
        if Lucide["lucide-" .. rbx] then return Lucide["lucide-" .. rbx] end
        if rbx:match("^%d+$") then return "rbxassetid://" .. rbx end
        return rbx
    end
    return tostring(rbx)
end

local GradientWhiteToGrey = ColorSequence.new{
    ColorSequenceKeypoint.new(0,    Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(163, 163, 163)),
    ColorSequenceKeypoint.new(1,    Color3.fromRGB(100, 100, 100))
}

local function MakeGradient(parent, rotation)
    return Library:Create("UIGradient", {
        Parent   = parent,
        Color    = GradientWhiteToGrey,
        Rotation = rotation or 90
    })
end

function Library:NewRows(parent, title, desc, T)
    local Rows = Library:Create("Frame", {
        Name             = "Rows",
        Parent           = parent,
        BackgroundColor3 = T.Row,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 40)
    })
    Library:Create("UIStroke",     { Parent = Rows, Color = T.Stroke, Thickness = 0.5 })
    Library:Create("UICorner",     { Parent = Rows, CornerRadius = UDim.new(0, 3) })
    Library:Create("UIListLayout", {
        Parent            = Rows,
        Padding           = UDim.new(0, 6),
        FillDirection     = Enum.FillDirection.Horizontal,
        SortOrder         = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })
    Library:Create("UIPadding", {
        Parent        = Rows,
        PaddingBottom = UDim.new(0, 6),
        PaddingTop    = UDim.new(0, 5)
    })

    local Vec = Library:Create("Frame", {
        Name                   = "Vectorize",
        Parent                 = Rows,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0)
    })
    Library:Create("UIPadding", {
        Parent       = Vec,
        PaddingLeft  = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    local Right = Library:Create("Frame", {
        Name                   = "Right",
        Parent                 = Vec,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0)
    })
    Library:Create("UIListLayout", {
        Parent              = Right,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Center
    })

    local Left = Library:Create("Frame", {
        Name                   = "Left",
        Parent                 = Vec,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0)
    })

    local Text = Library:Create("Frame", {
        Name                   = "Text",
        Parent                 = Left,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0)
    })
    Library:Create("UIListLayout", {
        Parent              = Text,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Center
    })

    local TitleLbl = Library:Create("TextLabel", {
        Name                   = "Title",
        Parent                 = Text,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        LayoutOrder            = -1,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 0, 0, 13),
        Font                   = Enum.Font.GothamSemibold,
        RichText               = true,
        Text                   = title or "",
        TextColor3             = T.Text,
        TextSize               = 13,
        TextStrokeTransparency = 0.7,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        AutomaticSize          = Enum.AutomaticSize.Y
    })
    MakeGradient(TitleLbl)

    Library:Create("TextLabel", {
        Name                   = "Desc",
        Parent                 = Text,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 0, 0, 10),
        Font                   = Enum.Font.GothamMedium,
        RichText               = true,
        Text                   = desc or "",
        TextColor3             = T.SubText,
        TextSize               = 10,
        TextStrokeTransparency = 0.7,
        TextTransparency       = 0.2,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        AutomaticSize          = Enum.AutomaticSize.Y
    })

    return Rows
end

local NotifGui
do
    NotifGui = Library:Create("ScreenGui", {
        Name           = "VitaNotifs",
        Parent         = Library:Parent(),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset = true,
        ResetOnSpawn   = false
    })
    Library:Create("Frame", {
        Name                   = "Container",
        Parent                 = NotifGui,
        AnchorPoint            = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(1, -15, 1, -15),
        Size                   = UDim2.new(0, 280, 1, -30)
    })
    Library:Create("UIListLayout", {
        Parent              = NotifGui.Container,
        Padding             = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Bottom
    })
end

function Library:Notification(Args)
    local Title    = Args.Title    or "Notification"
    local Desc     = Args.Desc     or ""
    local Duration = Args.Duration or 3
    local NType    = Args.Type     or "Info"
    local Icon     = Args.Icon

    local typeColors = {
        Info    = Color3.fromRGB(80, 140, 255),
        Success = Color3.fromRGB(80, 220, 120),
        Warning = Color3.fromRGB(255, 190, 60),
        Error   = Color3.fromRGB(255, 80, 80),
    }
    local typeIcons = {
        Info    = "rbxassetid://10723374641",
        Success = "rbxassetid://10709790387",
        Warning = "rbxassetid://10709753149",
        Error   = "rbxassetid://10747383819",
    }
    local accentColor = typeColors[NType] or typeColors.Info
    local iconAsset   = Icon and Library:Asset(Icon) or (typeIcons[NType] or typeIcons.Info)

    local Notif = Library:Create("Frame", {
        Name             = "Notif",
        Parent           = NotifGui.Container,
        BackgroundColor3 = Color3.fromRGB(13, 13, 13),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 68),
        ClipsDescendants = true
    })
    Library:Create("UICorner", { Parent = Notif, CornerRadius = UDim.new(0, 5) })
    Library:Create("UIStroke", { Parent = Notif, Color = Color3.fromRGB(28, 28, 28), Thickness = 0.8 })

    local Accent = Library:Create("Frame", {
        Name             = "Accent",
        Parent           = Notif,
        BackgroundColor3 = accentColor,
        BorderSizePixel  = 0,
        Size             = UDim2.new(0, 3, 1, 0)
    })
    Library:Create("UICorner", { Parent = Accent, CornerRadius = UDim.new(0, 3) })

    local Content = Library:Create("Frame", {
        Name                   = "Content",
        Parent                 = Notif,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 10, 0, 0),
        Size                   = UDim2.new(1, -10, 1, 0)
    })
    Library:Create("UIListLayout", {
        Parent            = Content,
        Padding           = UDim.new(0, 3),
        SortOrder         = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })
    Library:Create("UIPadding", {
        Parent       = Content,
        PaddingLeft  = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8)
    })

    local TitleRow = Library:Create("Frame", {
        Name                   = "TitleRow",
        Parent                 = Content,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 0, 18),
        LayoutOrder            = -2
    })
    Library:Create("UIListLayout", {
        Parent            = TitleRow,
        Padding           = UDim.new(0, 5),
        FillDirection     = Enum.FillDirection.Horizontal,
        SortOrder         = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })

    Library:Create("ImageLabel", {
        Name                   = "Icon",
        Parent                 = TitleRow,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(0, 14, 0, 14),
        Image                  = iconAsset,
        ImageColor3            = accentColor
    })

    Library:Create("TextLabel", {
        Name                   = "Title",
        Parent                 = TitleRow,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, -20, 0, 14),
        Font                   = Enum.Font.GothamBold,
        Text                   = Title,
        TextColor3             = accentColor,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true
    })

    Library:Create("TextLabel", {
        Name                   = "Desc",
        Parent                 = Content,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 0, 11),
        LayoutOrder            = -1,
        Font                   = Enum.Font.GothamMedium,
        Text                   = Desc,
        TextColor3             = Color3.fromRGB(180, 180, 180),
        TextSize               = 11,
        TextTransparency       = 0.2,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true
    })

    local ProgBg = Library:Create("Frame", {
        Parent           = Content,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 0, 2),
    })
    Library:Create("UICorner", { Parent = ProgBg, CornerRadius = UDim.new(1, 0) })
    local ProgFill = Library:Create("Frame", {
        Parent           = ProgBg,
        BackgroundColor3 = accentColor,
        BorderSizePixel  = 0,
        Size             = UDim2.new(1, 0, 1, 0),
    })
    Library:Create("UICorner", { Parent = ProgFill, CornerRadius = UDim.new(1, 0) })

    TweenService:Create(Notif, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
    }):Play()
    TweenService:Create(ProgFill, TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    task.delay(Duration, function()
        TweenService:Create(Notif, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        task.wait(0.35)
        Notif:Destroy()
    end)

    return Notif
end

function Library:Window(Args)
    local Title             = Args.Title     or "Vita UI"
    local SubTitle          = Args.SubTitle  or "Made by vita6it"
    local ToggleKey         = Args.ToggleKey or Enum.KeyCode.LeftControl
    local AutoScale         = Args.AutoScale ~= false
    local BaseScale         = Args.Scale     or 1.45
    local CustomSize        = Args.Size
    local ExecIdentifyShown = Args.ExecIdentifyShown ~= false
    local BbIcon            = Args.BbIcon or "rbxassetid://104055321996495"

    local uT = Args.Theme or {}
    if Args.BG        then uT.Background = Args.BG        end
    if Args.Tab       then uT.TabBg      = Args.Tab       end
    if Args.TabImage  then uT.TabImage   = Args.TabImage  end
    if Args.TabStroke then uT.TabStroke  = Args.TabStroke end

    local T = {
        Accent     = ResolveColor(uT.Accent     or Color3.fromRGB(255, 0, 127)),
        Background = ResolveColor(uT.Background or Color3.fromRGB(11, 11, 11)),
        Row        = ResolveColor(uT.Row        or Color3.fromRGB(15, 15, 15)),
        RowAlt     = ResolveColor(uT.RowAlt     or Color3.fromRGB(10, 10, 10)),
        Stroke     = ResolveColor(uT.Stroke     or Color3.fromRGB(25, 25, 25)),
        Text       = ResolveColor(uT.Text       or Color3.fromRGB(255, 255, 255)),
        SubText    = ResolveColor(uT.SubText    or Color3.fromRGB(163, 163, 163)),
        TabBg      = ResolveColor(uT.TabBg      or Color3.fromRGB(10, 10, 10)),
        TabStroke  = ResolveColor(uT.TabStroke  or Color3.fromRGB(75, 0, 38)),
        TabImage   = ResolveColor(uT.TabImage   or uT.Accent or Color3.fromRGB(255, 0, 127)),
        DropBg     = ResolveColor(uT.DropBg     or Color3.fromRGB(18, 18, 18)),
        DropStroke = ResolveColor(uT.DropStroke or Color3.fromRGB(30, 30, 30)),
        PillBg     = ResolveColor(uT.PillBg     or Color3.fromRGB(11, 11, 11)),
    }

    local accentRefs    = {}
    local bgRefs        = {}
    local tabImageRefs  = {}
    local tabBgRefs     = {}
    local tabStrokeRefs = {}
    local function trackAccent(inst, prop)    table.insert(accentRefs,    {inst, prop}); return inst end
    local function trackBg(inst, prop)        table.insert(bgRefs,        {inst, prop}); return inst end
    local function trackTabImage(inst, prop)  table.insert(tabImageRefs,  {inst, prop}); return inst end
    local function trackTabBg(inst, prop)     table.insert(tabBgRefs,     {inst, prop}); return inst end
    local function trackTabStroke(inst, prop) table.insert(tabStrokeRefs, {inst, prop}); return inst end

    local Xova = Library:Create("ScreenGui", {
        Name           = "Xova",
        Parent         = Library:Parent(),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset = true,
        ResetOnSpawn   = false
    })

    local Background = Library:Create("Frame", {
        Name             = "Background",
        Parent           = Xova,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.Background,
        BorderSizePixel  = 0,
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = CustomSize or UDim2.new(0, 500, 0, 350)
    })
    trackBg(Background, "BackgroundColor3")
    Library:Create("UICorner", { Parent = Background })
    Library:Create("ImageLabel", {
        Name                   = "Shadow",
        Parent                 = Background,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 120, 1, 120),
        ZIndex                 = 0,
        Image                  = "rbxassetid://8992230677",
        ImageColor3            = Color3.fromRGB(0, 0, 0),
        ImageTransparency      = 0.5,
        ScaleType              = Enum.ScaleType.Slice,
        SliceCenter            = Rect.new(99, 99, 99, 99)
    })

    function Library:IsDropdownOpen()
        for _, v in pairs(Background:GetChildren()) do
            if v.Name == "Dropdown" and v.Visible then return true end
        end
        return false
    end

    local Header = Library:Create("Frame", {
        Name                   = "Header",
        Parent                 = Background,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 0, 40)
    })

    local ReturnBtn = Library:Create("ImageLabel", {
        Name                   = "Return",
        Parent                 = Header,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 25, 0.5, 1),
        Size                   = UDim2.new(0, 27, 0, 27),
        Image                  = "rbxassetid://130391877219356",
        ImageColor3            = T.Accent,
        Visible                = false
    })
    trackAccent(ReturnBtn, "ImageColor3")
    MakeGradient(ReturnBtn)

    local HeadScale = Library:Create("Frame", {
        Name                   = "HeadScale",
        Parent                 = Header,
        AnchorPoint            = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(1, 0, 0, 0),
        Size                   = UDim2.new(1, 0, 1, 0)
    })
    Library:Create("UIListLayout", {
        Parent            = HeadScale,
        FillDirection     = Enum.FillDirection.Horizontal,
        SortOrder         = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })
    Library:Create("UIPadding", {
        Parent        = HeadScale,
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft   = UDim.new(0, 15),
        PaddingRight  = UDim.new(0, 15),
        PaddingTop    = UDim.new(0, 20)
    })

    local Info = Library:Create("Frame", {
        Name                   = "Info",
        Parent                 = HeadScale,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, -100, 0, 28)
    })
    Library:Create("UIListLayout", {
        Parent              = Info,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder
    })

    local TitleLabel = Library:Create("TextLabel", {
        Name                   = "Title",
        Parent                 = Info,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 0, 0, 14),
        Font                   = Enum.Font.GothamBold,
        RichText               = true,
        Text                   = Title,
        TextColor3             = T.Accent,
        TextSize               = 14,
        TextStrokeTransparency = 0.7,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        AutomaticSize          = Enum.AutomaticSize.Y
    })
    trackAccent(TitleLabel, "TextColor3")
    MakeGradient(TitleLabel)

    Library:Create("TextLabel", {
        Name                   = "SubTitle",
        Parent                 = Info,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 0, 0, 10),
        Font                   = Enum.Font.GothamMedium,
        RichText               = true,
        Text                   = SubTitle,
        TextColor3             = T.Text,
        TextSize               = 10,
        TextStrokeTransparency = 0.7,
        TextTransparency       = 0.6,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        AutomaticSize          = Enum.AutomaticSize.Y
    })

    local Expires = Library:Create("Frame", {
        Name                   = "Expires",
        Parent                 = HeadScale,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.787, 0, -3.5, 0),
        Size                   = UDim2.new(0, 100, 0, 40)
    })
    Library:Create("UIListLayout", {
        Parent              = Expires,
        Padding             = UDim.new(0, 10),
        FillDirection       = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        VerticalAlignment   = Enum.VerticalAlignment.Center
    })

    local ExpiresIcon = Library:Create("ImageLabel", {
        Name                   = "Asset",
        Parent                 = Expires,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(0, 20, 0, 20),
        Image                  = "rbxassetid://100865348188048",
        ImageColor3            = T.Accent,
        LayoutOrder            = 1
    })
    trackAccent(ExpiresIcon, "ImageColor3")
    MakeGradient(ExpiresIcon)

    local ExpiresInfo = Library:Create("Frame", {
        Name                   = "Info",
        Parent                 = Expires,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 0, 0, 28)
    })
    Library:Create("UIListLayout", {
        Parent              = ExpiresInfo,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder
    })

    local ExpiresTitle = Library:Create("TextLabel", {
        Name                   = "Title",
        Parent                 = ExpiresInfo,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 0, 0, 14),
        Font                   = Enum.Font.GothamSemibold,
        RichText               = true,
        Text                   = "Expires at",
        TextColor3             = T.Accent,
        TextSize               = 13,
        TextStrokeTransparency = 0.7,
        TextXAlignment         = Enum.TextXAlignment.Right,
        TextWrapped            = true,
        AutomaticSize          = Enum.AutomaticSize.Y
    })
    trackAccent(ExpiresTitle, "TextColor3")
    MakeGradient(ExpiresTitle)

    local THETIME = Library:Create("TextLabel", {
        Name                   = "Time",
        Parent                 = ExpiresInfo,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(1, 0, 0, 10),
        Font                   = Enum.Font.GothamMedium,
        RichText               = true,
        Text                   = "00:00:00 Hours",
        TextColor3             = T.Text,
        TextSize               = 10,
        TextStrokeTransparency = 0.7,
        TextTransparency       = 0.6,
        TextXAlignment         = Enum.TextXAlignment.Right,
        TextWrapped            = true,
        AutomaticSize          = Enum.AutomaticSize.Y
    })

    local Scale = Library:Create("Frame", {
        Name                   = "Scale",
        Parent                 = Background,
        AnchorPoint            = Vector2.new(0, 1),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0, 0, 1, 0),
        Size                   = UDim2.new(1, 0, 1, -40)
    })
    Scale.ClipsDescendants = true

    local Home = Library:Create("Frame", {
        Name                   = "Home",
        Parent                 = Scale,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0)
    })
    Library:Create("UIPadding", {
        Parent        = Home,
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft   = UDim.new(0, 14),
        PaddingRight  = UDim.new(0, 14)
    })

    local MainTabsScrolling = Library:Create("ScrollingFrame", {
        Name                      = "ScrollingFrame",
        Parent                    = Home,
        Active                    = true,
        BackgroundTransparency    = 1,
        BorderSizePixel           = 0,
        Size                      = UDim2.new(1, 0, 1, 0),
        ClipsDescendants          = true,
        AutomaticCanvasSize        = Enum.AutomaticSize.None,
        BottomImage               = "rbxasset://textures/ui/Scroll/scroll-bottom.png",
        CanvasPosition            = Vector2.new(0, 0),
        ElasticBehavior           = Enum.ElasticBehavior.WhenScrollable,
        MidImage                  = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        ScrollBarImageColor3      = Color3.fromRGB(0, 0, 0),
        ScrollBarThickness        = 0,
        ScrollingDirection        = Enum.ScrollingDirection.XY,
        TopImage                  = "rbxasset://textures/ui/Scroll/scroll-top.png",
        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
    })
    Library:Create("UIPadding", {
        Parent        = MainTabsScrolling,
        PaddingBottom = UDim.new(0, 1),
        PaddingLeft   = UDim.new(0, 1),
        PaddingRight  = UDim.new(0, 1),
        PaddingTop    = UDim.new(0, 1)
    })
    local MainTabsLayout = Library:Create("UIListLayout", {
        Parent    = MainTabsScrolling,
        Padding   = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    MainTabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        MainTabsScrolling.CanvasSize = UDim2.new(0, 0, 0, MainTabsLayout.AbsoluteContentSize.Y + 15)
    end)

    local PageService = Library:Create("Frame", {
        Name                   = "Pages",
        Parent                 = Scale,
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Size                   = UDim2.new(1, 0, 1, 0),
        Visible                = false
    })

    local function PageService_JumpTo(frame)
        for _, v in pairs(Scale:GetChildren()) do
            if v ~= frame and v.Name == "NewPage" then
                v.Visible = false
            end
        end
        frame.Visible = true
        Home.Visible  = false
        PageService.Visible = false
    end

    local Scaler
    if AutoScale then
        Scaler = Library:Create("UIScale", {
            Parent = Background,
            Scale  = BaseScale
        })
        if AutoScale then
            local function UpdateScale()
                if Scaler:GetAttribute("ManualScale") then return end
                local vp = workspace.CurrentCamera.ViewportSize
                local ratio = math.min(vp.X / 1920, vp.Y / 1080)
                Scaler.Scale = math.clamp(ratio * BaseScale, 0.4, 3)
            end
            workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
            UpdateScale()
        end
    else
        Scaler = Library:Create("UIScale", { Parent = Background, Scale = BaseScale })
    end

    Library:Draggable(Header)

    local ExecLabel = Library:Create("TextLabel", {
        Name                   = "ExecIdentity",
        Parent                 = Background,
        AnchorPoint            = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 1, 12),
        Size                   = UDim2.new(1, 0, 0, 10),
        Font                   = Enum.Font.GothamMedium,
        Text                   = GetExecutorName(),
        TextColor3             = T.SubText,
        TextSize               = 9,
        TextTransparency       = 0.5,
        Visible                = ExecIdentifyShown
    })

    local Logo
    local ToggleScreen = Library:Create("ScreenGui", {
        Name           = "VitaToggle",
        Parent         = Library:Parent(),
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset = true,
        ResetOnSpawn   = false
    })
    local PillBtn = Library:Create("ImageButton", {
        Name                   = "Pill",
        Parent                 = ToggleScreen,
        AnchorPoint            = Vector2.new(0.5, 0),
        BackgroundColor3       = T.PillBg,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0, 10),
        Size                   = UDim2.new(0, 45, 0, 20),
        Image                  = "",
        Visible                = false
    })
    Library:Create("UICorner", { Parent = PillBtn, CornerRadius = UDim.new(1, 0) })
    Library:Create("UIStroke", { Parent = PillBtn, Color = Color3.fromRGB(35, 35, 35), Thickness = 0.8 })

    Logo = Library:Create("ImageLabel", {
        Name                   = "Logo",
        Parent                 = PillBtn,
        AnchorPoint            = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Position               = UDim2.new(0.5, 0, 0.5, 0),
        Size                   = UDim2.new(0, 16, 0, 16),
        Image                  = Library:Asset(BbIcon),
        ImageColor3            = T.Accent
    })
    trackAccent(Logo, "ImageColor3")

    local visible = true

    local function ToggleUI()
        visible = not visible
        Background.Visible  = visible
        ExecLabel.Visible   = visible and ExecIdentifyShown
        PillBtn.Visible     = not visible
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == ToggleKey then
            ToggleUI()
        end
    end)

    PillBtn.MouseButton1Click:Connect(ToggleUI)

    local Window = {}

    function Window:NewPage(Args)
        local PageTitle = Args.Title    or "Page"
        local PageDesc  = Args.Desc     or ""
        local PageIcon  = Args.Icon     or "rbxassetid://10734950309"
        local TabImage  = Args.TabImage

        local NewTabs = Library:Create("Frame", {
            Name             = "NewTabs",
            Parent           = MainTabsScrolling,
            BackgroundColor3 = T.TabBg,
            BorderSizePixel  = 0,
            Size             = UDim2.new(0, 230, 0, 55),
            ClipsDescendants = true
        })
        trackTabBg(NewTabs, "BackgroundColor3")
        local TabClick = Library:Button(NewTabs)
        Library:Create("UICorner", { Parent = NewTabs, CornerRadius = UDim.new(0, 5) })
        local TabStrokeInst = Library:Create("UIStroke", { Parent = NewTabs, Color = T.TabStroke, Thickness = 1 })
        trackTabStroke(TabStrokeInst, "Color")

        local TabBannerColor = TabImage and ResolveColor(TabImage) or T.TabImage
        local TabBanner = Library:Create("ImageLabel", {
            Name                   = "Banner",
            Parent                 = NewTabs,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 1, 0),
            Image                  = "rbxassetid://125411502674016",
            ImageColor3            = TabBannerColor,
            ScaleType              = Enum.ScaleType.Crop
        })
        if not TabImage then
            trackTabImage(TabBanner, "ImageColor3")
        end
        Library:Create("UICorner", { Parent = TabBanner, CornerRadius = UDim.new(0, 2) })

        local TabInfo = Library:Create("Frame", {
            Name                   = "Info",
            Parent                 = NewTabs,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 1, 0)
        })
        Library:Create("UIListLayout", {
            Parent            = TabInfo,
            Padding           = UDim.new(0, 10),
            FillDirection     = Enum.FillDirection.Horizontal,
            SortOrder         = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center
        })
        Library:Create("UIPadding", { Parent = TabInfo, PaddingLeft = UDim.new(0, 15) })

        local TabIcon = Library:Create("ImageLabel", {
            Name                   = "Icon",
            Parent                 = TabInfo,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            LayoutOrder            = -1,
            Size                   = UDim2.new(0, 25, 0, 25),
            Image                  = Library:Asset(PageIcon),
            ImageColor3            = T.Accent
        })
        trackAccent(TabIcon, "ImageColor3")
        MakeGradient(TabIcon)

        local TabText = Library:Create("Frame", {
            Name                   = "Text",
            Parent                 = TabInfo,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Position               = UDim2.new(0.11, 0, 0.14, 0),
            Size                   = UDim2.new(0, 150, 0, 32)
        })
        Library:Create("UIListLayout", {
            Parent            = TabText,
            Padding           = UDim.new(0, 2),
            SortOrder         = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center
        })

        local TabTitleLabel = Library:Create("TextLabel", {
            Name                   = "Title",
            Parent                 = TabText,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0, 150, 0, 14),
            Font                   = Enum.Font.GothamBold,
            RichText               = true,
            Text                   = PageTitle,
            TextColor3             = T.Accent,
            TextSize               = 15,
            TextStrokeTransparency = 0.45,
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextWrapped            = true,
            AutomaticSize          = Enum.AutomaticSize.Y
        })
        trackAccent(TabTitleLabel, "TextColor3")
        MakeGradient(TabTitleLabel)

        Library:Create("TextLabel", {
            Name                   = "Desc",
            Parent                 = TabText,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(0.9, 0, 0, 10),
            Font                   = Enum.Font.GothamMedium,
            RichText               = true,
            Text                   = PageDesc,
            TextColor3             = T.Text,
            TextSize               = 10,
            TextStrokeTransparency = 0.5,
            TextTransparency       = 0.2,
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextWrapped            = true,
            AutomaticSize          = Enum.AutomaticSize.Y
        })

        local NewPage = Library:Create("Frame", {
            Name                   = "NewPage",
            Parent                 = Scale,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            Size                   = UDim2.new(1, 0, 1, 0),
            Visible                = false
        })
        local PageScrolling = Library:Create("ScrollingFrame", {
            Name                      = "PageScrolling",
            Parent                    = NewPage,
            Active                    = true,
            BackgroundTransparency    = 1,
            BorderSizePixel           = 0,
            Size                      = UDim2.new(1, 0, 1, 0),
            ClipsDescendants          = true,
            AutomaticCanvasSize        = Enum.AutomaticSize.None,
            BottomImage               = "rbxasset://textures/ui/Scroll/scroll-bottom.png",
            CanvasPosition            = Vector2.new(0, 0),
            ElasticBehavior           = Enum.ElasticBehavior.WhenScrollable,
            MidImage                  = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            ScrollBarImageColor3      = Color3.fromRGB(0, 0, 0),
            ScrollBarThickness        = 0,
            ScrollingDirection        = Enum.ScrollingDirection.XY,
            TopImage                  = "rbxasset://textures/ui/Scroll/scroll-top.png",
            VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
        })
        Library:Create("UIPadding", {
            Parent        = PageScrolling,
            PaddingBottom = UDim.new(0, 1),
            PaddingLeft   = UDim.new(0, 15),
            PaddingRight  = UDim.new(0, 15),
            PaddingTop    = UDim.new(0, 1)
        })
        local PageLayout = Library:Create("UIListLayout", {
            Parent        = PageScrolling,
            Padding       = UDim.new(0, 5),
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder     = Enum.SortOrder.LayoutOrder
        })
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageScrolling.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
        end)

        local BackBtn = Library:Create("TextButton", {
            Name                   = "BackBtn",
            Parent                 = NewPage,
            AnchorPoint            = Vector2.new(0, 0),
            BackgroundColor3       = T.TabBg,
            BorderSizePixel        = 0,
            Position               = UDim2.new(0, 8, 0, 4),
            Size                   = UDim2.new(0, 28, 0, 22),
            Font                   = Enum.Font.GothamBold,
            Text                   = "←",
            TextColor3             = T.Accent,
            TextSize               = 14,
            ZIndex                 = 10
        })
        Library:Create("UICorner", { Parent = BackBtn, CornerRadius = UDim.new(0, 4) })
        Library:Create("UIStroke", { Parent = BackBtn, Color = T.Stroke, Thickness = 0.8 })

        BackBtn.MouseButton1Click:Connect(function()
            NewPage.Visible = false
            Home.Visible    = true
            Library:Tween({ v = HeadScale, t = 0.2, s = "Exponential", d = "Out", g = { Size = UDim2.new(1, 0, 1, 0) } }):Play()
            ReturnBtn.Visible = false
        end)

        local function OnChangePage()
            Library:Tween({ v = HeadScale, t = 0.2, s = "Exponential", d = "Out", g = { Size = UDim2.new(1, -30, 1, 0) } }):Play()
            ReturnBtn.Visible = true
            for _, v in pairs(Scale:GetChildren()) do
                if v.Name == "NewPage" then v.Visible = false end
            end
            NewPage.Visible = true
            Home.Visible    = false
        end
        TabClick.MouseButton1Click:Connect(OnChangePage)

        local Page = {}

        function Page:Section(Text)
            local Lbl = Library:Create("TextLabel", {
                Name                   = "Title",
                Parent                 = PageScrolling,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                LayoutOrder            = 0,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(1, 0, 0, 20),
                Font                   = Enum.Font.GothamBold,
                RichText               = true,
                Text                   = " " .. Text,
                TextColor3             = T.Text,
                TextSize               = 15,
                TextStrokeTransparency = 0.7,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextWrapped            = true,
                AutomaticSize          = Enum.AutomaticSize.Y
            })
            MakeGradient(Lbl)
            return Lbl
        end

        function Page:Paragraph(Args)
            local PTitle = Args.Title
            local PDesc  = Args.Desc
            local Icon   = Args.Image or Args.Icon
            local Rows   = Library:NewRows(PageScrolling, PTitle, PDesc, T)
            local Right  = Rows.Vectorize.Right
            local Left   = Rows.Vectorize.Left.Text

            local IconLbl = Library:Create("ImageLabel", {
                Parent                 = Right,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0, 0.5, 0.5, 1),
                Size                   = UDim2.new(0, 20, 0, 20),
                Image                  = Library:Asset(Icon),
                ImageColor3            = T.Accent
            })
            trackAccent(IconLbl, "ImageColor3")
            MakeGradient(IconLbl)

            local Data = { Title = PTitle, Desc = PDesc, Image = IconLbl, Icon = IconLbl, Instance = Rows }
            return setmetatable({}, {
                __newindex = function(t, k, v)
                    rawset(Data, k, v)
                    if k == "Title" then Left.Title.Text = tostring(v)
                    elseif k == "Desc"  then Left.Desc.Text  = tostring(v)
                    elseif k == "Icon" or k == "Image" then
                        IconLbl.Image = Library:Asset(v)
                    end
                end,
                __index = Data
            })
        end

        function Page:RightLabel(Args)
            local RTitle    = Args.Title
            local RDesc     = Args.Desc
            local RightText = Args.Right or "None"
            local Rows      = Library:NewRows(PageScrolling, RTitle, RDesc, T)
            local Right     = Rows.Vectorize.Right
            local Left      = Rows.Vectorize.Left.Text

            local Lbl = Library:Create("TextLabel", {
                Name                   = "Title",
                Parent                 = Right,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                LayoutOrder            = -1,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(1, 0, 0, 13),
                Selectable             = false,
                Font                   = Enum.Font.GothamSemibold,
                RichText               = true,
                Text                   = RightText,
                TextColor3             = T.Text,
                TextSize               = 12,
                TextStrokeTransparency = 0.7,
                TextXAlignment         = Enum.TextXAlignment.Right,
                TextWrapped            = true,
                AutomaticSize          = Enum.AutomaticSize.Y
            })
            MakeGradient(Lbl)

            local Data = { Title = RTitle, Desc = RDesc, Right = RightText, Label = Lbl, Instance = Rows }
            return setmetatable({}, {
                __newindex = function(t, k, v)
                    rawset(Data, k, v)
                    if k == "Title" then Left.Title.Text = tostring(v)
                    elseif k == "Desc"  then Left.Desc.Text = tostring(v)
                    elseif k == "Right" then Lbl.Text        = tostring(v)
                    end
                end,
                __index = Data
            })
        end

        function Page:Button(Args)
            local BTitle    = Args.Title
            local BDesc     = Args.Desc
            local BtnText   = Args.Text or "Click"
            local BIcon     = Args.Icon or Args.Image
            local Callback  = Args.Callback
            local Rows      = Library:NewRows(PageScrolling, BTitle, BDesc, T)
            local Right     = Rows.Vectorize.Right
            local Left      = Rows.Vectorize.Left.Text

            local Btn = Library:Create("Frame", {
                Name             = "Button",
                Parent           = Right,
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0.73, 0, 0.167, 0),
                Size             = UDim2.new(0, 75, 0, 25),
                ClipsDescendants = true
            })
            trackAccent(Btn, "BackgroundColor3")
            Library:Create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 3) })
            Library:Create("UIGradient", {
                Parent   = Btn,
                Color    = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(56,  56,  56))
                },
                Rotation = 90
            })

            if BIcon then
                Library:Create("UIListLayout", {
                    Parent            = Btn,
                    Padding           = UDim.new(0, 4),
                    FillDirection     = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    SortOrder         = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center
                })
                Library:Create("ImageLabel", {
                    Parent                 = Btn,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(0, 14, 0, 14),
                    Image                  = Library:Asset(BIcon),
                    LayoutOrder            = -1
                })
            end

            local BtnLbl = Library:Create("TextLabel", {
                Name                   = "Title",
                Parent                 = Btn,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(1, -10, 1, 0),
                Font                   = Enum.Font.GothamSemibold,
                RichText               = true,
                Text                   = BtnText,
                TextColor3             = T.Text,
                TextSize               = 11,
                TextStrokeTransparency = 0.7,
                TextWrapped            = true,
                AutomaticSize          = Enum.AutomaticSize.Y
            })
            Btn.Size = UDim2.new(0, math.max(75, BtnLbl.TextBounds.X + 40), 0, 25)
            local Click = Library:Button(Btn)
            Click.MouseButton1Click:Connect(function()
                if Library:IsDropdownOpen() then return end
                task.spawn(Library.Effect, Click, Btn)
                if Callback then pcall(Callback) end
            end)

            local Data = { Title = BTitle, Desc = BDesc, Text = BtnText, Instance = Rows }
            return setmetatable({}, {
                __newindex = function(t, k, v)
                    rawset(Data, k, v)
                    if k == "Title" then Left.Title.Text = tostring(v)
                    elseif k == "Desc"  then Left.Desc.Text = tostring(v)
                    elseif k == "Text"  then BtnLbl.Text    = tostring(v)
                    end
                end,
                __index = Data
            })
        end

        function Page:Toggle(Args)
            local TTitle   = Args.Title
            local TDesc    = Args.Desc
            local Value    = Args.Value or false
            local Callback = Args.Callback or function() end
            local Rows     = Library:NewRows(PageScrolling, TTitle, TDesc, T)
            local Left     = Rows.Vectorize.Left.Text
            local Right    = Rows.Vectorize.Right
            local TitleLbl = Left.Title

            local Bg = Library:Create("Frame", {
                Name             = "Background",
                Parent           = Right,
                BackgroundColor3 = T.RowAlt,
                BorderSizePixel  = 0,
                Size             = UDim2.new(0, 20, 0, 20)
            })
            local Stroke = Library:Create("UIStroke", { Parent = Bg, Color = T.Stroke, Thickness = 0.5 })
            Library:Create("UICorner", { Parent = Bg, CornerRadius = UDim.new(0, 5) })

            local Highlight = Library:Create("Frame", {
                Name             = "Highlight",
                Parent           = Bg,
                AnchorPoint      = Vector2.new(0.5, 0.5),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0.5, 0, 0.5, 0),
                Size             = UDim2.new(0, 20, 0, 20)
            })
            trackAccent(Highlight, "BackgroundColor3")
            Library:Create("UICorner", { Parent = Highlight, CornerRadius = UDim.new(0, 5) })
            Library:Create("UIGradient", {
                Parent   = Highlight,
                Color    = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(56,  56,  56))
                },
                Rotation = 90
            })
            local CheckImg = Library:Create("ImageLabel", {
                Parent                 = Highlight,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(0.45, 0, 0.45, 0),
                Image                  = "rbxassetid://86682186031062"
            })

            local ClickBtn = Library:Button(Bg)
            local Data = { Title = TTitle, Desc = TDesc, Value = Value }

            local function OnChanged(val)
                Data.Value = val
                if val then
                    pcall(Callback, val)
                    CheckImg.Size        = UDim2.new(0.85, 0, 0.85, 0)
                    TitleLbl.TextColor3  = T.Accent
                    Library:Tween({ v = Highlight, t = 0.5, s = "Exponential", d = "Out", g = { BackgroundTransparency = 0 } }):Play()
                    Library:Tween({ v = CheckImg,  t = 0.5, s = "Exponential", d = "Out", g = { ImageTransparency = 0 } }):Play()
                    Library:Tween({ v = CheckImg,  t = 0.3, s = "Exponential", d = "Out", g = { Size = UDim2.new(0.5, 0, 0.5, 0) } }):Play()
                    Stroke.Thickness = 0
                else
                    pcall(Callback, val)
                    TitleLbl.TextColor3 = T.Text
                    Library:Tween({ v = Highlight, t = 0.5, s = "Exponential", d = "Out", g = { BackgroundTransparency = 1 } }):Play()
                    Library:Tween({ v = CheckImg,  t = 0.5, s = "Exponential", d = "Out", g = { ImageTransparency = 1 } }):Play()
                    Stroke.Thickness = 0.5
                end
            end

            ClickBtn.MouseButton1Click:Connect(function()
                if Library:IsDropdownOpen() then return end
                OnChanged(not Data.Value)
            end)
            OnChanged(Value)

            return setmetatable({}, {
                __newindex = function(t, k, v)
                    rawset(Data, k, v)
                    if k == "Title" then Left.Title.Text = tostring(v)
                    elseif k == "Desc"  then Left.Desc.Text = tostring(v)
                    elseif k == "Value" then OnChanged(v) end
                end,
                __index = Data
            })
        end

        function Page:Slider(Args)
            local STitle   = Args.Title
            local SDesc    = Args.Desc
            local Min      = Args.Min      or 0
            local Max      = Args.Max      or 100
            local Rounding = Args.Rounding or 0
            local Value    = Args.Value    or Min
            local Suffix   = Args.Suffix   or ""
            local Callback = Args.Callback or function() end

            local SliderFrame = Library:Create("Frame", {
                Name             = "Slider",
                Parent           = PageScrolling,
                BackgroundColor3 = T.Row,
                BorderSizePixel  = 0,
                Size             = UDim2.new(1, 0, 0, 42),
                Selectable       = false
            })
            Library:Create("UICorner", { Parent = SliderFrame, CornerRadius = UDim.new(0, 3) })
            Library:Create("UIStroke", { Parent = SliderFrame, Color = T.Stroke, Thickness = 0.5 })
            Library:Create("UIPadding", {
                Parent        = SliderFrame,
                PaddingBottom = UDim.new(0, 1),
                PaddingLeft   = UDim.new(0, 10),
                PaddingRight  = UDim.new(0, 10)
            })

            local TextF = Library:Create("Frame", {
                Name                   = "Text",
                Parent                 = SliderFrame,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0, 0, 0.1, 0),
                Size                   = UDim2.new(0, 111, 0, 22),
                Selectable             = false
            })
            Library:Create("UIListLayout", { Parent = TextF, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center })
            Library:Create("UIPadding", { Parent = TextF, PaddingBottom = UDim.new(0, 3) })

            local TitleLbl = Library:Create("TextLabel", {
                Name                   = "Title",
                Parent                 = TextF,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                LayoutOrder            = -1,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(1, 0, 0, 13),
                Selectable             = false,
                Font                   = Enum.Font.GothamSemibold,
                RichText               = true,
                Text                   = STitle or "",
                TextColor3             = T.Text,
                TextSize               = 12,
                TextStrokeTransparency = 0.7,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextWrapped            = true,
                AutomaticSize          = Enum.AutomaticSize.Y
            })
            MakeGradient(TitleLbl)

            if SDesc then
                Library:Create("TextLabel", {
                    Name                   = "Desc",
                    Parent                 = TextF,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Size                   = UDim2.new(1, 0, 0, 9),
                    Font                   = Enum.Font.GothamMedium,
                    Text                   = SDesc,
                    TextColor3             = T.SubText,
                    TextSize               = 9,
                    TextTransparency       = 0.3,
                    TextXAlignment         = Enum.TextXAlignment.Left,
                    TextWrapped            = true
                })
            end

            local Scaling  = Library:Create("Frame",   { Name = "Scaling",  Parent = SliderFrame, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), Selectable = false })
            local Slide    = Library:Create("Frame",   { Name = "Slide",    Parent = Scaling,     AnchorPoint = Vector2.new(0, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 23), Selectable = false })
            local ColorBar = Library:Create("Frame",   { Name = "ColorBar", Parent = Slide,       AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(10, 10, 10), BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 5), Selectable = false })
            Library:Create("UICorner", { Parent = ColorBar, CornerRadius = UDim.new(0, 3) })

            local Fill = Library:Create("Frame", {
                Name             = "Fill",
                Parent           = ColorBar,
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                Size             = UDim2.new(0, 0, 1, 0),
                Selectable       = false
            })
            trackAccent(Fill, "BackgroundColor3")
            Library:Create("UICorner", { Parent = Fill, CornerRadius = UDim.new(0, 3) })
            Library:Create("UIGradient", { Parent = Fill, Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(47, 47, 47)) }, Rotation = 90 })
            Library:Create("Frame", { Name = "Circle", Parent = Fill, AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 5, 0, 11), Selectable = false })

            local ValueBox = Library:Create("TextBox", {
                Name                   = "Boxvalue",
                Parent                 = Scaling,
                AnchorPoint            = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(1, -5, 0.449, -2),
                Size                   = UDim2.new(0, 60, 0, 15),
                ZIndex                 = 5,
                Font                   = Enum.Font.GothamMedium,
                Text                   = tostring(Value),
                TextColor3             = T.Text,
                TextSize               = 11,
                TextTransparency       = 0.5,
                TextTruncate           = Enum.TextTruncate.AtEnd,
                TextXAlignment         = Enum.TextXAlignment.Right,
                TextWrapped            = true
            })

            local dragging = false
            local Data = { Title = STitle, Desc = SDesc, Value = Value, Min = Min, Max = Max }

            local function Round(n, d) return math.floor(n * (10 ^ d) + 0.5) / (10 ^ d) end
            local function UpdateSlider(val)
                val = math.clamp(val, Min, Max)
                val = Round(val, Rounding)
                Data.Value = val
                local ratio = (val - Min) / (Max - Min)
                Library:Tween({ v = Fill, t = 0.1, s = "Linear", d = "Out", g = { Size = UDim2.new(ratio, 0, 1, 0) } }):Play()
                ValueBox.Text = tostring(val) .. (Suffix ~= "" and (" " .. Suffix) or "")
                pcall(Callback, val)
                return val
            end
            local function GetVal(input)
                local ax = ColorBar.AbsolutePosition.X
                local aw = ColorBar.AbsoluteSize.X
                return math.clamp((input.Position.X - ax) / aw, 0, 1) * (Max - Min) + Min
            end
            local function SetDragging(state)
                dragging = state
                local color = state and T.Accent or T.Text
                Library:Tween({ v = ValueBox, t = 0.3, s = "Back", d = "Out", g = { TextSize = state and 15 or 11 } }):Play()
                Library:Tween({ v = ValueBox, t = 0.2, s = "Exponential", d = "Out", g = { TextColor3 = color } }):Play()
                Library:Tween({ v = TitleLbl, t = 0.2, s = "Exponential", d = "Out", g = { TextColor3 = color } }):Play()
            end

            local ClickBtn = Library:Button(SliderFrame)
            ClickBtn.InputBegan:Connect(function(input)
                if Library:IsDropdownOpen() then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    SetDragging(true); UpdateSlider(GetVal(input))
                end
            end)
            ClickBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    SetDragging(false)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if Library:IsDropdownOpen() then return end
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(GetVal(input))
                end
            end)
            ValueBox.Focused:Connect(function()
                Library:Tween({ v = ValueBox, t = 0.2, s = "Exponential", d = "Out", g = { TextColor3 = T.Accent } }):Play()
                Library:Tween({ v = TitleLbl, t = 0.2, s = "Exponential", d = "Out", g = { TextColor3 = T.Accent } }):Play()
            end)
            ValueBox.FocusLost:Connect(function()
                Library:Tween({ v = ValueBox, t = 0.2, s = "Exponential", d = "Out", g = { TextColor3 = T.Text } }):Play()
                Library:Tween({ v = TitleLbl, t = 0.2, s = "Exponential", d = "Out", g = { TextColor3 = T.Text } }):Play()
                Value = UpdateSlider(tonumber(ValueBox.Text:match("%d+%.?%d*")) or Value)
            end)
            UpdateSlider(Value)

            return setmetatable({}, {
                __newindex = function(t, k, v)
                    rawset(Data, k, v)
                    if k == "Title" then TitleLbl.Text = tostring(v)
                    elseif k == "Value" then UpdateSlider(v)
                    elseif k == "Min" then Min = v
                    elseif k == "Max" then Max = v
                    end
                end,
                __index = Data
            })
        end

        function Page:Input(Args)
            local Value       = Args.Value    or ""
            local Callback    = Args.Callback or function() end
            local ITitle      = Args.Title
            local IDesc       = Args.Desc
            local Placeholder = Args.Placeholder or (ITitle and (ITitle .. (IDesc and (" — " .. IDesc) or "")) or "Type here and press Enter")
            local ClearOnSubmit = Args.ClearOnSubmit or false

            local InputFrame = Library:Create("Frame", {
                Name                   = "Input",
                Parent                 = PageScrolling,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 0, 30),
                Selectable             = false
            })
            Library:Create("UIListLayout", { Parent = InputFrame, Padding = UDim.new(0, 5), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center })

            local Front = Library:Create("Frame", {
                Name             = "Front",
                Parent           = InputFrame,
                BackgroundColor3 = T.Row,
                BorderSizePixel  = 0,
                Size             = UDim2.new(1, -70, 1, 0),
                Selectable       = false
            })
            Library:Create("UICorner", { Parent = Front, CornerRadius = UDim.new(0, 2) })
            Library:Create("UIStroke", { Parent = Front, Color = T.Stroke, Thickness = 0.5 })

            local TitleAbove
            if ITitle then
                TitleAbove = Library:Create("TextLabel", {
                    Name                   = "TitleAbove",
                    Parent                 = Front,
                    BackgroundTransparency = 1,
                    BorderSizePixel        = 0,
                    Position               = UDim2.new(0, 8, 0, -14),
                    Size                   = UDim2.new(1, -16, 0, 12),
                    Font                   = Enum.Font.GothamSemibold,
                    Text                   = ITitle,
                    TextColor3             = T.SubText,
                    TextSize               = 10,
                    TextXAlignment         = Enum.TextXAlignment.Left
                })
            end

            local TextBox = Library:Create("TextBox", {
                Parent                 = Front,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(1, -20, 1, 0),
                Font                   = Enum.Font.GothamMedium,
                PlaceholderColor3      = Color3.fromRGB(55, 55, 55),
                PlaceholderText        = Placeholder,
                Text                   = tostring(Value),
                TextColor3             = Color3.fromRGB(100, 100, 100),
                TextSize               = 11,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextWrapped            = true
            })

            local Enter = Library:Create("Frame", {
                Name             = "Enter",
                Parent           = InputFrame,
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                Size             = UDim2.new(0, 30, 0, 30),
                Selectable       = false
            })
            trackAccent(Enter, "BackgroundColor3")
            Library:Create("UICorner", { Parent = Enter, CornerRadius = UDim.new(0, 3) })
            Library:Create("UIGradient", { Parent = Enter, Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(56, 56, 56)) }, Rotation = 90 })

            local EnterIcon = Library:Create("ImageLabel", {
                Name                   = "Asset",
                Parent                 = Enter,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(0, 15, 0, 15),
                Image                  = "rbxassetid://78020815235467"
            })
            local CopyBtn = Library:Button(Enter)

            local ClearBtn = Library:Create("Frame", {
                Name             = "ClearBtn",
                Parent           = InputFrame,
                BackgroundColor3 = T.RowAlt,
                BorderSizePixel  = 0,
                Size             = UDim2.new(0, 30, 0, 30),
                Selectable       = false
            })
            Library:Create("UICorner", { Parent = ClearBtn, CornerRadius = UDim.new(0, 3) })
            Library:Create("UIStroke", { Parent = ClearBtn, Color = T.Stroke, Thickness = 0.5 })
            Library:Create("ImageLabel", {
                Parent                 = ClearBtn,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(0, 12, 0, 12),
                Image                  = "rbxassetid://10747384394",
                ImageColor3            = T.SubText
            })
            local ClearBtnClick = Library:Button(ClearBtn)
            ClearBtnClick.MouseButton1Click:Connect(function()
                TextBox.Text = ""
            end)

            TextBox.FocusLost:Connect(function(entered)
                if entered then
                    pcall(Callback, TextBox.Text)
                    if ClearOnSubmit then TextBox.Text = "" end
                end
            end)
            CopyBtn.MouseButton1Click:Connect(function()
                if Library:IsDropdownOpen() then return end
                pcall(setclipboard, TextBox.Text)
                EnterIcon.Image = "rbxassetid://121742282171603"
                task.delay(3, function() EnterIcon.Image = "rbxassetid://78020815235467" end)
            end)

            local Data = { Title = ITitle, Desc = IDesc, Value = TextBox.Text, TextBox = TextBox }
            return setmetatable({}, {
                __newindex = function(t, k, v)
                    rawset(Data, k, v)
                    if k == "Title" and TitleAbove then TitleAbove.Text = tostring(v)
                    elseif k == "Value" then TextBox.Text = tostring(v)
                    elseif k == "Placeholder" then TextBox.PlaceholderText = tostring(v)
                    end
                end,
                __index = function(t, k)
                    if k == "Value" then return TextBox.Text end
                    return Data[k]
                end
            })
        end

        function Page:Dropdown(Args)
            local DTitle   = Args.Title
            local List     = Args.List or {}
            local Value    = Args.Value
            local Callback = Args.Callback or function() end
            local IsMulti  = typeof(Value) == "table"
            local Placeholder = Args.Placeholder or "Select..."

            local Rows = Library:NewRows(PageScrolling, DTitle, "N/A", T)
            local Right = Rows.Vectorize.Right
            local Left  = Rows.Vectorize.Left.Text

            Library:Create("ImageLabel", { Parent = Right, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(0, 20, 0, 20), Image = "rbxassetid://132291592681506", ImageTransparency = 0.5 })

            local Open = Library:Button(Rows.Vectorize)

            local function GetText()
                if IsMulti then return type(Value) == "table" and #Value > 0 and table.concat(Value, ", ") or Placeholder end
                return Value ~= nil and tostring(Value) or Placeholder
            end
            Left.Desc.Text = GetText()

            local DropFrame = Library:Create("Frame", {
                Name             = "Dropdown",
                Parent           = Background,
                AnchorPoint      = Vector2.new(0.5, 0.5),
                BackgroundColor3 = T.DropBg,
                BorderSizePixel  = 0,
                Position         = UDim2.new(0.5, 0, 0.3, 0),
                Size             = UDim2.new(0, 300, 0, 250),
                ZIndex           = 500,
                Selectable       = false,
                Visible          = false
            })
            Library:Create("UICorner", { Parent = DropFrame, CornerRadius = UDim.new(0, 3) })
            Library:Create("UIStroke", { Parent = DropFrame, Color = T.DropStroke, Thickness = 0.5 })
            Library:Create("UIListLayout", { Parent = DropFrame, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center })
            Library:Create("UIPadding", { Parent = DropFrame, PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10) })

            local DropText = Library:Create("Frame", { Name = "Text", Parent = DropFrame, BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = -5, Size = UDim2.new(1, 0, 0, 30), ZIndex = 500, Selectable = false })
            Library:Create("UIListLayout", { Parent = DropText, Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center })

            Library:Create("TextLabel", { Name = "Title", Parent = DropText, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = -1, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 13), ZIndex = 500, Selectable = false, Font = Enum.Font.GothamSemibold, RichText = true, Text = DTitle or "", TextColor3 = T.Accent, TextSize = 14, TextStrokeTransparency = 0.7, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y })
            MakeGradient(DropText.Title)

            local Desc1 = Library:Create("TextLabel", { Name = "Desc", Parent = DropText, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, 0, 0, 10), ZIndex = 500, Selectable = false, Font = Enum.Font.GothamMedium, RichText = true, Text = GetText(), TextColor3 = T.Text, TextSize = 10, TextStrokeTransparency = 0.7, TextTransparency = 0.6, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y })

            local InputF  = Library:Create("Frame",  { Name = "Input",  Parent = DropFrame, BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = -4, Size = UDim2.new(1, 0, 0, 25), ZIndex = 500, Selectable = false })
            Library:Create("UIListLayout", { Parent = InputF, Padding = UDim.new(0, 5), FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center })
            local FrontF  = Library:Create("Frame",  { Name = "Front",  Parent = InputF, BackgroundColor3 = T.Row, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), ZIndex = 500, Selectable = false })
            Library:Create("UICorner", { Parent = FrontF, CornerRadius = UDim.new(0, 2) })
            Library:Create("UIStroke", { Parent = FrontF, Color = T.Stroke, Thickness = 0.5 })
            local SearchBox = Library:Create("TextBox", { Name = "Search", Parent = FrontF, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, CursorPosition = -1, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, -20, 1, 0), ZIndex = 500, Font = Enum.Font.GothamMedium, PlaceholderColor3 = Color3.fromRGB(55, 55, 55), PlaceholderText = "Search", Text = "", TextColor3 = T.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true })

            local List1 = Library:Create("ScrollingFrame", { Name = "List", Parent = DropFrame, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 160), ZIndex = 500, ScrollBarThickness = 0 })
            local ScrollL = Library:Create("UIListLayout", { Parent = List1, Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center })
            Library:Create("UIPadding", { Parent = List1, PaddingLeft = UDim.new(0, 1), PaddingRight = UDim.new(0, 1) })
            ScrollL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                List1.CanvasSize = UDim2.new(0, 0, 0, ScrollL.AbsoluteContentSize.Y + 15)
            end)

            local selectedValues = {}
            local selectedOrder  = 0

            local function isInTable(val, tbl)
                if type(tbl) ~= "table" then return false end
                for _, v in pairs(tbl) do if v == val then return true end end
                return false
            end

            local function Settext()
                local txt
                if IsMulti then
                    txt = table.concat(Value, ", ")
                else
                    txt = tostring(Value)
                end
                Desc1.Text     = txt
                Left.Desc.Text = txt
            end

            local isOpen = false
            UserInputService.InputBegan:Connect(function(A)
                if not isOpen then return end
                local mouse = LocalPlayer:GetMouse()
                local mx, my = mouse.X, mouse.Y
                local dp, ds = DropFrame.AbsolutePosition, DropFrame.AbsoluteSize
                if A.UserInputType == Enum.UserInputType.MouseButton1 or A.UserInputType == Enum.UserInputType.Touch then
                    if not (mx >= dp.X and mx <= dp.X + ds.X and my >= dp.Y and my <= dp.Y + ds.Y) then
                        isOpen = false; DropFrame.Visible = false; DropFrame.Position = UDim2.new(0.5, 0, 0.3, 0)
                    end
                end
            end)
            Open.MouseButton1Click:Connect(function()
                if Library:IsDropdownOpen() and not isOpen then return end
                isOpen = not isOpen
                if isOpen then
                    DropFrame.Visible = true
                    Library:Tween({ v = DropFrame, t = 0.3, s = "Back", d = "Out", g = { Position = UDim2.new(0.5, 0, 0.5, 0) } }):Play()
                else
                    DropFrame.Visible = false; DropFrame.Position = UDim2.new(0.5, 0, 0.3, 0)
                end
            end)

            local Setting = {}

            function Setting:Close()
                isOpen = false
                DropFrame.Visible = false
                DropFrame.Position = UDim2.new(0.5, 0, 0.3, 0)
            end

            function Setting:Clear(a)
                for _, v in ipairs(List1:GetChildren()) do
                    if v:IsA("Frame") then
                        local should = a == nil or (type(a) == "string" and v.Title.Text == a) or (type(a) == "table" and isInTable(v.Title.Text, a))
                        if should then v:Destroy() end
                    end
                end
                if a == nil then
                    Value = IsMulti and {} or nil
                    selectedValues = {}
                    selectedOrder  = 0
                    Desc1.Text     = Placeholder
                    Left.Desc.Text = Placeholder
                end
            end

            function Setting:SetList(newList)
                Setting:Clear()
                List = newList
                for _, name in ipairs(newList) do Setting:AddList(name) end
            end

            function Setting:SetValue(val)
                if IsMulti then
                    if type(val) ~= "table" then val = {val} end
                    Value = val
                    selectedValues = {}
                    selectedOrder  = 0
                    for _, v in pairs(List1:GetChildren()) do
                        if v:IsA("Frame") and v.Name == "NewList" then
                            local selected = isInTable(v.Title.Text, val)
                            v.Title.TextColor3 = selected and T.Accent or T.Text
                            v.BackgroundTransparency = selected and 0.85 or 1
                            if selected then
                                selectedOrder = selectedOrder - 1
                                selectedValues[v.Title.Text] = selectedOrder
                                v.LayoutOrder = selectedOrder
                            else
                                v.LayoutOrder = 0
                            end
                        end
                    end
                    Settext()
                    pcall(Callback, val)
                else
                    Value = val
                    for _, v in pairs(List1:GetChildren()) do
                        if v:IsA("Frame") and v.Name == "NewList" then
                            local selected = v.Title.Text == tostring(val)
                            v.Title.TextColor3 = selected and T.Accent or T.Text
                            v.BackgroundTransparency = selected and 0.85 or 1
                        end
                    end
                    Settext()
                    pcall(Callback, val)
                end
            end

            function Setting:AddList(Name)
                local Item = Library:Create("Frame", { Name = "NewList", Parent = List1, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = 0, Size = UDim2.new(1, 0, 0, 25), ZIndex = 500, Selectable = false })
                Library:Create("UICorner", { Parent = Item, CornerRadius = UDim.new(0, 2) })
                local ItemTitle = Library:Create("TextLabel", { Name = "Title", Parent = Item, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = -1, Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(1, -15, 1, 0), ZIndex = 500, Selectable = false, Font = Enum.Font.GothamSemibold, RichText = true, Text = tostring(Name), TextColor3 = T.Text, TextSize = 11, TextStrokeTransparency = 0.7, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y })
                MakeGradient(ItemTitle)

                local function OnValue(val)
                    ItemTitle.TextColor3 = val and T.Accent or T.Text
                    Library:Tween({ v = Item, t = 0.2, s = "Linear", d = "Out", g = { BackgroundTransparency = val and 0.85 or 1 } }):Play()
                end
                local ItemClick = Library:Button(Item)
                local function OnSelected()
                    if IsMulti then
                        if selectedValues[Name] then
                            selectedValues[Name] = nil; Item.LayoutOrder = 0; OnValue(false)
                        else
                            selectedOrder = selectedOrder - 1; selectedValues[Name] = selectedOrder; Item.LayoutOrder = selectedOrder; OnValue(true)
                        end
                        local sel = {}; for i in pairs(selectedValues) do table.insert(sel, i) end
                        if #sel > 0 then table.sort(sel); Value = sel; Settext() else Desc1.Text = Placeholder; Left.Desc.Text = Placeholder end
                        pcall(Callback, sel)
                    else
                        for _, v in pairs(List1:GetChildren()) do
                            if v:IsA("Frame") and v.Name == "NewList" then
                                v.Title.TextColor3 = T.Text
                                Library:Tween({ v = v, t = 0.2, s = "Linear", d = "Out", g = { BackgroundTransparency = 1 } }):Play()
                            end
                        end
                        OnValue(true); Value = Name; Settext(); pcall(Callback, Value)
                    end
                end
                delay(0, function()
                    if IsMulti then
                        if isInTable(Name, Value) then
                            selectedOrder = selectedOrder - 1; selectedValues[Name] = selectedOrder; Item.LayoutOrder = selectedOrder; OnValue(true)
                            local sel = {}; for i in pairs(selectedValues) do table.insert(sel, i) end
                            if #sel > 0 then table.sort(sel); Settext() else Desc1.Text = Placeholder; Left.Desc.Text = Placeholder end
                        end
                    else
                        if Name == Value then OnValue(true); Settext() end
                    end
                end)
                ItemClick.MouseButton1Click:Connect(OnSelected)
                return Item
            end

            function Setting:RemoveItem(Name)
                for _, v in ipairs(List1:GetChildren()) do
                    if v:IsA("Frame") and v.Name == "NewList" and v.Title.Text == tostring(Name) then
                        if IsMulti and selectedValues[Name] then
                            selectedValues[Name] = nil
                            local sel = {}; for i in pairs(selectedValues) do table.insert(sel, i) end
                            Value = sel; Settext()
                        elseif not IsMulti and Value == Name then
                            Value = nil; Desc1.Text = Placeholder; Left.Desc.Text = Placeholder
                        end
                        v:Destroy()
                        return true
                    end
                end
                return false
            end

            function Setting:GetValue()
                return Value
            end

            function Setting:SetTitle(newTitle)
                DTitle = newTitle
                DropText.Title.Text = tostring(newTitle)
                Left.Title.Text     = tostring(newTitle)
            end

            SearchBox.Changed:Connect(function()
                local s = string.lower(SearchBox.Text)
                for _, v in pairs(List1:GetChildren()) do
                    if v:IsA("Frame") and v.Name == "NewList" then
                        v.Visible = string.find(string.lower(v.Title.Text), s, 1, true) ~= nil
                    end
                end
            end)
            for _, name in ipairs(List) do Setting:AddList(name) end
            return Setting
        end

        function Page:Keybind(Args)
            local KTitle   = Args.Title
            local KDesc    = Args.Desc
            local Value    = Args.Value or Enum.KeyCode.Unknown
            local Callback = Args.Callback or function() end
            local Rows     = Library:NewRows(PageScrolling, KTitle, KDesc, T)
            local Right    = Rows.Vectorize.Right
            local Left     = Rows.Vectorize.Left.Text

            local KeyBtn = Library:Create("Frame", {
                Name             = "KeyBind",
                Parent           = Right,
                BackgroundColor3 = T.RowAlt,
                BorderSizePixel  = 0,
                Size             = UDim2.new(0, 80, 0, 22),
                ClipsDescendants = true
            })
            Library:Create("UICorner", { Parent = KeyBtn, CornerRadius = UDim.new(0, 3) })
            Library:Create("UIStroke", { Parent = KeyBtn, Color = T.Stroke, Thickness = 0.5 })

            local KeyLabel = Library:Create("TextLabel", {
                Parent                 = KeyBtn,
                AnchorPoint            = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Position               = UDim2.new(0.5, 0, 0.5, 0),
                Size                   = UDim2.new(1, -8, 1, 0),
                Font                   = Enum.Font.GothamSemibold,
                Text                   = tostring(Value.Name),
                TextColor3             = T.Accent,
                TextSize               = 11,
                TextTruncate           = Enum.TextTruncate.AtEnd,
                TextWrapped            = true,
                AutomaticSize          = Enum.AutomaticSize.Y
            })
            trackAccent(KeyLabel, "TextColor3")

            local ClickBtn  = Library:Button(KeyBtn)
            local listening = false
            local Data      = { Title = KTitle, Desc = KDesc, Value = Value }

            local function SetKey(key)
                Data.Value          = key
                KeyLabel.Text       = tostring(key.Name)
                KeyLabel.TextColor3 = T.Accent
                Library:Tween({ v = KeyBtn, t = 0.2, s = "Exponential", d = "Out", g = { BackgroundColor3 = T.RowAlt } }):Play()
                pcall(Callback, key)
            end

            ClickBtn.MouseButton1Click:Connect(function()
                if Library:IsDropdownOpen() then return end
                if listening then return end
                listening           = true
                KeyLabel.Text       = "..."
                KeyLabel.TextColor3 = T.Text
                Library:Tween({ v = KeyBtn, t = 0.2, s = "Exponential", d = "Out", g = { BackgroundColor3 = T.Stroke } }):Play()

                local conn
                conn = UserInputService.InputBegan:Connect(function(input, processed)
                    if processed then return end
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        conn:Disconnect()
                        SetKey(input.KeyCode)
                    end
                end)
            end)

            UserInputService.InputBegan:Connect(function(input, processed)
                if processed or listening then return end
                if input.KeyCode == Data.Value then
                    pcall(Callback, Data.Value)
                end
            end)

            return setmetatable({}, {
                __newindex = function(t, k, v)
                    rawset(Data, k, v)
                    if k == "Title" then Left.Title.Text = tostring(v)
                    elseif k == "Desc"  then Left.Desc.Text = tostring(v)
                    elseif k == "Value" then SetKey(v) end
                end,
                __index = Data
            })
        end

        function Page:Banner(Assets)
            local Banner = Library:Create("ImageLabel", {
                Name                   = "NewBanner",
                Parent                 = PageScrolling,
                BackgroundTransparency = 1,
                BorderSizePixel        = 0,
                Size                   = UDim2.new(1, 0, 0, 235),
                Image                  = Library:Asset(Assets),
                ScaleType              = Enum.ScaleType.Crop
            })
            Library:Create("UICorner", { Parent = Banner, CornerRadius = UDim.new(0, 3) })

            local BannerData = { Instance = Banner }
            return setmetatable({}, {
                __newindex = function(t, k, v)
                    rawset(BannerData, k, v)
                    if k == "Image" then Banner.Image = Library:Asset(v)
                    elseif k == "Size"  then Banner.Size = v
                    elseif k == "Visible" then Banner.Visible = v
                    end
                end,
                __index = BannerData
            })
        end

        function Page:ColorPicker(Args)
            local CPTitle  = Args.Title
            local CPDesc   = Args.Desc
            local Value    = Args.Value or Color3.fromRGB(255, 255, 255)
            local Callback = Args.Callback or function() end
            local Rows     = Library:NewRows(PageScrolling, CPTitle, CPDesc, T)
            local Right    = Rows.Vectorize.Right
            local Left     = Rows.Vectorize.Left.Text

            local Preview = Library:Create("Frame", {
                Name             = "Preview",
                Parent           = Right,
                BackgroundColor3 = Value,
                BorderSizePixel  = 0,
                Size             = UDim2.new(0, 40, 0, 20)
            })
            Library:Create("UICorner",  { Parent = Preview, CornerRadius = UDim.new(0, 3) })
            Library:Create("UIStroke",  { Parent = Preview, Color = T.Stroke, Thickness = 0.5 })

            local Data = { Title = CPTitle, Desc = CPDesc, Value = Value }

            local function SetColor(c)
                if typeof(c) == "string" then c = ResolveColor(c) end
                Data.Value = c
                Preview.BackgroundColor3 = c
                Left.Desc.Text = string.format("R:%d G:%d B:%d", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
                pcall(Callback, c)
            end

            local PreviewClick = Library:Button(Preview)
            PreviewClick.MouseButton1Click:Connect(function() end)

            SetColor(Value)

            return setmetatable({}, {
                __newindex = function(t, k, v)
                    rawset(Data, k, v)
                    if k == "Title" then Left.Title.Text = tostring(v)
                    elseif k == "Desc"  then Left.Desc.Text  = tostring(v)
                    elseif k == "Value" then SetColor(v) end
                end,
                __index = Data
            })
        end

        function Page:Label(Args)
            local LTitle = Args.Title or ""
            local LDesc  = Args.Desc  or ""
            return Library:NewRows(PageScrolling, LTitle, LDesc, T)
        end

        return Page
    end

    function Library:SetTimeValue(Value)
        THETIME.Text = Value
    end

    function Library:SetWindowTitle(newTitle)
        TitleLabel.Text = newTitle
    end

    function Library:SetWindowSubTitle(newSubTitle)
        Info.SubTitle.Text = newSubTitle
    end

    function Library:AddSizeSlider(Page)
        return Page:Slider({
            Title    = "Interface Scale",
            Desc     = "Adjust the UI scale",
            Min      = 0.5,
            Max      = 2.5,
            Rounding = 1,
            Value    = Scaler.Scale,
            Callback = function(v)
                Scaler:SetAttribute("ManualScale", true)
                Scaler.Scale = v
            end
        })
    end

    function Library:SetTheme(newTheme)
        if newTheme.BG  then newTheme.Background = newTheme.BG;  newTheme.BG  = nil end
        if newTheme.Tab then newTheme.TabBg       = newTheme.Tab; newTheme.Tab = nil end

        for k, v in pairs(newTheme) do
            T[k] = ResolveColor(v)
        end

        for _, ref in ipairs(accentRefs) do
            local inst, prop = ref[1], ref[2]
            if inst and inst.Parent then pcall(function() inst[prop] = T.Accent end) end
        end
        for _, ref in ipairs(bgRefs) do
            local inst, prop = ref[1], ref[2]
            if inst and inst.Parent then pcall(function() inst[prop] = T.Background end) end
        end
        for _, ref in ipairs(tabImageRefs) do
            local inst, prop = ref[1], ref[2]
            if inst and inst.Parent then pcall(function() inst[prop] = T.TabImage end) end
        end
        for _, ref in ipairs(tabBgRefs) do
            local inst, prop = ref[1], ref[2]
            if inst and inst.Parent then pcall(function() inst[prop] = T.TabBg end) end
        end
        for _, ref in ipairs(tabStrokeRefs) do
            local inst, prop = ref[1], ref[2]
            if inst and inst.Parent then pcall(function() inst[prop] = T.TabStroke end) end
        end
    end

    function Library:SetPillIcon(icon)
        Logo.Image = Library:Asset(icon)
    end

    function Library:SetExecutorIdentity(v)
        ExecLabel.Visible = v == true
    end

    function Library:GetTheme()
        local copy = {}
        for k, v in pairs(T) do copy[k] = v end
        return copy
    end

    function Library:Destroy()
        pcall(function() Xova:Destroy() end)
        pcall(function() ToggleScreen:Destroy() end)
        pcall(function() NotifGui:Destroy() end)
    end

    return Window
end

return Library
