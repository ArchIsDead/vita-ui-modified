# Vita UI Library

A clean, performant, mobile-friendly executor UI library for Roblox.

---

## Installation

```lua
local Library = loadstring(game:HttpGet("YOUR_RAW_URL"))()
```

---

## Window

```lua
local Window = Library:Window({
    Title             = "My Script",
    SubTitle          = "v1.0",
    ToggleKey         = Enum.KeyCode.RightControl,
    BbIcon            = "settings",
    AutoScale         = true,
    Scale             = 1.45,
    Size              = UDim2.new(0, 520, 0, 370),
    ExecIdentifyShown = true,
    Theme = {
        Accent     = "#FF007F",
        Background = "#0D0D0D",
        Row        = "#0F0F0F",
        RowAlt     = "#0A0A0A",
        Stroke     = "#191919",
        Text       = "#FFFFFF",
        SubText    = "#A3A3A3",
        TabBg      = "#0A0A0A",
        TabStroke  = "#4B0026",
        TabImage   = "#FF007F",
        DropBg     = "#121212",
        DropStroke = "#1E1E1E",
        PillBg     = "#0B0B0B",
    }
})
```

### Window Methods

| Method | Description |
|---|---|
| `Library:SetTheme(table)` | Update theme colors at runtime |
| `Library:GetTheme()` | Returns current theme table |
| `Library:SetPillIcon(icon)` | Change floating pill icon |
| `Library:SetExecutorIdentity(bool)` | Show/hide user info block |
| `Library:SetTimeValue(string)` | Set header time display |
| `Library:SetWindowTitle(string)` | Change window title |
| `Library:SetWindowSubTitle(string)` | Change window subtitle |
| `Library:AddSizeSlider(Page)` | Add a scale slider (capped to screen) |
| `Library:Lock()` | Disable all interactions |
| `Library:Unlock()` | Re-enable all interactions |
| `Library:IsLocked()` | Returns locked state |
| `Library:Notification(Args)` | Show a toast notification |
| `Library:Destroy()` | Destroy entire UI |

---

## Pages

```lua
local Page = Window:NewPage({
    Title    = "Combat",
    Desc     = "Aimbot & ESP",
    Icon     = "sword",
    TabImage = "#FF0055"
})
```

---

## Elements

### Section

```lua
Page:Section("Movement")
```

---

### Paragraph

Rich info row with optional image, thumbnail, color tint, and inline buttons.

```lua
local Para = Page:Paragraph({
    Title         = "Player Info",
    Desc          = "Shows player data",
    Color         = "#1A1A1A",
    Image         = "info",
    ImageSize     = 20,
    Thumbnail     = "rbxassetid://123",
    ThumbnailSize = 50,
    Locked        = false,
    Buttons = {
        { Icon = "bird", Title = "Fly", Callback = function() print("fly") end },
    }
})

Para:SetTitle("Updated Title")
Para:SetDesc("Updated desc")
Para:SetImage("check")
Para:SetThumbnail("rbxassetid://456")
Para:SetColor("#222222")
Para:Destroy()
```

---

### Toggle

```lua
local T = Page:Toggle({
    Title    = "Enable Speed",
    Desc     = "Walk speed hack",
    Value    = false,
    Callback = function(v) print(v) end
})

T:SetTitle("Speed Hack")
T:SetDesc("Modified")
T:SetValue(true)
print(T:GetValue())
T:Destroy()
```

---

### Button

```lua
local B = Page:Button({
    Title    = "Teleport",
    Desc     = "Jump to waypoint",
    Text     = "Go",
    Icon     = "map-pin",
    Callback = function() end
})

B:SetTitle("New Title")
B:SetDesc("New Desc")
B:SetText("Execute")
B:Destroy()
```

---

### Slider

```lua
local S = Page:Slider({
    Title    = "Walk Speed",
    Desc     = "Movement speed",
    Min      = 0,
    Max      = 250,
    Rounding = 1,
    Value    = 16,
    Suffix   = "studs/s",
    Callback = function(v) print(v) end
})

S:SetTitle("Speed")
S:SetValue(100)
S:SetMin(0)
S:SetMax(500)
print(S:GetValue())
S:Destroy()
```

---

### Input

```lua
local I = Page:Input({
    Title         = "Target",
    Desc          = "Player name",
    Placeholder   = "Enter name...",
    Value         = "",
    ClearOnSubmit = false,
    Callback      = function(text) print(text) end
})

I:SetValue("PlayerOne")
I:SetPlaceholder("New prompt")
print(I:GetValue())
I:Destroy()
```

