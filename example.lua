local Library = loadstring(game:HttpGet("YOUR_RAW_URL"))()

local Window = Library:Window({
    Title             = "Vita Script",
    SubTitle          = "v0.1",
    ToggleKey         = Enum.KeyCode.RightControl,
    BbIcon            = "settings",
    AutoScale         = true,
    Scale             = 1.45,
    ExecIdentifyShown = true,
    Theme = {
        Accent    = "#FF007F",
        Background= "#0D0D0D",
        Row       = "#0F0F0F",
        TabBg     = "#0A0A0A",
        TabStroke = "#4B0026",
        TabImage  = "#FF007F",
    }
})

local Cfg = Library.Config
Cfg:Create("default", { speed=16, esp=false })
Cfg:SetActive("default")

local MovePage = Window:NewPage({
    Title    = "Movement",
    Desc     = "Speed & Fly",
    Icon     = "zap",
    TabImage = "#FF007F"
})

MovePage:Section("Speed")

local SpeedSlider = MovePage:Slider({
    Title    = "Walk Speed",
    Icon     = "activity",
    Min      = 0,
    Max      = 250,
    Rounding = 1,
    Value    = Cfg:GetValue("speed") or 16,
    Suffix   = "st/s",
    Callback = function(v)
        Cfg:SetValue("speed", v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = v
        end
    end
})

local FlyToggle = MovePage:Toggle({
    Title    = "Fly",
    Desc     = "Enable noclip fly",
    Icon     = "wind",
    Value    = false,
    Callback = function(v) print("Fly:", v) end
})

MovePage:Button({
    Title    = "Reset Speed",
    Text     = "Reset",
    Icon     = "rotate-ccw",
    Callback = function()
        SpeedSlider:SetValue(16)
        Cfg:SetValue("speed", 16)
        Library:Notification({Title="Reset",Desc="Speed reset to 16.",Duration=2,Type="Info"})
    end
})

local VisPage = Window:NewPage({
    Title    = "Visuals",
    Desc     = "ESP & Highlights",
    Icon     = "eye",
    TabImage = "#0088FF"
})

VisPage:Section("ESP")

local EspToggle = VisPage:Toggle({
    Title    = "Enable ESP",
    Desc     = "Player highlights",
    Icon     = "eye",
    Value    = Cfg:GetValue("esp") or false,
    Callback = function(v)
        Cfg:SetValue("esp", v)
    end
})

local EspColor = VisPage:ColorPicker({
    Title    = "ESP Color",
    Desc     = "Highlight color",
    Icon     = "palette",
    Value    = Color3.fromRGB(255, 0, 127),
    Callback = function(c) print("Color:", c) end
})

VisPage:Paragraph({
    Title         = "TestUser",
    Desc          = "Distance: 42 studs",
    Color         = "#111111",
    ImageMode     = "beside",
    Image         = "user",
    ImageSize     = 18,
    Thumbnail     = "https://www.roblox.com/headshot-thumbnail/image?userId=1&width=48&height=48&format=png",
    ThumbnailSize = 44,
    Buttons = {
        { Icon="crosshair", Title="Lock",   Callback=function() end },
        { Icon="user-x",    Title="Ignore", Callback=function() end },
    }
})

local MiscPage = Window:NewPage({
    Title    = "Misc",
    Desc     = "Utilities",
    Icon     = "layers",
    TabImage = "#9955FF"
})

MiscPage:Section("Input")

local TargetInput = MiscPage:Input({
    Placeholder = "Enter player name...",
    Icon        = "search",
    Callback    = function(text) print("Target:", text) end
})

local NotesArea = MiscPage:Input({
    MultiLine = true,
    Lines     = 5,
    Placeholder = "Enter notes...",
    Callback  = function(text) print("Notes:", text) end
})

local ModeDrop = MiscPage:Dropdown({
    Title       = "Mode",
    List        = {"Silent","Visible","Ghost"},
    Value       = "Silent",
    Icon        = "layers",
    Placeholder = "Select mode...",
    Search      = false,
    Callback    = function(v) print("Mode:", v) end
})

local MultiDrop = MiscPage:Dropdown({
    Title    = "Features",
    List     = {"ESP","Aimbot","Fly","Speed"},
    Value    = {"ESP"},
    Search   = true,
    Callback = function(sel) print(table.concat(sel,", ")) end
})

local BindKey = MiscPage:Keybind({
    Title    = "Activate",
    Icon     = "keyboard",
    Value    = Enum.KeyCode.F,
    Callback = function(key)
        Library:Notification({Title="Key",Desc=key.Name,Duration=2,Type="Info"})
    end
})

MiscPage:Banner("rbxassetid://125411502674016")

local NotifsPage = Window:NewPage({
    Title    = "Notifs",
    Desc     = "Toast demos",
    Icon     = "bell",
    TabImage = "#FF6600"
})

NotifsPage:Section("Types")

for _, t in ipairs({"Info","Success","Warning","Error"}) do
    NotifsPage:Button({
        Text     = t,
        Callback = function()
            Library:Notification({Title=t,Desc="This is a "..t:lower().." notification.",Duration=3,Type=t})
        end
    })
end

NotifsPage:Button({
    Text     = "Custom Color",
    Callback = function()
        Library:Notification({Title="Custom",Desc="Green color.",Duration=3,Color="#00FF88"})
    end
})

local SettingsPage = Window:NewPage({
    Title    = "Settings",
    Desc     = "UI & Config",
    Icon     = "settings",
    TabImage = "#444444"
})

SettingsPage:Section("Interface")
Library:AddSizeSlider(SettingsPage)

SettingsPage:Section("Theme")

local themes = {
    {"Pink","#FF007F"},{"Blue","#0088FF"},{"Green","#00CC66"},
    {"Purple","#9955FF"},{"Orange","#FF6600"},
}
for _, th in ipairs(themes) do
    SettingsPage:Button({
        Text     = th[1],
        Callback = function()
            Library:SetTheme({Accent=th[2],TabImage=th[2]})
        end
    })
end

SettingsPage:ConfigManager({
    SectionTitle = "Config Manager",
    AutoLoadKey  = "__r4washere__",
    OnLoad       = function(data)
        if data.speed then SpeedSlider:SetValue(data.speed) end
        if data.esp   then EspToggle:SetValue(data.esp) end
    end
})

local startTime = tick()
task.spawn(function()
    while task.wait(1) do
        local e=tick()-startTime
        local h=math.floor(e/3600)
        local m=math.floor((e%3600)/60)
        local s=math.floor(e%60)
        Library:SetTimeValue(string.format("%02d:%02d:%02d",h,m,s))
    end
end)
