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
        sg.Name="ImageDisplay_"..HttpService:GenerateGUID(false)
        sg.DisplayOrder=9999; sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        sg.ResetOnSpawn=false; sg.ScreenInsets=Enum.ScreenInsets.None; sg.Parent=CoreGui
        local il=Instance.new("ImageLabel")
        il.Size=UDim2.new(0,cfg.size or 400,0,cfg.size or 400)
        il.Position=UDim2.new(0.5,0,0.5,0); il.AnchorPoint=Vector2.new(0.5,0.5)
        il.BackgroundTransparency=1; il.Image=cfg.url or ""; il.Parent=sg
        if cfg.duration then task.delay(cfg.duration,function() sg:Destroy() end) end
        return sg
    end
end

local Lucide={}
task.spawn(function()
    local ok,res=pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ArchIsDead/Arch-Vault/refs/heads/main/lucide-icons.lua"))()
    end)
    if ok and type(res)=="table" then for k,v in pairs(res) do Lucide[k]=v end end
end)

local ConfigSystem={}
do
    local _store={}; local _active=nil
    function ConfigSystem:Create(n,d)
        if not n or n=="" then return false,"Name required" end
        if _store[n] then return false,"Already exists" end
        _store[n]={name=n,data=d or {},created=os.time(),updated=os.time()}; return true
    end
    function ConfigSystem:Load(n) if not _store[n] then return false end; _active=n; return true end
    function ConfigSystem:Save(n,d)
        n=n or _active; if not n then return false end
        if not _store[n] then return self:Create(n,d)
        else if d then _store[n].data=d end; _store[n].updated=os.time(); return true end
    end
    function ConfigSystem:Overwrite(n,d)
        if not _store[n] then return false end
        _store[n].data=d or _store[n].data; _store[n].updated=os.time(); return true
    end
    function ConfigSystem:SetActive(n) if not _store[n] then return false end; _active=n; return true end
    function ConfigSystem:Active() return _active end
    function ConfigSystem:Get(n) return _store[n or _active] end
    function ConfigSystem:GetData(n) local c=_store[n or _active]; return c and c.data or nil end
    function ConfigSystem:SetValue(k,v,n)
        n=n or _active; if not n then return false end
        if not _store[n] then self:Create(n) end
        _store[n].data[k]=v; _store[n].updated=os.time(); return true
    end
    function ConfigSystem:GetValue(k,n) local c=_store[n or _active]; return c and c.data[k] or nil end
    function ConfigSystem:Delete(n)
        if not _store[n] then return false end
        _store[n]=nil; if _active==n then _active=nil end; return true
    end
    function ConfigSystem:Rename(o,nw)
        if not _store[o] or _store[nw] then return false end
        _store[nw]=_store[o]; _store[nw].name=nw; _store[o]=nil
        if _active==o then _active=nw end; return true
    end
    function ConfigSystem:Duplicate(n,nn)
        if not _store[n] then return false end
        nn=nn or (n.."_copy"); if _store[nn] then return false end
        local c={}; for k,v in pairs(_store[n].data) do c[k]=v end; return self:Create(nn,c)
    end
    function ConfigSystem:Import(n,j)
        local ok,d=pcall(HttpService.JSONDecode,HttpService,j); if not ok then return false end; return self:Save(n,d)
    end
    function ConfigSystem:Export(n)
        local c=_store[n or _active]; if not c then return nil end
        local ok,json=pcall(HttpService.JSONEncode,HttpService,c.data)
        return ok and json or nil
    end
    function ConfigSystem:Clear(n)
        n=n or _active; if not _store[n] then return false end
        _store[n].data={}; _store[n].updated=os.time(); return true
    end
    function ConfigSystem:List() local t={}; for k in pairs(_store) do table.insert(t,k) end; table.sort(t); return t end
    function ConfigSystem:Exists(n) return _store[n]~=nil end
    function ConfigSystem:Count() local n=0; for _ in pairs(_store) do n=n+1 end; return n end
end
Library.Config=ConfigSystem

function Library:Parent()
    if not RunService:IsStudio() then return (gethui and gethui()) or PlayerGui end
    return PlayerGui
end

function Library:Hex(hex)
    hex=hex:gsub("#","")
    return Color3.fromRGB(tonumber(hex:sub(1,2),16) or 0,tonumber(hex:sub(3,4),16) or 0,tonumber(hex:sub(5,6),16) or 0)
end

local function RC(v)
    if typeof(v)=="Color3" then return v end
    if type(v)=="string" then return Library:Hex(v) end
    return v
end

local function GetExec()
    if getexecutorname then local ok,n=pcall(getexecutorname); if ok and n and n~="" then return n end end
    if identifyexecutor then local ok,n=pcall(identifyexecutor); if ok and n and n~="" then return n end end
    return "Unknown"
end

function Library:Create(Class,Props)
    local i=Instance.new(Class); for k,v in Props do i[k]=v end; return i
end

function Library:Draggable(handle,target)
    target=target or handle
    local dragging,dragInput,dragStart,startPos=false,nil,nil,nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=inp.Position; startPos=target.Position
            inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    handle.InputChanged:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then dragInput=inp end
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
        Name="Click",Parent=parent,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),Font=Enum.Font.SourceSans,Text="",
        TextColor3=Color3.fromRGB(0,0,0),TextSize=14,ZIndex=parent.ZIndex+3
    })
end

function Library:Tween(info)
    return TweenService:Create(info.v,TweenInfo.new(info.t,Enum.EasingStyle[info.s],Enum.EasingDirection[info.d]),info.g)
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

local function MkGrad(p,r)
    Library:Create("UIGradient",{Parent=p,Rotation=r or 90,
        Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.75,Color3.fromRGB(163,163,163)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(100,100,100))}})
end

local function BtnGrad(p)
    Library:Create("UIGradient",{Parent=p,Rotation=90,
        Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(56,56,56))}})
end

local function Ripple(btn)
    local m=Players.LocalPlayer:GetMouse()
    local rx=math.clamp(m.X-btn.AbsolutePosition.X,0,btn.AbsoluteSize.X)
    local ry=math.clamp(m.Y-btn.AbsolutePosition.Y,0,btn.AbsoluteSize.Y)
    local rip=Library:Create("Frame",{Parent=btn,
        BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0.65,
        BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0,rx,0,ry),Size=UDim2.new(0,0,0,0),ZIndex=btn.ZIndex+2})
    Library:Create("UICorner",{Parent=rip,CornerRadius=UDim.new(1,0)})
    local maxD=math.max(btn.AbsoluteSize.X,btn.AbsoluteSize.Y)*2
    local t=TweenService:Create(rip,TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
        Size=UDim2.new(0,maxD,0,maxD),BackgroundTransparency=1})
    t.Completed:Once(function() rip:Destroy() end); t:Play()
end

