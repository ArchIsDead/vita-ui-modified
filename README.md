# Modified Vita UI Library

Clean and Sexy.

---

## Load

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
    UserName          = "CustomName",
    ExecutorName      = "MyExec",
    Theme = {
        Accent      = "#FF007F",
        Background  = "#0D0D0D",
        Row         = "#0F0F0F",
        RowAlt      = "#0A0A0A",
        Stroke      = "#191919",
        Text        = "#FFFFFF",
        SubText     = "#A3A3A3",
        TabBg       = "#0A0A0A",
        TabStroke   = "#4B0026",
        TabImage    = "#FF007F",
        DropBg      = "#121212",
        DropStroke  = "#1E1E1E",
        PillBg      = "#0B0B0B",
    }
})
```

All fields are optional. Title, SubTitle, UserName, ExecutorName can all be nil to hide them.

---

## Pages

```lua
local Page = Window:NewPage({
    Title    = "Combat",
    Desc     = "Aimbot settings",
    Icon     = "sword",
    TabImage = "#FF0055"
})
```

---

## Elements

Every element returns an object with named methods. All `Title`, `Desc`, `Icon` fields are optional.

### Section

```lua
Page:Section("Movement")
```

---

### Paragraph

```lua
local P = Page:Paragraph({
    Title         = "Player Info",
    Desc          = "Some description",
    Color         = "#1A1A1A",
    Image         = "info",
    ImageSize     = 20,
    ImageMode     = "beside",
    Thumbnail     = "rbxassetid://123",
    ThumbnailSize = 50,
    Buttons = {
        { Icon="bird", Title="Fly",  Callback=function() end },
        { Icon="zap",  Title="Kick", Callback=function() end },
    },
    LockMessage = "Premium only"
})

P:SetTitle("New Title")
P:SetDesc("New desc")
P:SetImage("check")
P:SetThumbnail("rbxassetid://456")
P:SetColor("#222")
P:Lock("This is locked")
P:Unlock()
P:Destroy()
```

`ImageMode = "top"` places the image as a banner above the row. Use `TopImageHeight` to control its height.

---

### Toggle

```lua
local T = Page:Toggle({
    Title    = "Enable Speed",
    Desc     = "Walk speed hack",
    Icon     = "zap",
    Value    = false,
    Callback = function(v) print(v) end,
    LockMessage = "Locked"
})

T:SetTitle("Speed")
T:SetDesc("Updated")
T:SetValue(true)
T:GetValue()
T:Lock("Paused")
T:Unlock()
T:Destroy()
```

---

### Button

```lua
local B = Page:Button({
    Title    = "Teleport",
    Desc     = "Jumps to waypoint",
    Text     = "Go",
    Icon     = "map-pin",
    Callback = function() end,
    LockMessage = "Locked"
})

B:SetTitle("Warp")
B:SetDesc("Updated")
B:SetText("Execute")
B:Lock()
B:Unlock()
B:Destroy()
```

---

### Slider

```lua
local S = Page:Slider({
    Title    = "Walk Speed",
    Desc     = "Movement speed",
    Icon     = "activity",
    Min      = 0,
    Max      = 250,
    Rounding = 1,
    Value    = 16,
    Suffix   = "st/s",
    Callback = function(v) print(v) end,
    LockMessage = "Locked"
})

S:SetTitle("Speed")
S:SetValue(100)
S:SetMin(0)
S:SetMax(500)
S:GetValue()
S:Lock()
S:Unlock()
S:Destroy()
```

---

### Input

```lua
local I = Page:Input({
    Title         = "Target",
    Placeholder   = "Enter name...",
    Icon          = "search",
    Value         = "",
    ClearOnSubmit = false,
    Callback      = function(text) print(text) end,
    LockMessage   = "Locked"
})

I:SetValue("Player1")
I:SetPlaceholder("New hint")
I:GetValue()
I:Lock()
I:Unlock()
I:Destroy()
```

Multi-line textarea:

```lua
local TA = Page:Input({
    Title     = "Notes",
    MultiLine = true,
    Lines     = 6,
    Callback  = function(text) print(text) end
})
```

---

### Dropdown

```lua
local D = Page:Dropdown({
    Title       = "Mode",
    List        = {"Mode A", "Mode B", "Mode C"},
    Value       = "Mode A",
    Icon        = "layers",
    Placeholder = "Select mode...",
    Search      = true,
    Callback    = function(v) print(v) end
})

