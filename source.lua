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

if not getgenv().ShowImage then
    getgenv().ShowImage = function(cfg)
        cfg = cfg or {}
        local sg = Instance.new("ScreenGui")
        sg.Name           = "ImageDisplay_" .. HttpService:GenerateGUID(false)
        sg.DisplayOrder   = 9999
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.ResetOnSpawn   = false
        sg.ScreenInsets   = Enum.ScreenInsets.None
        sg.Parent         = CoreGui
        local il = Instance.new("ImageLabel")
        il.Size                   = UDim2.new(0, cfg.size or 400, 0, cfg.size or 400)
        il.Position               = UDim2.new(0.5, 0, 0.5, 0)
        il.AnchorPoint            = Vector2.new(0.5, 0.5)
        il.BackgroundTransparency = 1
        il.Image                  = cfg.url or ""
        il.Parent                 = sg
        if cfg.duration then task.delay(cfg.duration, function() sg:Destroy() end) end
        return sg
    end
end

local Lucide = {}
task.spawn(function()
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ArchIsDead/Arch-Vault/refs/heads/main/lucide-icons.lua"))()
    end)
    if ok and type(res) == "table" then
        for k, v in pairs(res) do Lucide[k] = v end
    end
end)

local ConfigSystem = {}
do
    local _store  = {}
    local _active = nil

    function ConfigSystem:Create(name, data)
        if not name or name == "" then return false, "Name required" end
        if _store[name] then return false, "Already exists" end
        _store[name] = { name=name, data=data or {}, created=os.time(), updated=os.time() }
        return true
    end
    function ConfigSystem:Load(name)
        if not _store[name] then return false end
        _active = name; return true
    end
    function ConfigSystem:Save(name, data)
        name = name or _active
        if not name then return false end
        if not _store[name] then
            local ok = self:Create(name, data)
            return ok
        else
            if data then _store[name].data = data end
            _store[name].updated = os.time()
            return true
        end
    end
    function ConfigSystem:Overwrite(name, data)
        if not _store[name] then return false end
        _store[name].data    = data or _store[name].data
        _store[name].updated = os.time()
        return true
    end
    function ConfigSystem:SetActive(name)
        if not _store[name] then return false end
        _active = name; return true
    end
    function ConfigSystem:Active()  return _active end
    function ConfigSystem:Get(name) return _store[name or _active] end
    function ConfigSystem:GetData(name)
        local c = _store[name or _active]; return c and c.data or nil
    end
    function ConfigSystem:SetValue(key, value, name)
        name = name or _active
        if not name then return false end
        if not _store[name] then self:Create(name) end
        _store[name].data[key] = value
        _store[name].updated   = os.time()
        return true
    end
    function ConfigSystem:GetValue(key, name)
        local c = _store[name or _active]; return c and c.data[key] or nil
    end
    function ConfigSystem:Delete(name)
        if not _store[name] then return false end
        _store[name] = nil
        if _active == name then _active = nil end
        return true
    end
    function ConfigSystem:Rename(old, new)
        if not _store[old] or _store[new] then return false end
        _store[new] = _store[old]; _store[new].name = new; _store[old] = nil
        if _active == old then _active = new end
        return true
    end
    function ConfigSystem:Duplicate(name, newName)
        if not _store[name] then return false end
        newName = newName or (name.."_copy")
        if _store[newName] then return false end
        local copy = {}
        for k, v in pairs(_store[name].data) do copy[k] = v end
        return self:Create(newName, copy)
    end
    function ConfigSystem:Import(name, json)
        local ok, data = pcall(HttpService.JSONDecode, HttpService, json)
        if not ok then return false end
        return self:Save(name, data)
    end
    function ConfigSystem:Clear(name)
        name = name or _active
        if not _store[name] then return false end
        _store[name].data = {}; _store[name].updated = os.time(); return true
    end
    function ConfigSystem:List()
        local t = {}
        for k in pairs(_store) do table.insert(t, k) end
        table.sort(t); return t
    end
    function ConfigSystem:Exists(name) return _store[name] ~= nil end
    function ConfigSystem:Count()
        local n = 0; for _ in pairs(_store) do n = n + 1 end; return n
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
    return Color3.fromRGB(
        tonumber(hex:sub(1,2),16) or 0,
        tonumber(hex:sub(3,4),16) or 0,
        tonumber(hex:sub(5,6),16) or 0
    )
end

local function RC(v)
    if typeof(v) == "Color3" then return v end
    if type(v)   == "string" then return Library:Hex(v) end
    return v
end

local function GetExec()
    if getexecutorname then local ok,n=pcall(getexecutorname); if ok and n and n~="" then return n end end
    if identifyexecutor then local ok,n=pcall(identifyexecutor); if ok and n and n~="" then return n end end
    return "Unknown"
end

function Library:Create(Class, Props)
    local inst = Instance.new(Class)
    for k, v in Props do inst[k] = v end
    return inst
end

function Library:Draggable(handle, target)
    target = target or handle
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging=true; dragStart=inp.Position; startPos=target.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
            dragInput=inp
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp==dragInput and dragging then
            local d=inp.Position-dragStart
            target.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

function Library:Button(parent)
    return Library:Create("TextButton",{
        Name="Click",Parent=parent,
        BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),Font=Enum.Font.SourceSans,Text="",
        TextColor3=Color3.fromRGB(0,0,0),TextSize=14,
        ZIndex=parent.ZIndex+3
    })
end

function Library:Tween(info)
    return TweenService:Create(info.v,TweenInfo.new(info.t,Enum.EasingStyle[info.s],Enum.EasingDirection[info.d]),info.g)
end

function Library.Effect(c, p)
    p.ClipsDescendants=true
    local mouse=Players.LocalPlayer:GetMouse()
    local rx=mouse.X-c.AbsolutePosition.X
    local ry=mouse.Y-c.AbsolutePosition.Y
    if rx<0 or ry<0 or rx>c.AbsoluteSize.X or ry>c.AbsoluteSize.Y then return end
    local circle=Library:Create("Frame",{
        Parent=p,BackgroundColor3=Color3.fromRGB(255,255,255),
        BackgroundTransparency=0.75,BorderSizePixel=0,
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0,rx,0,ry),Size=UDim2.new(0,0,0,0),ZIndex=p.ZIndex
    })
    Library:Create("UICorner",{Parent=circle,CornerRadius=UDim.new(1,0)})
    local t=TweenService:Create(circle,TweenInfo.new(2.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Size=UDim2.new(0,c.AbsoluteSize.X*1.5,0,c.AbsoluteSize.X*1.5),
        BackgroundTransparency=1
    })
    t.Completed:Once(function() circle:Destroy() end); t:Play()
end

function Library:Asset(rbx)
    if rbx==nil then return "" end
    if typeof(rbx)=="number" then return "rbxassetid://"..rbx end
    if typeof(rbx)=="string" then
        if rbx:match("^https?://") then return rbx end
        if rbx:find("rbxassetid://") then return rbx end
        if Lucide[rbx] then return Lucide[rbx] end
        if Lucide["lucide-"..rbx] then return Lucide["lucide-"..rbx] end
        if rbx:match("^%d+$") then return "rbxassetid://"..rbx end
        return rbx
    end
    return tostring(rbx)
end

local function MkGrad(parent,rot)
    return Library:Create("UIGradient",{
        Parent=parent,Rotation=rot or 90,
        Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.75,Color3.fromRGB(163,163,163)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(100,100,100))
        }
    })
end

local function AccentGrad(parent)
    Library:Create("UIGradient",{
        Parent=parent,Rotation=90,
        Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(56,56,56))
        }
    })
end

function Library:NewRows(parent, title, desc, T)
    local Rows=Library:Create("Frame",{
        Name="Rows",Parent=parent,
        BackgroundColor3=T.Row,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,40)
    })
    Library:Create("UIStroke",{Parent=Rows,Color=T.Stroke,Thickness=0.5})
    Library:Create("UICorner",{Parent=Rows,CornerRadius=UDim.new(0,3)})
    Library:Create("UIListLayout",{Parent=Rows,Padding=UDim.new(0,6),
        FillDirection=Enum.FillDirection.Horizontal,
        SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center})
    Library:Create("UIPadding",{Parent=Rows,PaddingBottom=UDim.new(0,6),PaddingTop=UDim.new(0,5)})

    local Vec=Library:Create("Frame",{Name="Vectorize",Parent=Rows,
        BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)})
    Library:Create("UIPadding",{Parent=Vec,PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})

    local Right=Library:Create("Frame",{Name="Right",Parent=Vec,
        BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)})
    Library:Create("UIListLayout",{Parent=Right,
        HorizontalAlignment=Enum.HorizontalAlignment.Right,
        SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center})

    local Left=Library:Create("Frame",{Name="Left",Parent=Vec,
        BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)})
    local Text=Library:Create("Frame",{Name="Text",Parent=Left,
        BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)})
    Library:Create("UIListLayout",{Parent=Text,
        HorizontalAlignment=Enum.HorizontalAlignment.Center,
        SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center})

    if title and title ~= "" then
        local TL=Library:Create("TextLabel",{
            Name="Title",Parent=Text,
            AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,
            LayoutOrder=-1,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,0,13),
            Font=Enum.Font.GothamSemibold,RichText=true,
            Text=title,TextColor3=T.Text,TextSize=13,TextStrokeTransparency=0.7,
            TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y
        })
        MkGrad(TL)
    else
        Library:Create("TextLabel",{
            Name="Title",Parent=Text,
            BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(0,0,0,0),Text="",TextSize=1,Visible=false
        })
    end

    if desc and desc ~= "" then
        Library:Create("TextLabel",{
            Name="Desc",Parent=Text,
            AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,
            Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,0,10),
            Font=Enum.Font.GothamMedium,RichText=true,
            Text=desc,TextColor3=T.SubText,TextSize=10,TextStrokeTransparency=0.7,TextTransparency=0.2,
            TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y
        })
    else
        Library:Create("TextLabel",{
            Name="Desc",Parent=Text,
            BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(0,0,0,0),Text="",TextSize=1,Visible=false
        })
    end

    return Rows
end

local NotifGui=Library:Create("ScreenGui",{
    Name="VitaNotifications",Parent=Library:Parent(),
    ZIndexBehavior=Enum.ZIndexBehavior.Global,
    DisplayOrder=999,IgnoreGuiInset=true,ResetOnSpawn=false
})
local NotifHolder=Library:Create("Frame",{
    Name="Holder",Parent=NotifGui,
    BackgroundTransparency=1,AnchorPoint=Vector2.new(1,1),
    Position=UDim2.new(1,-15,1,-15),Size=UDim2.new(0,270,1,-30)
})
Library:Create("UIListLayout",{
    Parent=NotifHolder,VerticalAlignment=Enum.VerticalAlignment.Bottom,
    SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8),
    FillDirection=Enum.FillDirection.Vertical
})