function Library:NewRows(parent,title,desc,T)
    local Rows=Library:Create("Frame",{Name="Rows",Parent=parent,
        BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.new(1,0,0,42)})
    Library:Create("UIStroke",{Parent=Rows,Color=T.Stroke,Thickness=0.5})
    Library:Create("UICorner",{Parent=Rows,CornerRadius=UDim.new(0,4)})

    local Left=Library:Create("Frame",{Name="Left",Parent=Rows,
        BackgroundTransparency=1,BorderSizePixel=0,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,12,0.5,0),
        Size=UDim2.new(1,-116,1,0)})
    Library:Create("UIListLayout",{Parent=Left,FillDirection=Enum.FillDirection.Vertical,
        SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,2)})

    if title and title~="" then
        local TL=Library:Create("TextLabel",{Name="Title",Parent=Left,
            BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=1,
            Size=UDim2.new(1,0,0,14),Font=Enum.Font.GothamSemibold,RichText=true,Text=title,
            TextColor3=T.Text,TextSize=13,TextStrokeTransparency=0.7,
            TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
        MkGrad(TL)
    else
        Library:Create("TextLabel",{Name="Title",Parent=Left,BackgroundTransparency=1,
            BorderSizePixel=0,Size=UDim2.new(0,0,0,0),Text="",TextSize=1,Visible=false,LayoutOrder=1})
    end

    if desc and desc~="" then
        Library:Create("TextLabel",{Name="Desc",Parent=Left,BackgroundTransparency=1,
            BorderSizePixel=0,LayoutOrder=2,Size=UDim2.new(1,0,0,11),
            Font=Enum.Font.GothamMedium,RichText=true,Text=desc,
            TextColor3=T.SubText,TextSize=10,TextStrokeTransparency=0.7,TextTransparency=0.25,
            TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
    else
        Library:Create("TextLabel",{Name="Desc",Parent=Left,BackgroundTransparency=1,
            BorderSizePixel=0,Size=UDim2.new(0,0,0,0),Text="",TextSize=1,Visible=false,LayoutOrder=2})
    end

    local Right=Library:Create("Frame",{Name="Right",Parent=Rows,
        BackgroundTransparency=1,BorderSizePixel=0,
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.new(0,0,0,34),AutomaticSize=Enum.AutomaticSize.X})
    Library:Create("UIListLayout",{Parent=Right,FillDirection=Enum.FillDirection.Horizontal,
        HorizontalAlignment=Enum.HorizontalAlignment.Right,VerticalAlignment=Enum.VerticalAlignment.Center,
        SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)})

    return Rows
end

local NotifGui=Library:Create("ScreenGui",{
    Name="VitaNotifications",Parent=Library:Parent(),
    ZIndexBehavior=Enum.ZIndexBehavior.Global,
    DisplayOrder=999,IgnoreGuiInset=true,ResetOnSpawn=false})
local NotifHolder=Library:Create("Frame",{
    Name="Holder",Parent=NotifGui,
    BackgroundTransparency=1,AnchorPoint=Vector2.new(1,1),
    Position=UDim2.new(1,-15,1,-15),Size=UDim2.new(0,275,1,-30)})
Library:Create("UIListLayout",{Parent=NotifHolder,
    VerticalAlignment=Enum.VerticalAlignment.Bottom,
    SortOrder=Enum.SortOrder.LayoutOrder,
    Padding=UDim.new(0,8),FillDirection=Enum.FillDirection.Vertical})

function Library:Notification(Args)
    local Title=Args.Title or "Notification"
    local Desc=Args.Desc or ""
    local Duration=Args.Duration or 3
    local NType=Args.Type or "Info"
    local ac=Args.Color and RC(Args.Color) or ({
        Info=Color3.fromRGB(100,149,237),Success=Color3.fromRGB(50,200,100),
        Warning=Color3.fromRGB(255,165,0),Error=Color3.fromRGB(220,50,50)})[NType] or Color3.fromRGB(100,149,237)
    local Icon=Args.Icon

    local Notif=Library:Create("Frame",{Name="Notification",Parent=NotifHolder,
        BackgroundColor3=Color3.fromRGB(13,13,13),BorderSizePixel=0,
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        ClipsDescendants=false,BackgroundTransparency=1})
    Library:Create("UICorner",{Parent=Notif,CornerRadius=UDim.new(0,6)})
    Library:Create("UIStroke",{Parent=Notif,Color=Color3.fromRGB(35,35,35),Thickness=0.5})

    local Bar=Library:Create("Frame",{Parent=Notif,BackgroundColor3=ac,BorderSizePixel=0,Size=UDim2.new(0,3,1,0)})
    Library:Create("UICorner",{Parent=Bar,CornerRadius=UDim.new(0,2)})

    local C=Library:Create("Frame",{Parent=Notif,BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-15,1,0),AutomaticSize=Enum.AutomaticSize.Y})
    Library:Create("UIPadding",{Parent=C,PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),PaddingRight=UDim.new(0,8)})
    Library:Create("UIListLayout",{Parent=C,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5)})

    local TRow=Library:Create("Frame",{Parent=C,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=1})
    Library:Create("UIListLayout",{Parent=TRow,FillDirection=Enum.FillDirection.Horizontal,
        Padding=UDim.new(0,5),VerticalAlignment=Enum.VerticalAlignment.Center,
        SortOrder=Enum.SortOrder.LayoutOrder})
    if Icon then
        Library:Create("ImageLabel",{Parent=TRow,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(0,14,0,14),LayoutOrder=1,
            Image=Library:Asset(Icon),ImageColor3=ac})
    end
    Library:Create("TextLabel",{Parent=TRow,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,-20,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2,
        Font=Enum.Font.GothamBold,Text=Title,TextColor3=ac,TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,RichText=true,TextWrapped=true})

    Library:Create("TextLabel",{Parent=C,BackgroundTransparency=1,BorderSizePixel=0,
        AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),LayoutOrder=2,
        Font=Enum.Font.GothamMedium,Text=Desc,
        TextColor3=Color3.fromRGB(200,200,200),TextSize=11,TextTransparency=0.2,
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})

    local PBg=Library:Create("Frame",{Parent=C,BackgroundColor3=Color3.fromRGB(30,30,30),
        BorderSizePixel=0,Size=UDim2.new(1,0,0,2),LayoutOrder=3})
    Library:Create("UICorner",{Parent=PBg,CornerRadius=UDim.new(1,0)})
    local PFill=Library:Create("Frame",{Parent=PBg,BackgroundColor3=ac,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)})
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
    local Title          = Args.Title
    local SubTitle       = Args.SubTitle
    local ToggleKey      = Args.ToggleKey or Enum.KeyCode.LeftControl
    local AutoScale      = Args.AutoScale~=false
    local BaseScale      = Args.Scale or 1.45
    local CustomSize     = Args.Size
    local ExecIdShown    = Args.ExecIdentifyShown~=false
    local BbIcon         = Args.BbIcon or "rbxassetid://104055321996495"
    local CustomUserName = Args.UserName
    local CustomExecutor = Args.ExecutorName

    local RAW_W=CustomSize and CustomSize.X.Offset or 500
    local RAW_H=CustomSize and CustomSize.Y.Offset or 350

    local uT=Args.Theme or {}
    if Args.BG then uT.Background=Args.BG end
    if Args.Tab then uT.TabBg=Args.Tab end
    if Args.TabImage then uT.TabImage=Args.TabImage end
    if Args.TabStroke then uT.TabStroke=Args.TabStroke end

    local T={
        Accent    =RC(uT.Accent     or Color3.fromRGB(255,0,127)),
        Background=RC(uT.Background or Color3.fromRGB(11,11,11)),
        Row       =RC(uT.Row        or Color3.fromRGB(15,15,15)),
        RowAlt    =RC(uT.RowAlt     or Color3.fromRGB(10,10,10)),
        Stroke    =RC(uT.Stroke     or Color3.fromRGB(25,25,25)),
        Text      =RC(uT.Text       or Color3.fromRGB(255,255,255)),
        SubText   =RC(uT.SubText    or Color3.fromRGB(163,163,163)),
        TabBg     =RC(uT.TabBg      or Color3.fromRGB(10,10,10)),
        TabStroke =RC(uT.TabStroke  or Color3.fromRGB(75,0,38)),
        TabImage  =RC(uT.TabImage   or uT.Accent or Color3.fromRGB(255,0,127)),
        DropBg    =RC(uT.DropBg     or Color3.fromRGB(18,18,18)),
        DropStroke=RC(uT.DropStroke or Color3.fromRGB(30,30,30)),
        PillBg    =RC(uT.PillBg     or Color3.fromRGB(11,11,11)),
    }

    local aRefs,bRefs,tiRefs,tbRefs,tsRefs={},{},{},{},{}
    local function tA(i,p) table.insert(aRefs, {i,p}); return i end
    local function tB(i,p) table.insert(bRefs, {i,p}); return i end
    local function tTI(i,p) table.insert(tiRefs,{i,p}); return i end
    local function tTB(i,p) table.insert(tbRefs,{i,p}); return i end
    local function tTS(i,p) table.insert(tsRefs,{i,p}); return i end

    local Xova=Library:Create("ScreenGui",{Name="Xova",Parent=Library:Parent(),
        ZIndexBehavior=Enum.ZIndexBehavior.Global,
        DisplayOrder=10,IgnoreGuiInset=true,ResetOnSpawn=false})

    local function GetVP() local cam=workspace.CurrentCamera; return cam and cam.ViewportSize or Vector2.new(1280,720) end
    local function MaxSc() local vp=GetVP(); return math.min((vp.X*0.95)/RAW_W,(vp.Y*0.95)/RAW_H) end
    local function CS(s) return math.clamp(s,0.35,MaxSc()) end
    local function ASV() local vp=GetVP(); return CS(math.min(vp.X/1920,vp.Y/1080)*BaseScale*1.5) end

    local Scaler=Library:Create("UIScale",{Parent=Xova,
        Scale=Mobile and CS(1) or (AutoScale and ASV() or CS(BaseScale))})
    if AutoScale and not Mobile then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if not Scaler:GetAttribute("ManualScale") then Scaler.Scale=ASV() end
        end)
    end

    local Background=Library:Create("Frame",{Name="Background",Parent=Xova,
        AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.Background,
        BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,RAW_W,0,RAW_H)})
    tB(Background,"BackgroundColor3")
    Library:Create("UICorner",{Parent=Background,CornerRadius=UDim.new(0,6)})
    Library:Create("ImageLabel",{Name="Shadow",Parent=Background,
        AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,
        BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(1,120,1,120),ZIndex=0,
        Image="rbxassetid://8992230677",ImageColor3=Color3.fromRGB(0,0,0),
        ImageTransparency=0.5,ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(99,99,99,99)})

    function Library:IsDropdownOpen()
        for _,v in pairs(Background:GetChildren()) do
            if (v.Name=="Dropdown" or v.Name=="ColorPickerFrame") and v.Visible then return true end
        end
        return false
    end

    local HDR_H=52

    local Header=Library:Create("Frame",{Name="Header",Parent=Background,
        BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,HDR_H)})
    Library:Create("Frame",{Parent=Header,Name="Div",BackgroundColor3=T.Stroke,
        BorderSizePixel=0,AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1)})

    local ReturnBtn=Library:Create("TextButton",{Name="Return",Parent=Header,
        BackgroundColor3=T.TabBg,BorderSizePixel=0,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,9,0.5,0),
        Size=UDim2.new(0,30,0,30),Text="",AutoButtonColor=false,
        Visible=false,ZIndex=6,ClipsDescendants=true})
    Library:Create("UICorner",{Parent=ReturnBtn,CornerRadius=UDim.new(1,0)})
    Library:Create("UIStroke",{Parent=ReturnBtn,Color=T.Stroke,Thickness=0.6})
    local RetArrow=Library:Create("ImageLabel",{Parent=ReturnBtn,
        AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,14,0,14),
        Image="rbxassetid://130391877219356",ImageColor3=T.Accent,ZIndex=7})
    tA(RetArrow,"ImageColor3")

    local AvatarBtn
    if ExecIdShown then
        AvatarBtn=Library:Create("TextButton",{Name="AvatarBtn",Parent=Header,
            BackgroundColor3=T.Background,BorderSizePixel=0,
            AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),
            Size=UDim2.new(0,34,0,34),Text="",AutoButtonColor=false,
            ZIndex=5,ClipsDescendants=false})
        Library:Create("UICorner",{Parent=AvatarBtn,CornerRadius=UDim.new(1,0)})
        local ARing=Library:Create("Frame",{Parent=AvatarBtn,
            AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.Accent,BorderSizePixel=0,
            Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,1,0)})
        Library:Create("UICorner",{Parent=ARing,CornerRadius=UDim.new(1,0)})
        tA(ARing,"BackgroundColor3")
        local AClip=Library:Create("Frame",{Parent=ARing,
            AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.Background,BorderSizePixel=0,
            Position=UDim2.new(0.5,0,0.5,0),
            Size=UDim2.new(1,-3,1,-3),ClipsDescendants=true})
        Library:Create("UICorner",{Parent=AClip,CornerRadius=UDim.new(1,0)})
        tB(AClip,"BackgroundColor3")
        local AImg=Library:Create("ImageLabel",{Parent=AClip,
            AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,
            BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,1,0),Image=""})
        task.spawn(function()
            local ok,img=pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48)
            end)
            if ok and img then AImg.Image=img end
        end)
        local avatarTooltip=Library:Create("Frame",{Parent=Header,
            BackgroundColor3=T.TabBg,BorderSizePixel=0,
            AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-10,1,4),
            Size=UDim2.new(0,0,0,24),AutomaticSize=Enum.AutomaticSize.X,
            Visible=false,ZIndex=20})
        Library:Create("UICorner",{Parent=avatarTooltip,CornerRadius=UDim.new(0,4)})
        Library:Create("UIStroke",{Parent=avatarTooltip,Color=T.Stroke,Thickness=0.5})
        Library:Create("UIPadding",{Parent=avatarTooltip,PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)})
        local ttLine1=Library:Create("TextLabel",{Parent=avatarTooltip,
            BackgroundTransparency=1,BorderSizePixel=0,
            AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),
            Size=UDim2.new(0,0,0,12),AutomaticSize=Enum.AutomaticSize.X,
            Font=Enum.Font.GothamBold,Text=(CustomUserName or LocalPlayer.DisplayName),
            TextColor3=T.Text,TextSize=11,ZIndex=21})
        local ttLine2=Library:Create("TextLabel",{Parent=avatarTooltip,
            BackgroundTransparency=1,BorderSizePixel=0,
            AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,11),
            Size=UDim2.new(0,0,0,10),AutomaticSize=Enum.AutomaticSize.X,
            Font=Enum.Font.GothamMedium,Text=(CustomExecutor or GetExec()),
            TextColor3=T.Accent,TextSize=10,ZIndex=21,TextTransparency=0.2})
        tA(ttLine2,"TextColor3")
        AvatarBtn.MouseEnter:Connect(function() avatarTooltip.Visible=true end)
        AvatarBtn.MouseLeave:Connect(function() avatarTooltip.Visible=false end)
    end

    local HeaderRow=Library:Create("Frame",{Name="HeaderRow",Parent=Header,
        BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)})
    Library:Create("UIPadding",{Parent=HeaderRow,
        PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,ExecIdShown and 52 or 12),
        PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,7)})
    Library:Create("UIListLayout",{Parent=HeaderRow,
        FillDirection=Enum.FillDirection.Horizontal,
        SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Center,
        Padding=UDim.new(0,0)})

    local TitleBlock=Library:Create("Frame",{Name="TitleBlock",Parent=Header,
        BackgroundTransparency=1,BorderSizePixel=0,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,12,0.5,0),
        Size=UDim2.new(1,-58,0,34)})
    Library:Create("UIListLayout",{Parent=TitleBlock,
        SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,1)})

    local TitleLabel
    if Title and Title~="" then
        TitleLabel=Library:Create("TextLabel",{Name="Title",Parent=TitleBlock,
            BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,15),
            Font=Enum.Font.GothamBold,RichText=true,Text=Title,
            TextColor3=T.Accent,TextSize=14,TextStrokeTransparency=0.7,
            TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
        tA(TitleLabel,"TextColor3"); MkGrad(TitleLabel)
    end
    local SubTitleLabel
    if SubTitle and SubTitle~="" then
        SubTitleLabel=Library:Create("TextLabel",{Name="SubTitle",Parent=TitleBlock,
            BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,11),
            Font=Enum.Font.GothamMedium,RichText=true,Text=SubTitle,
            TextColor3=T.Text,TextSize=10,TextStrokeTransparency=0.7,TextTransparency=0.6,
            TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
    end

    local TimeFrame=Library:Create("Frame",{Name="TimeFrame",Parent=Header,
        BackgroundTransparency=1,BorderSizePixel=0,
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.new(0,0,0,28),AutomaticSize=Enum.AutomaticSize.X})
    Library:Create("UIListLayout",{Parent=TimeFrame,
        SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center,
        HorizontalAlignment=Enum.HorizontalAlignment.Right})
    local THETIME=Library:Create("TextLabel",{Name="Time",Parent=TimeFrame,
        BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(0,0,0,10),AutomaticSize=Enum.AutomaticSize.X,
        Font=Enum.Font.GothamMedium,Text="",
        TextColor3=T.SubText,TextSize=10,TextTransparency=0.35,
        TextXAlignment=Enum.TextXAlignment.Right})

    local Scale=Library:Create("Frame",{Name="Scale",Parent=Background,
        AnchorPoint=Vector2.new(0,1),BackgroundTransparency=1,
        BorderSizePixel=0,Position=UDim2.new(0,0,1,0),
        Size=UDim2.new(1,0,1,-(HDR_H+1))})
    Scale.ClipsDescendants=true

    local Home=Library:Create("Frame",{Name="Home",Parent=Scale,
        BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)})
    Library:Create("UIPadding",{Parent=Home,
        PaddingBottom=UDim.new(0,14),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12),PaddingTop=UDim.new(0,10)})

    local MTS=Library:Create("ScrollingFrame",{Name="TabScrolling",Parent=Home,
        Active=true,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),ClipsDescendants=true,
        AutomaticCanvasSize=Enum.AutomaticSize.None,
        BottomImage="rbxasset://textures/ui/Scroll/scroll-bottom.png",
        CanvasPosition=Vector2.new(0,0),ElasticBehavior=Enum.ElasticBehavior.WhenScrollable,
        MidImage="rbxasset://textures/ui/Scroll/scroll-middle.png",
        ScrollBarImageColor3=Color3.fromRGB(0,0,0),ScrollBarThickness=0,
        ScrollingDirection=Enum.ScrollingDirection.XY,
        TopImage="rbxasset://textures/ui/Scroll/scroll-top.png",
        VerticalScrollBarPosition=Enum.VerticalScrollBarPosition.Right})
    Library:Create("UIPadding",{Parent=MTS,
        PaddingBottom=UDim.new(0,1),PaddingLeft=UDim.new(0,1),
        PaddingRight=UDim.new(0,1),PaddingTop=UDim.new(0,1)})
    local MTL=Library:Create("UIListLayout",{Parent=MTS,Padding=UDim.new(0,10),
        FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,Wraps=true})
    MTL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        MTS.CanvasSize=UDim2.new(0,0,0,MTL.AbsoluteContentSize.Y+15)
    end)

    local PageService=Library:Create("UIPageLayout",{Parent=Scale})
    PageService.HorizontalAlignment=Enum.HorizontalAlignment.Left
    PageService.EasingStyle=Enum.EasingStyle.Exponential
    PageService.TweenTime=0.45
    PageService.GamepadInputEnabled=false
    PageService.ScrollWheelInputEnabled=false
    PageService.TouchInputEnabled=false
    Library.PageService=PageService

    local ToggleScreen=Library:Create("ScreenGui",{Name="VitaToggle",Parent=Library:Parent(),
        ZIndexBehavior=Enum.ZIndexBehavior.Global,DisplayOrder=11,IgnoreGuiInset=true,ResetOnSpawn=false})
    local Pillow=Library:Create("TextButton",{Name="Pillow",Parent=ToggleScreen,
        BackgroundColor3=T.PillBg,BorderSizePixel=0,
        Position=UDim2.new(0.06,0,0.15,0),Size=UDim2.new(0,50,0,50),
        Text="",ClipsDescendants=true})
    tB(Pillow,"BackgroundColor3")
    Library:Create("UICorner",{Parent=Pillow,CornerRadius=UDim.new(1,0)})
    Library:Create("UIStroke",{Parent=Pillow,Color=T.Stroke,Thickness=0.6})
    local PillLogo=Library:Create("ImageLabel",{Name="Logo",Parent=Pillow,
        AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,
        BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0.52,0,0.52,0),Image=Library:Asset(BbIcon),
        ImageColor3=T.Accent})
    tA(PillLogo,"ImageColor3")
    Library:Draggable(Pillow)
    Pillow.MouseButton1Click:Connect(function() Background.Visible=not Background.Visible end)
    UserInputService.InputBegan:Connect(function(inp,proc)
        if proc then return end
        if inp.KeyCode==ToggleKey then Background.Visible=not Background.Visible end
    end)

    local function OnReturn()
        ReturnBtn.Visible=false
        if AvatarBtn then AvatarBtn.Visible=true end
        TitleBlock.Position=UDim2.new(0,12,0.5,0)
        PageService:JumpTo(Home)
    end
    ReturnBtn.MouseButton1Click:Connect(OnReturn)
    PageService:JumpTo(Home)
    Library:Draggable(Header,Background)

    local _locked=false
    local _lockMsg="This element is locked"

    local function BuildColorPicker(parentFrame,initialColor,onChanged)
        local H,S,V=Color3.toHSV(initialColor)
        local cur=initialColor

        local PF=Library:Create("Frame",{Name="ColorPickerFrame",Parent=parentFrame,
            AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.DropBg,
            BorderSizePixel=0,Position=UDim2.new(0.5,0,0.35,0),
            Size=UDim2.new(0,300,0,260),ZIndex=600,Visible=false})
        Library:Create("UICorner",{Parent=PF,CornerRadius=UDim.new(0,8)})
        Library:Create("UIStroke",{Parent=PF,Color=T.DropStroke,Thickness=0.8})

        local CPHdr=Library:Create("Frame",{Parent=PF,
            BackgroundColor3=Color3.fromRGB(20,20,20),BorderSizePixel=0,
            Size=UDim2.new(1,0,0,32),ZIndex=601})
        Library:Create("UICorner",{Parent=CPHdr,CornerRadius=UDim.new(0,8)})
        Library:Create("TextLabel",{Parent=CPHdr,BackgroundTransparency=1,BorderSizePixel=0,
            Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-40,1,0),
            Font=Enum.Font.GothamBold,Text="Color Picker",
            TextColor3=T.Text,TextSize=12,ZIndex=601,TextXAlignment=Enum.TextXAlignment.Left})
        local ClosePF=Library:Create("TextButton",{Parent=CPHdr,
            BackgroundTransparency=1,BorderSizePixel=0,
            AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-10,0.5,0),
            Size=UDim2.new(0,22,0,22),
            Font=Enum.Font.GothamBold,Text="✕",
            TextColor3=T.SubText,TextSize=14,ZIndex=602})

        local Body=Library:Create("Frame",{Parent=PF,BackgroundTransparency=1,BorderSizePixel=0,
            Position=UDim2.new(0,10,0,38),Size=UDim2.new(1,-20,0,216),ZIndex=601})

        local SV=Library:Create("Frame",{Parent=Body,
            BackgroundColor3=Color3.fromHSV(H,1,1),BorderSizePixel=0,
            Position=UDim2.new(0,0,0,0),
            Size=UDim2.new(1,-22,0,136),ZIndex=601,ClipsDescendants=true})
        Library:Create("UICorner",{Parent=SV,CornerRadius=UDim.new(0,6)})
        Library:Create("UIGradient",{Parent=SV,
            Color=ColorSequence.new{
                ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))},
            Transparency=NumberSequence.new{
                NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}})
        local BL=Library:Create("Frame",{Parent=SV,BackgroundColor3=Color3.fromRGB(0,0,0),
            BackgroundTransparency=0,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=602})
        Library:Create("UIGradient",{Parent=BL,Rotation=90,
            Color=ColorSequence.new{
                ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))},
            Transparency=NumberSequence.new{
                NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}})
        local SVC=Library:Create("Frame",{Parent=SV,
            BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,
            AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(S,0,1-V,0),
            Size=UDim2.new(0,12,0,12),ZIndex=603})
        Library:Create("UICorner",{Parent=SVC,CornerRadius=UDim.new(1,0)})
        Library:Create("UIStroke",{Parent=SVC,Color=Color3.fromRGB(0,0,0),Thickness=2})

        local HF=Library:Create("Frame",{Parent=Body,
            BackgroundColor3=Color3.fromRGB(255,0,0),BorderSizePixel=0,
            AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),
            Size=UDim2.new(0,16,0,136),ZIndex=601,ClipsDescendants=true})
        Library:Create("UICorner",{Parent=HF,CornerRadius=UDim.new(0,5)})
        Library:Create("UIGradient",{Parent=HF,Rotation=90,
            Color=ColorSequence.new{
                ColorSequenceKeypoint.new(0,   Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.17,Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(0.33,Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.50,Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.67,Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.83,Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(1,   Color3.fromRGB(255,0,0))}})
        local HC=Library:Create("Frame",{Parent=HF,
            BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,
            AnchorPoint=Vector2.new(0.5,0.5),
            Position=UDim2.new(0.5,0,H,0),Size=UDim2.new(1,6,0,6),ZIndex=603})
        Library:Create("UICorner",{Parent=HC,CornerRadius=UDim.new(0,2)})
        Library:Create("UIStroke",{Parent=HC,Color=Color3.fromRGB(0,0,0),Thickness=1.2})

        local InputArea=Library:Create("Frame",{Parent=Body,BackgroundTransparency=1,BorderSizePixel=0,
            Position=UDim2.new(0,0,0,144),Size=UDim2.new(1,0,0,68),ZIndex=601})
        Library:Create("UIListLayout",{Parent=InputArea,FillDirection=Enum.FillDirection.Vertical,
            Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})

        local SwRow=Library:Create("Frame",{Parent=InputArea,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,28),LayoutOrder=1})
        Library:Create("UIListLayout",{Parent=SwRow,FillDirection=Enum.FillDirection.Horizontal,
            Padding=UDim.new(0,6),VerticalAlignment=Enum.VerticalAlignment.Center,
            SortOrder=Enum.SortOrder.LayoutOrder})
        local SwPrev=Library:Create("Frame",{Parent=SwRow,BackgroundColor3=initialColor,BorderSizePixel=0,
            Size=UDim2.new(0,26,0,24),ZIndex=601,LayoutOrder=1})
        Library:Create("UICorner",{Parent=SwPrev,CornerRadius=UDim.new(0,4)})
        Library:Create("UIStroke",{Parent=SwPrev,Color=T.Stroke,Thickness=0.6})
        local HexIn=Library:Create("TextBox",{Parent=SwRow,BackgroundColor3=T.Row,BorderSizePixel=0,
            Size=UDim2.new(1,-32,0,24),ZIndex=601,LayoutOrder=2,
            Font=Enum.Font.GothamMedium,
            Text="#"..string.format("%02X%02X%02X",
                math.floor(initialColor.R*255),math.floor(initialColor.G*255),math.floor(initialColor.B*255)),
            TextColor3=T.Text,TextSize=11,
            PlaceholderText="#RRGGBB",PlaceholderColor3=T.SubText,
            TextXAlignment=Enum.TextXAlignment.Center,ClearTextOnFocus=false})
        Library:Create("UICorner",{Parent=HexIn,CornerRadius=UDim.new(0,4)})
        Library:Create("UIStroke",{Parent=HexIn,Color=T.Stroke,Thickness=0.5})

        local RGBRow=Library:Create("Frame",{Parent=InputArea,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,24),LayoutOrder=2})
        Library:Create("UIListLayout",{Parent=RGBRow,FillDirection=Enum.FillDirection.Horizontal,
            Padding=UDim.new(0,4),VerticalAlignment=Enum.VerticalAlignment.Center,
            SortOrder=Enum.SortOrder.LayoutOrder})

        local function MkRGB(lbl,val,lo)
            local c=Library:Create("Frame",{Parent=RGBRow,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0.333,-3,1,0),LayoutOrder=lo})
            Library:Create("UIListLayout",{Parent=c,FillDirection=Enum.FillDirection.Horizontal,
                Padding=UDim.new(0,3),VerticalAlignment=Enum.VerticalAlignment.Center,
                SortOrder=Enum.SortOrder.LayoutOrder})
            Library:Create("TextLabel",{Parent=c,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0,14,1,0),LayoutOrder=1,Font=Enum.Font.GothamSemibold,
                Text=lbl,TextColor3=T.SubText,TextSize=10,TextXAlignment=Enum.TextXAlignment.Center})
            local b=Library:Create("TextBox",{Parent=c,BackgroundColor3=T.Row,BorderSizePixel=0,
                Size=UDim2.new(1,-17,1,0),LayoutOrder=2,Font=Enum.Font.GothamMedium,
                Text=tostring(val),TextColor3=T.Text,TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Center,ZIndex=601,ClearTextOnFocus=false})
            Library:Create("UICorner",{Parent=b,CornerRadius=UDim.new(0,3)})
            Library:Create("UIStroke",{Parent=b,Color=T.Stroke,Thickness=0.5})
            return b
        end
        local RBox=MkRGB("R",math.floor(initialColor.R*255),1)
        local GBox=MkRGB("G",math.floor(initialColor.G*255),2)
        local BBox=MkRGB("B",math.floor(initialColor.B*255),3)

        local function UpdateAll()
            cur=Color3.fromHSV(H,S,V)
            SV.BackgroundColor3=Color3.fromHSV(H,1,1)
            SVC.Position=UDim2.new(S,0,1-V,0)
            HC.Position=UDim2.new(0.5,0,H,0)
            SwPrev.BackgroundColor3=cur
            local r,g,b=math.floor(cur.R*255),math.floor(cur.G*255),math.floor(cur.B*255)
            HexIn.Text="#"..string.format("%02X%02X%02X",r,g,b)
            RBox.Text=tostring(r); GBox.Text=tostring(g); BBox.Text=tostring(b)
            pcall(onChanged,cur)
        end

        local svDrag,hueDrag=false,false
        local SvBtn=Library:Button(SV); SvBtn.ZIndex=602; SvBtn.Name="SvBtn"
        SvBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                svDrag=true
                local pos=SV.AbsolutePosition; local rel=SV.AbsoluteSize
                S=math.clamp((inp.Position.X-pos.X)/rel.X,0,1)
                V=math.clamp(1-(inp.Position.Y-pos.Y)/rel.Y,0,1)
                UpdateAll()
            end
        end)
        SvBtn.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then svDrag=false end
        end)
        local HBtn=Library:Button(HF); HBtn.ZIndex=602; HBtn.Name="HBtn"
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
            if not PF.Visible then return end
            if inp.UserInputType~=Enum.UserInputType.MouseMovement and inp.UserInputType~=Enum.UserInputType.Touch then return end
            if svDrag then
                local pos=SV.AbsolutePosition; local rel=SV.AbsoluteSize
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
        local function RGBChanged()
            local r=math.clamp(tonumber(RBox.Text) or 0,0,255)
            local g=math.clamp(tonumber(GBox.Text) or 0,0,255)
            local b=math.clamp(tonumber(BBox.Text) or 0,0,255)
            H,S,V=Color3.toHSV(Color3.fromRGB(r,g,b)); UpdateAll()
        end
        RBox.FocusLost:Connect(RGBChanged)
        GBox.FocusLost:Connect(RGBChanged)
        BBox.FocusLost:Connect(RGBChanged)
        UserInputService.InputBegan:Connect(function(A)
            if not PF.Visible then return end
            if A.UserInputType~=Enum.UserInputType.MouseButton1 and A.UserInputType~=Enum.UserInputType.Touch then return end
            local m=LocalPlayer:GetMouse()
            local dp,ds=PF.AbsolutePosition,PF.AbsoluteSize
            if not(m.X>=dp.X and m.X<=dp.X+ds.X and m.Y>=dp.Y and m.Y<=dp.Y+ds.Y) then PF.Visible=false end
        end)
        ClosePF.MouseButton1Click:Connect(function() PF.Visible=false end)
        UpdateAll()
        return PF,function() return cur end,function(c) H,S,V=Color3.toHSV(c); UpdateAll() end
    end

    local Window={}

    function Window:Popup(Args)
        local PTitle=Args.Title or "Popup"
        local PDesc=Args.Desc or ""
        local PButtons=Args.Buttons or {{Text="OK",Callback=function()end}}
        local Overlay=Library:Create("Frame",{Name="PopupOverlay",Parent=Background,
            BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=0.5,
            BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=800})
        local PF=Library:Create("Frame",{Name="Popup",Parent=Background,
            AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.Background,
            BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),
            Size=UDim2.new(0,300,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=801})
        Library:Create("UICorner",{Parent=PF,CornerRadius=UDim.new(0,6)})
        Library:Create("UIStroke",{Parent=PF,Color=T.Stroke,Thickness=0.8})
        Library:Create("UIListLayout",{Parent=PF,SortOrder=Enum.SortOrder.LayoutOrder})
        local PHdr=Library:Create("Frame",{Parent=PF,BackgroundColor3=T.TabBg,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,40),ZIndex=802})
        Library:Create("UICorner",{Parent=PHdr,CornerRadius=UDim.new(0,6)})
        Library:Create("UIPadding",{Parent=PHdr,PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)})
        Library:Create("UIStroke",{Parent=PHdr,Color=T.Stroke,Thickness=0.5})
        Library:Create("TextLabel",{Parent=PHdr,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,Text=PTitle,
            TextColor3=T.Accent,TextSize=13,ZIndex=803,
            TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
        local PBody=Library:Create("Frame",{Parent=PF,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=802})
        Library:Create("UIPadding",{Parent=PBody,
            PaddingTop=UDim.new(0,14),PaddingBottom=UDim.new(0,14),
            PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)})
        Library:Create("UIListLayout",{Parent=PBody,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,12)})
        Library:Create("TextLabel",{Parent=PBody,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            Font=Enum.Font.GothamMedium,Text=PDesc,
            TextColor3=T.Text,TextSize=12,ZIndex=803,
            TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,TextTransparency=0.1})
        local BR=Library:Create("Frame",{Parent=PBody,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,30),ZIndex=802})
        Library:Create("UIListLayout",{Parent=BR,FillDirection=Enum.FillDirection.Horizontal,
            HorizontalAlignment=Enum.HorizontalAlignment.Right,
            Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder,
            VerticalAlignment=Enum.VerticalAlignment.Center})
        local function Close() pcall(function()PF:Destroy()end); pcall(function()Overlay:Destroy()end) end
        for _,bd in ipairs(PButtons) do
            local isMain=bd.Style=="main" or bd.Style==nil
            local Btn=Library:Create("TextButton",{Parent=BR,
                BackgroundColor3=isMain and T.Accent or T.RowAlt,
                BorderSizePixel=0,Size=UDim2.new(0,80,0,30),ZIndex=803,
                Font=Enum.Font.GothamSemibold,Text=bd.Text or "OK",
                TextColor3=T.Text,TextSize=11,ClipsDescendants=true,AutoButtonColor=false})
            Library:Create("UICorner",{Parent=Btn,CornerRadius=UDim.new(0,4)})
            Library:Create("UIPadding",{Parent=Btn,PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})
            if isMain then BtnGrad(Btn) end
            Btn.MouseButton1Click:Connect(function() Ripple(Btn); Close(); if bd.Callback then pcall(bd.Callback) end end)
        end
        Library:Create("TextButton",{Parent=Overlay,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0),Text="",ZIndex=800}).MouseButton1Click:Connect(Close)
        return {Close=Close}
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
        local TabImg   =Args.TabImage

        local NewTabs=Library:Create("Frame",{Name="NewTabs",Parent=MTS,
            BackgroundColor3=T.TabBg,BorderSizePixel=0,
            Size=UDim2.new(0,230,0,55),ClipsDescendants=true})
        tTB(NewTabs,"BackgroundColor3")
        local TabCB=Library:Button(NewTabs)
        Library:Create("UICorner",{Parent=NewTabs,CornerRadius=UDim.new(0,5)})
        local TSI=Library:Create("UIStroke",{Parent=NewTabs,Color=T.TabStroke,Thickness=1})
        tTS(TSI,"Color")
        local TBC=TabImg and RC(TabImg) or T.TabImage
        local TabBanner=Library:Create("ImageLabel",{Name="Banner",Parent=NewTabs,
            BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),
            Image="rbxassetid://125411502674016",ImageColor3=TBC,ScaleType=Enum.ScaleType.Crop})
        if not TabImg then tTI(TabBanner,"ImageColor3") end
        Library:Create("UICorner",{Parent=TabBanner,CornerRadius=UDim.new(0,2)})
        local TabInfo=Library:Create("Frame",{Name="Info",Parent=NewTabs,
            BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)})
        Library:Create("UIListLayout",{Parent=TabInfo,Padding=UDim.new(0,10),
            FillDirection=Enum.FillDirection.Horizontal,
            SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center})
        Library:Create("UIPadding",{Parent=TabInfo,PaddingLeft=UDim.new(0,14)})
        local TabIcon=Library:Create("ImageLabel",{Name="Icon",Parent=TabInfo,
            BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-1,
            Size=UDim2.new(0,24,0,24),Image=Library:Asset(PageIcon),ImageColor3=T.Accent})
        tA(TabIcon,"ImageColor3"); MkGrad(TabIcon)
        local TabText=Library:Create("Frame",{Name="Text",Parent=TabInfo,
            BackgroundTransparency=1,BorderSizePixel=0,
            Position=UDim2.new(0.11,0,0.14,0),Size=UDim2.new(0,150,0,32)})
        Library:Create("UIListLayout",{Parent=TabText,Padding=UDim.new(0,2),
            SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center})
        local TabTL=Library:Create("TextLabel",{Name="Title",Parent=TabText,
            BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0,150,0,14),
            Font=Enum.Font.GothamBold,RichText=true,Text=PageTitle,
            TextColor3=T.Accent,TextSize=14,
            TextStrokeTransparency=0.45,TextXAlignment=Enum.TextXAlignment.Left,
            TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y})
        tA(TabTL,"TextColor3"); MkGrad(TabTL)
        Library:Create("TextLabel",{Name="Desc",Parent=TabText,
            BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0.9,0,0,10),
            Font=Enum.Font.GothamMedium,RichText=true,Text=PageDesc,
            TextColor3=T.Text,TextSize=10,TextStrokeTransparency=0.5,TextTransparency=0.25,
            TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y})

        local NewPage=Library:Create("Frame",{Name="NewPage",Parent=Scale,
            BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)})
        local PS=Library:Create("ScrollingFrame",{Name="PageScrolling",Parent=NewPage,
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
            VerticalScrollBarPosition=Enum.VerticalScrollBarPosition.Right})
        Library:Create("UIPadding",{Parent=PS,
            PaddingBottom=UDim.new(0,8),PaddingLeft=UDim.new(0,14),
            PaddingRight=UDim.new(0,14),PaddingTop=UDim.new(0,8)})
        local PL=Library:Create("UIListLayout",{Parent=PS,Padding=UDim.new(0,5),
            FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder})
        PL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PS.CanvasSize=UDim2.new(0,0,0,PL.AbsoluteContentSize.Y+18)
        end)

        TabCB.MouseButton1Click:Connect(function()
            if _locked then return end
            ReturnBtn.Visible=true
            if AvatarBtn then AvatarBtn.Visible=false end
            TitleBlock.Position=UDim2.new(0,48,0.5,0)
            PageService:JumpTo(NewPage)
        end)

        local Page={}

        local function LockOv(parent,msg)
            local ov=Library:Create("Frame",{Parent=parent,
                BackgroundColor3=T.Background,BackgroundTransparency=0.25,
                BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=50,Visible=false})
            Library:Create("UICorner",{Parent=ov,CornerRadius=UDim.new(0,4)})
            Library:Create("TextLabel",{Parent=ov,BackgroundTransparency=1,BorderSizePixel=0,
                AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
                Size=UDim2.new(1,-10,1,0),ZIndex=51,
                Font=Enum.Font.GothamMedium,Text=msg or _lockMsg,
                TextColor3=T.SubText,TextSize=10,
                TextXAlignment=Enum.TextXAlignment.Center,TextWrapped=true})
            return ov
        end

        function Page:Section(txt)
            local L=Library:Create("TextLabel",{Name="Section",Parent=PS,
                AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,
                LayoutOrder=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,0,22),
                Font=Enum.Font.GothamBold,RichText=true,
                Text="  "..txt,TextColor3=T.Text,TextSize=14,
                TextStrokeTransparency=0.7,TextXAlignment=Enum.TextXAlignment.Left,
                TextWrapped=true,AutomaticSize=Enum.AutomaticSize.None})
            MkGrad(L); return L
        end

        function Page:Paragraph(Args)
            local PTitle     = Args.Title
            local PDesc      = Args.Desc
            local PColor     = Args.Color
            local PImage     = Args.Image or Args.Icon
            local PImageSize = Args.ImageSize or 20
            local PImageMode = Args.ImageMode or "beside"
            local PTopImgH   = Args.TopImageHeight or 120
            local PThumb     = Args.Thumbnail
            local PThumbSize = Args.ThumbnailSize or 44
            local PBtns      = Args.Buttons or {}
            local PLockMsg   = Args.LockMessage
            local isTop = PImageMode=="top"

            local Rows=Library:Create("Frame",{Name="Rows",Parent=PS,
                BackgroundColor3=PColor and RC(PColor) or T.Row,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y})
            Library:Create("UIStroke",{Parent=Rows,Color=T.Stroke,Thickness=0.5})
            Library:Create("UICorner",{Parent=Rows,CornerRadius=UDim.new(0,4)})
            Library:Create("UIListLayout",{Parent=Rows,FillDirection=Enum.FillDirection.Vertical,
                SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0)})

            if isTop and PImage and PImage~="" then
                local TI=Library:Create("ImageLabel",{Parent=Rows,
                    BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=0,
                    BorderSizePixel=0,Size=UDim2.new(1,0,0,PTopImgH),LayoutOrder=1,
                    Image=Library:Asset(PImage),ScaleType=Enum.ScaleType.Crop})
                Library:Create("UICorner",{Parent=TI,CornerRadius=UDim.new(0,4)})
            end

            local Inner=Library:Create("Frame",{Parent=Rows,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2})
            Library:Create("UIPadding",{Parent=Inner,
                PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),
                PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})
            Library:Create("UIListLayout",{Parent=Inner,FillDirection=Enum.FillDirection.Horizontal,
                VerticalAlignment=Enum.VerticalAlignment.Center,
                SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,10)})

            local ThumbLbl
            if PThumb and PThumb~="" then
                ThumbLbl=Library:Create("ImageLabel",{Parent=Inner,BackgroundTransparency=1,BorderSizePixel=0,
                    LayoutOrder=1,Size=UDim2.new(0,PThumbSize,0,PThumbSize),
                    Image=Library:Asset(PThumb),ImageColor3=Color3.fromRGB(255,255,255)})
                Library:Create("UICorner",{Parent=ThumbLbl,CornerRadius=UDim.new(0,5)})
            end

            local btnCount=#PBtns
            local iconW=(not isTop and PImage and PImage~="") and (PImageSize+10) or 0
            local btnsW=btnCount>0 and (btnCount*62+(btnCount-1)*6+4) or 0
            local thumbW=(PThumb and PThumb~="") and (PThumbSize+10) or 0
            local textW=1-(btnsW+iconW)/(RAW_W-28-thumbW)
            if textW<0.3 then textW=0.3 end

            local TextBlock=Library:Create("Frame",{Parent=Inner,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(textW,-(thumbW),0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2})
            Library:Create("UIListLayout",{Parent=TextBlock,SortOrder=Enum.SortOrder.LayoutOrder,
                VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,3)})

            local TitleLbl=Library:Create("TextLabel",{Name="Title",Parent=TextBlock,
                BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),
                AutomaticSize=Enum.AutomaticSize.Y,
                Font=Enum.Font.GothamSemibold,RichText=true,Text=PTitle or "",
                TextColor3=T.Text,TextSize=13,TextStrokeTransparency=0.7,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
            if PTitle and PTitle~="" then MkGrad(TitleLbl) end

            local DescLbl=Library:Create("TextLabel",{Name="Desc",Parent=TextBlock,
                BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),
                AutomaticSize=Enum.AutomaticSize.Y,
                Font=Enum.Font.GothamMedium,RichText=true,Text=PDesc or "",
                TextColor3=T.SubText,TextSize=10,TextStrokeTransparency=0.7,TextTransparency=0.25,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})

            local RightBlock=Library:Create("Frame",{Parent=Inner,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0,iconW+btnsW,0,28),LayoutOrder=3})
            Library:Create("UIListLayout",{Parent=RightBlock,FillDirection=Enum.FillDirection.Horizontal,
                HorizontalAlignment=Enum.HorizontalAlignment.Right,
                VerticalAlignment=Enum.VerticalAlignment.Center,
                SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)})

            local IconLbl
            if not isTop and PImage and PImage~="" then
                IconLbl=Library:Create("ImageLabel",{Parent=RightBlock,BackgroundTransparency=1,BorderSizePixel=0,
                    LayoutOrder=1,Size=UDim2.new(0,PImageSize,0,PImageSize),
                    Image=Library:Asset(PImage),ImageColor3=T.Accent})
                tA(IconLbl,"ImageColor3"); MkGrad(IconLbl)
            end

            for bi,btnDef in ipairs(PBtns) do
                local BF=Library:Create("TextButton",{Parent=RightBlock,
                    BackgroundColor3=T.Accent,BorderSizePixel=0,
                    Size=UDim2.new(0,60,0,26),ClipsDescendants=true,LayoutOrder=10+bi,
                    Font=Enum.Font.GothamSemibold,Text=btnDef.Title or "Btn",
                    TextColor3=T.Text,TextSize=10,AutoButtonColor=false,
                    TextXAlignment=Enum.TextXAlignment.Center})
                tA(BF,"BackgroundColor3")
                Library:Create("UICorner",{Parent=BF,CornerRadius=UDim.new(0,4)})
                BtnGrad(BF)
                Library:Create("UIPadding",{Parent=BF,PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)})
                if btnDef.Icon and btnDef.Icon~="" then
                    Library:Create("ImageLabel",{Parent=BF,BackgroundTransparency=1,BorderSizePixel=0,
                        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,5,0.5,0),
                        Size=UDim2.new(0,11,0,11),ZIndex=BF.ZIndex+1,
                        Image=Library:Asset(btnDef.Icon)})
                    BF.TextXAlignment=Enum.TextXAlignment.Right
                end
                BF.MouseButton1Click:Connect(function()
                    if _locked then return end
                    Ripple(BF)
                    if btnDef.Callback then pcall(btnDef.Callback) end
                end)
            end

            local lov=LockOv(Rows,PLockMsg)
            local obj={}
            function obj:SetTitle(v) TitleLbl.Text=tostring(v) end
            function obj:SetDesc(v)  DescLbl.Text=tostring(v) end
            function obj:SetImage(v) if IconLbl then IconLbl.Image=Library:Asset(v) end end
            function obj:SetThumbnail(v) if ThumbLbl then ThumbLbl.Image=Library:Asset(v) end end
            function obj:SetColor(v) Rows.BackgroundColor3=RC(v) end
            function obj:Lock(m)   lov.Visible=true; if m then lov:FindFirstChildWhichIsA("TextLabel",true).Text=m end end
            function obj:Unlock()  lov.Visible=false end
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
            local Rows=Library:NewRows(PS,Args.Title,Args.Desc,T)
            local Right=Rows.Right; local Left=Rows.Left
            local RightText=Args.Right or "None"
            local Lbl=Library:Create("TextLabel",{Name="RLabel",Parent=Right,
                BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0,0,0,14),AutomaticSize=Enum.AutomaticSize.X,
                Selectable=false,Font=Enum.Font.GothamSemibold,RichText=true,
                Text=RightText,TextColor3=T.Text,TextSize=12,
                TextStrokeTransparency=0.7,TextXAlignment=Enum.TextXAlignment.Right,
                TextWrapped=false})
            MkGrad(Lbl)
            local lov=LockOv(Rows,Args.LockMessage)
            local obj={}
            function obj:SetTitle(v) local t=Left:FindFirstChild("Title"); if t then t.Text=tostring(v) end end
            function obj:SetDesc(v)  local d=Left:FindFirstChild("Desc");  if d then d.Text=tostring(v) end end
            function obj:SetRight(v) Lbl.Text=tostring(v) end
            function obj:Lock(m)   lov.Visible=true; if m then lov:FindFirstChildWhichIsA("TextLabel",true).Text=m end end
            function obj:Unlock()  lov.Visible=false end
            function obj:Destroy() Rows:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v)
                    rawset(t,k,v)
                    if k=="Title" then local tl=Left:FindFirstChild("Title"); if tl then tl.Text=tostring(v) end
                    elseif k=="Desc" then local dl=Left:FindFirstChild("Desc"); if dl then dl.Text=tostring(v) end
                    elseif k=="Right" then Lbl.Text=tostring(v) end
                end,
                __index=function(t,k)
                    if k=="Right" then return Lbl.Text end; return rawget(t,k)
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
            local Rows     = Library:NewRows(PS,BTitle,BDesc,T)
            local Right    = Rows.Right; local Left = Rows.Left

            local Btn=Library:Create("TextButton",{Name="Button",Parent=Right,
                BackgroundColor3=T.Accent,BorderSizePixel=0,
                Size=UDim2.new(0,0,0,26),AutomaticSize=Enum.AutomaticSize.X,
                ClipsDescendants=true,
                Font=Enum.Font.GothamSemibold,Text=BtnText,
                TextColor3=T.Text,TextSize=11,
                AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Center})
            Library:Create("UISizeConstraint",{Parent=Btn,MinSize=Vector2.new(60,26),MaxSize=Vector2.new(130,26)})
            tA(Btn,"BackgroundColor3")
            Library:Create("UICorner",{Parent=Btn,CornerRadius=UDim.new(0,4)})
            BtnGrad(Btn)
            Library:Create("UIPadding",{Parent=Btn,PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})

            Btn.MouseButton1Click:Connect(function()
                if _locked or Library:IsDropdownOpen() then return end
                Ripple(Btn)
                if Callback then pcall(Callback) end
            end)

            local lov=LockOv(Rows,Args.LockMessage)
            local obj={}
            function obj:SetTitle(v) local t=Left:FindFirstChild("Title"); if t then t.Text=tostring(v) end end
            function obj:SetDesc(v)  local d=Left:FindFirstChild("Desc");  if d then d.Text=tostring(v) end end
            function obj:SetText(v)  Btn.Text=tostring(v) end
            function obj:Lock(m)   lov.Visible=true; if m then lov:FindFirstChildWhichIsA("TextLabel",true).Text=m end end
            function obj:Unlock()  lov.Visible=false end
            function obj:Destroy() Rows:Destroy() end
            setmetatable(obj,{__newindex=function(t,k,v)
                rawset(t,k,v)
                if k=="Title" then local tl=Left:FindFirstChild("Title"); if tl then tl.Text=tostring(v) end
                elseif k=="Desc" then local dl=Left:FindFirstChild("Desc"); if dl then dl.Text=tostring(v) end
                elseif k=="Text" then Btn.Text=tostring(v) end
            end})
            return obj
        end

        function Page:Toggle(Args)
            local TTitle   = Args.Title
            local TDesc    = Args.Desc
            local Value    = Args.Value or false
            local Callback = Args.Callback or function()end
            local Rows     = Library:NewRows(PS,TTitle,TDesc,T)
            local Left     = Rows.Left; local Right = Rows.Right
            local TitleLbl = Left:FindFirstChild("Title")

            local Bg=Library:Create("Frame",{Name="ToggleBg",Parent=Right,
                BackgroundColor3=T.RowAlt,BorderSizePixel=0,Size=UDim2.new(0,22,0,22)})
            local Stroke=Library:Create("UIStroke",{Parent=Bg,Color=T.Stroke,Thickness=0.6})
            Library:Create("UICorner",{Parent=Bg,CornerRadius=UDim.new(0,5)})

            local Hl=Library:Create("Frame",{Parent=Bg,
                AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.Accent,BorderSizePixel=0,
                Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,1,0)})
            tA(Hl,"BackgroundColor3")
            Library:Create("UICorner",{Parent=Hl,CornerRadius=UDim.new(0,5)})
            BtnGrad(Hl)
            local ChkImg=Library:Create("ImageLabel",{Parent=Hl,
                AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,
                BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),
                Size=UDim2.new(0.52,0,0.52,0),Image="rbxassetid://86682186031062",
                ImageTransparency=1})

            local CB=Library:Button(Bg); local Data={Value=Value}

            local function OnChanged(val)
                Data.Value=val
                if val then
                    pcall(Callback,val)
                    if TitleLbl then TitleLbl.TextColor3=T.Accent end
                    Library:Tween({v=Hl,t=0.3,s="Exponential",d="Out",g={BackgroundTransparency=0}}):Play()
                    Library:Tween({v=ChkImg,t=0.25,s="Exponential",d="Out",g={ImageTransparency=0,Size=UDim2.new(0.55,0,0.55,0)}}):Play()
                    Stroke.Thickness=0
                else
                    pcall(Callback,val)
                    if TitleLbl then TitleLbl.TextColor3=T.Text end
                    Library:Tween({v=Hl,t=0.3,s="Exponential",d="Out",g={BackgroundTransparency=1}}):Play()
                    Library:Tween({v=ChkImg,t=0.25,s="Exponential",d="Out",g={ImageTransparency=1}}):Play()
                    Stroke.Thickness=0.6
                end
            end

            CB.MouseButton1Click:Connect(function()
                if _locked or Library:IsDropdownOpen() then return end
                OnChanged(not Data.Value)
            end)
            OnChanged(Value)

            local lov=LockOv(Rows,Args.LockMessage)
            local obj={}
            function obj:SetTitle(v) if TitleLbl then TitleLbl.Text=tostring(v) end end
            function obj:SetDesc(v)  local d=Left:FindFirstChild("Desc"); if d then d.Text=tostring(v) end end
            function obj:SetValue(v) OnChanged(v) end
            function obj:GetValue()  return Data.Value end
            function obj:Lock(m)   lov.Visible=true; if m then lov:FindFirstChildWhichIsA("TextLabel",true).Text=m end end
            function obj:Unlock()  lov.Visible=false end
            function obj:Destroy() Rows:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v)
                    rawset(t,k,v)
                    if k=="Title" and TitleLbl then TitleLbl.Text=tostring(v)
                    elseif k=="Value" then OnChanged(v) end
                end,
                __index=function(t,k)
                    if k=="Value" then return Data.Value end; return rawget(t,k)
                end
            })
            return obj
        end

        function Page:Slider(Args)
            local STitle=Args.Title; local SDesc=Args.Desc
            local Min=Args.Min or 0; local Max=Args.Max or 100
            local Rounding=Args.Rounding or 0
            local Value=Args.Value or Min
            local Suffix=Args.Suffix or ""; local Callback=Args.Callback or function()end

            local SF=Library:Create("Frame",{Name="Slider",Parent=PS,
                BackgroundColor3=T.Row,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,46),Selectable=false})
            Library:Create("UICorner",{Parent=SF,CornerRadius=UDim.new(0,4)})
            Library:Create("UIStroke",{Parent=SF,Color=T.Stroke,Thickness=0.5})
            Library:Create("UIPadding",{Parent=SF,PaddingBottom=UDim.new(0,2),
                PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12),PaddingTop=UDim.new(0,2)})

            local TopRow=Library:Create("Frame",{Parent=SF,BackgroundTransparency=1,BorderSizePixel=0,
                Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,0,0,22),Selectable=false})
            Library:Create("UIListLayout",{Parent=TopRow,FillDirection=Enum.FillDirection.Horizontal,
                VerticalAlignment=Enum.VerticalAlignment.Center,
                SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5)})
            local TitleLbl=Library:Create("TextLabel",{Name="Title",Parent=TopRow,
                BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,-70,0,14),LayoutOrder=2,Selectable=false,
                Font=Enum.Font.GothamSemibold,RichText=true,
                Text=STitle or "",TextColor3=T.Text,TextSize=12,
                TextStrokeTransparency=0.7,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false})
            if STitle and STitle~="" then MkGrad(TitleLbl) end
            local ValueBox=Library:Create("TextBox",{Name="ValBox",Parent=TopRow,
                AnchorPoint=Vector2.new(1,0.5),BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0,60,0,14),LayoutOrder=3,Selectable=true,ZIndex=3,
                Font=Enum.Font.GothamMedium,Text=tostring(Value),
                TextColor3=T.SubText,TextSize=11,TextTransparency=0.3,
                TextXAlignment=Enum.TextXAlignment.Right,TextWrapped=false,
                ClearTextOnFocus=false})

            local BarTrack=Library:Create("Frame",{Name="BarTrack",Parent=SF,
                AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),
                BackgroundColor3=Color3.fromRGB(18,18,18),BorderSizePixel=0,
                Size=UDim2.new(1,0,0,6),Selectable=false})
            Library:Create("UICorner",{Parent=BarTrack,CornerRadius=UDim.new(0,3)})
            local Fill=Library:Create("Frame",{Name="Fill",Parent=BarTrack,
                BackgroundColor3=T.Accent,BorderSizePixel=0,Size=UDim2.new(0,0,1,0),Selectable=false})
            tA(Fill,"BackgroundColor3")
            Library:Create("UICorner",{Parent=Fill,CornerRadius=UDim.new(0,3)})
            BtnGrad(Fill)
            local Knob=Library:Create("Frame",{Name="Knob",Parent=Fill,
                AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=Color3.fromRGB(255,255,255),
                BorderSizePixel=0,Position=UDim2.new(1,0,0.5,0),Size=UDim2.new(0,13,0,13),Selectable=false})
            Library:Create("UICorner",{Parent=Knob,CornerRadius=UDim.new(1,0)})
            Library:Create("UIStroke",{Parent=Knob,Color=Color3.fromRGB(180,180,180),Thickness=0.5})

            local dragging=false
            local Data={Value=Value}

            local function Round(n,d) return math.floor(n*(10^d)+0.5)/(10^d) end
            local function UpdateSlider(val)
                val=math.clamp(val,Min,Max); val=Round(val,Rounding); Data.Value=val
                Library:Tween({v=Fill,t=0.08,s="Linear",d="Out",g={Size=UDim2.new((val-Min)/(Max-Min),0,1,0)}}):Play()
                ValueBox.Text=tostring(val)..(Suffix~="" and (" "..Suffix) or "")
                pcall(Callback,val); return val
            end
            local function GetVal(inp)
                local ax=BarTrack.AbsolutePosition.X; local aw=BarTrack.AbsoluteSize.X
                return math.clamp((inp.Position.X-ax)/aw,0,1)*(Max-Min)+Min
            end
            local function SetDrag(s)
                dragging=s; local col=s and T.Accent or T.SubText
                Library:Tween({v=ValueBox,t=0.2,s="Exponential",d="Out",g={TextColor3=col,TextTransparency=s and 0 or 0.3}}):Play()
                Library:Tween({v=Knob,t=0.2,s="Back",d="Out",g={Size=s and UDim2.new(0,15,0,15) or UDim2.new(0,13,0,13)}}):Play()
            end
            local HitBtn=Library:Button(SF); HitBtn.ZIndex=4
            HitBtn.InputBegan:Connect(function(inp)
                if _locked or Library:IsDropdownOpen() then return end
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                    SetDrag(true); UpdateSlider(GetVal(inp))
                end
            end)
            HitBtn.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then SetDrag(false) end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if Library:IsDropdownOpen() then return end
                if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
                    UpdateSlider(GetVal(inp))
                end
            end)
            ValueBox.Focused:Connect(function()
                Library:Tween({v=ValueBox,t=0.2,s="Exponential",d="Out",g={TextColor3=T.Accent,TextTransparency=0}}):Play()
            end)
            ValueBox.FocusLost:Connect(function()
                Library:Tween({v=ValueBox,t=0.2,s="Exponential",d="Out",g={TextColor3=T.SubText,TextTransparency=0.3}}):Play()
                Value=UpdateSlider(tonumber(ValueBox.Text:match("%-?%d+%.?%d*")) or Value)
            end)
            UpdateSlider(Value)

            local lov=LockOv(SF,Args.LockMessage)
            local obj={}
            function obj:SetTitle(v) TitleLbl.Text=tostring(v) end
            function obj:SetValue(v) UpdateSlider(v) end
            function obj:SetMin(v)   Min=v end
            function obj:SetMax(v)   Max=v end
            function obj:GetValue()  return Data.Value end
            function obj:Lock(m)   lov.Visible=true; if m then lov:FindFirstChildWhichIsA("TextLabel",true).Text=m end end
            function obj:Unlock()  lov.Visible=false end
            function obj:Destroy() SF:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v)
                    rawset(t,k,v)
                    if k=="Title" then TitleLbl.Text=tostring(v)
                    elseif k=="Value" then UpdateSlider(v)
                    elseif k=="Min" then Min=v
                    elseif k=="Max" then Max=v end
                end,
                __index=function(t,k)
                    if k=="Value" then return Data.Value end; return rawget(t,k)
                end
            })
            return obj
        end

        function Page:Input(Args)
            local Value=Args.Value or ""; local Callback=Args.Callback or function()end
            local ITitle=Args.Title; local Placeholder=Args.Placeholder or "Type here..."
            local COS=Args.ClearOnSubmit or false
            local MultiLine=Args.MultiLine or false; local Lines=Args.Lines or 4

            if MultiLine then
                local TA=Library:Create("Frame",{Name="TextArea",Parent=PS,
                    BackgroundColor3=T.Row,BorderSizePixel=0,
                    Size=UDim2.new(1,0,0,Lines*18+20)})
                Library:Create("UICorner",{Parent=TA,CornerRadius=UDim.new(0,4)})
                Library:Create("UIStroke",{Parent=TA,Color=T.Stroke,Thickness=0.5})
                Library:Create("UIPadding",{Parent=TA,PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6),
                    PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})
                if ITitle and ITitle~="" then
                    Library:Create("TextLabel",{Parent=TA,BackgroundTransparency=1,BorderSizePixel=0,
                        Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,0,0,13),
                        Font=Enum.Font.GothamSemibold,Text=ITitle,TextColor3=T.SubText,TextSize=10,
                        TextXAlignment=Enum.TextXAlignment.Left})
                end
                local TB=Library:Create("TextBox",{Parent=TA,BackgroundTransparency=1,BorderSizePixel=0,
                    Position=UDim2.new(0,0,0,(ITitle and ITitle~="") and 15 or 0),
                    Size=UDim2.new(1,0,1,-(ITitle and ITitle~="" and 15 or 0)),
                    Font=Enum.Font.GothamMedium,PlaceholderColor3=Color3.fromRGB(60,60,60),
                    PlaceholderText=Placeholder,Text=tostring(Value),
                    TextColor3=Color3.fromRGB(180,180,180),TextSize=11,
                    TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,MultiLine=true,ClearTextOnFocus=false})
                TB.FocusLost:Connect(function(e) if e and not _locked then pcall(Callback,TB.Text) end end)
                local obj={}
                function obj:SetValue(v) TB.Text=tostring(v) end
                function obj:SetPlaceholder(v) TB.PlaceholderText=tostring(v) end
                function obj:GetValue() return TB.Text end
                function obj:Destroy() TA:Destroy() end
                setmetatable(obj,{
                    __newindex=function(t,k,v) rawset(t,k,v); if k=="Value" then TB.Text=tostring(v)
                    elseif k=="Placeholder" then TB.PlaceholderText=tostring(v) end end,
                    __index=function(t,k) if k=="Value" then return TB.Text end; return rawget(t,k) end
                })
                return obj
            end

            local IF=Library:Create("Frame",{Name="Input",Parent=PS,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,34),Selectable=false})
            Library:Create("UIListLayout",{Parent=IF,Padding=UDim.new(0,6),
                FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,
                VerticalAlignment=Enum.VerticalAlignment.Center})
            local Front=Library:Create("Frame",{Name="Front",Parent=IF,
                BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.new(1,-42,1,0),Selectable=false})
            Library:Create("UICorner",{Parent=Front,CornerRadius=UDim.new(0,4)})
            Library:Create("UIStroke",{Parent=Front,Color=T.Stroke,Thickness=0.5})
            local FR=Library:Create("Frame",{Parent=Front,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)})
            Library:Create("UIListLayout",{Parent=FR,FillDirection=Enum.FillDirection.Horizontal,
                Padding=UDim.new(0,5),VerticalAlignment=Enum.VerticalAlignment.Center,
                SortOrder=Enum.SortOrder.LayoutOrder})
            Library:Create("UIPadding",{Parent=FR,PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,6)})
            if Args.Icon and Args.Icon~="" then
                Library:Create("ImageLabel",{Parent=FR,BackgroundTransparency=1,BorderSizePixel=0,
                    Size=UDim2.new(0,13,0,13),LayoutOrder=1,
                    Image=Library:Asset(Args.Icon),ImageColor3=T.SubText})
            end
            local TB=Library:Create("TextBox",{Parent=FR,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,0,1,0),LayoutOrder=2,
                Font=Enum.Font.GothamMedium,PlaceholderColor3=Color3.fromRGB(60,60,60),
                PlaceholderText=Placeholder,Text=tostring(Value),
                TextColor3=Color3.fromRGB(170,170,170),TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ClearTextOnFocus=false})
            local Enter=Library:Create("TextButton",{Name="Enter",Parent=IF,
                BackgroundColor3=T.Accent,BorderSizePixel=0,Size=UDim2.new(0,36,0,34),
                Font=Enum.Font.GothamSemibold,Text="↵",TextColor3=T.Text,TextSize=14,
                AutoButtonColor=false,ClipsDescendants=true})
            tA(Enter,"BackgroundColor3")
            Library:Create("UICorner",{Parent=Enter,CornerRadius=UDim.new(0,4)})
            BtnGrad(Enter)
            TB.FocusLost:Connect(function(e)
                if e then if not _locked then pcall(Callback,TB.Text) end; if COS then TB.Text="" end end
            end)
            Enter.MouseButton1Click:Connect(function()
                Ripple(Enter)
                pcall(setclipboard,TB.Text)
                Enter.Text="✓"
                task.delay(2,function() Enter.Text="↵" end)
            end)
            local lov=LockOv(IF,Args.LockMessage)
            local obj={}
            function obj:SetPlaceholder(v) TB.PlaceholderText=tostring(v) end
            function obj:SetValue(v)       TB.Text=tostring(v) end
            function obj:GetValue()        return TB.Text end
            function obj:Lock(m)  lov.Visible=true; if m then lov:FindFirstChildWhichIsA("TextLabel",true).Text=m end end
            function obj:Unlock() lov.Visible=false end
            function obj:Destroy() IF:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v) rawset(t,k,v); if k=="Value" then TB.Text=tostring(v)
                elseif k=="Placeholder" then TB.PlaceholderText=tostring(v) end end,
                __index=function(t,k) if k=="Value" then return TB.Text end; return rawget(t,k) end
            })
            return obj
        end

        function Page:Dropdown(Args)
            local DTitle=Args.Title; local List=Args.List or {}; local Value=Args.Value
            local Callback=Args.Callback or function()end; local IsMulti=typeof(Value)=="table"
            local Placeholder=Args.Placeholder or "Select..."; local ShowSearch=Args.Search~=false

            local Rows=Library:NewRows(PS,DTitle,nil,T)
            local Right=Rows.Right; local Left=Rows.Left

            Library:Create("ImageLabel",{Parent=Right,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0,20,0,20),Image="rbxassetid://132291592681506",ImageTransparency=0.5})
            local Open=Library:Button(Rows)

            local function GetText()
                if IsMulti then return type(Value)=="table" and #Value>0 and table.concat(Value,", ") or Placeholder end
                return Value~=nil and tostring(Value) or Placeholder
            end
            local DescEl=Left:FindFirstChild("Desc")
            if DescEl then DescEl.Text=GetText() end

            local DF=Library:Create("Frame",{Name="Dropdown",Parent=Background,
                AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.DropBg,
                BorderSizePixel=0,Position=UDim2.new(0.5,0,0.3,0),
                Size=UDim2.new(0,300,0,ShowSearch and 255 or 220),
                ZIndex=500,Selectable=false,Visible=false})
            Library:Create("UICorner",{Parent=DF,CornerRadius=UDim.new(0,4)})
            Library:Create("UIStroke",{Parent=DF,Color=T.DropStroke,Thickness=0.5})
            Library:Create("UIListLayout",{Parent=DF,Padding=UDim.new(0,5),
                SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center})
            Library:Create("UIPadding",{Parent=DF,PaddingBottom=UDim.new(0,10),
                PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),PaddingTop=UDim.new(0,10)})

            local DText=Library:Create("Frame",{Name="DText",Parent=DF,BackgroundTransparency=1,
                BorderSizePixel=0,LayoutOrder=-5,Size=UDim2.new(1,0,0,32),ZIndex=500})
            Library:Create("UIListLayout",{Parent=DText,Padding=UDim.new(0,1),
                SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center,
                VerticalAlignment=Enum.VerticalAlignment.Center})
            local DTL=Library:Create("TextLabel",{Name="Title",Parent=DText,
                AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,
                LayoutOrder=-1,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,0,14),
                ZIndex=500,Font=Enum.Font.GothamSemibold,RichText=true,
                Text=DTitle or "",TextColor3=T.Accent,TextSize=14,
                TextStrokeTransparency=0.7,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
            MkGrad(DTL)
            local D1=Library:Create("TextLabel",{Name="Desc",Parent=DText,
                AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,
                Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,0,11),
                ZIndex=500,Font=Enum.Font.GothamMedium,RichText=true,
                Text=GetText(),TextColor3=T.Text,TextSize=10,
                TextStrokeTransparency=0.7,TextTransparency=0.55,
                TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left})

            local SearchBox
            if ShowSearch then
                local SIF=Library:Create("Frame",{Name="SIF",Parent=DF,BackgroundTransparency=1,
                    BorderSizePixel=0,LayoutOrder=-4,Size=UDim2.new(1,0,0,26),ZIndex=500})
                Library:Create("UIListLayout",{Parent=SIF,Padding=UDim.new(0,5),
                    FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,
                    VerticalAlignment=Enum.VerticalAlignment.Center})
                local SF=Library:Create("Frame",{Name="SF",Parent=SIF,
                    BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=500})
                Library:Create("UICorner",{Parent=SF,CornerRadius=UDim.new(0,3)})
                Library:Create("UIStroke",{Parent=SF,Color=T.Stroke,Thickness=0.5})
                SearchBox=Library:Create("TextBox",{Name="Search",Parent=SF,
                    AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,
                    CursorPosition=-1,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,-16,1,0),
                    ZIndex=500,Font=Enum.Font.GothamMedium,PlaceholderColor3=Color3.fromRGB(60,60,60),
                    PlaceholderText="Search...",Text="",TextColor3=T.Text,TextSize=11,
                    TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ClearTextOnFocus=false})
            end

            local List1=Library:Create("ScrollingFrame",{Name="List",Parent=DF,
                BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,ShowSearch and 150 or 163),ZIndex=500,ScrollBarThickness=0})
            local SL=Library:Create("UIListLayout",{Parent=List1,Padding=UDim.new(0,3),
                SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center})
            Library:Create("UIPadding",{Parent=List1,PaddingLeft=UDim.new(0,1),PaddingRight=UDim.new(0,1)})
            SL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                List1.CanvasSize=UDim2.new(0,0,0,SL.AbsoluteContentSize.Y+12)
            end)

            local selVals={}; local selOrd=0
            local function isInT(val,tbl) if type(tbl)~="table" then return false end; for _,v in pairs(tbl) do if v==val then return true end end; return false end
            local function SetText() local txt=IsMulti and table.concat(Value,", ") or tostring(Value); D1.Text=txt; if DescEl then DescEl.Text=txt end end
            local isOpen=false
            UserInputService.InputBegan:Connect(function(A)
                if not isOpen then return end
                if A.UserInputType~=Enum.UserInputType.MouseButton1 and A.UserInputType~=Enum.UserInputType.Touch then return end
                local m=LocalPlayer:GetMouse(); local dp,ds=DF.AbsolutePosition,DF.AbsoluteSize
                if not(m.X>=dp.X and m.X<=dp.X+ds.X and m.Y>=dp.Y and m.Y<=dp.Y+ds.Y) then
                    isOpen=false; DF.Visible=false; DF.Position=UDim2.new(0.5,0,0.3,0)
                end
            end)
            Open.MouseButton1Click:Connect(function()
                if _locked then return end
                if Library:IsDropdownOpen() and not isOpen then return end
                isOpen=not isOpen
                if isOpen then
                    DF.Visible=true
                    Library:Tween({v=DF,t=0.28,s="Back",d="Out",g={Position=UDim2.new(0.5,0,0.5,0)}}):Play()
                else DF.Visible=false; DF.Position=UDim2.new(0.5,0,0.3,0) end
            end)

            local Setting={}
            function Setting:Close() isOpen=false; DF.Visible=false; DF.Position=UDim2.new(0.5,0,0.3,0) end
            function Setting:Clear(a)
                for _,v in ipairs(List1:GetChildren()) do
                    if v:IsA("Frame") then
                        local s=a==nil or (type(a)=="string" and v:FindFirstChild("Title") and v.Title.Text==a)
                            or (type(a)=="table" and v:FindFirstChild("Title") and isInT(v.Title.Text,a))
                        if s then v:Destroy() end
                    end
                end
                if a==nil then Value=IsMulti and {} or nil; selVals={}; selOrd=0; D1.Text=Placeholder; if DescEl then DescEl.Text=Placeholder end end
            end
            function Setting:SetList(nl) Setting:Clear(); List=nl; for _,n in ipairs(nl) do Setting:AddList(n) end end
            function Setting:SetValue(val)
                if IsMulti then
                    if type(val)~="table" then val={val} end; Value=val; selVals={}; selOrd=0
                    for _,v in pairs(List1:GetChildren()) do
                        if v:IsA("Frame") and v.Name=="Item" and v:FindFirstChild("Title") then
                            local s=isInT(v.Title.Text,val); v.Title.TextColor3=s and T.Accent or T.Text; v.BackgroundTransparency=s and 0.82 or 1
                            if s then selOrd=selOrd-1; selVals[v.Title.Text]=selOrd; v.LayoutOrder=selOrd else v.LayoutOrder=0 end
                        end
                    end; SetText(); pcall(Callback,val)
                else
                    Value=val
                    for _,v in pairs(List1:GetChildren()) do
                        if v:IsA("Frame") and v.Name=="Item" and v:FindFirstChild("Title") then
                            v.Title.TextColor3=v.Title.Text==tostring(val) and T.Accent or T.Text
                            v.BackgroundTransparency=v.Title.Text==tostring(val) and 0.82 or 1
                        end
                    end; SetText(); pcall(Callback,val)
                end
            end
            function Setting:AddList(Name)
                local Item=Library:Create("Frame",{Name="Item",Parent=List1,
                    BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=1,
                    BorderSizePixel=0,LayoutOrder=0,Size=UDim2.new(1,0,0,26),ZIndex=500})
                Library:Create("UICorner",{Parent=Item,CornerRadius=UDim.new(0,3)})
                Library:Create("UIPadding",{Parent=Item,PaddingLeft=UDim.new(0,8)})
                local IT=Library:Create("TextLabel",{Name="Title",Parent=Item,
                    AnchorPoint=Vector2.new(0,0.5),BackgroundTransparency=1,BorderSizePixel=0,
                    Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,-8,0,13),
                    ZIndex=500,Font=Enum.Font.GothamMedium,RichText=true,
                    Text=tostring(Name),TextColor3=T.Text,TextSize=12,
                    TextStrokeTransparency=0.7,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false,
                    TextTruncate=Enum.TextTruncate.AtEnd})
                local function OV(v) IT.TextColor3=v and T.Accent or T.Text; Library:Tween({v=Item,t=0.18,s="Linear",d="Out",g={BackgroundTransparency=v and 0.82 or 1}}):Play() end
                local IC=Library:Button(Item)
                local function OnSel()
                    if IsMulti then
                        if selVals[Name] then selVals[Name]=nil; Item.LayoutOrder=0; OV(false)
                        else selOrd=selOrd-1; selVals[Name]=selOrd; Item.LayoutOrder=selOrd; OV(true) end
                        local s={}; for i in pairs(selVals) do table.insert(s,i) end
                        if #s>0 then table.sort(s); Value=s; SetText() else D1.Text=Placeholder; if DescEl then DescEl.Text=Placeholder end end
                        pcall(Callback,s)
                    else
                        for _,v in pairs(List1:GetChildren()) do
                            if v:IsA("Frame") and v.Name=="Item" then v.Title.TextColor3=T.Text; Library:Tween({v=v,t=0.18,s="Linear",d="Out",g={BackgroundTransparency=1}}):Play() end
                        end
                        OV(true); Value=Name; SetText(); pcall(Callback,Value)
                    end
                end
                delay(0,function()
                    if IsMulti then
                        if isInT(Name,Value) then
                            selOrd=selOrd-1; selVals[Name]=selOrd; Item.LayoutOrder=selOrd; OV(true)
                            local s={}; for i in pairs(selVals) do table.insert(s,i) end
                            if #s>0 then table.sort(s); SetText() else D1.Text=Placeholder; if DescEl then DescEl.Text=Placeholder end end
                        end
                    else if Name==Value then OV(true); SetText() end end
                end)
                IC.MouseButton1Click:Connect(OnSel); return Item
            end
            function Setting:RemoveItem(Name)
                for _,v in ipairs(List1:GetChildren()) do
                    if v:IsA("Frame") and v.Name=="Item" and v:FindFirstChild("Title") and v.Title.Text==tostring(Name) then v:Destroy(); return true end
                end; return false
            end
            function Setting:GetValue()    return Value end
            function Setting:SetTitle(t)   DTL.Text=tostring(t) end
            function Setting:SetPlaceholder(p) Placeholder=p; if SearchBox then SearchBox.PlaceholderText=p end end
            function Setting:Destroy()     Rows:Destroy(); DF:Destroy() end
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
            for _,n in ipairs(List) do Setting:AddList(n) end
            return Setting
        end

        function Page:Keybind(Args)
            local KTitle=Args.Title; local KDesc=Args.Desc
            local Value=Args.Value or Enum.KeyCode.Unknown
            local Callback=Args.Callback or function()end
            local Rows=Library:NewRows(PS,KTitle,KDesc,T)
            local Right=Rows.Right; local Left=Rows.Left

            local KB=Library:Create("Frame",{Name="KeyBind",Parent=Right,
                BackgroundColor3=T.RowAlt,BorderSizePixel=0,Size=UDim2.new(0,82,0,24),ClipsDescendants=true})
            Library:Create("UICorner",{Parent=KB,CornerRadius=UDim.new(0,4)})
            Library:Create("UIStroke",{Parent=KB,Color=T.Stroke,Thickness=0.5})
            local KL=Library:Create("TextLabel",{Parent=KB,
                AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,
                Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,-8,1,0),
                Font=Enum.Font.GothamSemibold,Text=tostring(Value.Name),
                TextColor3=T.Accent,TextSize=11,
                TextTruncate=Enum.TextTruncate.AtEnd,TextWrapped=false})
            tA(KL,"TextColor3")

            local CBK=Library:Button(KB); local listening=false; local Data={Value=Value}
            local function SetKey(k)
                Data.Value=k; KL.Text=tostring(k.Name); KL.TextColor3=T.Accent
                Library:Tween({v=KB,t=0.2,s="Exponential",d="Out",g={BackgroundColor3=T.RowAlt}}):Play()
                pcall(Callback,k)
            end
            CBK.MouseButton1Click:Connect(function()
                if _locked or Library:IsDropdownOpen() then return end
                if listening then return end; listening=true; KL.Text="..."; KL.TextColor3=T.Text
                Library:Tween({v=KB,t=0.2,s="Exponential",d="Out",g={BackgroundColor3=T.Stroke}}):Play()
                local conn; conn=UserInputService.InputBegan:Connect(function(inp,proc)
                    if proc then return end
                    if inp.UserInputType==Enum.UserInputType.Keyboard then listening=false; conn:Disconnect(); SetKey(inp.KeyCode) end
                end)
            end)
            UserInputService.InputBegan:Connect(function(inp,proc)
                if proc or listening then return end
                if inp.KeyCode==Data.Value then pcall(Callback,Data.Value) end
            end)
            local lov=LockOv(Rows,Args.LockMessage)
            local obj={}
            function obj:SetTitle(v) local t=Left:FindFirstChild("Title"); if t then t.Text=tostring(v) end end
            function obj:SetDesc(v)  local d=Left:FindFirstChild("Desc");  if d then d.Text=tostring(v) end end
            function obj:SetValue(v) SetKey(v) end
            function obj:GetValue()  return Data.Value end
            function obj:Lock(m)   lov.Visible=true; if m then lov:FindFirstChildWhichIsA("TextLabel",true).Text=m end end
            function obj:Unlock()  lov.Visible=false end
            function obj:Destroy() Rows:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v) rawset(t,k,v); if k=="Value" then SetKey(v) end end,
                __index=function(t,k) if k=="Value" then return Data.Value end; return rawget(t,k) end
            })
            return obj
        end

        function Page:ColorPicker(Args)
            local CPTitle=Args.Title; local CPDesc=Args.Desc
            local Value=Args.Value or Color3.fromRGB(255,255,255)
            local Callback=Args.Callback or function()end
            if typeof(Value)=="string" then Value=RC(Value) end
            local Rows=Library:NewRows(PS,CPTitle,CPDesc,T)
            local Right=Rows.Right; local Left=Rows.Left

            local Swatch=Library:Create("Frame",{Name="Swatch",Parent=Right,
                BackgroundColor3=Value,BorderSizePixel=0,Size=UDim2.new(0,42,0,22)})
            Library:Create("UICorner",{Parent=Swatch,CornerRadius=UDim.new(0,4)})
            Library:Create("UIStroke",{Parent=Swatch,Color=T.Stroke,Thickness=0.5})
            local SC=Library:Button(Swatch)

            local PF,getColor,setColorFn=BuildColorPicker(Background,Value,function(c)
                Value=c; Swatch.BackgroundColor3=c
                local d=Left:FindFirstChild("Desc")
                if d then d.Text=string.format("#%02X%02X%02X",math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255)) end
                pcall(Callback,c)
            end)
            SC.MouseButton1Click:Connect(function()
                if _locked then return end
                PF.Visible=not PF.Visible
                if PF.Visible then Library:Tween({v=PF,t=0.25,s="Back",d="Out",g={Position=UDim2.new(0.5,0,0.5,0)}}):Play() end
            end)

            local lov=LockOv(Rows,Args.LockMessage)
            local obj={}
            function obj:SetTitle(v) local t=Left:FindFirstChild("Title"); if t then t.Text=tostring(v) end end
            function obj:SetDesc(v)  local d=Left:FindFirstChild("Desc");  if d then d.Text=tostring(v) end end
            function obj:SetValue(v) if typeof(v)=="string" then v=RC(v) end; Value=v; Swatch.BackgroundColor3=v; setColorFn(v) end
            function obj:GetValue()  return getColor() end
            function obj:Lock(m)   lov.Visible=true; if m then lov:FindFirstChildWhichIsA("TextLabel",true).Text=m end end
            function obj:Unlock()  lov.Visible=false end
            function obj:Destroy() Rows:Destroy(); PF:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v)
                    rawset(t,k,v)
                    if k=="Title" then local tl=Left:FindFirstChild("Title"); if tl then tl.Text=tostring(v) end
                    elseif k=="Desc" then local dl=Left:FindFirstChild("Desc"); if dl then dl.Text=tostring(v) end
                    elseif k=="Value" then if typeof(v)=="string" then v=RC(v) end; Value=v; Swatch.BackgroundColor3=v; setColorFn(v) end
                end,
                __index=function(t,k) if k=="Value" then return getColor() end; return rawget(t,k) end
            })
            return obj
        end

        function Page:Banner(Assets)
            local B=Library:Create("ImageLabel",{Name="Banner",Parent=PS,
                BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,220),
                Image=Library:Asset(Assets),ScaleType=Enum.ScaleType.Crop})
            Library:Create("UICorner",{Parent=B,CornerRadius=UDim.new(0,4)})
            local obj={}
            function obj:SetImage(v) B.Image=Library:Asset(v) end
            function obj:SetSize(v)  B.Size=v end
            function obj:Destroy()   B:Destroy() end
            setmetatable(obj,{__newindex=function(t,k,v)
                rawset(t,k,v)
                if k=="Image" then B.Image=Library:Asset(v)
                elseif k=="Visible" then B.Visible=v
                elseif k=="Size" then B.Size=v end
            end})
            return obj
        end

        function Page:Divider()
            return Library:Create("Frame",{Name="Divider",Parent=PS,
                BackgroundColor3=T.Stroke,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,1),BackgroundTransparency=0.4})
        end

        function Page:Label(Args)
            local Rows=Library:NewRows(PS,Args.Title,Args.Desc,T)
            local Left=Rows.Left
            local obj={}
            function obj:SetTitle(v) local t=Left:FindFirstChild("Title"); if t then t.Text=tostring(v) end end
            function obj:SetDesc(v)  local d=Left:FindFirstChild("Desc");  if d then d.Text=tostring(v) end end
            function obj:Destroy() Rows:Destroy() end
            setmetatable(obj,{__newindex=function(t,k,v)
                rawset(t,k,v)
                if k=="Title" then local tl=Left:FindFirstChild("Title"); if tl then tl.Text=tostring(v) end
                elseif k=="Desc" then local dl=Left:FindFirstChild("Desc"); if dl then dl.Text=tostring(v) end end
            end})
            return obj
        end

        function Page:Progress(Args)
            local PTitle=Args.Title; local PDesc=Args.Desc
            local Value=math.clamp(Args.Value or 0,0,100)
            local Max=Args.Max or 100; local Suffix=Args.Suffix or "%"
            local Color=Args.Color and RC(Args.Color) or nil

            local SF=Library:Create("Frame",{Name="Progress",Parent=PS,
                BackgroundColor3=T.Row,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,48),Selectable=false})
            Library:Create("UICorner",{Parent=SF,CornerRadius=UDim.new(0,4)})
            Library:Create("UIStroke",{Parent=SF,Color=T.Stroke,Thickness=0.5})
            Library:Create("UIPadding",{Parent=SF,PaddingBottom=UDim.new(0,4),
                PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12),PaddingTop=UDim.new(0,4)})

            local TopRow=Library:Create("Frame",{Parent=SF,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,20)})
            Library:Create("UIListLayout",{Parent=TopRow,FillDirection=Enum.FillDirection.Horizontal,
                VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder})
            local TitleLbl=Library:Create("TextLabel",{Name="Title",Parent=TopRow,
                BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(1,-60,0,14),LayoutOrder=1,
                Font=Enum.Font.GothamSemibold,Text=PTitle or "",TextColor3=T.Text,TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false})
            if PTitle and PTitle~="" then MkGrad(TitleLbl) end
            local ValLbl=Library:Create("TextLabel",{Name="Value",Parent=TopRow,
                BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0,60,0,14),LayoutOrder=2,
                Font=Enum.Font.GothamMedium,Text=tostring(Value)..Suffix,
                TextColor3=T.SubText,TextSize=11,TextTransparency=0.3,
                TextXAlignment=Enum.TextXAlignment.Right,TextWrapped=false})

            local BarBg=Library:Create("Frame",{Parent=SF,
                AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,-4),
                BackgroundColor3=Color3.fromRGB(18,18,18),BorderSizePixel=0,
                Size=UDim2.new(1,0,0,7)})
            Library:Create("UICorner",{Parent=BarBg,CornerRadius=UDim.new(0,4)})
            local BarFill=Library:Create("Frame",{Parent=BarBg,
                BackgroundColor3=Color or T.Accent,BorderSizePixel=0,
                Size=UDim2.new(Value/Max,0,1,0)})
            Library:Create("UICorner",{Parent=BarFill,CornerRadius=UDim.new(0,4)})
            BtnGrad(BarFill)
            if not Color then tA(BarFill,"BackgroundColor3") end

            local Data={Value=Value}
            local function SetVal(v)
                v=math.clamp(v,0,Max); Data.Value=v
                Library:Tween({v=BarFill,t=0.35,s="Exponential",d="Out",g={Size=UDim2.new(v/Max,0,1,0)}}):Play()
                ValLbl.Text=tostring(math.floor(v))..Suffix
            end

            local obj={}
            function obj:SetValue(v) SetVal(v) end
            function obj:GetValue()  return Data.Value end
            function obj:SetTitle(v) TitleLbl.Text=tostring(v) end
            function obj:SetColor(v) BarFill.BackgroundColor3=RC(v) end
            function obj:Destroy()   SF:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v)
                    rawset(t,k,v)
                    if k=="Value" then SetVal(v)
                    elseif k=="Title" then TitleLbl.Text=tostring(v) end
                end,
                __index=function(t,k)
                    if k=="Value" then return Data.Value end; return rawget(t,k)
                end
            })
            return obj
        end

        function Page:MultiButton(Args)
            local MTitle=Args.Title; local Buttons=Args.Buttons or {}

            local SF=Library:Create("Frame",{Name="MultiBtn",Parent=PS,
                BackgroundColor3=T.Row,BorderSizePixel=0,
                Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y})
            Library:Create("UICorner",{Parent=SF,CornerRadius=UDim.new(0,4)})
            Library:Create("UIStroke",{Parent=SF,Color=T.Stroke,Thickness=0.5})
            Library:Create("UIPadding",{Parent=SF,PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,10),
                PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})
            Library:Create("UIListLayout",{Parent=SF,FillDirection=Enum.FillDirection.Vertical,
                SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8)})

            if MTitle and MTitle~="" then
                local TL=Library:Create("TextLabel",{Name="Title",Parent=SF,
                    BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=1,
                    Size=UDim2.new(1,0,0,14),Font=Enum.Font.GothamSemibold,RichText=true,
                    Text=MTitle,TextColor3=T.Text,TextSize=13,TextStrokeTransparency=0.7,
                    TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false})
                MkGrad(TL)
            end

            local BtnRow=Library:Create("Frame",{Parent=SF,BackgroundTransparency=1,BorderSizePixel=0,
                LayoutOrder=2,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y})
            Library:Create("UIListLayout",{Parent=BtnRow,FillDirection=Enum.FillDirection.Horizontal,
                SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6),
                VerticalAlignment=Enum.VerticalAlignment.Center,Wraps=true})

            for _,bd in ipairs(Buttons) do
                local Btn=Library:Create("TextButton",{Parent=BtnRow,
                    BackgroundColor3=bd.Color and RC(bd.Color) or T.Accent,BorderSizePixel=0,
                    Size=UDim2.new(0,0,0,28),AutomaticSize=Enum.AutomaticSize.X,
                    Font=Enum.Font.GothamSemibold,Text=bd.Text or "Btn",
                    TextColor3=T.Text,TextSize=11,ClipsDescendants=true,AutoButtonColor=false})
                Library:Create("UICorner",{Parent=Btn,CornerRadius=UDim.new(0,4)})
                Library:Create("UIPadding",{Parent=Btn,PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})
                if not bd.Color then tA(Btn,"BackgroundColor3") end
                BtnGrad(Btn)
                Btn.MouseButton1Click:Connect(function()
                    if _locked then return end
                    Ripple(Btn)
                    if bd.Callback then pcall(bd.Callback) end
                end)
            end

            local obj={}
            function obj:Destroy() SF:Destroy() end
            return obj
        end

        function Page:ConfigManager(Args)
            Args=Args or {}
            local Cfg=Library.Config
            local OnLoad=Args.OnLoad or function()end
            local AutoKey=Args.AutoLoadKey or "__vitaauto__"

            Page:Section(Args.SectionTitle or "Config Manager")

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
            local nameInput=Page:Input({Placeholder="Config name...",Value=Cfg:Active() or ""})

            local BRF=Library:Create("Frame",{Name="CfgBtnRow",Parent=PS,
                BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,36)})
            Library:Create("UIListLayout",{Parent=BRF,FillDirection=Enum.FillDirection.Horizontal,
                Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,
                VerticalAlignment=Enum.VerticalAlignment.Center,
                HorizontalAlignment=Enum.HorizontalAlignment.Left})

            local function CB(text,color,cb)
                local b=Library:Create("TextButton",{Parent=BRF,
                    BackgroundColor3=color,BorderSizePixel=0,
                    Size=UDim2.new(0,0,0,32),AutomaticSize=Enum.AutomaticSize.X,
                    Font=Enum.Font.GothamSemibold,Text=text,
                    TextColor3=Color3.fromRGB(255,255,255),TextSize=12,
                    ClipsDescendants=true,AutoButtonColor=false})
                Library:Create("UICorner",{Parent=b,CornerRadius=UDim.new(0,4)})
                Library:Create("UIPadding",{Parent=b,PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)})
                b.MouseButton1Click:Connect(function() Ripple(b); if cb then pcall(cb) end end)
                return b
            end

            CB("Save",T.Accent,function()
                local name=nameInput:GetValue(); if name=="" then name=Cfg:Active() end
                if not name or name=="" then Library:Notification({Title="Config",Desc="Enter a config name.",Duration=2,Type="Warning"}); return end
                local ok,err=Cfg:Create(name)
                if not ok then Library:Notification({Title="Config",Desc=err or "Already exists.",Duration=2,Type="Warning"}); return end
                Cfg:Save(name); Refresh(); Library:Notification({Title="Saved",Desc='"'..name..'" saved.',Duration=2,Type="Success"})
            end)
            CB("Overwrite",Color3.fromRGB(200,140,30),function()
                local name=cfgDrop:GetValue() or nameInput:GetValue()
                if not name or name=="" or not Cfg:Exists(name) then Library:Notification({Title="Config",Desc="Select an existing config.",Duration=2,Type="Warning"}); return end
                Cfg:Overwrite(name); Refresh(); Library:Notification({Title="Overwritten",Desc='"'..name..'" updated.',Duration=2,Type="Success"})
            end)
            CB("Load",Color3.fromRGB(55,120,220),function()
                local name=cfgDrop:GetValue() or nameInput:GetValue()
                if not name or name=="" then Library:Notification({Title="Config",Desc="Select a config first.",Duration=2,Type="Warning"}); return end
                if Cfg:Load(name) then pcall(OnLoad,Cfg:GetData(name)); Library:Notification({Title="Loaded",Desc='"'..name..'" loaded.',Duration=2,Type="Success"})
                else Library:Notification({Title="Error",Desc="Config not found.",Duration=2,Type="Error"}) end
            end)
            CB("Delete",Color3.fromRGB(205,45,45),function()
                local name=cfgDrop:GetValue() or nameInput:GetValue()
                if not name or name=="" then return end
                Window:Dialog({Title="Delete Config",Desc='Delete "'..name..'"?',ConfirmText="Delete",
                    OnConfirm=function() Cfg:Delete(name); Refresh(); Library:Notification({Title="Deleted",Desc='"'..name..'" deleted.',Duration=2,Type="Info"}) end
                })
            end)
            CB("Auto",Color3.fromRGB(55,165,55),function()
                local name=cfgDrop:GetValue() or nameInput:GetValue()
                if not name or name=="" then Library:Notification({Title="Config",Desc="Select a config.",Duration=2,Type="Warning"}); return end
                if Cfg:Exists("__vitaauto__") then Cfg:Overwrite("__vitaauto__",{target=name})
                else Cfg:Create("__vitaauto__",{target=name}) end
                Library:Notification({Title="Auto Load",Desc='"'..name..'" on next run.',Duration=3,Type="Success"})
            end)

            if Cfg:Exists(AutoKey) then
                local tgt=Cfg:GetValue("target",AutoKey)
                if tgt and Cfg:Exists(tgt) then
                    task.delay(0.2,function() if Cfg:Load(tgt) then pcall(OnLoad,Cfg:GetData(tgt)) end end)
                end
            end
        end

        return Page
    end

    function Library:SetTimeValue(v)      THETIME.Text=tostring(v) end
    function Library:SetWindowTitle(v)    if TitleLabel then TitleLabel.Text=tostring(v) end end
    function Library:SetWindowSubTitle(v) if SubTitleLabel then SubTitleLabel.Text=tostring(v) end end

    function Library:AddSizeSlider(Page)
        return Page:Slider({
            Title="Interface Scale",
            Min=0.35,Max=math.floor(MaxSc()*10+0.5)/10,
            Rounding=2,Value=Scaler.Scale,
            Callback=function(v)
                Scaler:SetAttribute("ManualScale",true)
                Scaler.Scale=CS(v)
            end
        })
    end

    function Library:SetTheme(nt)
        if nt.BG then nt.Background=nt.BG; nt.BG=nil end
        if nt.Tab then nt.TabBg=nt.Tab; nt.Tab=nil end
        for k,v in pairs(nt) do T[k]=RC(v) end
        for _,r in ipairs(aRefs)  do local i,p=r[1],r[2]; if i and i.Parent then pcall(function() i[p]=T.Accent     end) end end
        for _,r in ipairs(bRefs)  do local i,p=r[1],r[2]; if i and i.Parent then pcall(function() i[p]=T.Background end) end end
        for _,r in ipairs(tiRefs) do local i,p=r[1],r[2]; if i and i.Parent then pcall(function() i[p]=T.TabImage   end) end end
        for _,r in ipairs(tbRefs) do local i,p=r[1],r[2]; if i and i.Parent then pcall(function() i[p]=T.TabBg      end) end end
        for _,r in ipairs(tsRefs) do local i,p=r[1],r[2]; if i and i.Parent then pcall(function() i[p]=T.TabStroke  end) end end
    end

    function Library:GetTheme() local c={}; for k,v in pairs(T) do c[k]=v end; return c end
    function Library:SetPillIcon(icon) local L=Xova:FindFirstChild("Pillow",true); if L then L.Image=Library:Asset(icon) end end
    function Library:SetExecutorIdentity(v) if AvatarBtn then AvatarBtn.Visible=v==true end end
    function Library:SetLockText(msg) _lockMsg=msg end
    function Library:Lock()    _locked=true end
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