D:SetValue("Mode B")
D:AddList("Mode D")
D:RemoveItem("Mode A")
D:SetList({"X","Y","Z"})
D:SetTitle("New Title")
D:SetPlaceholder("Pick one...")
D:GetValue()
D:Clear()
D:Close()
D:Destroy()
```

Multi-select: pass a table as `Value`.

`Search = false` hides the search box.

---

### Keybind

```lua
local K = Page:Keybind({
    Title    = "Toggle ESP",
    Icon     = "keyboard",
    Value    = Enum.KeyCode.F,
    Callback = function(key) print(key.Name) end,
    LockMessage = "Locked"
})

K:SetValue(Enum.KeyCode.G)
K:GetValue()
K:Lock()
K:Unlock()
K:Destroy()
```

---

### ColorPicker

Popup with sat/val square, vertical hue bar, hex input, and RGB inputs.

```lua
local C = Page:ColorPicker({
    Title    = "ESP Color",
    Icon     = "palette",
    Value    = Color3.fromRGB(255, 0, 127),
    Callback = function(color) print(color) end,
    LockMessage = "Locked"
})

C:SetValue("#00FF88")
C:SetValue(Color3.fromRGB(0, 200, 100))
C:GetValue()
C:Lock()
C:Unlock()
C:Destroy()
```

---

### RightLabel

```lua
local L = Page:RightLabel({
    Title = "Status",
    Desc  = "Current state",
    Icon  = "info",
    Right = "Active"
})

L:SetTitle("Connection")
L:SetRight("Online")
L:Destroy()
```

---

### Banner

```lua
local B = Page:Banner("rbxassetid://12345")
B:SetImage("https://example.com/banner.png")
B:SetSize(UDim2.new(1,0,0,180))
B:Destroy()
```

---

### ConfigManager

Adds a full config manager section with a dropdown, name input, and action buttons.

```lua
Page:ConfigManager({
    SectionTitle = "Config Manager",
    AutoLoadKey  = "__myscript__",
    OnLoad       = function(data)
        if data.speed then SpeedSlider:SetValue(data.speed) end
    end
})
```

Buttons: Save (creates new, blocks duplicate names), Overwrite (updates existing), Load, Delete (with confirm dialog), Auto (sets auto-load on next run).

---

## Notifications

Rendered in a separate ScreenGui at DisplayOrder 999, always above the main UI.

```lua
Library:Notification({
    Title    = "Success",
    Desc     = "Done.",
    Duration = 3,
    Type     = "Success",
    Icon     = "check-circle",
    Color    = "#00FF88"
})
```

`Type` accepts: `Info`, `Success`, `Warning`, `Error`.
`Color` overrides the type color entirely.

---

## Lock / Unlock

Global lock disables all interactive elements:

```lua
Library:Lock()
Library:Unlock()
Library:IsLocked()
Library:SetLockText("Cooldown active")
```

Per-element lock shows an overlay with custom text:

```lua
Toggle:Lock("Premium required")
Toggle:Unlock()
```

---

## Config System

```lua
local Cfg = Library.Config

Cfg:Create("default", { speed=16 })
Cfg:SetActive("default")
Cfg:SetValue("speed", 100)
Cfg:GetValue("speed")
Cfg:Save("default")
Cfg:Overwrite("default", { speed=200 })
Cfg:Load("default")
Cfg:Delete("default")
Cfg:Rename("old", "new")
Cfg:Duplicate("default", "preset1")
Cfg:Import("name", jsonString)
Cfg:Clear("default")
Cfg:List()
Cfg:Count()
Cfg:Exists("default")
Cfg:Active()
```

`Create` returns `false, "Already exists"` if the name is taken.

---

## Library Methods

| Method | Description |
|---|---|
| `Library:SetTheme(table)` | Update theme colors at runtime |
| `Library:GetTheme()` | Returns current theme table |
| `Library:SetPillIcon(icon)` | Change floating pill icon |
| `Library:SetExecutorIdentity(bool)` | Show/hide user info block |
| `Library:SetTimeValue(string)` | Set header time text |
| `Library:SetWindowTitle(string)` | Change window title |
| `Library:SetWindowSubTitle(string)` | Change window subtitle |
| `Library:AddSizeSlider(Page)` | Add a scale slider capped to screen |
| `Library:Lock()` | Disable all interactions |
| `Library:Unlock()` | Re-enable all interactions |
| `Library:IsLocked()` | Returns locked state |
| `Library:SetLockText(string)` | Change default lock overlay text |
| `Library:Notification(Args)` | Show a toast notification |
| `Library:Destroy()` | Destroy entire UI |

---

## Icons

`Library:Asset(icon)` resolves Lucide short names (`"settings"`), full names (`"lucide-star"`), numeric IDs, `rbxassetid://` strings, and `https://` URLs.

---

## ShowImage

```lua
getgenv().ShowImage({
    url      = "https://example.com/image.png",
    size     = 500,
    duration = 5
})
```
