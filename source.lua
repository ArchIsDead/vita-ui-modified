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

local Exec = { name="Unknown", clipboard=false, readfile=false, writefile=false, listfiles=false, makefolder=false, httpGet=false, gethui=false }
do
    if getexecutorname then local ok,n=pcall(getexecutorname); if ok and n and n~="" then Exec.name=n end
    elseif identifyexecutor then local ok,n=pcall(identifyexecutor); if ok and n and n~="" then Exec.name=n end end
    Exec.clipboard   = type(setclipboard)=="function" or type(toclipboard)=="function"
    Exec.readfile    = type(readfile)=="function"
    Exec.writefile   = type(writefile)=="function"
    Exec.listfiles   = type(listfiles)=="function"
    Exec.makefolder  = type(makefolder)=="function"
    Exec.httpGet     = type(game.HttpGet)=="function" or (type(syn)=="table" and type(syn.request)=="function")
    Exec.gethui      = type(gethui)=="function"
end
Library.Exec = Exec

local function VClip(txt)
    if setclipboard then pcall(setclipboard,txt) elseif toclipboard then pcall(toclipboard,txt) end
end

local Cfg = {}
do
    local _folder = "VitaConfigs"
    local _active = nil
    local _mem    = {}

    local function fpath(name) return _folder.."/"..name..".json" end

    local function fdisk_write(name, data)
        if not Exec.writefile then return false end
        if Exec.makefolder then pcall(makefolder,_folder) end
        local ok,j = pcall(HttpService.JSONEncode,HttpService,data)
        if not ok then return false end
        local ok2 = pcall(writefile,fpath(name),j)
        return ok2
    end

    local function fdisk_read(name)
        if not Exec.readfile then return nil end
        local ok,raw = pcall(readfile,fpath(name))
        if not ok or not raw or raw=="" then return nil end
        local ok2,data = pcall(HttpService.JSONDecode,HttpService,raw)
        if not ok2 then return nil end
        return data
    end

    local function fdisk_delete(name)
        if not Exec.writefile then return end
        pcall(writefile,fpath(name),"")
    end

    local function fdisk_list()
        local t = {}
        if not Exec.listfiles then
            for k in pairs(_mem) do table.insert(t,k) end
            table.sort(t); return t
        end
        if Exec.makefolder then pcall(makefolder,_folder) end
        local ok,files = pcall(listfiles,_folder)
        if ok and files then
            for _,f in ipairs(files) do
                local name = f:match("([^/\\]+)%.json$")
                if name then table.insert(t,name) end
            end
        end
        table.sort(t); return t
    end

    function Cfg:SetFolder(n) _folder=n end
    function Cfg:GetFolder()  return _folder end
    function Cfg:ActiveCfg()  return _active end
    function Cfg:Exists(n)    return _mem[n]~=nil or (Exec.readfile and fdisk_read(n)~=nil) end
    function Cfg:GetData(n)   return _mem[n or _active] end

    function Cfg:addcfg(name, data)
        if not name or name=="" then return false end
        data = data or {}
        _mem[name] = data
        fdisk_write(name, data)
        return true
    end

    function Cfg:delcfg(name)
        if not name or not _mem[name] then return false end
        _mem[name] = nil
        if _active == name then _active = nil end
        fdisk_delete(name)
        return true
    end

    function Cfg:loadcfg(name)
        if not name then return nil end
        if not _mem[name] then
            local d = fdisk_read(name)
            if d then _mem[name] = d else return nil end
        end
        _active = name
        return _mem[name]
    end

    function Cfg:updcfg(name, data)
        name = name or _active
        if not name then return false end
        if not _mem[name] then
            if data then _mem[name] = data else return false end
        elseif data then
            for k,v in pairs(data) do _mem[name][k]=v end
        end
        fdisk_write(name, _mem[name])
        return true
    end

    function Cfg:autoloadcfg(onLoaded)
        local markerFile = _folder.."/._autoload"
        if not Exec.readfile then return end
        if Exec.makefolder then pcall(makefolder,_folder) end
        local ok,raw = pcall(readfile,markerFile)
        if not ok or not raw or raw=="" then return end
        local name = raw:match("^(.-)%s*$")
        if not name or name=="" then return end
        local data = self:loadcfg(name)
        if data and onLoaded then pcall(onLoaded,name,data) end
    end

    function Cfg:setautoload(name)
        if not Exec.writefile then return false end
        if Exec.makefolder then pcall(makefolder,_folder) end
        local ok = pcall(writefile,_folder.."/._autoload",name)
        return ok
    end

    function Cfg:clearautoload()
        if not Exec.writefile then return end
        pcall(writefile,_folder.."/._autoload","")
    end

    function Cfg:listcfg()
        return fdisk_list()
    end

    function Cfg:setval(key, val, name)
        name = name or _active
        if not name then return false end
        if not _mem[name] then _mem[name]={} end
        _mem[name][key] = val
        fdisk_write(name, _mem[name])
        return true
    end

    function Cfg:getval(key, name)
        local d = _mem[name or _active]
        return d and d[key] or nil
    end

    function Cfg:exportcfg(name)
        local d = _mem[name or _active]
        if not d then return nil end
        local ok,j = pcall(HttpService.JSONEncode,HttpService,d)
        return ok and j or nil
    end

    function Cfg:importcfg(name, json)
        local ok,d = pcall(HttpService.JSONDecode,HttpService,json)
        if not ok then return false end
        return self:addcfg(name,d)
    end

end
Library.Cfg = Cfg

function Library:Parent()
    if not RunService:IsStudio() then
        if Exec.gethui then local ok,h=pcall(gethui); if ok then return h end end
        return PlayerGui
    end
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

function Library:Create(c,p)
    local i=Instance.new(c)
    for k,v in p do i[k]=v end
    return i
end

function Library:Tween(info)
    return TweenService:Create(info.v,TweenInfo.new(info.t,Enum.EasingStyle[info.s],Enum.EasingDirection[info.d]),info.g)
end

function Library:Draggable(handle,target)
    target=target or handle
    local drag,dI,dS,sP=false,nil,nil,nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            drag=true; dS=inp.Position; sP=target.Position
            inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then drag=false end end)
        end
    end)
    handle.InputChanged:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then dI=inp end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp==dI and drag then
            local d=inp.Position-dS
            target.Position=UDim2.new(sP.X.Scale,sP.X.Offset+d.X,sP.Y.Scale,sP.Y.Offset+d.Y)
        end
    end)
end

function Library:Button(parent)
    return Library:Create("TextButton",{Name="Click",Parent=parent,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),Font=Enum.Font.SourceSans,Text="",TextColor3=Color3.fromRGB(0,0,0),TextSize=14,ZIndex=parent.ZIndex+3})
end

function Library:Asset(rbx)
    if rbx==nil then return "" end
    if typeof(rbx)=="number" then return "rbxassetid://"..rbx end
    if typeof(rbx)=="string" then
        if rbx:match("^https?://") then return rbx end
        if rbx:find("rbxassetid://") then return rbx end
        if rbx:match("^%d+$") then return "rbxassetid://"..rbx end
        return rbx
    end
    return tostring(rbx)
end

local Lucide={}
if Exec.httpGet then
    task.spawn(function()
        local ok,res=pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/ArchIsDead/Arch-Vault/refs/heads/main/lucide-icons.lua"))()
        end)
        if ok and type(res)=="table" then
            for k,v in pairs(res) do Lucide[k]=v end
            local _orig=Library.Asset
            function Library:Asset(rbx)
                if type(rbx)=="string" then
                    if Lucide[rbx] then return Lucide[rbx] end
                    if Lucide["lucide-"..rbx] then return Lucide["lucide-"..rbx] end
                end
                return _orig(self,rbx)
            end
        end
    end)
end

local function MkGrad(p,r)
    Library:Create("UIGradient",{Parent=p,Rotation=r or 90,Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.75,Color3.fromRGB(200,200,200)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(150,150,150))}})
end

local function BtnGrad(p)
    Library:Create("UIGradient",{Parent=p,Rotation=90,Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(56,56,56))}})
end

local function Ripple(btn)
    if not btn or not btn.Parent then return end
    local m=Players.LocalPlayer:GetMouse()
    local rx=math.clamp(m.X-btn.AbsolutePosition.X,0,btn.AbsoluteSize.X)
    local ry=math.clamp(m.Y-btn.AbsolutePosition.Y,0,btn.AbsoluteSize.Y)
    local rip=Library:Create("Frame",{Parent=btn,BackgroundColor3=Color3.fromRGB(255,255,255),
        BackgroundTransparency=0.7,BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0,rx,0,ry),Size=UDim2.new(0,0,0,0),ZIndex=btn.ZIndex+2})
    Library:Create("UICorner",{Parent=rip,CornerRadius=UDim.new(1,0)})
    local maxD=math.max(btn.AbsoluteSize.X,btn.AbsoluteSize.Y)*2.2
    local t=TweenService:Create(rip,TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(0,maxD,0,maxD),BackgroundTransparency=1})
    t.Completed:Once(function() rip:Destroy() end); t:Play()
end

function Library:NewRows(parent,title,desc,T)
    local Frame=Library:Create("Frame",{Name="Rows",Parent=parent,BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.new(1,0,0,44)})
    Library:Create("UIStroke",{Parent=Frame,Color=T.Stroke,Thickness=0.5})
    Library:Create("UICorner",{Parent=Frame,CornerRadius=UDim.new(0,5)})
    local Left=Library:Create("Frame",{Name="Left",Parent=Frame,BackgroundTransparency=1,BorderSizePixel=0,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,14,0.5,0),Size=UDim2.new(1,-120,1,0)})
    Library:Create("UIListLayout",{Parent=Left,FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,2)})
    if title and title~="" then
        local TL=Library:Create("TextLabel",{Name="Title",Parent=Left,BackgroundTransparency=1,BorderSizePixel=0,
            LayoutOrder=1,Size=UDim2.new(1,0,0,14),Font=Enum.Font.GothamSemibold,RichText=true,Text=title,
            TextColor3=T.Text,TextSize=13,TextStrokeTransparency=0.7,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
        MkGrad(TL)
    else
        Library:Create("TextLabel",{Name="Title",Parent=Left,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(0,0,0,0),Text="",TextSize=1,Visible=false,LayoutOrder=1})
    end
    if desc and desc~="" then
        Library:Create("TextLabel",{Name="Desc",Parent=Left,BackgroundTransparency=1,BorderSizePixel=0,
            LayoutOrder=2,Size=UDim2.new(1,0,0,11),Font=Enum.Font.GothamMedium,RichText=true,Text=desc,
            TextColor3=T.SubText,TextSize=10,TextStrokeTransparency=0.7,TextTransparency=0.3,
            TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
    else
        Library:Create("TextLabel",{Name="Desc",Parent=Left,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(0,0,0,0),Text="",TextSize=1,Visible=false,LayoutOrder=2})
    end
    local Right=Library:Create("Frame",{Name="Right",Parent=Frame,BackgroundTransparency=1,BorderSizePixel=0,
        AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-14,0.5,0),Size=UDim2.new(0,0,0,36),AutomaticSize=Enum.AutomaticSize.X})
    Library:Create("UIListLayout",{Parent=Right,FillDirection=Enum.FillDirection.Horizontal,
        HorizontalAlignment=Enum.HorizontalAlignment.Right,VerticalAlignment=Enum.VerticalAlignment.Center,
        SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)})
    return {Frame=Frame,Left=Left,Right=Right}
end

local T_ACCENT_FALLBACK = Color3.fromRGB(100,149,237)

local NotifGui=Library:Create("ScreenGui",{Name="VitaNotifs",Parent=Library:Parent(),
    ZIndexBehavior=Enum.ZIndexBehavior.Global,DisplayOrder=999,IgnoreGuiInset=true,ResetOnSpawn=false})
local NotifHolder=Library:Create("Frame",{Name="Holder",Parent=NotifGui,BackgroundTransparency=1,
    AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-16,1,-16),Size=UDim2.new(0,280,1,-32)})
Library:Create("UIListLayout",{Parent=NotifHolder,VerticalAlignment=Enum.VerticalAlignment.Bottom,
    SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8)})