function Library:Notification(Args)
    local Title    = Args.Title    or "Notification"
    local Desc     = Args.Desc     or ""
    local Duration = Args.Duration or 3
    local NType    = Args.Type     or "Info"
    local CustomColor = Args.Color and RC(Args.Color) or nil
    local Icon     = Args.Icon

    local typeColors={
        Info=Color3.fromRGB(100,149,237),Success=Color3.fromRGB(50,200,100),
        Warning=Color3.fromRGB(255,165,0),Error=Color3.fromRGB(220,50,50),
    }
    local ac = CustomColor or typeColors[NType] or typeColors.Info

    local Notif=Library:Create("Frame",{
        Name="Notification",Parent=NotifHolder,
        BackgroundColor3=Color3.fromRGB(13,13,13),BorderSizePixel=0,
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        ClipsDescendants=false,BackgroundTransparency=1,
    })
    Library:Create("UICorner",{Parent=Notif,CornerRadius=UDim.new(0,6)})
    Library:Create("UIStroke",{Parent=Notif,Color=Color3.fromRGB(30,30,30),Thickness=0.5})

    local Bar=Library:Create("Frame",{Parent=Notif,BackgroundColor3=ac,BorderSizePixel=0,Size=UDim2.new(0,3,1,0)})
    Library:Create("UICorner",{Parent=Bar,CornerRadius=UDim.new(0,2)})

    local Content=Library:Create("Frame",{
        Parent=Notif,BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-12,1,0),
        AutomaticSize=Enum.AutomaticSize.Y,
    })
    Library:Create("UIPadding",{Parent=Content,PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),PaddingRight=UDim.new(0,10)})
    Library:Create("UIListLayout",{Parent=Content,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)})

    local TRow=Library:Create("Frame",{
        Parent=Content,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,16),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=1
    })
    Library:Create("UIListLayout",{Parent=TRow,FillDirection=Enum.FillDirection.Horizontal,
        Padding=UDim.new(0,5),VerticalAlignment=Enum.VerticalAlignment.Center,
        SortOrder=Enum.SortOrder.LayoutOrder})

    if Icon then
        Library:Create("ImageLabel",{
            Parent=TRow,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(0,13,0,13),LayoutOrder=1,
            Image=Library:Asset(Icon),ImageColor3=ac
        })
    end
    Library:Create("TextLabel",{
        Parent=TRow,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,-20,0,14),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2,
        Font=Enum.Font.GothamBold,Text=Title,
        TextColor3=ac,TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,RichText=true,TextWrapped=true
    })

    Library:Create("TextLabel",{
        Parent=Content,BackgroundTransparency=1,BorderSizePixel=0,
        AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),LayoutOrder=2,
        Font=Enum.Font.GothamMedium,Text=Desc,
        TextColor3=Color3.fromRGB(200,200,200),TextSize=11,
        TextTransparency=0.2,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true
    })

    local PBg=Library:Create("Frame",{
        Parent=Content,BackgroundColor3=Color3.fromRGB(30,30,30),
        BorderSizePixel=0,Size=UDim2.new(1,0,0,2),LayoutOrder=3
    })
    Library:Create("UICorner",{Parent=PBg,CornerRadius=UDim.new(1,0)})
    local PFill=Library:Create("Frame",{
        Parent=PBg,BackgroundColor3=ac,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)
    })
    Library:Create("UICorner",{Parent=PFill,CornerRadius=UDim.new(1,0)})

    TweenService:Create(Notif,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0}):Play()
    TweenService:Create(PFill,TweenInfo.new(Duration,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Size=UDim2.new(0,0,1,0)}):Play()
    task.delay(Duration,function()
        TweenService:Create(Notif,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
        task.wait(0.35); Notif:Destroy()
    end)
    return Notif
end

function Library:Window(Args)
    local Title             = Args.Title
    local SubTitle          = Args.SubTitle
    local ToggleKey         = Args.ToggleKey or Enum.KeyCode.LeftControl
    local AutoScale         = Args.AutoScale ~= false
    local BaseScale         = Args.Scale    or 1.45
    local CustomSize        = Args.Size
    local ShowUserInfo      = Args.ExecIdentifyShown ~= false
    local BbIcon            = Args.BbIcon or "rbxassetid://104055321996495"
    local CustomUserName    = Args.UserName
    local CustomExecutor    = Args.ExecutorName

    local RAW_W = CustomSize and CustomSize.X.Offset or 500
    local RAW_H = CustomSize and CustomSize.Y.Offset or 350

    local uT = Args.Theme or {}
    if Args.BG        then uT.Background=Args.BG        end
    if Args.Tab       then uT.TabBg=Args.Tab            end
    if Args.TabImage  then uT.TabImage=Args.TabImage    end
    if Args.TabStroke then uT.TabStroke=Args.TabStroke  end

    local T = {
        Accent    = RC(uT.Accent     or Color3.fromRGB(255,0,127)),
        Background= RC(uT.Background or Color3.fromRGB(11,11,11)),
        Row       = RC(uT.Row        or Color3.fromRGB(15,15,15)),
        RowAlt    = RC(uT.RowAlt     or Color3.fromRGB(10,10,10)),
        Stroke    = RC(uT.Stroke     or Color3.fromRGB(25,25,25)),
        Text      = RC(uT.Text       or Color3.fromRGB(255,255,255)),
        SubText   = RC(uT.SubText    or Color3.fromRGB(163,163,163)),
        TabBg     = RC(uT.TabBg      or Color3.fromRGB(10,10,10)),
        TabStroke = RC(uT.TabStroke  or Color3.fromRGB(75,0,38)),
        TabImage  = RC(uT.TabImage   or uT.Accent or Color3.fromRGB(255,0,127)),
        DropBg    = RC(uT.DropBg     or Color3.fromRGB(18,18,18)),
        DropStroke= RC(uT.DropStroke or Color3.fromRGB(30,30,30)),
        PillBg    = RC(uT.PillBg     or Color3.fromRGB(11,11,11)),
    }

    local accentRefs={} local bgRefs={} local tabImageRefs={} local tabBgRefs={} local tabStrokeRefs={}
    local function tA(i,p) table.insert(accentRefs,   {i,p}); return i end
    local function tB(i,p) table.insert(bgRefs,       {i,p}); return i end
    local function tTI(i,p) table.insert(tabImageRefs,{i,p}); return i end
    local function tTB(i,p) table.insert(tabBgRefs,   {i,p}); return i end
    local function tTS(i,p) table.insert(tabStrokeRefs,{i,p}); return i end

    local Xova=Library:Create("ScreenGui",{
        Name="Xova",Parent=Library:Parent(),
        ZIndexBehavior=Enum.ZIndexBehavior.Global,
        DisplayOrder=10,IgnoreGuiInset=true,ResetOnSpawn=false
    })

    local function GetVP()
        local cam=workspace.CurrentCamera
        return cam and cam.ViewportSize or Vector2.new(1280,720)
    end
    local function MaxScale()
        local vp=GetVP()
        return math.min((vp.X*0.95)/RAW_W,(vp.Y*0.95)/RAW_H)
    end
    local function CS(s) return math.clamp(s,0.35,MaxScale()) end
    local function ASV()
        local vp=GetVP()
        return CS(math.min(vp.X/1920,vp.Y/1080)*BaseScale*1.5)
    end

    local Scaler=Library:Create("UIScale",{
        Parent=Xova,
        Scale=Mobile and CS(1) or (AutoScale and ASV() or CS(BaseScale))
    })
    if AutoScale and not Mobile then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if not Scaler:GetAttribute("ManualScale") then Scaler.Scale=ASV() end
        end)
    end

    local Background=Library:Create("Frame",{
        Name="Background",Parent=Xova,
        AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.Background,
        BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,RAW_W,0,RAW_H)
    })
    tB(Background,"BackgroundColor3")
    Library:Create("UICorner",{Parent=Background})
    Library:Create("ImageLabel",{
        Name="Shadow",Parent=Background,
        AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,
        BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(1,120,1,120),ZIndex=0,
        Image="rbxassetid://8992230677",ImageColor3=Color3.fromRGB(0,0,0),
        ImageTransparency=0.5,ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(99,99,99,99)
    })

    function Library:IsDropdownOpen()
        for _,v in pairs(Background:GetChildren()) do
            if (v.Name=="Dropdown" or v.Name=="ColorPickerFrame") and v.Visible then return true end
        end
        return false
    end

    local HDR_H=48
    local Header=Library:Create("Frame",{
        Name="Header",Parent=Background,
        BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,HDR_H)
    })
    Library:Create("Frame",{
        Parent=Header,Name="Div",BackgroundColor3=T.Stroke,BorderSizePixel=0,
        AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1)
    })

    local ReturnBtn=Library:Create("ImageLabel",{
        Name="Return",Parent=Header,
        AnchorPoint=Vector2.new(0,0.5),BackgroundTransparency=1,
        BorderSizePixel=0,Position=UDim2.new(0,10,0.5,0),
        Size=UDim2.new(0,18,0,18),
        Image="rbxassetid://130391877219356",
        ImageColor3=T.Accent,Visible=false,ZIndex=5
    })
    tA(ReturnBtn,"ImageColor3")
    MkGrad(ReturnBtn)

    local HeaderRow=Library:Create("Frame",{
        Name="HeaderRow",Parent=Header,
        BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0)
    })
    Library:Create("UIPadding",{Parent=HeaderRow,
        PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12),
        PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6)})
    Library:Create("UIListLayout",{Parent=HeaderRow,
        FillDirection=Enum.FillDirection.Horizontal,
        SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Center,
        Padding=UDim.new(0,8)})

    local UserBlock
    if ShowUserInfo then
        UserBlock=Library:Create("Frame",{
            Name="UserBlock",Parent=HeaderRow,
            BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(0,148,0,30),LayoutOrder=1
        })
        Library:Create("UIListLayout",{Parent=UserBlock,
            FillDirection=Enum.FillDirection.Horizontal,
            Padding=UDim.new(0,7),VerticalAlignment=Enum.VerticalAlignment.Center,
            SortOrder=Enum.SortOrder.LayoutOrder})

        local AvatarOuter=Library:Create("Frame",{
            Parent=UserBlock,BackgroundColor3=T.Accent,BorderSizePixel=0,
            Size=UDim2.new(0,28,0,28),LayoutOrder=1,ClipsDescendants=false
        })
        Library:Create("UICorner",{Parent=AvatarOuter,CornerRadius=UDim.new(1,0)})
        tA(AvatarOuter,"BackgroundColor3")

        local AvatarInner=Library:Create("Frame",{
            Parent=AvatarOuter,BackgroundColor3=T.TabBg,BorderSizePixel=0,
            AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.new(0.5,0,0.5,0),
            Size=UDim2.new(1,-2,1,-2),ClipsDescendants=true
        })
        Library:Create("UICorner",{Parent=AvatarInner,CornerRadius=UDim.new(1,0)})

        local AvatarImg=Library:Create("ImageLabel",{
            Parent=AvatarInner,
            AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,
            BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),
            Size=UDim2.new(1,0,1,0),Image=""
        })
        task.spawn(function()
            local ok,img=pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48)
            end)
            if ok and img then AvatarImg.Image=img end
        end)

        local UTF=Library:Create("Frame",{
            Parent=UserBlock,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(0,108,0,28),LayoutOrder=2
        })
        Library:Create("UIListLayout",{Parent=UTF,SortOrder=Enum.SortOrder.LayoutOrder,
            VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,1)})

        local displayName=CustomUserName or LocalPlayer.DisplayName
        if displayName and displayName~="" then
            Library:Create("TextLabel",{
                Name="UserName",Parent=UTF,
                BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,13),
                Font=Enum.Font.GothamBold,Text=displayName,
                TextColor3=T.Text,TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd
            })
        end

        local execName=CustomExecutor or GetExec()
        if execName and execName~="" then
            local EL=Library:Create("TextLabel",{
                Name="Executor",Parent=UTF,
                BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,10),
                Font=Enum.Font.GothamMedium,Text=execName,
                TextColor3=T.Accent,TextSize=10,TextTransparency=0.2,
                TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd
            })
            tA(EL,"TextColor3")
        end

        Library:Create("Frame",{
            Name="VDiv",Parent=HeaderRow,BackgroundColor3=T.Stroke,BorderSizePixel=0,
            Size=UDim2.new(0,1,0,22),LayoutOrder=2,BackgroundTransparency=0.4
        })
    end

    local TitleBlock=Library:Create("Frame",{
        Name="TitleBlock",Parent=HeaderRow,
        BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,-(ShowUserInfo and 210 or 60),0,30),LayoutOrder=3
    })
    Library:Create("UIListLayout",{Parent=TitleBlock,
        SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,1)})

    local TitleLabel
    if Title and Title~="" then
        TitleLabel=Library:Create("TextLabel",{
            Name="Title",Parent=TitleBlock,
            BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,14),
            Font=Enum.Font.GothamBold,RichText=true,
            Text=Title,TextColor3=T.Accent,TextSize=14,
            TextStrokeTransparency=0.7,TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y
        })
        tA(TitleLabel,"TextColor3"); MkGrad(TitleLabel)
    end

    local SubTitleLabel
    if SubTitle and SubTitle~="" then
        SubTitleLabel=Library:Create("TextLabel",{
            Name="SubTitle",Parent=TitleBlock,
            BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,10),
            Font=Enum.Font.GothamMedium,RichText=true,
            Text=SubTitle,TextColor3=T.Text,TextSize=10,
            TextStrokeTransparency=0.7,TextTransparency=0.6,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y
        })
    end

    local TimeFrame=Library:Create("Frame",{
        Name="TimeFrame",Parent=HeaderRow,
        BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(0,0,0,28),LayoutOrder=4,AutomaticSize=Enum.AutomaticSize.X
    })
    Library:Create("UIListLayout",{Parent=TimeFrame,
        SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Center,
        HorizontalAlignment=Enum.HorizontalAlignment.Right})
    local THETIME=Library:Create("TextLabel",{
        Name="Time",Parent=TimeFrame,
        BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(0,0,0,10),AutomaticSize=Enum.AutomaticSize.X,
        Font=Enum.Font.GothamMedium,Text="",
        TextColor3=T.SubText,TextSize=10,TextTransparency=0.35,
        TextXAlignment=Enum.TextXAlignment.Right
    })

    local Scale=Library:Create("Frame",{
        Name="Scale",Parent=Background,
        AnchorPoint=Vector2.new(0,1),BackgroundTransparency=1,
        BorderSizePixel=0,Position=UDim2.new(0,0,1,0),
        Size=UDim2.new(1,0,1,-(HDR_H+1))
    })
    Scale.ClipsDescendants=true

    local Home=Library:Create("Frame",{
        Name="Home",Parent=Scale,
        BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)
    })
    Library:Create("UIPadding",{Parent=Home,
        PaddingBottom=UDim.new(0,15),PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)})

    local MTS=Library:Create("ScrollingFrame",{
        Name="ScrollingFrame",Parent=Home,
        Active=true,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),ClipsDescendants=true,
        AutomaticCanvasSize=Enum.AutomaticSize.None,
        BottomImage="rbxasset://textures/ui/Scroll/scroll-bottom.png",
        CanvasPosition=Vector2.new(0,0),ElasticBehavior=Enum.ElasticBehavior.WhenScrollable,
        MidImage="rbxasset://textures/ui/Scroll/scroll-middle.png",
        ScrollBarImageColor3=Color3.fromRGB(0,0,0),ScrollBarThickness=0,
        ScrollingDirection=Enum.ScrollingDirection.XY,
        TopImage="rbxasset://textures/ui/Scroll/scroll-top.png",
        VerticalScrollBarPosition=Enum.VerticalScrollBarPosition.Right
    })
    Library:Create("UIPadding",{Parent=MTS,
        PaddingBottom=UDim.new(0,1),PaddingLeft=UDim.new(0,1),
        PaddingRight=UDim.new(0,1),PaddingTop=UDim.new(0,1)})

    local TL=Library:Create("UIListLayout",{
        Parent=MTS,Padding=UDim.new(0,10),
        FillDirection=Enum.FillDirection.Horizontal,
        SortOrder=Enum.SortOrder.LayoutOrder,Wraps=true
    })
    TL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        MTS.CanvasSize=UDim2.new(0,0,0,TL.AbsoluteContentSize.Y+15)
    end)

    local PageService=Library:Create("UIPageLayout",{Parent=Scale})
    PageService.HorizontalAlignment=Enum.HorizontalAlignment.Left
    PageService.EasingStyle=Enum.EasingStyle.Exponential
    PageService.TweenTime=0.5
    PageService.GamepadInputEnabled=false
    PageService.ScrollWheelInputEnabled=false
    PageService.TouchInputEnabled=false
    Library.PageService=PageService

    local ToggleScreen=Library:Create("ScreenGui",{
        Name="VitaToggle",Parent=Library:Parent(),
        ZIndexBehavior=Enum.ZIndexBehavior.Global,
        DisplayOrder=11,IgnoreGuiInset=true,ResetOnSpawn=false
    })
    local Pillow=Library:Create("TextButton",{
        Name="Pillow",Parent=ToggleScreen,
        BackgroundColor3=T.PillBg,BorderSizePixel=0,
        Position=UDim2.new(0.06,0,0.15,0),
        Size=UDim2.new(0,50,0,50),
        Text="",ClipsDescendants=true
    })
    tB(Pillow,"BackgroundColor3")
    Library:Create("UICorner",{Parent=Pillow,CornerRadius=UDim.new(1,0)})
    local Logo=Library:Create("ImageLabel",{
        Name="Logo",Parent=Pillow,
        AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,
        BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0.5,0,0.5,0),Image=Library:Asset(BbIcon)
    })
    Library:Draggable(Pillow)
    Pillow.MouseButton1Click:Connect(function() Background.Visible=not Background.Visible end)
    UserInputService.InputBegan:Connect(function(Input,Processed)
        if Processed then return end
        if Input.KeyCode==ToggleKey then Background.Visible=not Background.Visible end
    end)

    local ReturnClickBtn=Library:Button(ReturnBtn)
    local function OnReturn()
        ReturnBtn.Visible=false
        PageService:JumpTo(Home)
    end
    ReturnClickBtn.MouseButton1Click:Connect(OnReturn)
    PageService:JumpTo(Home)
    Library:Draggable(Header,Background)

    local _locked=false
    local _lockedText="This element is locked"

    local function BuildColorPicker(parentFrame, initialColor, onChanged)
        local H,S,V=Color3.toHSV(initialColor)
        local currentColor=initialColor

        local PF=Library:Create("Frame",{
            Name="ColorPickerFrame",Parent=parentFrame,
            AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.DropBg,
            BorderSizePixel=0,Position=UDim2.new(0.5,0,0.35,0),
            Size=UDim2.new(0,320,0,270),
            ZIndex=600,Visible=false,ClipsDescendants=false
        })
        Library:Create("UICorner",{Parent=PF,CornerRadius=UDim.new(0,8)})
        Library:Create("UIStroke",{Parent=PF,Color=T.DropStroke,Thickness=0.8})

        local Header2=Library:Create("Frame",{
            Parent=PF,BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=0.6,
            BorderSizePixel=0,Size=UDim2.new(1,0,0,30),ZIndex=601
        })
        Library:Create("UICorner",{Parent=Header2,CornerRadius=UDim.new(0,8)})
        Library:Create("TextLabel",{
            Parent=Header2,BackgroundTransparency=1,BorderSizePixel=0,
            Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-40,1,0),
            Font=Enum.Font.GothamBold,Text="Color Picker",
            TextColor3=T.Text,TextSize=12,ZIndex=601,
            TextXAlignment=Enum.TextXAlignment.Left
        })
        local ClosePF=Library:Create("TextButton",{
            Parent=Header2,BackgroundTransparency=1,BorderSizePixel=0,
            AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),
            Size=UDim2.new(0,20,0,20),
            Font=Enum.Font.GothamBold,Text="✕",
            TextColor3=T.SubText,TextSize=13,ZIndex=602
        })

        local Body=Library:Create("Frame",{
            Parent=PF,BackgroundTransparency=1,BorderSizePixel=0,
            Position=UDim2.new(0,10,0,36),
            Size=UDim2.new(1,-20,0,228),ZIndex=601
        })

        local SV=Library:Create("Frame",{
            Parent=Body,BackgroundColor3=Color3.fromHSV(H,1,1),
            BorderSizePixel=0,Position=UDim2.new(0,0,0,0),
            Size=UDim2.new(1,-22,0,140),ZIndex=601,ClipsDescendants=true
        })
        Library:Create("UICorner",{Parent=SV,CornerRadius=UDim.new(0,6)})
        Library:Create("UIGradient",{Parent=SV,
            Color=ColorSequence.new{
                ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))},
            Transparency=NumberSequence.new{
                NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}})
        local BL=Library:Create("Frame",{
            Parent=SV,BackgroundColor3=Color3.fromRGB(0,0,0),
            BackgroundTransparency=0,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=602
        })
        Library:Create("UIGradient",{Parent=BL,
            Color=ColorSequence.new{
                ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))},
            Transparency=NumberSequence.new{
                NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)},
            Rotation=90})
        local SVC=Library:Create("Frame",{
            Parent=SV,BackgroundColor3=Color3.fromRGB(255,255,255),
            BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.new(S,0,1-V,0),Size=UDim2.new(0,12,0,12),ZIndex=603
        })
        Library:Create("UICorner",{Parent=SVC,CornerRadius=UDim.new(1,0)})
        Library:Create("UIStroke",{Parent=SVC,Color=Color3.fromRGB(0,0,0),Thickness=2})

        local HF=Library:Create("Frame",{
            Parent=Body,BackgroundColor3=Color3.fromRGB(255,0,0),
            BorderSizePixel=0,
            AnchorPoint=Vector2.new(1,0),
            Position=UDim2.new(1,0,0,0),
            Size=UDim2.new(0,14,0,140),ZIndex=601,ClipsDescendants=true
        })
        Library:Create("UICorner",{Parent=HF,CornerRadius=UDim.new(0,4)})
        Library:Create("UIGradient",{Parent=HF,
            Color=ColorSequence.new{
                ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.17,Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(0.33,Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.50,Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.67,Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.83,Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,0,0))}})
        local HC=Library:Create("Frame",{
            Parent=HF,BackgroundColor3=Color3.fromRGB(255,255,255),
            BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.new(0.5,0,H,0),Size=UDim2.new(1,4,0,6),ZIndex=603
        })
        Library:Create("UICorner",{Parent=HC,CornerRadius=UDim.new(0,2)})
        Library:Create("UIStroke",{Parent=HC,Color=Color3.fromRGB(0,0,0),Thickness=1})

        local InputArea=Library:Create("Frame",{
            Parent=Body,BackgroundTransparency=1,BorderSizePixel=0,
            Position=UDim2.new(0,0,0,148),
            Size=UDim2.new(1,0,0,80),ZIndex=601
        })
        Library:Create("UIListLayout",{Parent=InputArea,
            FillDirection=Enum.FillDirection.Vertical,
            Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})

        local SwatchRow=Library:Create("Frame",{
            Parent=InputArea,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,28),LayoutOrder=1
        })
        Library:Create("UIListLayout",{Parent=SwatchRow,FillDirection=Enum.FillDirection.Horizontal,
            Padding=UDim.new(0,6),VerticalAlignment=Enum.VerticalAlignment.Center,
            SortOrder=Enum.SortOrder.LayoutOrder})

        local SwatchPrev=Library:Create("Frame",{
            Parent=SwatchRow,BackgroundColor3=initialColor,BorderSizePixel=0,
            Size=UDim2.new(0,28,0,24),ZIndex=601,LayoutOrder=1
        })
        Library:Create("UICorner",{Parent=SwatchPrev,CornerRadius=UDim.new(0,4)})
        Library:Create("UIStroke",{Parent=SwatchPrev,Color=T.Stroke,Thickness=0.6})

        local HexIn=Library:Create("TextBox",{
            Parent=SwatchRow,BackgroundColor3=T.Row,BorderSizePixel=0,
            Size=UDim2.new(1,-34,0,24),ZIndex=601,LayoutOrder=2,
            Font=Enum.Font.GothamMedium,
            Text="#"..string.format("%02X%02X%02X",
                math.floor(initialColor.R*255),math.floor(initialColor.G*255),math.floor(initialColor.B*255)),
            TextColor3=T.Text,TextSize=11,
            PlaceholderText="#RRGGBB",PlaceholderColor3=T.SubText,
            TextXAlignment=Enum.TextXAlignment.Center
        })
        Library:Create("UICorner",{Parent=HexIn,CornerRadius=UDim.new(0,4)})
        Library:Create("UIStroke",{Parent=HexIn,Color=T.Stroke,Thickness=0.5})

        local RGBRow=Library:Create("Frame",{
            Parent=InputArea,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,26),LayoutOrder=2
        })
        Library:Create("UIListLayout",{Parent=RGBRow,FillDirection=Enum.FillDirection.Horizontal,
            Padding=UDim.new(0,4),VerticalAlignment=Enum.VerticalAlignment.Center,
            SortOrder=Enum.SortOrder.LayoutOrder})

        local function MkRGBInput(label,val,lo)
            local cont=Library:Create("Frame",{
                Parent=RGBRow,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0.33,-3,1,0),LayoutOrder=lo
            })
            Library:Create("UIListLayout",{Parent=cont,FillDirection=Enum.FillDirection.Horizontal,
                Padding=UDim.new(0,3),VerticalAlignment=Enum.VerticalAlignment.Center,
                SortOrder=Enum.SortOrder.LayoutOrder})
            Library:Create("TextLabel",{
                Parent=cont,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0,16,1,0),LayoutOrder=1,
                Font=Enum.Font.GothamSemibold,Text=label,
                TextColor3=T.SubText,TextSize=10,
                TextXAlignment=Enum.TextXAlignment.Center
            })
            local box=Library:Create("TextBox",{
                Parent=cont,BackgroundColor3=T.Row,BorderSizePixel=0,
                Size=UDim2.new(1,-19,1,0),LayoutOrder=2,
                Font=Enum.Font.GothamMedium,Text=tostring(val),
                TextColor3=T.Text,TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Center,ZIndex=601
            })
            Library:Create("UICorner",{Parent=box,CornerRadius=UDim.new(0,3)})
            Library:Create("UIStroke",{Parent=box,Color=T.Stroke,Thickness=0.5})
            return box
        end

        local Ri=math.floor(initialColor.R*255)
        local Gi=math.floor(initialColor.G*255)
        local Bi=math.floor(initialColor.B*255)
        local RBox=MkRGBInput("R",Ri,1)
        local GBox=MkRGBInput("G",Gi,2)
        local BBox=MkRGBInput("B",Bi,3)

        local function UpdateAll()
            currentColor=Color3.fromHSV(H,S,V)
            SV.BackgroundColor3=Color3.fromHSV(H,1,1)
            SVC.Position=UDim2.new(S,0,1-V,0)
            HC.Position=UDim2.new(0.5,0,H,0)
            SwatchPrev.BackgroundColor3=currentColor
            local r=math.floor(currentColor.R*255)
            local g=math.floor(currentColor.G*255)
            local b=math.floor(currentColor.B*255)
            HexIn.Text="#"..string.format("%02X%02X%02X",r,g,b)
            RBox.Text=tostring(r)
            GBox.Text=tostring(g)
            BBox.Text=tostring(b)
            pcall(onChanged,currentColor)
        end

        local svDrag,hueDrag=false,false

        local SvBtn=Library:Button(SV); SvBtn.ZIndex=604
        SvBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                svDrag=true
                local rel,pos=SV.AbsoluteSize,SV.AbsolutePosition
                S=math.clamp((inp.Position.X-pos.X)/rel.X,0,1)
                V=math.clamp(1-(inp.Position.Y-pos.Y)/rel.Y,0,1)
                UpdateAll()
            end
        end)
        SvBtn.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then svDrag=false end
        end)

        local HBtn=Library:Button(HF); HBtn.ZIndex=604
        HBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                hueDrag=true
                H=math.clamp((inp.Position.Y-HF.AbsolutePosition.Y)/HF.AbsoluteSize.Y,0,1)
                UpdateAll()
            end
        end)
        HBtn.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then hueDrag=false end
        end)

        UserInputService.InputChanged:Connect(function(inp)
            if inp.UserInputType~=Enum.UserInputType.MouseMovement and inp.UserInputType~=Enum.UserInputType.Touch then return end
            if svDrag then
                local rel,pos=SV.AbsoluteSize,SV.AbsolutePosition
                S=math.clamp((inp.Position.X-pos.X)/rel.X,0,1)
                V=math.clamp(1-(inp.Position.Y-pos.Y)/rel.Y,0,1)
                UpdateAll()
            elseif hueDrag then
                H=math.clamp((inp.Position.Y-HF.AbsolutePosition.Y)/HF.AbsoluteSize.Y,0,1)
                UpdateAll()
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                svDrag=false; hueDrag=false
            end
        end)

        HexIn.FocusLost:Connect(function()
            local h=HexIn.Text:gsub("#",""):gsub("%s","")
            if #h==6 then
                local ok,c=pcall(function()
                    return Color3.fromRGB(tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16))
                end)
                if ok then H,S,V=Color3.toHSV(c); UpdateAll() end
            end
        end)

        local function RGBFocusLost()
            local r=math.clamp(tonumber(RBox.Text) or 0,0,255)
            local g=math.clamp(tonumber(GBox.Text) or 0,0,255)
            local b=math.clamp(tonumber(BBox.Text) or 0,0,255)
            H,S,V=Color3.toHSV(Color3.fromRGB(r,g,b))
            UpdateAll()
        end
        RBox.FocusLost:Connect(RGBFocusLost)
        GBox.FocusLost:Connect(RGBFocusLost)
        BBox.FocusLost:Connect(RGBFocusLost)

        UserInputService.InputBegan:Connect(function(A)
            if not PF.Visible then return end
            if A.UserInputType~=Enum.UserInputType.MouseButton1 and A.UserInputType~=Enum.UserInputType.Touch then return end
            local m=LocalPlayer:GetMouse()
            local dp,ds=PF.AbsolutePosition,PF.AbsoluteSize
            if not(m.X>=dp.X and m.X<=dp.X+ds.X and m.Y>=dp.Y and m.Y<=dp.Y+ds.Y) then
                PF.Visible=false
            end
        end)
        ClosePF.MouseButton1Click:Connect(function() PF.Visible=false end)
        UpdateAll()
        return PF,function() return currentColor end,function(c) H,S,V=Color3.toHSV(c); UpdateAll() end
    end

    local Window={}

    function Window:Popup(Args)
        local PTitle=Args.Title or "Popup"
        local PDesc=Args.Desc or ""
        local PButtons=Args.Buttons or {{Text="OK",Callback=function()end}}

        local Overlay=Library:Create("Frame",{
            Name="PopupOverlay",Parent=Background,
            BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=0.5,
            BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=800
        })
        local PF=Library:Create("Frame",{
            Name="Popup",Parent=Background,
            AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.Background,
            BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),
            Size=UDim2.new(0,300,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            ZIndex=801
        })
        Library:Create("UICorner",{Parent=PF,CornerRadius=UDim.new(0,6)})
        Library:Create("UIStroke",{Parent=PF,Color=T.Stroke,Thickness=0.8})
        Library:Create("UIListLayout",{Parent=PF,SortOrder=Enum.SortOrder.LayoutOrder})

        local PHdr=Library:Create("Frame",{
            Parent=PF,BackgroundColor3=T.TabBg,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,38),ZIndex=802
        })
        Library:Create("UICorner",{Parent=PHdr,CornerRadius=UDim.new(0,6)})
        Library:Create("UIPadding",{Parent=PHdr,PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)})
        Library:Create("UIStroke",{Parent=PHdr,Color=T.Stroke,Thickness=0.5})
        Library:Create("TextLabel",{
            Parent=PHdr,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,Text=PTitle,
            TextColor3=T.Accent,TextSize=13,ZIndex=803,
            TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true
        })

        local PBody=Library:Create("Frame",{
            Parent=PF,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=802
        })
        Library:Create("UIPadding",{Parent=PBody,
            PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12),
            PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)})
        Library:Create("UIListLayout",{Parent=PBody,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,10)})

        Library:Create("TextLabel",{
            Parent=PBody,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            Font=Enum.Font.GothamMedium,Text=PDesc,
            TextColor3=T.Text,TextSize=12,ZIndex=803,
            TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,TextTransparency=0.1
        })

        local BR=Library:Create("Frame",{
            Parent=PBody,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,28),ZIndex=802
        })
        Library:Create("UIListLayout",{Parent=BR,
            FillDirection=Enum.FillDirection.Horizontal,
            HorizontalAlignment=Enum.HorizontalAlignment.Right,
            Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,
            VerticalAlignment=Enum.VerticalAlignment.Center})

        local function ClosePopup() pcall(function()PF:Destroy()end); pcall(function()Overlay:Destroy()end) end
        for _,bd in ipairs(PButtons) do
            local isMain=bd.Style=="main" or bd.Style==nil
            local Btn=Library:Create("TextButton",{
                Parent=BR,BackgroundColor3=isMain and T.Accent or T.RowAlt,
                BorderSizePixel=0,Size=UDim2.new(0,80,0,28),ZIndex=803,
                Font=Enum.Font.GothamSemibold,Text=bd.Text or "OK",
                TextColor3=T.Text,TextSize=11,ClipsDescendants=true
            })
            Library:Create("UICorner",{Parent=Btn,CornerRadius=UDim.new(0,4)})
            Library:Create("UIPadding",{Parent=Btn,PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})
            if isMain then AccentGrad(Btn) end
            Btn.MouseButton1Click:Connect(function()
                ClosePopup()
                if bd.Callback then pcall(bd.Callback) end
            end)
        end
        Library:Create("TextButton",{
            Parent=Overlay,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0),Text="",ZIndex=800
        }).MouseButton1Click:Connect(ClosePopup)
        return {Close=ClosePopup}
    end

    function Window:Dialog(Args)
        return self:Popup({
            Title=Args.Title or "Confirm",Desc=Args.Desc or "Are you sure?",
            Buttons={
                {Text=Args.ConfirmText or "Confirm",Style="main",Callback=Args.OnConfirm},
                {Text=Args.CancelText  or "Cancel", Style="alt", Callback=Args.OnCancel},
            }
        })
    end

    function Window:NewPage(Args)
        local PageTitle=Args.Title or "Page"
        local PageDesc =Args.Desc  or ""
        local PageIcon =Args.Icon  or 127194456372995
        local TabImage =Args.TabImage

        local NewTabs=Library:Create("Frame",{
            Name="NewTabs",Parent=MTS,
            BackgroundColor3=T.TabBg,BorderSizePixel=0,
            Size=UDim2.new(0,230,0,55),ClipsDescendants=true
        })
        tTB(NewTabs,"BackgroundColor3")
        local TabClick=Library:Button(NewTabs)
        Library:Create("UICorner",{Parent=NewTabs,CornerRadius=UDim.new(0,5)})
        local TSI=Library:Create("UIStroke",{Parent=NewTabs,Color=T.TabStroke,Thickness=1})
        tTS(TSI,"Color")

        local TBC=TabImage and RC(TabImage) or T.TabImage
        local TabBanner=Library:Create("ImageLabel",{
            Name="Banner",Parent=NewTabs,
            BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),
            Image="rbxassetid://125411502674016",
            ImageColor3=TBC,ScaleType=Enum.ScaleType.Crop
        })
        if not TabImage then tTI(TabBanner,"ImageColor3") end
        Library:Create("UICorner",{Parent=TabBanner,CornerRadius=UDim.new(0,2)})

        local TabInfo=Library:Create("Frame",{
            Name="Info",Parent=NewTabs,
            BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)
        })
        Library:Create("UIListLayout",{Parent=TabInfo,Padding=UDim.new(0,10),
            FillDirection=Enum.FillDirection.Horizontal,
            SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center})
        Library:Create("UIPadding",{Parent=TabInfo,PaddingLeft=UDim.new(0,15)})

        local TabIcon=Library:Create("ImageLabel",{
            Name="Icon",Parent=TabInfo,
            BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-1,
            Size=UDim2.new(0,25,0,25),
            Image=Library:Asset(PageIcon),ImageColor3=T.Accent
        })
        tA(TabIcon,"ImageColor3"); MkGrad(TabIcon)

        local TabText=Library:Create("Frame",{
            Name="Text",Parent=TabInfo,BackgroundTransparency=1,BorderSizePixel=0,
            Position=UDim2.new(0.11,0,0.14,0),Size=UDim2.new(0,150,0,32)
        })
        Library:Create("UIListLayout",{Parent=TabText,Padding=UDim.new(0,2),
            SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center})

        local TabTL=Library:Create("TextLabel",{
            Name="Title",Parent=TabText,
            BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0,150,0,14),
            Font=Enum.Font.GothamBold,RichText=true,
            Text=PageTitle,TextColor3=T.Accent,TextSize=15,
            TextStrokeTransparency=0.45,TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y
        })
        tA(TabTL,"TextColor3"); MkGrad(TabTL)

        Library:Create("TextLabel",{
            Name="Desc",Parent=TabText,
            BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0.9,0,0,10),
            Font=Enum.Font.GothamMedium,RichText=true,
            Text=PageDesc,TextColor3=T.Text,TextSize=10,
            TextStrokeTransparency=0.5,TextTransparency=0.2,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y
        })

        local NewPage=Library:Create("Frame",{
            Name="NewPage",Parent=Scale,
            BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)
        })
        local PageScrolling=Library:Create("ScrollingFrame",{
            Name="PageScrolling",Parent=NewPage,
            Active=true,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0),ClipsDescendants=true,
            AutomaticCanvasSize=Enum.AutomaticSize.None,
            BottomImage="rbxasset://textures/ui/Scroll/scroll-bottom.png",
            CanvasPosition=Vector2.new(0,0),
            ElasticBehavior=Enum.ElasticBehavior.WhenScrollable,
            MidImage="rbxasset://textures/ui/Scroll/scroll-middle.png",
            ScrollBarImageColor3=Color3.fromRGB(0,0,0),ScrollBarThickness=0,
            ScrollingDirection=Enum.ScrollingDirection.XY,
            TopImage="rbxasset://textures/ui/Scroll/scroll-top.png",
            VerticalScrollBarPosition=Enum.VerticalScrollBarPosition.Right
        })
        Library:Create("UIPadding",{Parent=PageScrolling,
            PaddingBottom=UDim.new(0,5),PaddingLeft=UDim.new(0,15),
            PaddingRight=UDim.new(0,15),PaddingTop=UDim.new(0,5)})
        local PL=Library:Create("UIListLayout",{
            Parent=PageScrolling,Padding=UDim.new(0,5),
            FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder
        })
        PL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageScrolling.CanvasSize=UDim2.new(0,0,0,PL.AbsoluteContentSize.Y+15)
        end)

        TabClick.MouseButton1Click:Connect(function()
            if _locked then return end
            ReturnBtn.Visible=true
            PageService:JumpTo(NewPage)
        end)

        local Page={}

        local function MakeLockOverlay(parent, customMsg)
            local ov=Library:Create("Frame",{
                Parent=parent,BackgroundColor3=T.Background,
                BackgroundTransparency=0.3,BorderSizePixel=0,
                Size=UDim2.new(1,0,1,0),ZIndex=50,Visible=false
            })
            Library:Create("UICorner",{Parent=ov,CornerRadius=UDim.new(0,3)})
            Library:Create("TextLabel",{
                Parent=ov,BackgroundTransparency=1,BorderSizePixel=0,
                AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
                Size=UDim2.new(1,-10,1,0),ZIndex=51,
                Font=Enum.Font.GothamMedium,
                Text=customMsg or _lockedText,
                TextColor3=T.SubText,TextSize=10,
                TextXAlignment=Enum.TextXAlignment.Center,TextWrapped=true
            })
            return ov
        end

        function Page:Section(SText)
            local Lbl=Library:Create("TextLabel",{
                Name="Section",Parent=PageScrolling,
                AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,
                LayoutOrder=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,0,20),
                Font=Enum.Font.GothamBold,RichText=true,
                Text=" "..SText,TextColor3=T.Text,TextSize=15,
                TextStrokeTransparency=0.7,TextXAlignment=Enum.TextXAlignment.Left,
                TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y
            })
            MkGrad(Lbl); return Lbl
        end

        function Page:Paragraph(Args)
            local PTitle         = Args.Title
            local PDesc          = Args.Desc
            local PColor         = Args.Color
            local PImage         = Args.Image or Args.Icon
            local PImageSize     = Args.ImageSize or 20
            local PImageMode     = Args.ImageMode or "beside"
            local PTopImageH     = Args.TopImageHeight or 120
            local PThumbnail     = Args.Thumbnail
            local PThumbnailSize = Args.ThumbnailSize or 40
            local PButtons       = Args.Buttons or {}
            local PLockMsg       = Args.LockMessage

            local isTop = PImageMode == "top"
            local hasTopImg = isTop and PImage and PImage ~= ""
            local hasThumb  = PThumbnail and PThumbnail ~= ""
            local hasBtns   = #PButtons > 0

            local Rows=Library:Create("Frame",{
                Name="Rows",Parent=PageScrolling,
                BackgroundColor3=PColor and RC(PColor) or T.Row,
                BorderSizePixel=0,
                Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y
            })
            Library:Create("UIStroke",{Parent=Rows,Color=T.Stroke,Thickness=0.5})
            Library:Create("UICorner",{Parent=Rows,CornerRadius=UDim.new(0,3)})
            Library:Create("UIListLayout",{Parent=Rows,
                FillDirection=Enum.FillDirection.Vertical,
                SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0)})

            if hasTopImg then
                local TopImg=Library:Create("ImageLabel",{
                    Parent=Rows,BackgroundColor3=Color3.fromRGB(0,0,0),
                    BackgroundTransparency=0,BorderSizePixel=0,
                    Size=UDim2.new(1,0,0,PTopImageH),LayoutOrder=1,
                    Image=Library:Asset(PImage),ScaleType=Enum.ScaleType.Crop
                })
                Library:Create("UICorner",{Parent=TopImg,CornerRadius=UDim.new(0,3)})
            end

            local InnerPad=Library:Create("Frame",{
                Parent=Rows,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2
            })
            Library:Create("UIPadding",{Parent=InnerPad,
                PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8),
                PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})
            Library:Create("UIListLayout",{Parent=InnerPad,
                FillDirection=Enum.FillDirection.Horizontal,
                VerticalAlignment=Enum.VerticalAlignment.Center,
                SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8)})

            local ThumbLbl
            if hasThumb then
                ThumbLbl=Library:Create("ImageLabel",{
                    Parent=InnerPad,BackgroundTransparency=1,BorderSizePixel=0,
                    LayoutOrder=1,Size=UDim2.new(0,PThumbnailSize,0,PThumbnailSize),
                    Image=Library:Asset(PThumbnail),ImageColor3=Color3.fromRGB(255,255,255)
                })
                Library:Create("UICorner",{Parent=ThumbLbl,CornerRadius=UDim.new(0,4)})
            end

            local TextW=1
            if hasThumb then TextW=TextW-0.18 end
            if hasBtns  then TextW=TextW-0.35 end
            if not isTop and PImage and PImage~="" then TextW=TextW-0.12 end

            local TextBlock=Library:Create("Frame",{
                Parent=InnerPad,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(TextW,-(hasThumb and PThumbnailSize+8 or 0),0,0),
                AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2
            })
            Library:Create("UIListLayout",{Parent=TextBlock,
                SortOrder=Enum.SortOrder.LayoutOrder,
                VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,2)})

            local TitleLbl=Library:Create("TextLabel",{
                Name="Title",Parent=TextBlock,
                BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),
                AutomaticSize=Enum.AutomaticSize.Y,
                Font=Enum.Font.GothamSemibold,RichText=true,
                Text=PTitle or "",TextColor3=T.Text,
                TextSize=13,TextStrokeTransparency=0.7,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true
            })
            if PTitle and PTitle~="" then MkGrad(TitleLbl) end

            local DescLbl=Library:Create("TextLabel",{
                Name="Desc",Parent=TextBlock,
                BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),
                AutomaticSize=Enum.AutomaticSize.Y,
                Font=Enum.Font.GothamMedium,RichText=true,
                Text=PDesc or "",TextColor3=T.SubText,
                TextSize=10,TextStrokeTransparency=0.7,TextTransparency=0.2,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true
            })

            local RightBlock=Library:Create("Frame",{
                Parent=InnerPad,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0,0,0,28),LayoutOrder=3,
                AutomaticSize=Enum.AutomaticSize.X
            })
            Library:Create("UIListLayout",{Parent=RightBlock,
                FillDirection=Enum.FillDirection.Horizontal,
                VerticalAlignment=Enum.VerticalAlignment.Center,
                SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)})

            local IconLbl
            if not isTop and PImage and PImage~="" then
                IconLbl=Library:Create("ImageLabel",{
                    Parent=RightBlock,BackgroundTransparency=1,BorderSizePixel=0,
                    LayoutOrder=1,Size=UDim2.new(0,PImageSize,0,PImageSize),
                    Image=Library:Asset(PImage),ImageColor3=T.Accent
                })
                tA(IconLbl,"ImageColor3"); MkGrad(IconLbl)
            end

            for bi,btnDef in ipairs(PButtons) do
                local btnW=math.max(50,string.len(btnDef.Title or "Button")*6+24)
                local BF=Library:Create("Frame",{
                    Parent=RightBlock,BackgroundColor3=T.Accent,BorderSizePixel=0,
                    Size=UDim2.new(0,btnW,0,24),ClipsDescendants=true,LayoutOrder=10+bi
                })
                tA(BF,"BackgroundColor3")
                Library:Create("UICorner",{Parent=BF,CornerRadius=UDim.new(0,3)})
                AccentGrad(BF)
                Library:Create("UIListLayout",{Parent=BF,
                    FillDirection=Enum.FillDirection.Horizontal,
                    VerticalAlignment=Enum.VerticalAlignment.Center,
                    HorizontalAlignment=Enum.HorizontalAlignment.Center,
                    Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})

                if btnDef.Icon and btnDef.Icon~="" then
                    Library:Create("ImageLabel",{
                        Parent=BF,BackgroundTransparency=1,BorderSizePixel=0,
                        Size=UDim2.new(0,12,0,12),LayoutOrder=1,
                        Image=Library:Asset(btnDef.Icon)
                    })
                end
                Library:Create("TextLabel",{
                    Parent=BF,BackgroundTransparency=1,BorderSizePixel=0,
                    Size=UDim2.new(0,btnW-(btnDef.Icon and 20 or 0),1,0),LayoutOrder=2,
                    Font=Enum.Font.GothamSemibold,
                    Text=btnDef.Title or "Button",
                    TextColor3=T.Text,TextSize=10,
                    TextXAlignment=Enum.TextXAlignment.Center
                })
                local BC=Library:Button(BF)
                BC.MouseButton1Click:Connect(function()
                    if _locked then return end
                    task.spawn(Library.Effect,BC,BF)
                    if btnDef.Callback then pcall(btnDef.Callback) end
                end)
            end

            local lockOv=MakeLockOverlay(Rows,PLockMsg)

            local obj={}
            function obj:SetTitle(txt) TitleLbl.Text=tostring(txt) end
            function obj:SetDesc(txt)  DescLbl.Text=tostring(txt) end
            function obj:SetImage(img) if IconLbl then IconLbl.Image=Library:Asset(img) end end
            function obj:SetThumbnail(img) if ThumbLbl then ThumbLbl.Image=Library:Asset(img) end end
            function obj:SetColor(col) Rows.BackgroundColor3=RC(col) end
            function obj:Lock(msg) lockOv.Visible=true; if msg then lockOv:FindFirstChild("TextLabel",true).Text=msg end end
            function obj:Unlock() lockOv.Visible=false end
            function obj:Destroy() Rows:Destroy() end
            setmetatable(obj,{__newindex=function(t,k,v)
                rawset(t,k,v)
                if k=="Title" then TitleLbl.Text=tostring(v)
                elseif k=="Desc" then DescLbl.Text=tostring(v)
                elseif k=="Image" or k=="Icon" then if IconLbl then IconLbl.Image=Library:Asset(v) end end
            end})
            return obj
        end

        function Page:RightLabel(Args)
            local Rows=Library:NewRows(PageScrolling,Args.Title,Args.Desc,T)
            local Right=Rows.Vectorize.Right
            local Left=Rows.Vectorize.Left.Text
            local RightText=Args.Right or "None"

            local Lbl=Library:Create("TextLabel",{
                Name="RLabel",Parent=Right,
                AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,
                LayoutOrder=-1,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,0,13),
                Selectable=false,Font=Enum.Font.GothamSemibold,RichText=true,
                Text=RightText,TextColor3=T.Text,TextSize=12,
                TextStrokeTransparency=0.7,TextXAlignment=Enum.TextXAlignment.Right,
                TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y
            })
            MkGrad(Lbl)

            if Args.Icon and Args.Icon~="" then
                local IL=Library:Create("ImageLabel",{
                    Parent=Right,BackgroundTransparency=1,BorderSizePixel=0,
                    Size=UDim2.new(0,16,0,16),Image=Library:Asset(Args.Icon),
                    ImageColor3=T.Accent,LayoutOrder=-2
                })
                tA(IL,"ImageColor3")
            end

            local lockOv=MakeLockOverlay(Rows,Args.LockMessage)
            local obj={}
            function obj:SetTitle(v) Left.Title.Text=tostring(v) end
            function obj:SetDesc(v)  Left.Desc.Text=tostring(v) end
            function obj:SetRight(v) Lbl.Text=tostring(v) end
            function obj:Lock(msg)   lockOv.Visible=true; if msg then lockOv:FindFirstChild("TextLabel",true).Text=msg end end
            function obj:Unlock()    lockOv.Visible=false end
            function obj:Destroy()   Rows:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v)
                    rawset(t,k,v)
                    if k=="Title" then Left.Title.Text=tostring(v)
                    elseif k=="Desc" then Left.Desc.Text=tostring(v)
                    elseif k=="Right" then Lbl.Text=tostring(v) end
                end,
                __index=function(t,k)
                    if k=="Right" then return Lbl.Text end
                    return rawget(t,k)
                end
            })
            return obj
        end

        function Page:Button(Args)
            local BTitle   = Args.Title
            local BDesc    = Args.Desc
            local BtnText  = Args.Text or "Click"
            local BIcon    = Args.Icon or Args.Image
            local Callback = Args.Callback
            local Rows     = Library:NewRows(PageScrolling,BTitle,BDesc,T)
            local Right    = Rows.Vectorize.Right
            local Left     = Rows.Vectorize.Left.Text

            local btnW=math.max(60,string.len(BtnText)*6+32)
            local Btn=Library:Create("Frame",{
                Name="Button",Parent=Right,
                BackgroundColor3=T.Accent,BorderSizePixel=0,
                Size=UDim2.new(0,btnW,0,25),ClipsDescendants=true
            })
            tA(Btn,"BackgroundColor3")
            Library:Create("UICorner",{Parent=Btn,CornerRadius=UDim.new(0,3)})
            AccentGrad(Btn)

            Library:Create("UIListLayout",{Parent=Btn,
                FillDirection=Enum.FillDirection.Horizontal,
                HorizontalAlignment=Enum.HorizontalAlignment.Center,
                VerticalAlignment=Enum.VerticalAlignment.Center,
                Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})

            if BIcon and BIcon~="" then
                Library:Create("ImageLabel",{
                    Parent=Btn,BackgroundTransparency=1,BorderSizePixel=0,
                    Size=UDim2.new(0,13,0,13),LayoutOrder=1,
                    Image=Library:Asset(BIcon)
                })
            end

            local BtnLbl=Library:Create("TextLabel",{
                Name="BtnText",Parent=Btn,
                BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,
                LayoutOrder=2,
                Font=Enum.Font.GothamSemibold,RichText=true,
                Text=BtnText,TextColor3=T.Text,TextSize=11,
                TextStrokeTransparency=0.7,TextWrapped=false
            })

            local Click=Library:Button(Btn)
            Click.MouseButton1Click:Connect(function()
                if _locked or Library:IsDropdownOpen() then return end
                task.spawn(Library.Effect,Click,Btn)
                if Callback then pcall(Callback) end
            end)

            local lockOv=MakeLockOverlay(Rows,Args.LockMessage)
            local obj={}
            function obj:SetTitle(v) Left.Title.Text=tostring(v) end
            function obj:SetDesc(v)  Left.Desc.Text=tostring(v) end
            function obj:SetText(v)  BtnLbl.Text=tostring(v) end
            function obj:Lock(msg)   lockOv.Visible=true; if msg then lockOv:FindFirstChild("TextLabel",true).Text=msg end end
            function obj:Unlock()    lockOv.Visible=false end
            function obj:Destroy()   Rows:Destroy() end
            setmetatable(obj,{__newindex=function(t,k,v)
                rawset(t,k,v)
                if k=="Title" then Left.Title.Text=tostring(v)
                elseif k=="Desc" then Left.Desc.Text=tostring(v)
                elseif k=="Text" then BtnLbl.Text=tostring(v) end
            end})
            return obj
        end

        function Page:Toggle(Args)
            local TTitle   = Args.Title
            local TDesc    = Args.Desc
            local Value    = Args.Value or false
            local Callback = Args.Callback or function()end
            local Rows     = Library:NewRows(PageScrolling,TTitle,TDesc,T)
            local Left     = Rows.Vectorize.Left.Text
            local Right    = Rows.Vectorize.Right
            local TitleLbl = Left:FindFirstChild("Title")

            if Args.Icon and Args.Icon~="" then
                local IL=Library:Create("ImageLabel",{
                    Parent=Right,BackgroundTransparency=1,BorderSizePixel=0,
                    Size=UDim2.new(0,16,0,16),Image=Library:Asset(Args.Icon),
                    ImageColor3=T.SubText,LayoutOrder=-2
                })
            end

            local Bg=Library:Create("Frame",{
                Name="ToggleBg",Parent=Right,
                BackgroundColor3=T.RowAlt,BorderSizePixel=0,Size=UDim2.new(0,20,0,20)
            })
            local Stroke=Library:Create("UIStroke",{Parent=Bg,Color=T.Stroke,Thickness=0.5})
            Library:Create("UICorner",{Parent=Bg,CornerRadius=UDim.new(0,5)})

            local Highlight=Library:Create("Frame",{
                Parent=Bg,AnchorPoint=Vector2.new(0.5,0.5),
                BackgroundColor3=T.Accent,BorderSizePixel=0,
                Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,20,0,20)
            })
            tA(Highlight,"BackgroundColor3")
            Library:Create("UICorner",{Parent=Highlight,CornerRadius=UDim.new(0,5)})
            AccentGrad(Highlight)
            local CheckImg=Library:Create("ImageLabel",{
                Parent=Highlight,AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,
                BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),
                Size=UDim2.new(0.45,0,0.45,0),Image="rbxassetid://86682186031062"
            })

            local ClickBtn=Library:Button(Bg)
            local Data={Value=Value}

            local function OnChanged(val)
                Data.Value=val
                if val then
                    pcall(Callback,val)
                    CheckImg.Size=UDim2.new(0.85,0,0.85,0)
                    if TitleLbl then TitleLbl.TextColor3=T.Accent end
                    Library:Tween({v=Highlight,t=0.5,s="Exponential",d="Out",g={BackgroundTransparency=0}}):Play()
                    Library:Tween({v=CheckImg,t=0.5,s="Exponential",d="Out",g={ImageTransparency=0}}):Play()
                    Library:Tween({v=CheckImg,t=0.3,s="Exponential",d="Out",g={Size=UDim2.new(0.5,0,0.5,0)}}):Play()
                    Stroke.Thickness=0
                else
                    pcall(Callback,val)
                    if TitleLbl then TitleLbl.TextColor3=T.Text end
                    Library:Tween({v=Highlight,t=0.5,s="Exponential",d="Out",g={BackgroundTransparency=1}}):Play()
                    Library:Tween({v=CheckImg,t=0.5,s="Exponential",d="Out",g={ImageTransparency=1}}):Play()
                    Stroke.Thickness=0.5
                end
            end

            ClickBtn.MouseButton1Click:Connect(function()
                if _locked or Library:IsDropdownOpen() then return end
                OnChanged(not Data.Value)
            end)
            OnChanged(Value)

            local lockOv=MakeLockOverlay(Rows,Args.LockMessage)
            local obj={}
            function obj:SetTitle(v) if TitleLbl then TitleLbl.Text=tostring(v) end end
            function obj:SetDesc(v)  local d=Left:FindFirstChild("Desc"); if d then d.Text=tostring(v) end end
            function obj:SetValue(v) OnChanged(v) end
            function obj:GetValue()  return Data.Value end
            function obj:Lock(msg)   lockOv.Visible=true; if msg then lockOv:FindFirstChild("TextLabel",true).Text=msg end end
            function obj:Unlock()    lockOv.Visible=false end
            function obj:Destroy()   Rows:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v)
                    rawset(t,k,v)
                    if k=="Title" and TitleLbl then TitleLbl.Text=tostring(v)
                    elseif k=="Value" then OnChanged(v) end
                end,
                __index=function(t,k)
                    if k=="Value" then return Data.Value end
                    return rawget(t,k)
                end
            })
            return obj
        end

        function Page:Slider(Args)
            local STitle   = Args.Title
            local SDesc    = Args.Desc
            local Min      = Args.Min      or 0
            local Max      = Args.Max      or 100
            local Rounding = Args.Rounding or 0
            local Value    = Args.Value    or Min
            local Suffix   = Args.Suffix   or ""
            local Callback = Args.Callback or function()end

            local SF=Library:Create("Frame",{
                Name="Slider",Parent=PageScrolling,
                BackgroundColor3=T.Row,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,42),Selectable=false
            })
            Library:Create("UICorner",{Parent=SF,CornerRadius=UDim.new(0,3)})
            Library:Create("UIStroke",{Parent=SF,Color=T.Stroke,Thickness=0.5})
            Library:Create("UIPadding",{Parent=SF,PaddingBottom=UDim.new(0,1),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})

            local TF=Library:Create("Frame",{
                Name="Text",Parent=SF,
                BackgroundTransparency=1,BorderSizePixel=0,
                Position=UDim2.new(0,0,0.1,0),Size=UDim2.new(0,111,0,22),Selectable=false
            })
            Library:Create("UIListLayout",{Parent=TF,SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center})
            Library:Create("UIPadding",{Parent=TF,PaddingBottom=UDim.new(0,3)})

            local HeaderRow2=Library:Create("Frame",{
                Parent=TF,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y
            })
            Library:Create("UIListLayout",{Parent=HeaderRow2,FillDirection=Enum.FillDirection.Horizontal,
                Padding=UDim.new(0,4),VerticalAlignment=Enum.VerticalAlignment.Center,
                SortOrder=Enum.SortOrder.LayoutOrder})

            if Args.Icon and Args.Icon~="" then
                Library:Create("ImageLabel",{
                    Parent=HeaderRow2,BackgroundTransparency=1,BorderSizePixel=0,
                    Size=UDim2.new(0,12,0,12),LayoutOrder=1,
                    Image=Library:Asset(Args.Icon),ImageColor3=T.SubText
                })
            end

            local TitleLbl=Library:Create("TextLabel",{
                Name="Title",Parent=HeaderRow2,
                BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0,0,0,13),AutomaticSize=Enum.AutomaticSize.X,
                LayoutOrder=2,Selectable=false,
                Font=Enum.Font.GothamSemibold,RichText=true,
                Text=STitle or "",TextColor3=T.Text,TextSize=12,
                TextStrokeTransparency=0.7,TextXAlignment=Enum.TextXAlignment.Left,
                TextWrapped=false
            })
            if STitle and STitle~="" then MkGrad(TitleLbl) end

            local Scaling=Library:Create("Frame",{Name="Scaling",Parent=SF,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),Selectable=false})
            local Slide=Library:Create("Frame",{Name="Slide",Parent=Scaling,AnchorPoint=Vector2.new(0,1),BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,23),Selectable=false})
            local ColorBar=Library:Create("Frame",{Name="ColorBar",Parent=Slide,AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=Color3.fromRGB(10,10,10),BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,0,5),Selectable=false})
            Library:Create("UICorner",{Parent=ColorBar,CornerRadius=UDim.new(0,3)})

            local Fill=Library:Create("Frame",{Name="Fill",Parent=ColorBar,BackgroundColor3=T.Accent,BorderSizePixel=0,Size=UDim2.new(0,0,1,0),Selectable=false})
            tA(Fill,"BackgroundColor3")
            Library:Create("UICorner",{Parent=Fill,CornerRadius=UDim.new(0,3)})
            Library:Create("UIGradient",{Parent=Fill,Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(47,47,47))},Rotation=90})
            Library:Create("Frame",{Name="Circle",Parent=Fill,AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,Position=UDim2.new(1,0,0.5,0),Size=UDim2.new(0,5,0,11),Selectable=false})

            local ValueBox=Library:Create("TextBox",{
                Name="Boxvalue",Parent=Scaling,
                AnchorPoint=Vector2.new(1,0.5),BackgroundTransparency=1,BorderSizePixel=0,
                Position=UDim2.new(1,-5,0.449,-2),Size=UDim2.new(0,60,0,15),ZIndex=5,
                Font=Enum.Font.GothamMedium,Text=tostring(Value),
                TextColor3=T.Text,TextSize=11,TextTransparency=0.5,
                TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Right,TextWrapped=true
            })

            local dragging=false
            local Data={Value=Value,Min=Min,Max=Max}

            local function Round(n,d) return math.floor(n*(10^d)+0.5)/(10^d) end
            local function UpdateSlider(val)
                val=math.clamp(val,Min,Max); val=Round(val,Rounding); Data.Value=val
                Library:Tween({v=Fill,t=0.1,s="Linear",d="Out",g={Size=UDim2.new((val-Min)/(Max-Min),0,1,0)}}):Play()
                ValueBox.Text=tostring(val)..(Suffix~="" and (" "..Suffix) or "")
                pcall(Callback,val); return val
            end
            local function GetVal(inp)
                local ax=ColorBar.AbsolutePosition.X; local aw=ColorBar.AbsoluteSize.X
                return math.clamp((inp.Position.X-ax)/aw,0,1)*(Max-Min)+Min
            end
            local function SetDrag(state)
                dragging=state; local col=state and T.Accent or T.Text
                Library:Tween({v=ValueBox,t=0.3,s="Back",d="Out",g={TextSize=state and 15 or 11}}):Play()
                Library:Tween({v=ValueBox,t=0.2,s="Exponential",d="Out",g={TextColor3=col}}):Play()
                Library:Tween({v=TitleLbl,t=0.2,s="Exponential",d="Out",g={TextColor3=col}}):Play()
            end

            local ClickBtn=Library:Button(SF)
            ClickBtn.InputBegan:Connect(function(inp)
                if _locked or Library:IsDropdownOpen() then return end
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                    SetDrag(true); UpdateSlider(GetVal(inp))
                end
            end)
            ClickBtn.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then SetDrag(false) end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if Library:IsDropdownOpen() then return end
                if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
                    UpdateSlider(GetVal(inp))
                end
            end)
            ValueBox.Focused:Connect(function()
                Library:Tween({v=ValueBox,t=0.2,s="Exponential",d="Out",g={TextColor3=T.Accent}}):Play()
                Library:Tween({v=TitleLbl,t=0.2,s="Exponential",d="Out",g={TextColor3=T.Accent}}):Play()
            end)
            ValueBox.FocusLost:Connect(function()
                Library:Tween({v=ValueBox,t=0.2,s="Exponential",d="Out",g={TextColor3=T.Text}}):Play()
                Library:Tween({v=TitleLbl,t=0.2,s="Exponential",d="Out",g={TextColor3=T.Text}}):Play()
                Value=UpdateSlider(tonumber(ValueBox.Text:match("%-?%d+%.?%d*")) or Value)
            end)
            UpdateSlider(Value)

            local lockOv=MakeLockOverlay(SF,Args.LockMessage)
            local obj={}
            function obj:SetTitle(v) TitleLbl.Text=tostring(v) end
            function obj:SetValue(v) UpdateSlider(v) end
            function obj:SetMin(v)   Min=v end
            function obj:SetMax(v)   Max=v end
            function obj:GetValue()  return Data.Value end
            function obj:Lock(msg)   lockOv.Visible=true; if msg then lockOv:FindFirstChild("TextLabel",true).Text=msg end end
            function obj:Unlock()    lockOv.Visible=false end
            function obj:Destroy()   SF:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v)
                    rawset(t,k,v)
                    if k=="Title" then TitleLbl.Text=tostring(v)
                    elseif k=="Value" then UpdateSlider(v)
                    elseif k=="Min" then Min=v
                    elseif k=="Max" then Max=v end
                end,
                __index=function(t,k)
                    if k=="Value" then return Data.Value end
                    return rawget(t,k)
                end
            })
            return obj
        end

        function Page:Input(Args)
            local Value         = Args.Value or ""
            local Callback      = Args.Callback or function()end
            local ITitle        = Args.Title
            local IDesc         = Args.Desc
            local Placeholder   = Args.Placeholder or "Type here..."
            local ClearOnSubmit = Args.ClearOnSubmit or false
            local MultiLine     = Args.MultiLine or false
            local LineCount     = Args.Lines or 4

            if MultiLine then
                local TA=Library:Create("Frame",{
                    Name="TextArea",Parent=PageScrolling,
                    BackgroundColor3=T.Row,BorderSizePixel=0,
                    Size=UDim2.new(1,0,0,LineCount*18+16)
                })
                Library:Create("UICorner",{Parent=TA,CornerRadius=UDim.new(0,3)})
                Library:Create("UIStroke",{Parent=TA,Color=T.Stroke,Thickness=0.5})
                Library:Create("UIPadding",{Parent=TA,PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})

                if ITitle and ITitle~="" then
                    Library:Create("TextLabel",{
                        Parent=TA,BackgroundTransparency=1,BorderSizePixel=0,
                        Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,0,0,12),
                        Font=Enum.Font.GothamSemibold,Text=ITitle,
                        TextColor3=T.SubText,TextSize=10,
                        TextXAlignment=Enum.TextXAlignment.Left
                    })
                end

                local TB=Library:Create("TextBox",{
                    Parent=TA,BackgroundTransparency=1,BorderSizePixel=0,
                    Position=UDim2.new(0,0,0,(ITitle and ITitle~="") and 14 or 0),
                    Size=UDim2.new(1,0,1,-(ITitle and ITitle~="" and 14 or 0)),
                    Font=Enum.Font.GothamMedium,
                    PlaceholderColor3=Color3.fromRGB(55,55,55),
                    PlaceholderText=Placeholder,
                    Text=tostring(Value),
                    TextColor3=Color3.fromRGB(180,180,180),
                    TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,
                    TextWrapped=true,MultiLine=true,ClearTextOnFocus=false
                })
                TB.FocusLost:Connect(function(e) if e and not _locked then pcall(Callback,TB.Text) end end)

                local obj={}
                function obj:SetValue(v)       TB.Text=tostring(v) end
                function obj:SetPlaceholder(v) TB.PlaceholderText=tostring(v) end
                function obj:GetValue()        return TB.Text end
                function obj:Destroy()         TA:Destroy() end
                setmetatable(obj,{
                    __newindex=function(t,k,v) rawset(t,k,v); if k=="Value" then TB.Text=tostring(v) elseif k=="Placeholder" then TB.PlaceholderText=tostring(v) end end,
                    __index=function(t,k) if k=="Value" then return TB.Text end; return rawget(t,k) end
                })
                return obj
            end

            local InputFrame=Library:Create("Frame",{
                Name="Input",Parent=PageScrolling,
                BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,30),Selectable=false
            })
            Library:Create("UIListLayout",{Parent=InputFrame,Padding=UDim.new(0,5),
                FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,
                VerticalAlignment=Enum.VerticalAlignment.Center})

            local Front=Library:Create("Frame",{
                Name="Front",Parent=InputFrame,
                BackgroundColor3=T.Row,BorderSizePixel=0,
                Size=UDim2.new(1,-35,1,0),Selectable=false
            })
            Library:Create("UICorner",{Parent=Front,CornerRadius=UDim.new(0,2)})
            Library:Create("UIStroke",{Parent=Front,Color=T.Stroke,Thickness=0.5})

            local FrontRow=Library:Create("Frame",{
                Parent=Front,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,0,1,0)
            })
            Library:Create("UIListLayout",{Parent=FrontRow,FillDirection=Enum.FillDirection.Horizontal,
                Padding=UDim.new(0,4),VerticalAlignment=Enum.VerticalAlignment.Center,
                SortOrder=Enum.SortOrder.LayoutOrder})
            Library:Create("UIPadding",{Parent=FrontRow,PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,4)})

            if Args.Icon and Args.Icon~="" then
                Library:Create("ImageLabel",{
                    Parent=FrontRow,BackgroundTransparency=1,BorderSizePixel=0,
                    Size=UDim2.new(0,12,0,12),LayoutOrder=1,
                    Image=Library:Asset(Args.Icon),ImageColor3=T.SubText
                })
            end

            local TextBox=Library:Create("TextBox",{
                Parent=FrontRow,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,0,1,0),LayoutOrder=2,
                Font=Enum.Font.GothamMedium,
                PlaceholderColor3=Color3.fromRGB(55,55,55),
                PlaceholderText=Placeholder,
                Text=tostring(Value),
                TextColor3=Color3.fromRGB(150,150,150),
                TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,
                ClearTextOnFocus=false
            })

            local Enter=Library:Create("Frame",{
                Name="Enter",Parent=InputFrame,
                BackgroundColor3=T.Accent,BorderSizePixel=0,
                Size=UDim2.new(0,30,0,30),Selectable=false
            })
            tA(Enter,"BackgroundColor3")
            Library:Create("UICorner",{Parent=Enter,CornerRadius=UDim.new(0,3)})
            AccentGrad(Enter)
            local EIcon=Library:Create("ImageLabel",{
                Name="Asset",Parent=Enter,
                AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,
                Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,15,0,15),
                Image="rbxassetid://78020815235467"
            })
            local CopyBtn=Library:Button(Enter)

            TextBox.FocusLost:Connect(function(entered)
                if entered then
                    if not _locked then pcall(Callback,TextBox.Text) end
                    if ClearOnSubmit then TextBox.Text="" end
                end
            end)
            CopyBtn.MouseButton1Click:Connect(function()
                if Library:IsDropdownOpen() then return end
                pcall(setclipboard,TextBox.Text)
                EIcon.Image="rbxassetid://121742282171603"
                task.delay(3,function() EIcon.Image="rbxassetid://78020815235467" end)
            end)

            local lockOv=MakeLockOverlay(InputFrame,Args.LockMessage)
            local obj={}
            function obj:SetPlaceholder(v) TextBox.PlaceholderText=tostring(v) end
            function obj:SetValue(v)       TextBox.Text=tostring(v) end
            function obj:GetValue()        return TextBox.Text end
            function obj:Lock(msg)         lockOv.Visible=true; if msg then lockOv:FindFirstChild("TextLabel",true).Text=msg end end
            function obj:Unlock()          lockOv.Visible=false end
            function obj:Destroy()         InputFrame:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v)
                    rawset(t,k,v)
                    if k=="Value" then TextBox.Text=tostring(v)
                    elseif k=="Placeholder" then TextBox.PlaceholderText=tostring(v) end
                end,
                __index=function(t,k)
                    if k=="Value" then return TextBox.Text end
                    return rawget(t,k)
                end
            })
            return obj
        end

        function Page:Dropdown(Args)
            local DTitle      = Args.Title
            local List        = Args.List or {}
            local Value       = Args.Value
            local Callback    = Args.Callback or function()end
            local IsMulti     = typeof(Value)=="table"
            local Placeholder = Args.Placeholder or "Select..."
            local ShowSearch  = Args.Search ~= false

            local Rows=Library:NewRows(PageScrolling,DTitle,nil,T)
            local Right=Rows.Vectorize.Right
            local Left=Rows.Vectorize.Left.Text

            Library:Create("ImageLabel",{
                Parent=Right,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0,20,0,20),Image="rbxassetid://132291592681506",ImageTransparency=0.5
            })

            if Args.Icon and Args.Icon~="" then
                Library:Create("ImageLabel",{
                    Parent=Right,BackgroundTransparency=1,BorderSizePixel=0,
                    Size=UDim2.new(0,16,0,16),Image=Library:Asset(Args.Icon),
                    ImageColor3=T.SubText,LayoutOrder=-2
                })
            end

            local Open=Library:Button(Rows.Vectorize)

            local function GetText()
                if IsMulti then return type(Value)=="table" and #Value>0 and table.concat(Value,", ") or Placeholder end
                return Value~=nil and tostring(Value) or Placeholder
            end

            local DescEl=Left:FindFirstChild("Desc")
            if DescEl then DescEl.Text=GetText() end

            local DropFrame=Library:Create("Frame",{
                Name="Dropdown",Parent=Background,
                AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.DropBg,
                BorderSizePixel=0,Position=UDim2.new(0.5,0,0.3,0),
                Size=UDim2.new(0,300,0,ShowSearch and 250 or 220),
                ZIndex=500,Selectable=false,Visible=false
            })
            Library:Create("UICorner",{Parent=DropFrame,CornerRadius=UDim.new(0,3)})
            Library:Create("UIStroke",{Parent=DropFrame,Color=T.DropStroke,Thickness=0.5})
            Library:Create("UIListLayout",{Parent=DropFrame,Padding=UDim.new(0,5),
                SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center})
            Library:Create("UIPadding",{Parent=DropFrame,
                PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,10),
                PaddingRight=UDim.new(0,10),PaddingTop=UDim.new(0,10)})

            local DText=Library:Create("Frame",{Name="Text",Parent=DropFrame,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-5,Size=UDim2.new(1,0,0,30),ZIndex=500,Selectable=false})
            Library:Create("UIListLayout",{Parent=DText,Padding=UDim.new(0,1),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Center})
            local DropTitle=Library:Create("TextLabel",{Name="Title",Parent=DText,AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-1,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,0,13),ZIndex=500,Selectable=false,Font=Enum.Font.GothamSemibold,RichText=true,Text=DTitle or "",TextColor3=T.Accent,TextSize=14,TextStrokeTransparency=0.7,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y})
            MkGrad(DropTitle)
            local Desc1=Library:Create("TextLabel",{Name="Desc",Parent=DText,AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,0,10),ZIndex=500,Selectable=false,Font=Enum.Font.GothamMedium,RichText=true,Text=GetText(),TextColor3=T.Text,TextSize=10,TextStrokeTransparency=0.7,TextTransparency=0.6,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y})

            local SearchBox
            if ShowSearch then
                local InputF=Library:Create("Frame",{Name="Input",Parent=DropFrame,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-4,Size=UDim2.new(1,0,0,25),ZIndex=500,Selectable=false})
                Library:Create("UIListLayout",{Parent=InputF,Padding=UDim.new(0,5),FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center})
                local FrontF=Library:Create("Frame",{Name="Front",Parent=InputF,BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=500,Selectable=false})
                Library:Create("UICorner",{Parent=FrontF,CornerRadius=UDim.new(0,2)})
                Library:Create("UIStroke",{Parent=FrontF,Color=T.Stroke,Thickness=0.5})
                SearchBox=Library:Create("TextBox",{Name="Search",Parent=FrontF,AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,CursorPosition=-1,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,-20,1,0),ZIndex=500,Font=Enum.Font.GothamMedium,PlaceholderColor3=Color3.fromRGB(55,55,55),PlaceholderText="Search",Text="",TextColor3=T.Text,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
            end

            local List1=Library:Create("ScrollingFrame",{Name="List",Parent=DropFrame,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,ShowSearch and 145 or 160),ZIndex=500,ScrollBarThickness=0})
            local ScrollL=Library:Create("UIListLayout",{Parent=List1,Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center})
            Library:Create("UIPadding",{Parent=List1,PaddingLeft=UDim.new(0,1),PaddingRight=UDim.new(0,1)})
            ScrollL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                List1.CanvasSize=UDim2.new(0,0,0,ScrollL.AbsoluteContentSize.Y+15)
            end)

            local selectedValues={}
            local selectedOrder=0

            local function isInT(val,tbl)
                if type(tbl)~="table" then return false end
                for _,v in pairs(tbl) do if v==val then return true end end
                return false
            end
            local function Settext()
                local txt=IsMulti and table.concat(Value,", ") or tostring(Value)
                Desc1.Text=txt
                if DescEl then DescEl.Text=txt end
            end

            local isOpen=false
            UserInputService.InputBegan:Connect(function(A)
                if not isOpen then return end
                if A.UserInputType~=Enum.UserInputType.MouseButton1 and A.UserInputType~=Enum.UserInputType.Touch then return end
                local m=LocalPlayer:GetMouse()
                local dp,ds=DropFrame.AbsolutePosition,DropFrame.AbsoluteSize
                if not(m.X>=dp.X and m.X<=dp.X+ds.X and m.Y>=dp.Y and m.Y<=dp.Y+ds.Y) then
                    isOpen=false; DropFrame.Visible=false; DropFrame.Position=UDim2.new(0.5,0,0.3,0)
                end
            end)
            Open.MouseButton1Click:Connect(function()
                if _locked then return end
                if Library:IsDropdownOpen() and not isOpen then return end
                isOpen=not isOpen
                if isOpen then
                    DropFrame.Visible=true
                    Library:Tween({v=DropFrame,t=0.3,s="Back",d="Out",g={Position=UDim2.new(0.5,0,0.5,0)}}):Play()
                else
                    DropFrame.Visible=false; DropFrame.Position=UDim2.new(0.5,0,0.3,0)
                end
            end)

            local Setting={}
            function Setting:Close() isOpen=false; DropFrame.Visible=false; DropFrame.Position=UDim2.new(0.5,0,0.3,0) end
            function Setting:Clear(a)
                for _,v in ipairs(List1:GetChildren()) do
                    if v:IsA("Frame") then
                        local should=a==nil or (type(a)=="string" and v:FindFirstChild("Title") and v.Title.Text==a) or (type(a)=="table" and v:FindFirstChild("Title") and isInT(v.Title.Text,a))
                        if should then v:Destroy() end
                    end
                end
                if a==nil then
                    Value=IsMulti and {} or nil; selectedValues={}; selectedOrder=0
                    Desc1.Text=Placeholder; if DescEl then DescEl.Text=Placeholder end
                end
            end
            function Setting:SetList(newList) Setting:Clear(); List=newList; for _,n in ipairs(newList) do Setting:AddList(n) end end
            function Setting:SetValue(val)
                if IsMulti then
                    if type(val)~="table" then val={val} end
                    Value=val; selectedValues={}; selectedOrder=0
                    for _,v in pairs(List1:GetChildren()) do
                        if v:IsA("Frame") and v.Name=="Item" and v:FindFirstChild("Title") then
                            local sel=isInT(v.Title.Text,val)
                            v.Title.TextColor3=sel and T.Accent or T.Text
                            v.BackgroundTransparency=sel and 0.85 or 1
                            if sel then selectedOrder=selectedOrder-1; selectedValues[v.Title.Text]=selectedOrder; v.LayoutOrder=selectedOrder else v.LayoutOrder=0 end
                        end
                    end; Settext(); pcall(Callback,val)
                else
                    Value=val
                    for _,v in pairs(List1:GetChildren()) do
                        if v:IsA("Frame") and v.Name=="Item" and v:FindFirstChild("Title") then
                            v.Title.TextColor3=v.Title.Text==tostring(val) and T.Accent or T.Text
                            v.BackgroundTransparency=v.Title.Text==tostring(val) and 0.85 or 1
                        end
                    end; Settext(); pcall(Callback,val)
                end
            end
            function Setting:AddList(Name)
                local Item=Library:Create("Frame",{Name="Item",Parent=List1,BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=0,Size=UDim2.new(1,0,0,25),ZIndex=500,Selectable=false})
                Library:Create("UICorner",{Parent=Item,CornerRadius=UDim.new(0,2)})
                local IT=Library:Create("TextLabel",{Name="Title",Parent=Item,AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-1,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,-15,1,0),ZIndex=500,Selectable=false,Font=Enum.Font.GothamSemibold,RichText=true,Text=tostring(Name),TextColor3=T.Text,TextSize=11,TextStrokeTransparency=0.7,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y})
                MkGrad(IT)
                local function OnValue(v) IT.TextColor3=v and T.Accent or T.Text; Library:Tween({v=Item,t=0.2,s="Linear",d="Out",g={BackgroundTransparency=v and 0.85 or 1}}):Play() end
                local IC=Library:Button(Item)
                local function OnSelected()
                    if IsMulti then
                        if selectedValues[Name] then selectedValues[Name]=nil; Item.LayoutOrder=0; OnValue(false)
                        else selectedOrder=selectedOrder-1; selectedValues[Name]=selectedOrder; Item.LayoutOrder=selectedOrder; OnValue(true) end
                        local sel={}; for i in pairs(selectedValues) do table.insert(sel,i) end
                        if #sel>0 then table.sort(sel); Value=sel; Settext() else Desc1.Text=Placeholder; if DescEl then DescEl.Text=Placeholder end end
                        pcall(Callback,sel)
                    else
                        for _,v in pairs(List1:GetChildren()) do
                            if v:IsA("Frame") and v.Name=="Item" then v.Title.TextColor3=T.Text; Library:Tween({v=v,t=0.2,s="Linear",d="Out",g={BackgroundTransparency=1}}):Play() end
                        end
                        OnValue(true); Value=Name; Settext(); pcall(Callback,Value)
                    end
                end
                delay(0,function()
                    if IsMulti then
                        if isInT(Name,Value) then
                            selectedOrder=selectedOrder-1; selectedValues[Name]=selectedOrder; Item.LayoutOrder=selectedOrder; OnValue(true)
                            local sel={}; for i in pairs(selectedValues) do table.insert(sel,i) end
                            if #sel>0 then table.sort(sel); Settext() else Desc1.Text=Placeholder; if DescEl then DescEl.Text=Placeholder end end
                        end
                    else if Name==Value then OnValue(true); Settext() end end
                end)
                IC.MouseButton1Click:Connect(OnSelected); return Item
            end
            function Setting:RemoveItem(Name)
                for _,v in ipairs(List1:GetChildren()) do
                    if v:IsA("Frame") and v.Name=="Item" and v:FindFirstChild("Title") and v.Title.Text==tostring(Name) then v:Destroy(); return true end
                end; return false
            end
            function Setting:GetValue()    return Value end
            function Setting:SetTitle(t)   DropTitle.Text=tostring(t) end
            function Setting:SetPlaceholder(p) Placeholder=p; if SearchBox then SearchBox.PlaceholderText=p end end
            function Setting:Destroy()     Rows:Destroy(); DropFrame:Destroy() end

            if SearchBox then
                SearchBox.Changed:Connect(function()
                    local s=string.lower(SearchBox.Text)
                    for _,v in pairs(List1:GetChildren()) do
                        if v:IsA("Frame") and v.Name=="Item" and v:FindFirstChild("Title") then
                            v.Visible=string.find(string.lower(v.Title.Text),s,1,true)~=nil
                        end
                    end
                end)
            end
            for _,name in ipairs(List) do Setting:AddList(name) end
            return Setting
        end

        function Page:Keybind(Args)
            local KTitle   = Args.Title
            local KDesc    = Args.Desc
            local Value    = Args.Value    or Enum.KeyCode.Unknown
            local Callback = Args.Callback or function()end
            local Rows     = Library:NewRows(PageScrolling,KTitle,KDesc,T)
            local Right    = Rows.Vectorize.Right
            local Left     = Rows.Vectorize.Left.Text

            if Args.Icon and Args.Icon~="" then
                Library:Create("ImageLabel",{
                    Parent=Right,BackgroundTransparency=1,BorderSizePixel=0,
                    Size=UDim2.new(0,16,0,16),Image=Library:Asset(Args.Icon),
                    ImageColor3=T.SubText,LayoutOrder=-2
                })
            end

            local KeyBtn=Library:Create("Frame",{
                Name="KeyBind",Parent=Right,
                BackgroundColor3=T.RowAlt,BorderSizePixel=0,
                Size=UDim2.new(0,80,0,22),ClipsDescendants=true
            })
            Library:Create("UICorner",{Parent=KeyBtn,CornerRadius=UDim.new(0,3)})
            Library:Create("UIStroke",{Parent=KeyBtn,Color=T.Stroke,Thickness=0.5})
            local KeyLabel=Library:Create("TextLabel",{
                Parent=KeyBtn,AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,
                Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,-8,1,0),
                Font=Enum.Font.GothamSemibold,Text=tostring(Value.Name),
                TextColor3=T.Accent,TextSize=11,
                TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y
            })
            tA(KeyLabel,"TextColor3")

            local ClickBtn=Library:Button(KeyBtn)
            local listening=false
            local Data={Value=Value}

            local function SetKey(key)
                Data.Value=key; KeyLabel.Text=tostring(key.Name); KeyLabel.TextColor3=T.Accent
                Library:Tween({v=KeyBtn,t=0.2,s="Exponential",d="Out",g={BackgroundColor3=T.RowAlt}}):Play()
                pcall(Callback,key)
            end

            ClickBtn.MouseButton1Click:Connect(function()
                if _locked or Library:IsDropdownOpen() then return end
                if listening then return end
                listening=true; KeyLabel.Text="..."; KeyLabel.TextColor3=T.Text
                Library:Tween({v=KeyBtn,t=0.2,s="Exponential",d="Out",g={BackgroundColor3=T.Stroke}}):Play()
                local conn; conn=UserInputService.InputBegan:Connect(function(inp,proc)
                    if proc then return end
                    if inp.UserInputType==Enum.UserInputType.Keyboard then
                        listening=false; conn:Disconnect(); SetKey(inp.KeyCode)
                    end
                end)
            end)
            UserInputService.InputBegan:Connect(function(inp,proc)
                if proc or listening then return end
                if inp.KeyCode==Data.Value then pcall(Callback,Data.Value) end
            end)

            local lockOv=MakeLockOverlay(Rows,Args.LockMessage)
            local obj={}
            function obj:SetTitle(v)  local tl=Left:FindFirstChild("Title"); if tl then tl.Text=tostring(v) end end
            function obj:SetDesc(v)   local dl=Left:FindFirstChild("Desc");  if dl then dl.Text=tostring(v) end end
            function obj:SetValue(v)  SetKey(v) end
            function obj:GetValue()   return Data.Value end
            function obj:Lock(msg)    lockOv.Visible=true; if msg then lockOv:FindFirstChild("TextLabel",true).Text=msg end end
            function obj:Unlock()     lockOv.Visible=false end
            function obj:Destroy()    Rows:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v)
                    rawset(t,k,v)
                    if k=="Value" then SetKey(v) end
                end,
                __index=function(t,k)
                    if k=="Value" then return Data.Value end
                    return rawget(t,k)
                end
            })
            return obj
        end

        function Page:ColorPicker(Args)
            local CPTitle  = Args.Title
            local CPDesc   = Args.Desc
            local Value    = Args.Value or Color3.fromRGB(255,255,255)
            local Callback = Args.Callback or function()end

            if typeof(Value)=="string" then Value=RC(Value) end

            local Rows=Library:NewRows(PageScrolling,CPTitle,CPDesc,T)
            local Right=Rows.Vectorize.Right
            local Left=Rows.Vectorize.Left.Text

            if Args.Icon and Args.Icon~="" then
                Library:Create("ImageLabel",{
                    Parent=Right,BackgroundTransparency=1,BorderSizePixel=0,
                    Size=UDim2.new(0,16,0,16),Image=Library:Asset(Args.Icon),
                    ImageColor3=T.SubText,LayoutOrder=-2
                })
            end

            local Swatch=Library:Create("Frame",{
                Name="Swatch",Parent=Right,
                BackgroundColor3=Value,BorderSizePixel=0,Size=UDim2.new(0,40,0,20)
            })
            Library:Create("UICorner",{Parent=Swatch,CornerRadius=UDim.new(0,3)})
            Library:Create("UIStroke",{Parent=Swatch,Color=T.Stroke,Thickness=0.5})
            local SwatchClick=Library:Button(Swatch)

            local PF,getColor,setColorFn=BuildColorPicker(Background,Value,function(c)
                Value=c; Swatch.BackgroundColor3=c
                local DescEl2=Left:FindFirstChild("Desc")
                if DescEl2 then DescEl2.Text=string.format("#%02X%02X%02X",math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255)) end
                pcall(Callback,c)
            end)

            SwatchClick.MouseButton1Click:Connect(function()
                if _locked then return end
                PF.Visible=not PF.Visible
                if PF.Visible then
                    Library:Tween({v=PF,t=0.25,s="Back",d="Out",g={Position=UDim2.new(0.5,0,0.5,0)}}):Play()
                end
            end)

            local lockOv=MakeLockOverlay(Rows,Args.LockMessage)
            local obj={}
            function obj:SetTitle(v) local tl=Left:FindFirstChild("Title"); if tl then tl.Text=tostring(v) end end
            function obj:SetDesc(v)  local dl=Left:FindFirstChild("Desc");  if dl then dl.Text=tostring(v) end end
            function obj:SetValue(v) if typeof(v)=="string" then v=RC(v) end; Value=v; Swatch.BackgroundColor3=v; setColorFn(v) end
            function obj:GetValue()  return getColor() end
            function obj:Lock(msg)   lockOv.Visible=true; if msg then lockOv:FindFirstChild("TextLabel",true).Text=msg end end
            function obj:Unlock()    lockOv.Visible=false end
            function obj:Destroy()   Rows:Destroy(); PF:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v)
                    rawset(t,k,v)
                    if k=="Title" then local tl=Left:FindFirstChild("Title"); if tl then tl.Text=tostring(v) end
                    elseif k=="Desc" then local dl=Left:FindFirstChild("Desc"); if dl then dl.Text=tostring(v) end
                    elseif k=="Value" then if typeof(v)=="string" then v=RC(v) end; Value=v; Swatch.BackgroundColor3=v; setColorFn(v) end
                end,
                __index=function(t,k)
                    if k=="Value" then return getColor() end
                    return rawget(t,k)
                end
            })
            return obj
        end

        function Page:Banner(Assets)
            local Banner=Library:Create("ImageLabel",{
                Name="Banner",Parent=PageScrolling,
                BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,235),
                Image=Library:Asset(Assets),ScaleType=Enum.ScaleType.Crop
            })
            Library:Create("UICorner",{Parent=Banner,CornerRadius=UDim.new(0,3)})
            local obj={}
            function obj:SetImage(v) Banner.Image=Library:Asset(v) end
            function obj:SetSize(v)  Banner.Size=v end
            function obj:Destroy()   Banner:Destroy() end
            setmetatable(obj,{__newindex=function(t,k,v)
                rawset(t,k,v)
                if k=="Image" then Banner.Image=Library:Asset(v)
                elseif k=="Visible" then Banner.Visible=v
                elseif k=="Size" then Banner.Size=v end
            end})
            return obj
        end

        function Page:ConfigManager(Args)
            Args=Args or {}
            local Cfg=Library.Config
            local OnLoad=Args.OnLoad or function()end
            local AutoKey=Args.AutoLoadKey or "__vitaauto__"
            local SecTitle=Args.SectionTitle or "Config Manager"

            Page:Section(SecTitle)

            local cfgDrop=Page:Dropdown({
                Title="Saved Configs",List=Cfg:List(),
                Placeholder="Select a config...",Value=Cfg:Active(),
                Search=true,
                Callback=function(v) Cfg:SetActive(v) end
            })

            local function Refresh()
                cfgDrop:SetList(Cfg:List())
                if Cfg:Active() then cfgDrop:SetValue(Cfg:Active()) end
            end

            local nameInput=Page:Input({
                Placeholder="Config name...",Value=Cfg:Active() or ""
            })

            local BtnRowFrame=Library:Create("Frame",{
                Name="CfgBtnRow",Parent=PageScrolling,
                BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,34)
            })
            Library:Create("UIListLayout",{Parent=BtnRowFrame,
                FillDirection=Enum.FillDirection.Horizontal,
                Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder,
                VerticalAlignment=Enum.VerticalAlignment.Center,
                HorizontalAlignment=Enum.HorizontalAlignment.Left})

            local function MkCfgBtn(text, color, cb)
                local w=math.max(54,string.len(text)*6+20)
                local b=Library:Create("TextButton",{
                    Parent=BtnRowFrame,BackgroundColor3=color,BorderSizePixel=0,
                    Size=UDim2.new(0,w,0,30),
                    Font=Enum.Font.GothamSemibold,Text=text,
                    TextColor3=T.Text,TextSize=11,ClipsDescendants=true
                })
                Library:Create("UICorner",{Parent=b,CornerRadius=UDim.new(0,4)})
                AccentGrad(b)
                b.MouseButton1Click:Connect(function()
                    task.spawn(Library.Effect,b,b)
                    if cb then pcall(cb) end
                end)
                return b
            end

            MkCfgBtn("Save",T.Accent,function()
                local name=nameInput:GetValue()
                if name=="" then name=Cfg:Active() end
                if not name or name=="" then
                    Library:Notification({Title="Config",Desc="Enter a config name.",Duration=2,Type="Warning"}); return
                end
                local ok,err=Cfg:Create(name)
                if not ok then
                    Library:Notification({Title="Config",Desc=err or "Name already exists.",Duration=2,Type="Warning"}); return
                end
                Cfg:Save(name); Refresh()
                Library:Notification({Title="Saved",Desc='"'..name..'" saved.',Duration=2,Type="Success"})
            end)

            MkCfgBtn("Overwrite",Color3.fromRGB(200,140,30),function()
                local name=cfgDrop:GetValue() or nameInput:GetValue()
                if not name or name=="" or not Cfg:Exists(name) then
                    Library:Notification({Title="Config",Desc="Select an existing config.",Duration=2,Type="Warning"}); return
                end
                Cfg:Overwrite(name); Refresh()
                Library:Notification({Title="Overwritten",Desc='"'..name..'" updated.',Duration=2,Type="Success"})
            end)

            MkCfgBtn("Load",Color3.fromRGB(60,130,220),function()
                local name=cfgDrop:GetValue() or nameInput:GetValue()
                if not name or name=="" then
                    Library:Notification({Title="Config",Desc="Select a config first.",Duration=2,Type="Warning"}); return
                end
                if Cfg:Load(name) then
                    pcall(OnLoad,Cfg:GetData(name))
                    Library:Notification({Title="Loaded",Desc='"'..name..'" loaded.',Duration=2,Type="Success"})
                else
                    Library:Notification({Title="Error",Desc="Config not found.",Duration=2,Type="Error"})
                end
            end)

            MkCfgBtn("Delete",Color3.fromRGB(200,50,50),function()
                local name=cfgDrop:GetValue() or nameInput:GetValue()
                if not name or name=="" then return end
                Window:Dialog({
                    Title="Delete Config",
                    Desc='Delete "'..name..'"?',
                    ConfirmText="Delete",
                    OnConfirm=function()
                        Cfg:Delete(name); Refresh()
                        Library:Notification({Title="Deleted",Desc='"'..name..'" deleted.',Duration=2,Type="Info"})
                    end
                })
            end)

            MkCfgBtn("Auto",Color3.fromRGB(70,160,70),function()
                local name=cfgDrop:GetValue() or nameInput:GetValue()
                if not name or name=="" then
                    Library:Notification({Title="Config",Desc="Select a config.",Duration=2,Type="Warning"}); return
                end
                if Cfg:Exists("__vitaauto__") then
                    Cfg:Overwrite("__vitaauto__",{target=name})
                else
                    Cfg:Create("__vitaauto__",{target=name})
                end
                Library:Notification({Title="Auto Load",Desc='"'..name..'" on next run.',Duration=3,Type="Success"})
            end)

            if Cfg:Exists(AutoKey) then
                local target=Cfg:GetValue("target",AutoKey)
                if target and Cfg:Exists(target) then
                    task.delay(0.2,function()
                        if Cfg:Load(target) then pcall(OnLoad,Cfg:GetData(target)) end
                    end)
                end
            end
        end

        return Page
    end

    function Library:SetTimeValue(v)   THETIME.Text=tostring(v) end
    function Library:SetWindowTitle(v) if TitleLabel then TitleLabel.Text=tostring(v) end end
    function Library:SetWindowSubTitle(v) if SubTitleLabel then SubTitleLabel.Text=tostring(v) end end

    function Library:AddSizeSlider(Page)
        local function CurMax() return MaxScale() end
        return Page:Slider({
            Title="Interface Scale",
            Min=0.35,
            Max=math.floor(CurMax()*10+0.5)/10,
            Rounding=2,
            Value=Scaler.Scale,
            Callback=function(v)
                local clamped=CS(v)
                Scaler:SetAttribute("ManualScale",true)
                Scaler.Scale=clamped
            end
        })
    end

    function Library:SetTheme(newTheme)
        if newTheme.BG  then newTheme.Background=newTheme.BG;  newTheme.BG=nil  end
        if newTheme.Tab then newTheme.TabBg=newTheme.Tab;       newTheme.Tab=nil end
        for k,v in pairs(newTheme) do T[k]=RC(v) end
        for _,ref in ipairs(accentRefs)    do local i,p=ref[1],ref[2]; if i and i.Parent then pcall(function() i[p]=T.Accent     end) end end
        for _,ref in ipairs(bgRefs)        do local i,p=ref[1],ref[2]; if i and i.Parent then pcall(function() i[p]=T.Background end) end end
        for _,ref in ipairs(tabImageRefs)  do local i,p=ref[1],ref[2]; if i and i.Parent then pcall(function() i[p]=T.TabImage   end) end end
        for _,ref in ipairs(tabBgRefs)     do local i,p=ref[1],ref[2]; if i and i.Parent then pcall(function() i[p]=T.TabBg      end) end end
        for _,ref in ipairs(tabStrokeRefs) do local i,p=ref[1],ref[2]; if i and i.Parent then pcall(function() i[p]=T.TabStroke  end) end end
    end

    function Library:GetTheme()
        local c={}; for k,v in pairs(T) do c[k]=v end; return c
    end

    function Library:SetPillIcon(icon) Logo.Image=Library:Asset(icon) end
    function Library:SetExecutorIdentity(v)
        if UserBlock then UserBlock.Visible=v==true end
    end
    function Library:SetLockText(msg) _lockedText=msg end
    function Library:Lock()    _locked=true  end
    function Library:Unlock()  _locked=false end
    function Library:IsLocked() return _locked end

    function Library:Destroy()
        pcall(function() Xova:Destroy() end)
        pcall(function() ToggleScreen:Destroy() end)
        pcall(function() NotifGui:Destroy() end)
    end

    return Window
end

return Library