---

### Dropdown

```lua
local D = Page:Dropdown({
    Title       = "Mode",
    List        = {"Mode A", "Mode B", "Mode C"},
    Value       = "Mode A",
    Placeholder = "Select mode...",
    Callback    = function(v) print(v) end
})

D:SetValue("Mode B")
D:AddList("Mode D")
D:RemoveItem("Mode A")
D:SetList({"X", "Y", "Z"})
D:SetTitle("New Title")
D:SetPlaceholder("Pick one...")
print(D:GetValue())
D:Clear()
D:Destroy()
```

Multi-select: pass a table as `Value`.

```lua
local M = Page:Dropdown({
    Title    = "Features",
    List     = {"ESP", "Aimbot", "Fly"},
    Value    = {"ESP"},
    Callback = function(selected)
        print(table.concat(selected, ", "))
    end
})
```

---

### Keybind

```lua
local K = Page:Keybind({
    Title    = "Toggle ESP",
    Desc     = "Press to activate",
    Value    = Enum.KeyCode.F,
    Callback = function(key) print(key.Name) end
})

K:SetValue(Enum.KeyCode.G)
K:SetTitle("ESP Key")
print(K:GetValue().Name)
K:Destroy()
```

---

### ColorPicker

```lua
local C = Page:ColorPicker({
    Title    = "ESP Color",
    Desc     = "Highlight color",
    Value    = Color3.fromRGB(255, 0, 127),
    Callback = function(color) print(color) end
})

C:SetValue("#00FF88")
C:SetValue(Color3.fromRGB(0, 200, 100))
print(C:GetValue())
C:Destroy()
```

---

### RightLabel

```lua
local L = Page:RightLabel({
    Title = "Status",
    Desc  = "Current state",
    Right = "Active"
})

L:SetTitle("Connection")
L:SetDesc("Network")
L:SetRight("Online")
print(L.Right)
L:Destroy()
```

---

### Banner

```lua
local B = Page:Banner("rbxassetid://12345")
B:SetImage("https://example.com/banner.png")
B:Destroy()
```

---

### Config Manager

Adds a full config manager UI section with dropdown, name input, and Save/Load/Delete/Auto Load/Export buttons.

```lua
Page:ConfigManager({
    SectionTitle = "Config Manager",
    AutoLoadKey  = "__myscript__",
    OnLoad       = function(data)
        if data.speed then SpeedSlider:SetValue(data.speed) end
    end
})
```

---

## Notifications

Notifications render in their own ScreenGui with `DisplayOrder=999` so they always appear above the main UI.

```lua
Library:Notification({
    Title    = "Success",
    Desc     = "Operation completed.",
    Duration = 3,
    Type     = "Success",  -- Info | Success | Warning | Error
    Icon     = "check-circle"
})
```

---

## Config System

```lua
local Cfg = Library.Config

Cfg:Create("default", { speed = 16, esp = false })
Cfg:SetActive("default")
Cfg:SetValue("speed", 100)
print(Cfg:GetValue("speed"))

local json = Cfg:Export("default")
Cfg:Import("backup", json)
Cfg:Duplicate("default", "preset1")
Cfg:Rename("preset1", "mypreset")
Cfg:Delete("mypreset")
Cfg:Clear()

print(Cfg:List())
print(Cfg:Count())
print(Cfg:Active())
print(Cfg:Exists("default"))
```

---

## Icon System

`Library:Asset(icon)` resolves:

| Input | Example | Result |
|---|---|---|
| Lucide short name | `"settings"` | Looks up `lucide-settings` |
| Lucide full name | `"lucide-star"` | Direct lookup |
| Number | `10734966248` | `rbxassetid://10734966248` |
| rbxassetid string | `"rbxassetid://123"` | Unchanged |
| https URL | `"https://example.com/img.png"` | Unchanged |

Icons are loaded from the Arch-Vault Lucide repository at startup.

---

## ShowImage

```lua
getgenv().ShowImage({
    url      = "https://example.com/image.png",
    size     = 500,
    duration = 5
})
```

---

## Scale Behavior

The `UIScale` is attached to the ScreenGui and is automatically clamped so the UI never exceeds 95% of the viewport in either dimension. `Library:AddSizeSlider()` enforces this same cap so the slider cannot set a value that would cause overflow.