function Library:Notification(Args)
    local Title=Args.Title or "Notification"; local Desc=Args.Desc or ""; local Duration=Args.Duration or 3
    local ac=Args.Color and RC(Args.Color) or T_ACCENT_FALLBACK or Color3.fromRGB(100,149,237)
    local N=Library:Create("Frame",{Parent=NotifHolder,BackgroundColor3=Color3.fromRGB(14,14,14),
        BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1})
    Library:Create("UICorner",{Parent=N,CornerRadius=UDim.new(0,8)})
    Library:Create("UIStroke",{Parent=N,Color=Color3.fromRGB(38,38,38),Thickness=0.7})
    Library:Create("Frame",{Parent=N,BackgroundColor3=ac,BorderSizePixel=0,Size=UDim2.new(0,3,1,0),ZIndex=2})
    local C=Library:Create("Frame",{Parent=N,BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-16,1,0),AutomaticSize=Enum.AutomaticSize.Y})
    Library:Create("UIPadding",{Parent=C,PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),PaddingRight=UDim.new(0,6)})
    Library:Create("UIListLayout",{Parent=C,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)})
    local TR=Library:Create("Frame",{Parent=C,BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=1})
    Library:Create("UIListLayout",{Parent=TR,FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6),VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder})
    if Args.Icon then Library:Create("ImageLabel",{Parent=TR,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0,14,0,14),LayoutOrder=1,Image=Library:Asset(Args.Icon),ImageColor3=ac}) end
    Library:Create("TextLabel",{Parent=TR,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,-20,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2,Font=Enum.Font.GothamBold,Text=Title,TextColor3=ac,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,RichText=true,TextWrapped=true})
    Library:Create("TextLabel",{Parent=C,BackgroundTransparency=1,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,Size=UDim2.new(1,0,0,0),LayoutOrder=2,Font=Enum.Font.GothamMedium,Text=Desc,TextColor3=Color3.fromRGB(200,200,200),TextSize=11,TextTransparency=0.15,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
    local PBg=Library:Create("Frame",{Parent=C,BackgroundColor3=Color3.fromRGB(30,30,30),BorderSizePixel=0,Size=UDim2.new(1,0,0,2),LayoutOrder=3})
    Library:Create("UICorner",{Parent=PBg,CornerRadius=UDim.new(1,0)})
    local PFr=Library:Create("Frame",{Parent=PBg,BackgroundColor3=ac,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)})
    Library:Create("UICorner",{Parent=PFr,CornerRadius=UDim.new(1,0)})
    TweenService:Create(N,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{BackgroundTransparency=0}):Play()
    TweenService:Create(PFr,TweenInfo.new(Duration,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Size=UDim2.new(0,0,1,0)}):Play()
    task.delay(Duration,function() TweenService:Create(N,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play(); task.wait(0.35); N:Destroy() end)
    return N
end

function Library:Window(Args)
    local Title=Args.Title; local SubTitle=Args.SubTitle
    local ToggleKey=Args.ToggleKey or Enum.KeyCode.LeftControl
    local AutoScale=Args.AutoScale~=false; local BaseScale=Args.Scale or 1.45
    local CustomSize=Args.Size; local BbIcon=Args.BbIcon or "rbxassetid://104055321996495"
    local FolderName=Args.FolderName or "VitaConfigs"
    Cfg:SetFolder(FolderName)
    local RAW_W=CustomSize and CustomSize.X.Offset or 500
    local RAW_H=CustomSize and CustomSize.Y.Offset or 350
    local uT=Args.Theme or {}
    local T={
        Accent=RC(uT.Accent or Color3.fromRGB(255,0,127)),Background=RC(uT.Background or Color3.fromRGB(11,11,11)),
        Row=RC(uT.Row or Color3.fromRGB(18,18,18)),RowAlt=RC(uT.RowAlt or Color3.fromRGB(13,13,13)),
        Stroke=RC(uT.Stroke or Color3.fromRGB(32,32,32)),Text=RC(uT.Text or Color3.fromRGB(235,235,235)),
        SubText=RC(uT.SubText or Color3.fromRGB(148,148,148)),TabBg=RC(uT.TabBg or Color3.fromRGB(13,13,13)),
        TabStroke=RC(uT.TabStroke or Color3.fromRGB(75,0,38)),TabImage=RC(uT.TabImage or uT.Accent or Color3.fromRGB(255,0,127)),
        DropBg=RC(uT.DropBg or Color3.fromRGB(16,16,16)),PillBg=RC(uT.PillBg or Color3.fromRGB(11,11,11)),
    }
    T_ACCENT_FALLBACK=T.Accent
    local _R={a={},bg={},row={},alt={},str={},txt={},sub={},tb={},ts={},ti={},db={}}
    local function rA(i,p)   table.insert(_R.a,  {i,p}); return i end
    local function rB(i,p)   table.insert(_R.bg, {i,p}); return i end
    local function rAlt(i,p) table.insert(_R.alt,{i,p}); return i end
    local function rTxt(i,p) table.insert(_R.txt,{i,p}); return i end
    local function rTB(i,p)  table.insert(_R.tb, {i,p}); return i end
    local function rTS(i,p)  table.insert(_R.ts, {i,p}); return i end
    local function rTI(i,p)  table.insert(_R.ti, {i,p}); return i end
    local function rDB(i,p)  table.insert(_R.db, {i,p}); return i end

    local Xova=Library:Create("ScreenGui",{Name="Xova",Parent=Library:Parent(),ZIndexBehavior=Enum.ZIndexBehavior.Global,DisplayOrder=10,IgnoreGuiInset=true,ResetOnSpawn=false})
    local function GetVP() local c=workspace.CurrentCamera; return c and c.ViewportSize or Vector2.new(1280,720) end
    local function MaxSc() local v=GetVP(); return math.min((v.X*.95)/RAW_W,(v.Y*.95)/RAW_H) end
    local function CS(s)   return math.clamp(s,0.35,MaxSc()) end
    local function ASV()   local v=GetVP(); return CS(math.min(v.X/1920,v.Y/1080)*BaseScale*1.5) end
    local Scaler=Library:Create("UIScale",{Parent=Xova,Scale=Mobile and CS(1) or (AutoScale and ASV() or CS(BaseScale))})
    if AutoScale and not Mobile then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if not Scaler:GetAttribute("ManualScale") then Scaler.Scale=ASV() end
        end)
    end

    local Background=Library:Create("Frame",{Name="Background",Parent=Xova,AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundColor3=T.Background,BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,RAW_W,0,RAW_H)})
    rB(Background,"BackgroundColor3")
    Library:Create("UICorner",{Parent=Background,CornerRadius=UDim.new(0,8)})
    Library:Create("UIStroke",{Parent=Background,Color=T.Stroke,Thickness=0.8})
    Library:Create("ImageLabel",{Name="Shadow",Parent=Background,AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,
        BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,120,1,120),ZIndex=0,
        Image="rbxassetid://8992230677",ImageColor3=Color3.fromRGB(0,0,0),ImageTransparency=0.5,
        ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(99,99,99,99)})

    function Library:IsDropdownOpen()
        for _,v in pairs(Background:GetChildren()) do
            if (v.Name=="Dropdown" or v.Name=="ColorPickerFrame") and v.Visible then return true end
        end; return false
    end

    local HDR_H=42
    local Header=Library:Create("Frame",{Name="Header",Parent=Background,BackgroundColor3=T.TabBg,BorderSizePixel=0,Size=UDim2.new(1,0,0,HDR_H)})
    Library:Create("UICorner",{Parent=Header,CornerRadius=UDim.new(0,8)}); rTB(Header,"BackgroundColor3")
    Library:Create("Frame",{Parent=Header,Name="Div",BackgroundColor3=T.Stroke,BorderSizePixel=0,AnchorPoint=Vector2.new(0,1),Position=UDim2.new(0,0,1,0),Size=UDim2.new(1,0,0,1)})

    local ScriptIconFrame=Library:Create("Frame",{Parent=Header,BackgroundTransparency=1,BorderSizePixel=0,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,12,0.5,0),Size=UDim2.new(0,30,0,30)})
    Library:Create("ImageLabel",{Parent=ScriptIconFrame,AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,
        BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,1,0),
        Image=Library:Asset(BbIcon),ImageColor3=T.Accent})

    local ReturnBtn=Library:Create("TextButton",{Name="Return",Parent=Header,BackgroundColor3=T.RowAlt,BorderSizePixel=0,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,9,0.5,0),Size=UDim2.new(0,30,0,30),
        Text="",AutoButtonColor=false,Visible=false,ZIndex=8,ClipsDescendants=true})
    Library:Create("UICorner",{Parent=ReturnBtn,CornerRadius=UDim.new(1,0)})
    Library:Create("UIStroke",{Parent=ReturnBtn,Color=T.Stroke,Thickness=0.7})
    local RetArrow=Library:Create("ImageLabel",{Parent=ReturnBtn,AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,
        BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,15,0,15),
        Image="rbxassetid://130391877219356",ImageColor3=T.Accent,ZIndex=9})
    rA(RetArrow,"ImageColor3")

    local TitleBlock=Library:Create("Frame",{Name="TitleBlock",Parent=Header,BackgroundTransparency=1,BorderSizePixel=0,
        AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,50,0.5,0),Size=UDim2.new(1,-20,0,28)})
    Library:Create("UIListLayout",{Parent=TitleBlock,SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,0)})
    local TitleLabel
    if Title and Title~="" then
        TitleLabel=Library:Create("TextLabel",{Name="Title",Parent=TitleBlock,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,14),Font=Enum.Font.GothamBold,RichText=true,Text=Title,
            TextColor3=T.Accent,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
        rA(TitleLabel,"TextColor3"); MkGrad(TitleLabel)
    end
    local SubTitleLabel
    if SubTitle and SubTitle~="" then
        SubTitleLabel=Library:Create("TextLabel",{Name="SubTitle",Parent=TitleBlock,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,10),Font=Enum.Font.GothamMedium,RichText=true,Text=SubTitle,
            TextColor3=T.SubText,TextSize=9,TextTransparency=0.4,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
    end
    local THETIME=Library:Create("TextLabel",{Name="TimerLbl",Parent=TitleBlock,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,10),Font=Enum.Font.GothamMedium,Text="",TextColor3=T.SubText,
        TextSize=9,TextTransparency=0.4,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false,Visible=false})

    local Scale=Library:Create("Frame",{Name="Scale",Parent=Background,AnchorPoint=Vector2.new(0,1),BackgroundTransparency=1,
        BorderSizePixel=0,Position=UDim2.new(0,0,1,-8),Size=UDim2.new(1,0,1,-(HDR_H+9)),ClipsDescendants=true})
    local Home=Library:Create("Frame",{Name="Home",Parent=Scale,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)})
    local MTS=Library:Create("ScrollingFrame",{Name="TabScrolling",Parent=Home,Active=true,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),ClipsDescendants=true,AutomaticCanvasSize=Enum.AutomaticSize.None,
        BottomImage="rbxasset://textures/ui/Scroll/scroll-bottom.png",CanvasPosition=Vector2.new(0,0),
        ElasticBehavior=Enum.ElasticBehavior.WhenScrollable,MidImage="rbxasset://textures/ui/Scroll/scroll-middle.png",
        ScrollBarImageColor3=T.Stroke,ScrollBarThickness=2,ScrollingDirection=Enum.ScrollingDirection.Y,
        TopImage="rbxasset://textures/ui/Scroll/scroll-top.png",VerticalScrollBarPosition=Enum.VerticalScrollBarPosition.Right})
    Library:Create("UIPadding",{Parent=MTS,PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})
    local MTL=Library:Create("UIGridLayout",{Parent=MTS,CellSize=UDim2.new(0.5,-7,0,72),CellPadding=UDim2.new(0,10,0,10),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Left,VerticalAlignment=Enum.VerticalAlignment.Top})
    MTL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() MTS.CanvasSize=UDim2.new(0,0,0,MTL.AbsoluteContentSize.Y+20) end)
    local PageService=Library:Create("UIPageLayout",{Parent=Scale})
    PageService.HorizontalAlignment=Enum.HorizontalAlignment.Left; PageService.EasingStyle=Enum.EasingStyle.Exponential
    PageService.TweenTime=0.4; PageService.GamepadInputEnabled=false; PageService.ScrollWheelInputEnabled=false; PageService.TouchInputEnabled=false
    Library.PageService=PageService

    local ToggleScreen=Library:Create("ScreenGui",{Name="VitaToggle",Parent=Library:Parent(),ZIndexBehavior=Enum.ZIndexBehavior.Global,DisplayOrder=11,IgnoreGuiInset=true,ResetOnSpawn=false})
    local Pillow=Library:Create("TextButton",{Name="Pillow",Parent=ToggleScreen,BackgroundColor3=T.PillBg,BorderSizePixel=0,
        Position=UDim2.new(0.06,0,0.15,0),Size=UDim2.new(0,50,0,50),Text="",ClipsDescendants=true,AutoButtonColor=false})
    rB(Pillow,"BackgroundColor3")
    Library:Create("UICorner",{Parent=Pillow,CornerRadius=UDim.new(1,0)})
    Library:Create("UIStroke",{Parent=Pillow,Color=T.Stroke,Thickness=0.7})
    local PillLogo=Library:Create("ImageLabel",{Name="Logo",Parent=Pillow,AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,
        BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0.54,0,0.54,0),Image=Library:Asset(BbIcon),ImageColor3=T.Accent})
    rA(PillLogo,"ImageColor3")
    Library:Draggable(Pillow)
    Pillow.MouseButton1Click:Connect(function() Background.Visible=not Background.Visible end)
    UserInputService.InputBegan:Connect(function(inp,proc)
        if proc then return end
        if inp.KeyCode==ToggleKey then Background.Visible=not Background.Visible end
    end)

    local MiniBar=Library:Create("Frame",{Name="MiniBar",Parent=Background,BackgroundColor3=T.TabBg,BorderSizePixel=0,
        AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,0),Size=UDim2.new(1,0,0,8),ZIndex=5})
    Library:Create("UICorner",{Parent=MiniBar,CornerRadius=UDim.new(0,4)}); rTB(MiniBar,"BackgroundColor3")
    local MiniHandle=Library:Create("Frame",{Parent=MiniBar,BackgroundColor3=T.Stroke,BorderSizePixel=0,
        AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,24,0,2),BackgroundTransparency=0.4})
    Library:Create("UICorner",{Parent=MiniHandle,CornerRadius=UDim.new(1,0)})

    local ResizeHandle=Library:Create("TextButton",{Name="ResizeHandle",Parent=Background,BackgroundTransparency=1,
        BorderSizePixel=0,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,0,1,0),Size=UDim2.new(0,22,0,22),Text="",ZIndex=10,AutoButtonColor=false})
    for ri=1,3 do
        Library:Create("Frame",{Parent=ResizeHandle,BackgroundColor3=T.Stroke,BorderSizePixel=0,
            AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-2,1,-2+((ri-1)*-5)),
            Size=UDim2.new(0,ri*8,0,1),BackgroundTransparency=0.3,Rotation=-45})
    end
    do
        local rDrag=false; local rStart=nil; local rSize=nil
        ResizeHandle.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                rDrag=true; rStart=inp.Position; rSize=Vector2.new(Background.Size.X.Offset,Background.Size.Y.Offset)
            end
        end)
        ResizeHandle.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then rDrag=false end end)
        UserInputService.InputChanged:Connect(function(inp)
            if not rDrag then return end
            if inp.UserInputType~=Enum.UserInputType.MouseMovement and inp.UserInputType~=Enum.UserInputType.Touch then return end
            local d=inp.Position-rStart
            local nW=math.clamp(rSize.X+d.X/Scaler.Scale,260,900)
            local nH=math.clamp(rSize.Y+d.Y/Scaler.Scale,200,700)
            Background.Size=UDim2.new(0,nW,0,nH); RAW_W=nW; RAW_H=nH
        end)
        UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then rDrag=false end end)
    end

    local _locked=false; local _lockMsg="Locked"
    local function OnReturn()
        ReturnBtn.Visible=false; ScriptIconFrame.Visible=true
        TitleBlock.Position=UDim2.new(0,50,0.5,0); PageService:JumpTo(Home)
    end
    ReturnBtn.MouseButton1Click:Connect(OnReturn)
    PageService:JumpTo(Home)
    Library:Draggable(Header,Background)

    local function BuildColorPicker(parentFrame,initialColor,onChanged)
        local H,S,V=Color3.toHSV(initialColor); local cur=initialColor
        local PF=Library:Create("Frame",{Name="ColorPickerFrame",Parent=parentFrame,AnchorPoint=Vector2.new(0.5,0.5),
            BackgroundColor3=Color3.fromRGB(50,50,55),BorderSizePixel=0,Position=UDim2.new(0.5,0,0.35,0),
            Size=UDim2.new(0,255,0,170),ZIndex=600,Visible=false})
        Library:Create("UICorner",{Parent=PF,CornerRadius=UDim.new(0,6)})
        Library:Create("UIStroke",{Parent=PF,Color=Color3.fromRGB(65,65,70),Thickness=0.8})
        Library:Create("UIPadding",{Parent=PF,PaddingLeft=UDim.new(0,5),PaddingRight=UDim.new(0,5),PaddingTop=UDim.new(0,5),PaddingBottom=UDim.new(0,5)})

        local PickerArea=Library:Create("Frame",{Parent=PF,BackgroundColor3=Color3.fromRGB(80,82,85),BorderSizePixel=0,
            Size=UDim2.new(0.5,-5,1,-25),ZIndex=601,ClipsDescendants=true})
        Library:Create("UICorner",{Parent=PickerArea,CornerRadius=UDim.new(0,6)})

        local ColorFrame=Library:Create("Frame",{Parent=PickerArea,BackgroundColor3=Color3.fromHSV(H,1,1),BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0),ZIndex=602})
        Library:Create("UICorner",{Parent=ColorFrame,CornerRadius=UDim.new(0,6)})

        local WhiteOverlay=Library:Create("Frame",{Parent=PickerArea,BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0),ZIndex=603})
        Library:Create("UICorner",{Parent=WhiteOverlay,CornerRadius=UDim.new(0,6)})
        Library:Create("UIGradient",{Parent=WhiteOverlay,Rotation=90,
            Color=ColorSequence.new(Color3.fromRGB(255,255,255)),
            Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}})

        local BlackOverlay=Library:Create("Frame",{Parent=PickerArea,BackgroundColor3=Color3.fromRGB(0,0,0),BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0),ZIndex=604})
        Library:Create("UICorner",{Parent=BlackOverlay,CornerRadius=UDim.new(0,6)})
        Library:Create("UIGradient",{Parent=BlackOverlay,Rotation=0,
            Color=ColorSequence.new(Color3.fromRGB(0,0,0)),
            Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}})

        local PickerDot=Library:Create("Frame",{Parent=PickerArea,BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,
            AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(8,8),ZIndex=610})
        Library:Create("UICorner",{Parent=PickerDot,CornerRadius=UDim.new(1,0)})
        Library:Create("UIStroke",{Parent=PickerDot,Color=Color3.fromRGB(0,0,0),Thickness=1})

        local HueArea=Library:Create("Frame",{Parent=PF,BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,
            AnchorPoint=Vector2.new(0,1),Position=UDim2.fromScale(0,1),Size=UDim2.new(0.5,-5,0,20),ZIndex=601})
        Library:Create("UICorner",{Parent=HueArea,CornerRadius=UDim.new(0,6)})
        Library:Create("UIGradient",{Parent=HueArea,Rotation=0,Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.167,Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(0.333,Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.667,Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(0.833,Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,0,0))}})

        local HueDrag=Library:Create("Frame",{Parent=HueArea,BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,
            AnchorPoint=Vector2.new(0,0.5),Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(0,3,1,0),ZIndex=612})
        Library:Create("UIStroke",{Parent=HueDrag,Color=Color3.fromRGB(0,0,0),Thickness=1})

        local RightBlock=Library:Create("Frame",{Parent=PF,BackgroundTransparency=1,BorderSizePixel=0,
            AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.new(0.5,-5,1,0),ZIndex=601})
        Library:Create("UIListLayout",{Parent=RightBlock,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5),FillDirection=Enum.FillDirection.Vertical})

        local HexInput=Library:Create("TextBox",{Parent=RightBlock,BackgroundColor3=Color3.fromRGB(62,62,67),BorderSizePixel=0,
            Size=UDim2.new(1,0,0,22),ZIndex=601,Font=Enum.Font.GothamMedium,PlaceholderText="#RRGGBB",
            Text="",TextColor3=Color3.fromRGB(255,255,255),TextSize=11,TextXAlignment=Enum.TextXAlignment.Center,ClearTextOnFocus=false})
        Library:Create("UICorner",{Parent=HexInput,CornerRadius=UDim.new(0,4)})

        local RGBDisplay=Library:Create("TextLabel",{Parent=RightBlock,BackgroundColor3=Color3.fromRGB(62,62,67),BorderSizePixel=0,
            Size=UDim2.new(1,0,0,42),ZIndex=601,Font=Enum.Font.GothamMedium,Text="R: 255\nG: 0\nB: 0",
            TextColor3=Color3.fromRGB(220,220,220),TextSize=10,TextXAlignment=Enum.TextXAlignment.Center})
        Library:Create("UICorner",{Parent=RGBDisplay,CornerRadius=UDim.new(0,4)})

        local Preview=Library:Create("Frame",{Parent=RightBlock,BackgroundColor3=Color3.fromRGB(255,0,0),BorderSizePixel=0,
            Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=601})
        Library:Create("UICorner",{Parent=Preview,CornerRadius=UDim.new(0,4)})
        Library:Create("UIAspectRatioConstraint",{Parent=Preview,AspectRatio=3.5,AspectType=Enum.AspectType.ScaleWithParentSize})

        local svDragging=false; local hueDragging=false

        local function UpdCP()
            cur=Color3.fromHSV(H,S,V)
            ColorFrame.BackgroundColor3=Color3.fromHSV(H,1,1)
            Preview.BackgroundColor3=cur
            local r=math.floor(cur.R*255); local g=math.floor(cur.G*255); local b=math.floor(cur.B*255)
            RGBDisplay.Text=string.format("R: %d\nG: %d\nB: %d",r,g,b)
            HexInput.Text=string.format("#%02X%02X%02X",r,g,b)
            local paW=PickerArea.AbsoluteSize.X; local paH=PickerArea.AbsoluteSize.Y
            if paW>0 then PickerDot.Position=UDim2.fromOffset(S*paW,(1-V)*paH) end
            local hW=HueArea.AbsoluteSize.X
            if hW>0 then HueDrag.Position=UDim2.new(0,H*hW,0.5,0) end
            pcall(onChanged,cur)
        end

        PickerArea.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                svDragging=true
                local mp=UserInputService:GetMouseLocation()
                local rx=math.clamp(mp.X-PickerArea.AbsolutePosition.X,0,PickerArea.AbsoluteSize.X)
                local ry=math.clamp(mp.Y-PickerArea.AbsolutePosition.Y,0,PickerArea.AbsoluteSize.Y)
                S=rx/PickerArea.AbsoluteSize.X; V=1-(ry/PickerArea.AbsoluteSize.Y)
                PickerDot.Position=UDim2.fromOffset(rx,ry); pcall(onChanged,Color3.fromHSV(H,S,V)); UpdCP()
            end
        end)

        HueArea.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                hueDragging=true
                local mp=UserInputService:GetMouseLocation()
                local rx=math.clamp(mp.X-HueArea.AbsolutePosition.X,0,HueArea.AbsoluteSize.X)
                H=rx/HueArea.AbsoluteSize.X
                HueDrag.Position=UDim2.new(0,rx,0.5,0); UpdCP()
            end
        end)

        UserInputService.InputChanged:Connect(function(inp)
            if not PF.Visible then return end
            if inp.UserInputType~=Enum.UserInputType.MouseMovement and inp.UserInputType~=Enum.UserInputType.Touch then return end
            if svDragging then
                local mp=UserInputService:GetMouseLocation()
                local rx=math.clamp(mp.X-PickerArea.AbsolutePosition.X,0,PickerArea.AbsoluteSize.X)
                local ry=math.clamp(mp.Y-PickerArea.AbsolutePosition.Y,0,PickerArea.AbsoluteSize.Y)
                S=rx/PickerArea.AbsoluteSize.X; V=1-(ry/PickerArea.AbsoluteSize.Y)
                PickerDot.Position=UDim2.fromOffset(rx,ry); UpdCP()
            elseif hueDragging then
                local mp=UserInputService:GetMouseLocation()
                local rx=math.clamp(mp.X-HueArea.AbsolutePosition.X,0,HueArea.AbsoluteSize.X)
                H=rx/HueArea.AbsoluteSize.X
                HueDrag.Position=UDim2.new(0,rx,0.5,0); UpdCP()
            end
        end)

        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                svDragging=false; hueDragging=false
            end
        end)

        UserInputService.InputBegan:Connect(function(A)
            if not PF.Visible then return end
            if A.UserInputType~=Enum.UserInputType.MouseButton1 and A.UserInputType~=Enum.UserInputType.Touch then return end
            local mp=UserInputService:GetMouseLocation()
            local dp,ds=PF.AbsolutePosition,PF.AbsoluteSize
            if not(mp.X>=dp.X and mp.X<=dp.X+ds.X and mp.Y>=dp.Y and mp.Y<=dp.Y+ds.Y) then PF.Visible=false end
        end)

        HexInput.FocusLost:Connect(function()
            local hex=HexInput.Text:match("#?([%x][%x][%x][%x][%x][%x])")
            if hex then
                local r=tonumber(hex:sub(1,2),16)/255
                local g=tonumber(hex:sub(3,4),16)/255
                local b=tonumber(hex:sub(5,6),16)/255
                H,S,V=Color3.toHSV(Color3.fromRGB(r*255,g*255,b*255)); UpdCP()
            end
        end)

        task.defer(UpdCP)
        PickerArea:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdCP)
        HueArea:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdCP)
        return PF, function() return cur end, function(c) H,S,V=Color3.toHSV(c); task.defer(UpdCP) end
    end

    local Window={}

    function Window:Popup(Args)
        local PTitle=Args.Title or "Popup"; local PDesc=Args.Desc or ""
        local PButtons=Args.Buttons or {{Text="OK",Callback=function()end}}
        local Overlay=Library:Create("Frame",{Name="PopupOverlay",Parent=Background,BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=0.55,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=800})
        local PF=Library:Create("Frame",{Name="Popup",Parent=Background,AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.TabBg,BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,290,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=801})
        Library:Create("UICorner",{Parent=PF,CornerRadius=UDim.new(0,8)}); Library:Create("UIStroke",{Parent=PF,Color=T.Stroke,Thickness=0.8})
        Library:Create("UIListLayout",{Parent=PF,SortOrder=Enum.SortOrder.LayoutOrder})
        local AL=Library:Create("Frame",{Parent=PF,BackgroundColor3=T.Accent,BorderSizePixel=0,Size=UDim2.new(1,0,0,3),ZIndex=802})
        Library:Create("UICorner",{Parent=AL,CornerRadius=UDim.new(0,8)}); rA(AL,"BackgroundColor3")
        local PHdr=Library:Create("Frame",{Parent=PF,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,42),ZIndex=802})
        Library:Create("UIPadding",{Parent=PHdr,PaddingLeft=UDim.new(0,16),PaddingRight=UDim.new(0,16)})
        Library:Create("TextLabel",{Parent=PHdr,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamBold,Text=PTitle,TextColor3=T.Text,TextSize=14,ZIndex=803,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
        local PBody=Library:Create("Frame",{Parent=PF,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=802})
        Library:Create("UIPadding",{Parent=PBody,PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,16),PaddingLeft=UDim.new(0,16),PaddingRight=UDim.new(0,16)})
        Library:Create("UIListLayout",{Parent=PBody,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,14)})
        Library:Create("TextLabel",{Parent=PBody,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Font=Enum.Font.GothamMedium,Text=PDesc,TextColor3=T.SubText,TextSize=12,ZIndex=803,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
        local BR=Library:Create("Frame",{Parent=PBody,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,32),ZIndex=802})
        Library:Create("UIListLayout",{Parent=BR,FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center})
        local function Close() pcall(function()PF:Destroy()end); pcall(function()Overlay:Destroy()end) end
        for _,bd in ipairs(PButtons) do
            local isM=bd.Style=="main" or bd.Style==nil
            local Btn=Library:Create("TextButton",{Parent=BR,BackgroundColor3=isM and T.Accent or Color3.fromRGB(35,35,35),BorderSizePixel=0,Size=UDim2.new(0,0,0,30),AutomaticSize=Enum.AutomaticSize.X,ZIndex=803,Font=Enum.Font.GothamSemibold,Text=bd.Text or "OK",TextColor3=Color3.fromRGB(255,255,255),TextSize=12,ClipsDescendants=true,AutoButtonColor=false})
            Library:Create("UICorner",{Parent=Btn,CornerRadius=UDim.new(0,6)}); Library:Create("UIPadding",{Parent=Btn,PaddingLeft=UDim.new(0,16),PaddingRight=UDim.new(0,16)})
            if isM then BtnGrad(Btn); rA(Btn,"BackgroundColor3") end
            Btn.MouseButton1Click:Connect(function() Ripple(Btn); Close(); if bd.Callback then pcall(bd.Callback) end end)
        end
        Library:Create("TextButton",{Parent=Overlay,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),Text="",ZIndex=800}).MouseButton1Click:Connect(Close)
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
        local PageTitle=Args.Title or "Page"; local PageDesc=Args.Desc or ""
        local PageIcon=Args.Icon or 127194456372995
        local TabImg=Args.TabImage
        local TabImgColor=Args.TabImageColor
        local NewTabs=Library:Create("Frame",{Name="NewTabs",Parent=MTS,BackgroundColor3=T.TabBg,BorderSizePixel=0,Size=UDim2.new(1,0,0,72),ClipsDescendants=true})
        rTB(NewTabs,"BackgroundColor3"); local TabCB=Library:Button(NewTabs)
        Library:Create("UICorner",{Parent=NewTabs,CornerRadius=UDim.new(0,6)})
        local TSI=Library:Create("UIStroke",{Parent=NewTabs,Color=T.TabStroke,Thickness=1}); rTS(TSI,"Color")
        local banImg=TabImg and Library:Asset(TabImg) or "rbxassetid://125411502674016"
        local banColor=TabImgColor and RC(TabImgColor) or T.TabImage
        local TabBann=Library:Create("ImageLabel",{Name="Banner",Parent=NewTabs,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0),Image=banImg,ImageColor3=banColor,ScaleType=Enum.ScaleType.Crop})
        if not TabImgColor and not TabImg then rTI(TabBann,"ImageColor3") end
        Library:Create("UICorner",{Parent=TabBann,CornerRadius=UDim.new(0,2)})
        local TabInfo=Library:Create("Frame",{Name="Info",Parent=NewTabs,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)})
        Library:Create("UIListLayout",{Parent=TabInfo,Padding=UDim.new(0,10),FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center})
        Library:Create("UIPadding",{Parent=TabInfo,PaddingLeft=UDim.new(0,14)})
        local TabIcon=Library:Create("ImageLabel",{Name="Icon",Parent=TabInfo,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-1,Size=UDim2.new(0,22,0,22),Image=Library:Asset(PageIcon),ImageColor3=T.Accent})
        rA(TabIcon,"ImageColor3"); MkGrad(TabIcon)
        local TabText=Library:Create("Frame",{Name="Text",Parent=TabInfo,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0,148,0,34)})
        Library:Create("UIListLayout",{Parent=TabText,Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center})
        local TabTL=Library:Create("TextLabel",{Name="Title",Parent=TabText,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0,148,0,14),Font=Enum.Font.GothamBold,RichText=true,Text=PageTitle,TextColor3=T.Accent,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
        rA(TabTL,"TextColor3"); MkGrad(TabTL)
        Library:Create("TextLabel",{Name="Desc",Parent=TabText,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0.9,0,0,10),Font=Enum.Font.GothamMedium,RichText=true,Text=PageDesc,TextColor3=T.SubText,TextSize=10,TextTransparency=0.3,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
        local NewPage=Library:Create("Frame",{Name="NewPage",Parent=Scale,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0)})
        local PS=Library:Create("ScrollingFrame",{Name="PageScrolling",Parent=NewPage,Active=true,BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,1,0),ClipsDescendants=true,AutomaticCanvasSize=Enum.AutomaticSize.None,
            BottomImage="rbxasset://textures/ui/Scroll/scroll-bottom.png",CanvasPosition=Vector2.new(0,0),
            ElasticBehavior=Enum.ElasticBehavior.WhenScrollable,MidImage="rbxasset://textures/ui/Scroll/scroll-middle.png",
            ScrollBarImageColor3=Color3.fromRGB(0,0,0),ScrollBarThickness=0,ScrollingDirection=Enum.ScrollingDirection.Y,
            TopImage="rbxasset://textures/ui/Scroll/scroll-top.png",VerticalScrollBarPosition=Enum.VerticalScrollBarPosition.Right})
        Library:Create("UIPadding",{Parent=PS,PaddingBottom=UDim.new(0,40),PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14),PaddingTop=UDim.new(0,10)})
        local PL=Library:Create("UIListLayout",{Parent=PS,Padding=UDim.new(0,6),FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder})
        PL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PS.CanvasSize=UDim2.new(0,0,0,PL.AbsoluteContentSize.Y+50)
        end)
        TabCB.MouseButton1Click:Connect(function()
            if _locked then return end
            ReturnBtn.Visible=true; ScriptIconFrame.Visible=false
            TitleBlock.Position=UDim2.new(0,48,0.5,0); PageService:JumpTo(NewPage)
        end)

        local Page={}

        local function LockOv(parent,msg)
            local ov=Library:Create("Frame",{Parent=parent,BackgroundColor3=Color3.fromRGB(12,12,14),
                BackgroundTransparency=0.08,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=50,Visible=false})
            Library:Create("UICorner",{Parent=ov,CornerRadius=UDim.new(0,5)})
            local inner=Library:Create("Frame",{Parent=ov,BackgroundTransparency=1,BorderSizePixel=0,
                AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),
                Size=UDim2.new(0,0,0,0),AutomaticSize=Enum.AutomaticSize.XY,ZIndex=51})
            Library:Create("UIListLayout",{Parent=inner,SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center,Padding=UDim.new(0,4)})
            Library:Create("ImageLabel",{Parent=inner,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0,18,0,18),Image="rbxassetid://6031135061",ImageColor3=Color3.fromRGB(180,180,190),ZIndex=52,LayoutOrder=1})
            Library:Create("TextLabel",{Parent=inner,BackgroundTransparency=1,BorderSizePixel=0,
                Size=UDim2.new(0,80,0,11),ZIndex=52,LayoutOrder=2,Font=Enum.Font.GothamMedium,
                Text=msg or _lockMsg,TextColor3=Color3.fromRGB(160,160,170),TextSize=10,
                TextXAlignment=Enum.TextXAlignment.Center,TextWrapped=true})
            return ov
        end

        function Page:Section(txt)
            local row=Library:Create("Frame",{Name="Section",Parent=PS,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,24)})
            Library:Create("UIListLayout",{Parent=row,FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder})
            Library:Create("TextLabel",{Name="SL",Parent=row,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0,0,0,14),AutomaticSize=Enum.AutomaticSize.X,LayoutOrder=1,Font=Enum.Font.GothamBold,RichText=true,Text=txt,TextColor3=T.SubText,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false})
            Library:Create("Frame",{Parent=row,BackgroundColor3=T.Stroke,BorderSizePixel=0,LayoutOrder=2,Size=UDim2.new(1,0,0,1),BackgroundTransparency=0.3})
            return row
        end

        function Page:Divider()
            return Library:Create("Frame",{Name="Divider",Parent=PS,BackgroundColor3=T.Stroke,BorderSizePixel=0,Size=UDim2.new(1,0,0,1),BackgroundTransparency=0.45})
        end

        function Page:Label(Args)
            local R=Library:NewRows(PS,Args.Title,Args.Desc,T); local Left=R.Left
            local obj={}
            function obj:SetTitle(v) local t=Left:FindFirstChild("Title");if t then t.Text=tostring(v) end end
            function obj:SetDesc(v)  local d=Left:FindFirstChild("Desc"); if d then d.Text=tostring(v) end end
            function obj:Destroy()   R.Frame:Destroy() end
            return obj
        end

        function Page:Paragraph(Args)
            local PTitle=Args.Title; local PDesc=Args.Desc; local PColor=Args.Color
            local PImage=Args.Image or Args.Icon; local PImageSize=Args.ImageSize or 20
            local PImageMode=Args.ImageMode or "beside"; local PTopImgH=Args.TopImageHeight or 120
            local PThumb=Args.Thumbnail; local PThumbSize=Args.ThumbnailSize or 44
            local PBtns=Args.Buttons or {}; local PLockMsg=Args.LockMessage; local isTop=PImageMode=="top"
            local Rows=Library:Create("Frame",{Name="Rows",Parent=PS,BackgroundColor3=PColor and RC(PColor) or T.Row,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y})
            Library:Create("UIStroke",{Parent=Rows,Color=T.Stroke,Thickness=0.5}); Library:Create("UICorner",{Parent=Rows,CornerRadius=UDim.new(0,5)})
            Library:Create("UIListLayout",{Parent=Rows,FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0)})
            if isTop and PImage and PImage~="" then
                local TI=Library:Create("ImageLabel",{Parent=Rows,BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=0,BorderSizePixel=0,Size=UDim2.new(1,0,0,PTopImgH),LayoutOrder=1,Image=Library:Asset(PImage),ScaleType=Enum.ScaleType.Crop})
                Library:Create("UICorner",{Parent=TI,CornerRadius=UDim.new(0,5)})
            end
            local Inner=Library:Create("Frame",{Parent=Rows,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2})
            Library:Create("UIPadding",{Parent=Inner,PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)})
            Library:Create("UIListLayout",{Parent=Inner,FillDirection=Enum.FillDirection.Horizontal,VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,10)})
            local ThumbLbl
            if PThumb and PThumb~="" then ThumbLbl=Library:Create("ImageLabel",{Parent=Inner,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=1,Size=UDim2.new(0,PThumbSize,0,PThumbSize),Image=Library:Asset(PThumb)}); Library:Create("UICorner",{Parent=ThumbLbl,CornerRadius=UDim.new(0,5)}) end
            local btnCnt=#PBtns; local iconW=(not isTop and PImage and PImage~="") and (PImageSize+10) or 0
            local btnsW=btnCnt>0 and (btnCnt*62+(btnCnt-1)*6) or 0; local thumbW=(PThumb and PThumb~="") and (PThumbSize+10) or 0
            local textFrac=math.max(0.3,1-(btnsW+iconW)/math.max(1,RAW_W-28-thumbW))
            local TextBlock=Library:Create("Frame",{Parent=Inner,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(textFrac,-thumbW,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2})
            Library:Create("UIListLayout",{Parent=TextBlock,SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,3)})
            local TitleLbl=Library:Create("TextLabel",{Name="Title",Parent=TextBlock,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Font=Enum.Font.GothamSemibold,RichText=true,Text=PTitle or "",TextColor3=T.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
            if PTitle and PTitle~="" then MkGrad(TitleLbl) end
            local DescLbl=Library:Create("TextLabel",{Name="Desc",Parent=TextBlock,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Font=Enum.Font.GothamMedium,RichText=true,Text=PDesc or "",TextColor3=T.SubText,TextSize=10,TextTransparency=0.3,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
            local RightBlock=Library:Create("Frame",{Parent=Inner,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0,iconW+btnsW,0,30),LayoutOrder=3})
            Library:Create("UIListLayout",{Parent=RightBlock,FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)})
            local IconLbl
            if not isTop and PImage and PImage~="" then IconLbl=Library:Create("ImageLabel",{Parent=RightBlock,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=1,Size=UDim2.new(0,PImageSize,0,PImageSize),Image=Library:Asset(PImage),ImageColor3=T.Accent}); rA(IconLbl,"ImageColor3") end
            for bi,bd in ipairs(PBtns) do
                local BF=Library:Create("TextButton",{Parent=RightBlock,BackgroundColor3=T.Accent,BorderSizePixel=0,Size=UDim2.new(0,60,0,26),ClipsDescendants=true,LayoutOrder=10+bi,Font=Enum.Font.GothamSemibold,Text=bd.Title or "Btn",TextColor3=Color3.fromRGB(255,255,255),TextSize=10,AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Center})
                rA(BF,"BackgroundColor3"); Library:Create("UICorner",{Parent=BF,CornerRadius=UDim.new(0,5)}); BtnGrad(BF); Library:Create("UIPadding",{Parent=BF,PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)})
                BF.MouseButton1Click:Connect(function() if _locked then return end; Ripple(BF); if bd.Callback then pcall(bd.Callback) end end)
            end
            local lov=LockOv(Rows,PLockMsg); local obj={}
            function obj:SetTitle(v) TitleLbl.Text=tostring(v) end; function obj:SetDesc(v) DescLbl.Text=tostring(v) end
            function obj:SetImage(v) if IconLbl then IconLbl.Image=Library:Asset(v) end end
            function obj:SetThumbnail(v) if ThumbLbl then ThumbLbl.Image=Library:Asset(v) end end
            function obj:SetColor(v) Rows.BackgroundColor3=RC(v) end
            function obj:Lock(m) lov.Visible=true; if m then lov:FindFirstChildWhichIsA("TextLabel",true).Text=m end end
            function obj:Unlock() lov.Visible=false end; function obj:Destroy() Rows:Destroy() end
            return obj
        end

        function Page:Button(Args)
            local Callback=Args.Callback; local BtnText=Args.Text or "Click"
            local SaveKey=Args.save and (Args.Title or tostring(Args.save))
            local R=Library:NewRows(PS,Args.Title,Args.Desc,T); local Right=R.Right; local Left=R.Left
            local Btn=Library:Create("TextButton",{Name="Button",Parent=Right,BackgroundColor3=T.Accent,BorderSizePixel=0,
                Size=UDim2.new(0,0,0,26),AutomaticSize=Enum.AutomaticSize.X,ClipsDescendants=true,
                Font=Enum.Font.GothamSemibold,Text=BtnText,TextColor3=Color3.fromRGB(255,255,255),TextSize=11,AutoButtonColor=false,TextXAlignment=Enum.TextXAlignment.Center})
            Library:Create("UISizeConstraint",{Parent=Btn,MinSize=Vector2.new(64,26),MaxSize=Vector2.new(140,26)})
            rA(Btn,"BackgroundColor3"); Library:Create("UICorner",{Parent=Btn,CornerRadius=UDim.new(0,5)}); BtnGrad(Btn)
            Library:Create("UIPadding",{Parent=Btn,PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})
            Btn.MouseButton1Click:Connect(function() if _locked or Library:IsDropdownOpen() then return end; Ripple(Btn); if Callback then pcall(Callback) end end)
            local lov=LockOv(R.Frame,Args.LockMessage); local obj={}
            function obj:SetTitle(v) local t=Left:FindFirstChild("Title");if t then t.Text=tostring(v) end end
            function obj:SetDesc(v)  local d=Left:FindFirstChild("Desc"); if d then d.Text=tostring(v) end end
            function obj:SetText(v)  Btn.Text=tostring(v) end; function obj:GetValue() return BtnText end
            function obj:Lock(m) lov.Visible=true; if m then lov:FindFirstChildWhichIsA("TextLabel",true).Text=m end end
            function obj:Unlock() lov.Visible=false end; function obj:Destroy() R.Frame:Destroy() end
            setmetatable(obj,{__newindex=function(t,k,v) rawset(t,k,v); if k=="Title" then local tl=Left:FindFirstChild("Title");if tl then tl.Text=tostring(v) end elseif k=="Desc" then local dl=Left:FindFirstChild("Desc");if dl then dl.Text=tostring(v) end elseif k=="Text" then Btn.Text=tostring(v) end end})
            return obj
        end

        function Page:Toggle(Args)
            local Value=Args.Value or false; local Callback=Args.Callback or function()end
            local SaveKey=Args.save and (Args.Title or tostring(Args.save))
            local R=Library:NewRows(PS,Args.Title,Args.Desc,T); local Left=R.Left; local Right=R.Right
            local TitleLbl=Left:FindFirstChild("Title")
            if SaveKey and Cfg:getval(SaveKey)~=nil then Value=Cfg:getval(SaveKey) end
            local Bg=Library:Create("Frame",{Name="ToggleBg",Parent=Right,BackgroundColor3=T.RowAlt,BorderSizePixel=0,Size=UDim2.new(0,22,0,22)})
            local Stroke=Library:Create("UIStroke",{Parent=Bg,Color=T.Stroke,Thickness=0.7}); Library:Create("UICorner",{Parent=Bg,CornerRadius=UDim.new(0,6)}); rAlt(Bg,"BackgroundColor3")
            local Hl=Library:Create("Frame",{Parent=Bg,AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.Accent,BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,0,1,0),BackgroundTransparency=1})
            Library:Create("UICorner",{Parent=Hl,CornerRadius=UDim.new(0,6)}); rA(Hl,"BackgroundColor3"); BtnGrad(Hl)
            local ChkImg=Library:Create("ImageLabel",{Parent=Hl,AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0.56,0,0.56,0),Image="rbxassetid://86682186031062",ImageTransparency=1})
            local CB=Library:Button(Bg); local Data={Value=Value}
            local function OnChanged(val)
                Data.Value=val; if SaveKey then Cfg:setval(SaveKey,val) end
                if val then pcall(Callback,val); if TitleLbl then TitleLbl.TextColor3=T.Accent end
                    Library:Tween({v=Hl,t=0.25,s="Exponential",d="Out",g={BackgroundTransparency=0}}):Play()
                    Library:Tween({v=ChkImg,t=0.2,s="Exponential",d="Out",g={ImageTransparency=0}}):Play(); Stroke.Thickness=0
                else pcall(Callback,val); if TitleLbl then TitleLbl.TextColor3=T.Text end
                    Library:Tween({v=Hl,t=0.25,s="Exponential",d="Out",g={BackgroundTransparency=1}}):Play()
                    Library:Tween({v=ChkImg,t=0.2,s="Exponential",d="Out",g={ImageTransparency=1}}):Play(); Stroke.Thickness=0.7
                end
            end
            CB.MouseButton1Click:Connect(function() if _locked or Library:IsDropdownOpen() then return end; OnChanged(not Data.Value) end)
            OnChanged(Value)
            local lov=LockOv(R.Frame,Args.LockMessage); local obj={}
            function obj:SetTitle(v) if TitleLbl then TitleLbl.Text=tostring(v) end end
            function obj:SetDesc(v)  local d=Left:FindFirstChild("Desc"); if d then d.Text=tostring(v) end end
            function obj:SetValue(v) OnChanged(v) end; function obj:GetValue() return Data.Value end
            function obj:Lock(m) lov.Visible=true; if m then lov:FindFirstChildWhichIsA("TextLabel",true).Text=m end end
            function obj:Unlock() lov.Visible=false end; function obj:Destroy() R.Frame:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v) rawset(t,k,v); if k=="Title" and TitleLbl then TitleLbl.Text=tostring(v) elseif k=="Value" then OnChanged(v) end end,
                __index=function(t,k) if k=="Value" then return Data.Value end; return rawget(t,k) end})
            return obj
        end

        function Page:Slider(Args)
            local Min=Args.Min or 0; local Max=Args.Max or 100
            local Rounding=Args.Rounding or 0; local Value=Args.Value or Min
            local Suffix=Args.Suffix or ""; local Callback=Args.Callback or function()end
            local SaveKey=Args.save and (Args.Title or tostring(Args.save))
            if SaveKey and Cfg:getval(SaveKey)~=nil then Value=Cfg:getval(SaveKey) end
            local SF=Library:Create("Frame",{Name="Slider",Parent=PS,BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.new(1,0,0,50)})
            Library:Create("UICorner",{Parent=SF,CornerRadius=UDim.new(0,5)}); Library:Create("UIStroke",{Parent=SF,Color=T.Stroke,Thickness=0.5})
            local TitleLbl=Library:Create("TextLabel",{Name="Title",Parent=SF,BackgroundTransparency=1,BorderSizePixel=0,
                Position=UDim2.new(0,14,0,10),Size=UDim2.new(1,-78,0,14),Font=Enum.Font.GothamSemibold,RichText=true,
                Text=Args.Title or "",TextColor3=T.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false})
            if Args.Title and Args.Title~="" then MkGrad(TitleLbl) end
            local ValueBox=Library:Create("TextBox",{Name="ValBox",Parent=SF,BackgroundTransparency=1,BorderSizePixel=0,
                AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,10),Size=UDim2.new(0,62,0,14),
                Font=Enum.Font.GothamMedium,Text=tostring(Value),TextColor3=T.SubText,TextSize=11,TextTransparency=0.3,
                TextXAlignment=Enum.TextXAlignment.Right,TextWrapped=false,ClearTextOnFocus=false})
            local BarTrack=Library:Create("Frame",{Name="BarTrack",Parent=SF,BackgroundColor3=Color3.fromRGB(30,30,30),BorderSizePixel=0,
                Position=UDim2.new(0,14,0,32),Size=UDim2.new(1,-28,0,6),ClipsDescendants=false})
            Library:Create("UICorner",{Parent=BarTrack,CornerRadius=UDim.new(0,3)})
            local Fill=Library:Create("Frame",{Name="Fill",Parent=BarTrack,BackgroundColor3=T.Accent,BorderSizePixel=0,Size=UDim2.new(0,0,1,0),ClipsDescendants=false})
            rA(Fill,"BackgroundColor3"); Library:Create("UICorner",{Parent=Fill,CornerRadius=UDim.new(0,3)}); BtnGrad(Fill)
            local Knob=Library:Create("Frame",{Name="Knob",Parent=SF,BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,
                AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0,14,0,35),Size=UDim2.new(0,14,0,14)})
            Library:Create("UICorner",{Parent=Knob,CornerRadius=UDim.new(1,0)}); Library:Create("UIStroke",{Parent=Knob,Color=Color3.fromRGB(160,160,160),Thickness=0.5})
            local dragging=false; local Data={Value=Value}
            local function Round(n,d) return math.floor(n*(10^d)+0.5)/(10^d) end
            local function Redraw(pct)
                local tW=BarTrack.AbsoluteSize.X
                if tW<=0 then return end
                Fill.Size=UDim2.new(pct,0,1,0)
                Knob.Position=UDim2.new(0,14+pct*tW,0,35)
            end
            local function UpdateSlider(val)
                val=math.clamp(val,Min,Max); val=Round(val,Rounding); Data.Value=val
                if SaveKey then Cfg:setval(SaveKey,val) end
                local pct=(val-Min)/(Max-Min)
                Redraw(pct)
                ValueBox.Text=tostring(val)..(Suffix~="" and (" "..Suffix) or "")
                pcall(Callback,val); return val
            end
            local function GetVal(inp)
                local ax=BarTrack.AbsolutePosition.X; local aw=BarTrack.AbsoluteSize.X
                if aw<=0 then return Value end
                return math.clamp((inp.Position.X-ax)/aw,0,1)*(Max-Min)+Min
            end
            local function SetDrag(s)
                dragging=s
                Library:Tween({v=ValueBox,t=0.12,s="Exponential",d="Out",g={TextColor3=s and T.Accent or T.SubText,TextTransparency=s and 0 or 0.3}}):Play()
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
                if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then UpdateSlider(GetVal(inp)) end
            end)
            ValueBox.Focused:Connect(function() Library:Tween({v=ValueBox,t=0.12,s="Exponential",d="Out",g={TextColor3=T.Accent,TextTransparency=0}}):Play() end)
            ValueBox.FocusLost:Connect(function()
                Library:Tween({v=ValueBox,t=0.12,s="Exponential",d="Out",g={TextColor3=T.SubText,TextTransparency=0.3}}):Play()
                Value=UpdateSlider(tonumber(ValueBox.Text:match("%-?%d+%.?%d*")) or Value)
            end)
            BarTrack:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                local pct=(Data.Value-Min)/(Max-Min); Redraw(pct)
            end)
            task.spawn(function()
                local t0=tick()
                while tick()-t0<10 do
                    RunService.Heartbeat:Wait()
                    if BarTrack.AbsoluteSize.X>0 then
                        local pct=(Data.Value-Min)/(Max-Min); Redraw(pct)
                        break
                    end
                end
            end)
            local lov=LockOv(SF,Args.LockMessage); local obj={}
            function obj:SetTitle(v) TitleLbl.Text=tostring(v) end
            function obj:SetValue(v) UpdateSlider(v) end
            function obj:SetMin(v) Min=v end; function obj:SetMax(v) Max=v end
            function obj:GetValue() return Data.Value end
            function obj:Lock(m) lov.Visible=true; if m then lov:FindFirstChildWhichIsA("TextLabel",true).Text=m end end
            function obj:Unlock() lov.Visible=false end; function obj:Destroy() SF:Destroy() end
            setmetatable(obj,{
                __newindex=function(t,k,v) rawset(t,k,v)
                    if k=="Title" then TitleLbl.Text=tostring(v)
                    elseif k=="Value" then UpdateSlider(v)
                    elseif k=="Min" then Min=v
                    elseif k=="Max" then Max=v end end,
                __index=function(t,k) if k=="Value" then return Data.Value end; return rawget(t,k) end})
            return obj
        end

        function Page:Input(Args)
            local Value=Args.Value or ""; local Callback=Args.Callback or function()end
            local Placeholder=Args.Placeholder or "Type here..."; local COS=Args.ClearOnSubmit or false
            local MultiLine=Args.MultiLine or false; local Lines=Args.Lines or 4; local ShowEnter=Args.ShowButton~=false
            local SaveKey=Args.save and (Args.Title or tostring(Args.save))
            if SaveKey and Cfg:getval(SaveKey)~=nil then Value=Cfg:getval(SaveKey) end
            if MultiLine then
                local TA=Library:Create("Frame",{Name="TextArea",Parent=PS,BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.new(1,0,0,Lines*16+22)})
                Library:Create("UICorner",{Parent=TA,CornerRadius=UDim.new(0,5)}); Library:Create("UIStroke",{Parent=TA,Color=T.Stroke,Thickness=0.5})
                Library:Create("UIPadding",{Parent=TA,PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,10)})
                if Args.Title and Args.Title~="" then Library:Create("TextLabel",{Parent=TA,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0,0,0,0),Size=UDim2.new(1,0,0,13),Font=Enum.Font.GothamSemibold,Text=Args.Title,TextColor3=T.SubText,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left}) end
                local yOff=(Args.Title and Args.Title~="") and 16 or 0
                local TB=Library:Create("TextBox",{Parent=TA,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0,0,0,yOff),Size=UDim2.new(1,0,1,-yOff),Font=Enum.Font.GothamMedium,PlaceholderColor3=Color3.fromRGB(68,68,68),PlaceholderText=Placeholder,Text=tostring(Value),TextColor3=Color3.fromRGB(200,200,200),TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,MultiLine=true,ClearTextOnFocus=false})
                TB.FocusLost:Connect(function(e) if e and not _locked then pcall(Callback,TB.Text); if SaveKey then Cfg:setval(SaveKey,TB.Text) end end end)
                local obj={}; function obj:SetValue(v) TB.Text=tostring(v) end; function obj:SetPlaceholder(v) TB.PlaceholderText=tostring(v) end; function obj:GetValue() return TB.Text end; function obj:Destroy() TA:Destroy() end
                setmetatable(obj,{__newindex=function(t,k,v) rawset(t,k,v); if k=="Value" then TB.Text=tostring(v) elseif k=="Placeholder" then TB.PlaceholderText=tostring(v) end end,__index=function(t,k) if k=="Value" then return TB.Text end; return rawget(t,k) end})
                return obj
            end
            local IF=Library:Create("Frame",{Name="InputFrame",Parent=PS,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,36)})
            Library:Create("UIListLayout",{Parent=IF,Padding=UDim.new(0,6),FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center})
            local frontW=ShowEnter and UDim2.new(1,-44,1,0) or UDim2.new(1,0,1,0)
            local Front=Library:Create("Frame",{Name="Front",Parent=IF,BackgroundColor3=T.Row,BorderSizePixel=0,Size=frontW,LayoutOrder=1})
            Library:Create("UICorner",{Parent=Front,CornerRadius=UDim.new(0,5)}); Library:Create("UIStroke",{Parent=Front,Color=T.Stroke,Thickness=0.5})
            Library:Create("UIPadding",{Parent=Front,PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,8)})
            local TB=Library:Create("TextBox",{Parent=Front,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),Font=Enum.Font.GothamMedium,PlaceholderColor3=Color3.fromRGB(68,68,68),PlaceholderText=Placeholder,Text=tostring(Value),TextColor3=Color3.fromRGB(200,200,200),TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=false,ClearTextOnFocus=false})
            TB.FocusLost:Connect(function(e) if e then if not _locked then pcall(Callback,TB.Text); if SaveKey then Cfg:setval(SaveKey,TB.Text) end end; if COS then TB.Text="" end end end)
            if ShowEnter then
                local Enter=Library:Create("TextButton",{Name="Enter",Parent=IF,BackgroundColor3=T.RowAlt,BorderSizePixel=0,Size=UDim2.new(0,36,0,36),Text="",AutoButtonColor=false,ClipsDescendants=true,LayoutOrder=2})
                rAlt(Enter,"BackgroundColor3")
                Library:Create("UICorner",{Parent=Enter,CornerRadius=UDim.new(0,5)})
                Library:Create("UIStroke",{Parent=Enter,Color=T.Stroke,Thickness=0.5})
                Library:Create("ImageLabel",{Parent=Enter,AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,16,0,16),Image="rbxassetid://78020815235467",ImageColor3=T.SubText})
                local copied=false
                Enter.MouseButton1Click:Connect(function()
                    if copied then return end
                    Ripple(Enter)
                    if Exec.clipboard then VClip(TB.Text) end
                    copied=true
                    local ck=Enter:FindFirstChildWhichIsA("ImageLabel"); if ck then ck.Image="rbxassetid://121742282171603"; ck.ImageColor3=T.Accent end
                    task.delay(1.5,function()
                        if Enter and Enter.Parent then
                            local ck2=Enter:FindFirstChildWhichIsA("ImageLabel"); if ck2 then ck2.Image="rbxassetid://78020815235467"; ck2.ImageColor3=T.SubText end
                            copied=false
                        end
                    end)
                end)
            end
            local lov=LockOv(IF,Args.LockMessage); local obj={}
            function obj:SetPlaceholder(v) TB.PlaceholderText=tostring(v) end; function obj:SetValue(v) TB.Text=tostring(v) end; function obj:GetValue() return TB.Text end
            function obj:Lock(m) lov.Visible=true; if m then lov:FindFirstChildWhichIsA("TextLabel",true).Text=m end end; function obj:Unlock() lov.Visible=false end; function obj:Destroy() IF:Destroy() end
            setmetatable(obj,{__newindex=function(t,k,v) rawset(t,k,v); if k=="Value" then TB.Text=tostring(v) elseif k=="Placeholder" then TB.PlaceholderText=tostring(v) end end,__index=function(t,k) if k=="Value" then return TB.Text end; return rawget(t,k) end})
            return obj
        end

        function Page:Dropdown(Args)
            local DTitle=Args.Title; local List=Args.List or {}; local Value=Args.Value
            local Callback=Args.Callback or function()end; local IsMulti=typeof(Value)=="table"
            local Placeholder=Args.Placeholder or "Select..."; local ShowSearch=Args.Search~=false
            local SaveKey=Args.save and (Args.Title or tostring(Args.save))
            if SaveKey and Cfg:getval(SaveKey)~=nil then Value=Cfg:getval(SaveKey) end
            local R=Library:NewRows(PS,DTitle,nil,T); local Right=R.Right; local Left=R.Left
            Library:Create("ImageLabel",{Parent=Right,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0,18,0,18),Image="rbxassetid://132291592681506",ImageTransparency=0.5,ImageColor3=T.SubText})
            local Open=Library:Button(R.Frame)
            local function GetText() if IsMulti then return type(Value)=="table" and #Value>0 and table.concat(Value,", ") or Placeholder end; return Value~=nil and tostring(Value) or Placeholder end
            local DescEl=Left:FindFirstChild("Desc"); if DescEl then DescEl.Text=GetText(); DescEl.Visible=true end
            local DF=Library:Create("Frame",{Name="Dropdown",Parent=Background,AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.DropBg,BorderSizePixel=0,Position=UDim2.new(0.5,0,0.3,0),Size=UDim2.new(0,300,0,ShowSearch and 255 or 220),ZIndex=500,Visible=false})
            rDB(DF,"BackgroundColor3"); Library:Create("UICorner",{Parent=DF,CornerRadius=UDim.new(0,6)}); Library:Create("UIStroke",{Parent=DF,Color=T.Stroke,Thickness=0.6})
            Library:Create("UIListLayout",{Parent=DF,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center})
            Library:Create("UIPadding",{Parent=DF,PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),PaddingTop=UDim.new(0,10)})
            local DHead=Library:Create("Frame",{Parent=DF,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-5,Size=UDim2.new(1,0,0,34),ZIndex=500})
            Library:Create("UIListLayout",{Parent=DHead,SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,1)})
            local DTL=Library:Create("TextLabel",{Name="Title",Parent=DHead,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,15),ZIndex=500,Font=Enum.Font.GothamBold,RichText=true,Text=DTitle or "",TextColor3=T.Accent,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left}); rA(DTL,"TextColor3")
            local D1=Library:Create("TextLabel",{Name="Desc",Parent=DHead,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,11),ZIndex=500,Font=Enum.Font.GothamMedium,Text=GetText(),TextColor3=T.SubText,TextSize=10,TextTransparency=0.4,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left})
            local SearchBox
            if ShowSearch then
                local SIF=Library:Create("Frame",{Parent=DF,BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=-4,Size=UDim2.new(1,0,0,28),ZIndex=500})
                local SF2=Library:Create("Frame",{Parent=SIF,BackgroundColor3=Color3.fromRGB(22,22,22),BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=500})
                Library:Create("UICorner",{Parent=SF2,CornerRadius=UDim.new(0,5)}); Library:Create("UIStroke",{Parent=SF2,Color=T.Stroke,Thickness=0.5})
                SearchBox=Library:Create("TextBox",{Parent=SF2,AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,-16,1,0),ZIndex=500,Font=Enum.Font.GothamMedium,PlaceholderColor3=Color3.fromRGB(68,68,68),PlaceholderText="Search...",Text="",TextColor3=T.Text,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false})
            end
            local List1=Library:Create("ScrollingFrame",{Name="List",Parent=DF,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,ShowSearch and 148 or 162),ZIndex=500,ScrollBarThickness=2,ScrollBarImageColor3=T.Stroke})
            local SL=Library:Create("UIListLayout",{Parent=List1,Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center})
            Library:Create("UIPadding",{Parent=List1,PaddingLeft=UDim.new(0,1),PaddingRight=UDim.new(0,1)})
            SL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() List1.CanvasSize=UDim2.new(0,0,0,SL.AbsoluteContentSize.Y+10) end)
            local selVals={}; local selOrd=0
            local function isInT(v,t2) if type(t2)~="table" then return false end; for _,x in pairs(t2) do if x==v then return true end end; return false end
            local function SetText() local txt=IsMulti and table.concat(Value,", ") or tostring(Value); D1.Text=txt; if DescEl then DescEl.Text=txt end; if SaveKey then Cfg:setval(SaveKey,Value) end end
            local isOpen=false
            UserInputService.InputBegan:Connect(function(A) if not isOpen then return end; if A.UserInputType~=Enum.UserInputType.MouseButton1 and A.UserInputType~=Enum.UserInputType.Touch then return end; local m=LocalPlayer:GetMouse(); local dp,ds=DF.AbsolutePosition,DF.AbsoluteSize; if not(m.X>=dp.X and m.X<=dp.X+ds.X and m.Y>=dp.Y and m.Y<=dp.Y+ds.Y) then isOpen=false; DF.Visible=false; DF.Position=UDim2.new(0.5,0,0.3,0) end end)
            Open.MouseButton1Click:Connect(function() if _locked then return end; if Library:IsDropdownOpen() and not isOpen then return end; isOpen=not isOpen; if isOpen then DF.Visible=true; Library:Tween({v=DF,t=0.25,s="Back",d="Out",g={Position=UDim2.new(0.5,0,0.5,0)}}):Play() else DF.Visible=false; DF.Position=UDim2.new(0.5,0,0.3,0) end end)
            local Setting={}
            function Setting:Close() isOpen=false; DF.Visible=false; DF.Position=UDim2.new(0.5,0,0.3,0) end
            function Setting:Clear(a) for _,v in ipairs(List1:GetChildren()) do if v:IsA("Frame") then local s=a==nil or (type(a)=="string" and v:FindFirstChild("Title") and v.Title.Text==a) or (type(a)=="table" and v:FindFirstChild("Title") and isInT(v.Title.Text,a)); if s then v:Destroy() end end end; if a==nil then Value=IsMulti and {} or nil; selVals={}; selOrd=0; D1.Text=Placeholder; if DescEl then DescEl.Text=Placeholder end end end
            function Setting:SetList(nl) Setting:Clear(); List=nl; for _,n in ipairs(nl) do Setting:AddList(n) end end
            function Setting:SetValue(val) if IsMulti then if type(val)~="table" then val={val} end; Value=val; selVals={}; selOrd=0; for _,v in pairs(List1:GetChildren()) do if v:IsA("Frame") and v.Name=="Item" and v:FindFirstChild("Title") then local s=isInT(v.Title.Text,val); v.Title.TextColor3=s and T.Accent or T.Text; v.BackgroundTransparency=s and 0.82 or 1; if s then selOrd=selOrd-1; selVals[v.Title.Text]=selOrd; v.LayoutOrder=selOrd else v.LayoutOrder=0 end end end; SetText(); pcall(Callback,val) else Value=val; for _,v in pairs(List1:GetChildren()) do if v:IsA("Frame") and v.Name=="Item" and v:FindFirstChild("Title") then v.Title.TextColor3=v.Title.Text==tostring(val) and T.Accent or T.Text; v.BackgroundTransparency=v.Title.Text==tostring(val) and 0.82 or 1 end end; SetText(); pcall(Callback,val) end end
            function Setting:AddList(Name)
                local Item=Library:Create("Frame",{Name="Item",Parent=List1,BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,LayoutOrder=0,Size=UDim2.new(1,0,0,28),ZIndex=500})
                Library:Create("UICorner",{Parent=Item,CornerRadius=UDim.new(0,5)}); Library:Create("UIPadding",{Parent=Item,PaddingLeft=UDim.new(0,10)})
                local IT=Library:Create("TextLabel",{Name="Title",Parent=Item,AnchorPoint=Vector2.new(0,0.5),BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,-10,0,14),ZIndex=500,Font=Enum.Font.GothamMedium,RichText=true,Text=tostring(Name),TextColor3=T.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=false,TextTruncate=Enum.TextTruncate.AtEnd}); rTxt(IT,"TextColor3")
                local function OV(v) IT.TextColor3=v and T.Accent or T.Text; Library:Tween({v=Item,t=0.15,s="Linear",d="Out",g={BackgroundTransparency=v and 0.82 or 1}}):Play() end
                local IC=Library:Button(Item)
                local function OnSel() if IsMulti then if selVals[Name] then selVals[Name]=nil; Item.LayoutOrder=0; OV(false) else selOrd=selOrd-1; selVals[Name]=selOrd; Item.LayoutOrder=selOrd; OV(true) end; local s={}; for i in pairs(selVals) do table.insert(s,i) end; if #s>0 then table.sort(s); Value=s; SetText() else D1.Text=Placeholder; if DescEl then DescEl.Text=Placeholder end end; pcall(Callback,s) else for _,v in pairs(List1:GetChildren()) do if v:IsA("Frame") and v.Name=="Item" then v.Title.TextColor3=T.Text; Library:Tween({v=v,t=0.15,s="Linear",d="Out",g={BackgroundTransparency=1}}):Play() end end; OV(true); Value=Name; SetText(); pcall(Callback,Value) end end
                delay(0,function() if IsMulti then if isInT(Name,Value) then selOrd=selOrd-1; selVals[Name]=selOrd; Item.LayoutOrder=selOrd; OV(true); local s={}; for i in pairs(selVals) do table.insert(s,i) end; if #s>0 then table.sort(s); SetText() else D1.Text=Placeholder; if DescEl then DescEl.Text=Placeholder end end end else if Name==Value then OV(true); SetText() end end end)
                IC.MouseButton1Click:Connect(OnSel); return Item
            end
            function Setting:RemoveItem(Name) for _,v in ipairs(List1:GetChildren()) do if v:IsA("Frame") and v.Name=="Item" and v:FindFirstChild("Title") and v.Title.Text==tostring(Name) then v:Destroy(); return true end end; return false end
            function Setting:GetValue() return Value end; function Setting:SetTitle(t) DTL.Text=tostring(t) end; function Setting:SetPlaceholder(p) Placeholder=p; if SearchBox then SearchBox.PlaceholderText=p end end
            function Setting:Destroy() R.Frame:Destroy(); DF:Destroy() end
            if SearchBox then SearchBox.Changed:Connect(function() local s=string.lower(SearchBox.Text); for _,v in pairs(List1:GetChildren()) do if v:IsA("Frame") and v.Name=="Item" and v:FindFirstChild("Title") then v.Visible=string.find(string.lower(v.Title.Text),s,1,true)~=nil end end end) end
            for _,n in ipairs(List) do Setting:AddList(n) end
            return Setting
        end

        function Page:Keybind(Args)
            local Value=Args.Value or Enum.KeyCode.Unknown; local Callback=Args.Callback or function()end
            local SaveKey=Args.save and (Args.Title or tostring(Args.save))
            if SaveKey and Cfg:getval(SaveKey)~=nil then local sv=Cfg:getval(SaveKey); if Enum.KeyCode[sv] then Value=Enum.KeyCode[sv] end end
            local R=Library:NewRows(PS,Args.Title,Args.Desc,T); local Right=R.Right; local Left=R.Left
            local KB=Library:Create("Frame",{Name="KeyBind",Parent=Right,BackgroundColor3=T.RowAlt,BorderSizePixel=0,Size=UDim2.new(0,84,0,26),ClipsDescendants=true})
            Library:Create("UICorner",{Parent=KB,CornerRadius=UDim.new(0,5)}); Library:Create("UIStroke",{Parent=KB,Color=T.Stroke,Thickness=0.5}); rAlt(KB,"BackgroundColor3")
            local KL=Library:Create("TextLabel",{Parent=KB,AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(1,-8,1,0),Font=Enum.Font.GothamSemibold,Text=tostring(Value.Name),TextColor3=T.Accent,TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd}); rA(KL,"TextColor3")
            local CBK=Library:Button(KB); local listening=false; local Data={Value=Value}
            local function SetKey(k) Data.Value=k; KL.Text=tostring(k.Name); KL.TextColor3=T.Accent; if SaveKey then Cfg:setval(SaveKey,k.Name) end; Library:Tween({v=KB,t=0.18,s="Exponential",d="Out",g={BackgroundColor3=T.RowAlt}}):Play(); pcall(Callback,k) end
            CBK.MouseButton1Click:Connect(function() if _locked or Library:IsDropdownOpen() then return end; if listening then return end; listening=true; KL.Text="..."; KL.TextColor3=T.Text; Library:Tween({v=KB,t=0.18,s="Exponential",d="Out",g={BackgroundColor3=T.Stroke}}):Play(); local conn; conn=UserInputService.InputBegan:Connect(function(inp,proc) if proc then return end; if inp.UserInputType==Enum.UserInputType.Keyboard then listening=false; conn:Disconnect(); SetKey(inp.KeyCode) end end) end)
            UserInputService.InputBegan:Connect(function(inp,proc) if proc or listening then return end; if inp.KeyCode==Data.Value then pcall(Callback,Data.Value) end end)
            local lov=LockOv(R.Frame,Args.LockMessage); local obj={}
            function obj:SetTitle(v) local t=Left:FindFirstChild("Title");if t then t.Text=tostring(v) end end
            function obj:SetDesc(v)  local d=Left:FindFirstChild("Desc"); if d then d.Text=tostring(v) end end
            function obj:SetValue(v) SetKey(v) end; function obj:GetValue() return Data.Value end
            function obj:Lock(m) lov.Visible=true; if m then lov:FindFirstChildWhichIsA("TextLabel",true).Text=m end end; function obj:Unlock() lov.Visible=false end; function obj:Destroy() R.Frame:Destroy() end
            setmetatable(obj,{__newindex=function(t,k,v) rawset(t,k,v); if k=="Value" then SetKey(v) end end,__index=function(t,k) if k=="Value" then return Data.Value end; return rawget(t,k) end})
            return obj
        end

        function Page:ColorPicker(Args)
            local R=Library:NewRows(PS,Args.Title,Args.Desc,T)
            local obj={}
            function obj:SetTitle(v) local t=R.Left:FindFirstChild("Title");if t then t.Text=tostring(v) end end
            function obj:SetValue(v) end; function obj:GetValue() return Color3.fromRGB(255,255,255) end
            function obj:Lock(m) end; function obj:Unlock() end; function obj:Destroy() R.Frame:Destroy() end
            return obj
        end

        function Page:RightLabel(Args)
            local R=Library:NewRows(PS,Args.Title,Args.Desc,T); local Right=R.Right; local Left=R.Left
            local Lbl=Library:Create("TextLabel",{Name="RLabel",Parent=Right,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(0,0,0,14),AutomaticSize=Enum.AutomaticSize.X,Font=Enum.Font.GothamSemibold,RichText=true,Text=Args.Right or "—",TextColor3=T.SubText,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right})
            local obj={}
            function obj:SetTitle(v) local t=Left:FindFirstChild("Title");if t then t.Text=tostring(v) end end; function obj:SetDesc(v) local d=Left:FindFirstChild("Desc"); if d then d.Text=tostring(v) end end
            function obj:SetRight(v) Lbl.Text=tostring(v) end; function obj:Destroy() R.Frame:Destroy() end
            setmetatable(obj,{__newindex=function(t,k,v) rawset(t,k,v); if k=="Right" then Lbl.Text=tostring(v) end end,__index=function(t,k) if k=="Right" then return Lbl.Text end; return rawget(t,k) end})
            return obj
        end

        function Page:Progress(Args)
            local Value=math.clamp(Args.Value or 0,0,100); local Max=Args.Max or 100; local Suffix=Args.Suffix or "%"
            local SF=Library:Create("Frame",{Name="Progress",Parent=PS,BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.new(1,0,0,50)})
            Library:Create("UICorner",{Parent=SF,CornerRadius=UDim.new(0,5)}); Library:Create("UIStroke",{Parent=SF,Color=T.Stroke,Thickness=0.5})
            local TitleLbl=Library:Create("TextLabel",{Name="Title",Parent=SF,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0,14,0,10),Size=UDim2.new(1,-78,0,14),Font=Enum.Font.GothamSemibold,Text=Args.Title or "",TextColor3=T.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left})
            if Args.Title and Args.Title~="" then MkGrad(TitleLbl) end
            local ValLbl=Library:Create("TextLabel",{Parent=SF,BackgroundTransparency=1,BorderSizePixel=0,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,10),Size=UDim2.new(0,62,0,14),Font=Enum.Font.GothamMedium,Text=tostring(Value)..Suffix,TextColor3=T.SubText,TextSize=11,TextTransparency=0.3,TextXAlignment=Enum.TextXAlignment.Right})
            local BarBg=Library:Create("Frame",{Parent=SF,BackgroundColor3=Color3.fromRGB(28,28,28),BorderSizePixel=0,Position=UDim2.new(0,14,0,32),Size=UDim2.new(1,-28,0,6)})
            Library:Create("UICorner",{Parent=BarBg,CornerRadius=UDim.new(0,3)})
            local BarFill=Library:Create("Frame",{Parent=BarBg,BackgroundColor3=Args.Color and RC(Args.Color) or T.Accent,BorderSizePixel=0,Size=UDim2.new(Value/Max,0,1,0)})
            Library:Create("UICorner",{Parent=BarFill,CornerRadius=UDim.new(0,3)}); BtnGrad(BarFill); if not Args.Color then rA(BarFill,"BackgroundColor3") end
            local Data={Value=Value}
            local function SetVal(v) v=math.clamp(v,0,Max); Data.Value=v; Library:Tween({v=BarFill,t=0.3,s="Exponential",d="Out",g={Size=UDim2.new(v/Max,0,1,0)}}):Play(); ValLbl.Text=tostring(math.floor(v))..Suffix end
            local obj={}; function obj:SetValue(v) SetVal(v) end; function obj:GetValue() return Data.Value end; function obj:SetTitle(v) TitleLbl.Text=tostring(v) end; function obj:SetColor(v) BarFill.BackgroundColor3=RC(v) end; function obj:Destroy() SF:Destroy() end
            setmetatable(obj,{__newindex=function(t,k,v) rawset(t,k,v); if k=="Value" then SetVal(v) elseif k=="Title" then TitleLbl.Text=tostring(v) end end,__index=function(t,k) if k=="Value" then return Data.Value end; return rawget(t,k) end})
            return obj
        end

        function Page:MultiButton(Args)
            local MTitle=Args.Title; local Buttons=Args.Buttons or {}
            local SF=Library:Create("Frame",{Name="MultiBtn",Parent=PS,BackgroundColor3=T.Row,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y})
            Library:Create("UICorner",{Parent=SF,CornerRadius=UDim.new(0,5)}); Library:Create("UIStroke",{Parent=SF,Color=T.Stroke,Thickness=0.5})
            Library:Create("UIPadding",{Parent=SF,PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)})
            Library:Create("UIListLayout",{Parent=SF,FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,8)})
            if MTitle and MTitle~="" then
                local TL=Library:Create("TextLabel",{Name="Title",Parent=SF,BackgroundTransparency=1,BorderSizePixel=0,
                    LayoutOrder=1,Size=UDim2.new(1,0,0,14),Font=Enum.Font.GothamSemibold,RichText=true,
                    Text=MTitle,TextColor3=T.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left})
                MkGrad(TL)
            end
            local BtnRow=Library:Create("Frame",{Parent=SF,BackgroundTransparency=1,BorderSizePixel=0,
                LayoutOrder=2,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y})
            Library:Create("UIListLayout",{Parent=BtnRow,FillDirection=Enum.FillDirection.Horizontal,
                SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6),VerticalAlignment=Enum.VerticalAlignment.Center,Wraps=true})
            local ts=game:GetService("TextService")
            for _,bd in ipairs(Buttons) do
                local label=bd.Text or "Btn"
                local tw=ts:GetTextSize(label,11,Enum.Font.GothamSemibold,Vector2.new(200,28)).X
                local btnW=math.clamp(tw+28,48,200)
                local Btn=Library:Create("TextButton",{Parent=BtnRow,BackgroundColor3=bd.Color and RC(bd.Color) or T.Accent,BorderSizePixel=0,
                    Size=UDim2.new(0,btnW,0,28),Font=Enum.Font.GothamSemibold,Text=label,
                    TextColor3=Color3.fromRGB(255,255,255),TextSize=11,ClipsDescendants=true,AutoButtonColor=false})
                Library:Create("UICorner",{Parent=Btn,CornerRadius=UDim.new(0,5)})
                if not bd.Color then rA(Btn,"BackgroundColor3") end; BtnGrad(Btn)
                Btn.MouseButton1Click:Connect(function() if _locked then return end; Ripple(Btn); if bd.Callback then pcall(bd.Callback) end end)
            end
            local obj={}; function obj:Destroy() SF:Destroy() end; return obj
        end

        function Page:Banner(asset)
            local B=Library:Create("ImageLabel",{Name="Banner",Parent=PS,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,200),Image=Library:Asset(asset),ScaleType=Enum.ScaleType.Crop})
            Library:Create("UICorner",{Parent=B,CornerRadius=UDim.new(0,5)})
            local obj={}; function obj:SetImage(v) B.Image=Library:Asset(v) end; function obj:SetSize(v) B.Size=v end; function obj:Destroy() B:Destroy() end; return obj
        end

        return Page
    end

    function Library:SetTimeValue(v) THETIME.Text=tostring(v); THETIME.Visible=tostring(v)~="" end
    function Library:SetTimer(fn)
        if fn==false or fn==nil then THETIME.Visible=false; THETIME.Text=""; return end
        THETIME.Visible=true
        if type(fn)=="function" then
            task.spawn(function()
                while THETIME and THETIME.Parent do
                    local ok,v=pcall(fn); if ok and v then THETIME.Text=tostring(v) end; task.wait(1)
                end
            end)
        else
            local startT=tick()
            task.spawn(function()
                while THETIME and THETIME.Parent do
                    local e=tick()-startT
                    THETIME.Text=string.format("%02d:%02d:%02d",math.floor(e/3600),math.floor((e%3600)/60),math.floor(e%60))
                    task.wait(1)
                end
            end)
        end
    end
    function Library:SetWindowTitle(v)    if TitleLabel    then TitleLabel.Text=tostring(v)    end end
    function Library:SetWindowSubTitle(v) if SubTitleLabel then SubTitleLabel.Text=tostring(v) end end

    function Library:AddSizeSlider(Page)
        return Page:Slider({Title="Interface Scale",Min=0.35,Max=math.floor(MaxSc()*10+0.5)/10,Rounding=2,Value=Scaler.Scale,
            Callback=function(v) Scaler:SetAttribute("ManualScale",true); Scaler.Scale=CS(v) end})
    end

    function Library:SetTheme(nt)
        if nt.BG  then nt.Background=nt.BG;  nt.BG=nil  end
        if nt.Tab then nt.TabBg=nt.Tab;       nt.Tab=nil end
        for k,v in pairs(nt) do T[k]=RC(v) end
        if T.Accent then T_ACCENT_FALLBACK=T.Accent end
        local function Apply(list,val) for _,r in ipairs(list) do local i,p=r[1],r[2]; if i and i.Parent then pcall(function() i[p]=val end) end end end
        Apply(_R.a,T.Accent);   Apply(_R.bg,T.Background); Apply(_R.row,T.Row)
        Apply(_R.alt,T.RowAlt); Apply(_R.str,T.Stroke);    Apply(_R.txt,T.Text)
        Apply(_R.sub,T.SubText);Apply(_R.tb,T.TabBg);      Apply(_R.ts,T.TabStroke)
        Apply(_R.ti,T.TabImage);Apply(_R.db,T.DropBg)
    end

    function Library:GetTheme() local c={}; for k,v in pairs(T) do c[k]=v end; return c end
    function Library:SetPillIcon(icon) if PillLogo then PillLogo.Image=Library:Asset(icon) end end
    function Library:SetLockText(msg)  _lockMsg=msg end
    function Library:Lock()            _locked=true  end
    function Library:Unlock()          _locked=false end
    function Library:IsLocked()        return _locked end
    function Library:Destroy()
        pcall(function() Xova:Destroy() end)
        pcall(function() ToggleScreen:Destroy() end)
        pcall(function() NotifGui:Destroy() end)
    end

    return Window
end

return Library
