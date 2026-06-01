--[[
     ██████╗  █████╗ ██╗      █████╗ ██╗  ██╗    ██╗  ██╗██╗   ██╗██████╗ 
    ██╔════╝ ██╔══██╗██║     ██╔══██╗╚██╗██╔╝    ██║  ██║██║   ██║██╔══██╗
    ██║  ███╗███████║██║     ███████║ ╚███╔╝     ███████║██║   ██║██████╔╝
    ██║   ██║██╔══██║██║     ██╔══██║ ██╔██╗     ██╔══██║██║   ██║██╔══██╗
    ╚██████╔╝██║  ██║███████╗██║  ██║██╔╝ ██╗    ██║  ██║╚██████╔╝██████╔╝
     ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
Hello! This was vibecoded then don´t judge me! 😭
Gimme credits! 🥺
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local HttpService = game:GetService("HttpService")

local function fetchJSON(url)
    local ok, raw = pcall(function() return game:HttpGet(url) end)
    if not ok then return nil end
    local decodeOk, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if decodeOk and data and data.Offsets then return data end
    return nil
end

local function load_offsets()
    if _G.GalaxOffsets then
        return _G.GalaxOffsets
    end

    local primaryUrl = "https://offsets.imtheo.lol/Offsets.json"
    local secondaryUrl = "https://raw.githubusercontent.com/WhyMayko/Matcha-Scripts/refs/heads/main/Offsets/Offsets.json"
    
    local data = fetchJSON(primaryUrl)
    if not data then data = fetchJSON(secondaryUrl) end

    if not data or not data.Offsets then
        warn("Galax Hub: Offsets load failed!")
        return nil
    end

    local offsets = data.Offsets

    if offsets.Humanoid and offsets.Humanoid.Sit then
        offsets.Humanoid.Sit = offsets.Humanoid.Sit + 1
    end

    _G.GalaxOffsets = offsets
    return offsets
end

local Offsets = load_offsets()
if not Offsets then return end

local OffsetTables = {
    Player = Offsets.Player or {},
    Humanoid = Offsets.Humanoid or {},
    BasePart = Offsets.BasePart or {},
    Primitive = Offsets.Primitive or {},
    PrimitiveFlags = Offsets.PrimitiveFlags or {},
    Camera = Offsets.Camera or {},
    Lighting = Offsets.Lighting or {},
    GuiObject = Offsets.GuiObject or {},
    GuiBase2D = Offsets.GuiBase2D or {},
    Sound = Offsets.Sound or {},
    ParticleEmitter = Offsets.ParticleEmitter or {},
    Beam = Offsets.Beam or {},
    Tool = Offsets.Tool or {},
}

local BasePartClasses = {
    Part = true,
    MeshPart = true,
    SpawnLocation = true,
    Seat = true,
    VehicleSeat = true,
    WedgePart = true,
    CornerWedgePart = true,
    TrussPart = true,
    UnionOperation = true,
    NegateOperation = true
}

local GuiObjectClasses = {
    GuiObject = true,
    Frame = true,
    TextLabel = true,
    TextButton = true,
    TextBox = true,
    ImageLabel = true,
    ImageButton = true,
    ScrollingFrame = true
}

local ValueBaseClasses = {
    StringValue = true,
    BoolValue = true,
    NumberValue = true,
    IntValue = true,
    FloatValue = true,
    Color3Value = true,
    ObjectValue = true
}

local function MemoryProp(name, offsetClass, offsetField, memType, readOnly)
    return { Kind = "memory", Name = name, OffsetClass = offsetClass, OffsetField = offsetField, Type = memType, ReadOnly = readOnly }
end

local function PrimitiveProp(name, offsetField, memType, readOnly)
    return { Kind = "primitive", Name = name, OffsetField = offsetField, Type = memType, ReadOnly = readOnly }
end

local function PrimitiveFlag(name, flagField, readOnly)
    return { Kind = "flag", Name = name, OffsetField = flagField, ReadOnly = readOnly }
end

local function DirectProp(name, readOnly)
    return { Kind = "direct", Name = name, ReadOnly = readOnly }
end

local function DirectComputedProp(name, readOnly, reader)
    return { Kind = "direct", Name = name, ReadOnly = readOnly, Reader = reader }
end

local DirectPropertySpecs = {
    BasePart = {
        DirectProp("Position", false),
        DirectProp("Size", false),
        DirectComputedProp("Rotation", true, function(target)
            local cf = target.CFrame
            return cf and typeof(cf) == "CFrame" and cf.LookVector or nil
        end),
        DirectProp("Color", false),
        DirectProp("Velocity", false),
        DirectProp("AssemblyLinearVelocity", false),
        DirectComputedProp("AssemblySpeed", true, function(target)
            local velocity = target.AssemblyLinearVelocity
            return velocity and velocity.Magnitude
        end),
        DirectProp("CanCollide", false)
    },
    Camera = {
        DirectProp("Position", false),
        DirectProp("ViewportSize", true)
    },
    GuiObject = {
        DirectProp("AbsolutePosition", true),
        DirectProp("AbsoluteSize", true)
    },
    ValueBase = {
        DirectProp("Value", false)
    },
    TextLabel = {
        DirectProp("Text", false)
    },
    MeshPart = {
        DirectProp("TextureId", false),
        DirectProp("MeshId", false)
    }
}

local PropertyOffsetSpecs = {
    Player = {
        MemoryProp("PlayerId", "Player", "UserId", "uint64", true),
        MemoryProp("UserId", "Player", "UserId", "uint64", true),
        MemoryProp("DisplayName", "Player", "DisplayName", "string", false),
        MemoryProp("LocaleId", "Player", "LocaleId", "string", true),
        MemoryProp("Team", "Player", "Team", "uintptr_t", true),
        MemoryProp("TeamColor", "Player", "TeamColor", "int", true),
        MemoryProp("AccountAge", "Player", "AccountAge", "int", true),
        MemoryProp("CameraMode", "Player", "CameraMode", "int", false),
        MemoryProp("MinZoomDistance", "Player", "MinZoomDistance", "float", false),
        MemoryProp("MaxZoomDistance", "Player", "MaxZoomDistance", "float", false),
        MemoryProp("HealthDisplayDistance", "Player", "HealthDisplayDistance", "float", false),
        MemoryProp("NameDisplayDistance", "Player", "NameDisplayDistance", "float", false),
        MemoryProp("Character / ModelInstance", "Player", "ModelInstance", "uintptr_t", true),
        MemoryProp("Mouse", "Player", "Mouse", "uintptr_t", true),
    },
    Humanoid = {
        MemoryProp("Health", "Humanoid", "Health", "float", false),
        MemoryProp("MaxHealth", "Humanoid", "MaxHealth", "float", false),
        MemoryProp("WalkSpeed", "Humanoid", "Walkspeed", "float", false),
        MemoryProp("WalkspeedCheck", "Humanoid", "WalkspeedCheck", "float", false),
        MemoryProp("JumpPower", "Humanoid", "JumpPower", "float", false),
        MemoryProp("JumpHeight", "Humanoid", "JumpHeight", "float", false),
        MemoryProp("HipHeight", "Humanoid", "HipHeight", "float", false),
        MemoryProp("MaxSlopeAngle", "Humanoid", "MaxSlopeAngle", "float", false),
        MemoryProp("MoveDirection", "Humanoid", "MoveDirection", "vector3", true),
        MemoryProp("TargetPoint", "Humanoid", "TargetPoint", "vector3", true),
        MemoryProp("MoveToPoint", "Humanoid", "MoveToPoint", "vector3", false),
        MemoryProp("MoveToPart", "Humanoid", "MoveToPart", "uintptr_t", true),
        MemoryProp("SeatPart", "Humanoid", "SeatPart", "uintptr_t", true),
        MemoryProp("HumanoidRootPart", "Humanoid", "HumanoidRootPart", "uintptr_t", true),
        MemoryProp("CameraOffset", "Humanoid", "CameraOffset", "vector3", false),
        MemoryProp("RigType", "Humanoid", "RigType", "int", true),
        MemoryProp("FloorMaterial", "Humanoid", "FloorMaterial", "int", true),
        MemoryProp("WalkTimer", "Humanoid", "WalkTimer", "float", true),
        MemoryProp("HumanoidState", "Humanoid", "HumanoidState", "int", true),
        MemoryProp("HumanoidStateID", "Humanoid", "HumanoidStateID", "int", true),
        MemoryProp("Jump", "Humanoid", "Jump", "bool", false),
        MemoryProp("Sit", "Humanoid", "Sit", "bool", false),
        MemoryProp("AutoRotate", "Humanoid", "AutoRotate", "bool", false),
        MemoryProp("PlatformStand", "Humanoid", "PlatformStand", "bool", false),
        MemoryProp("AutoJumpEnabled", "Humanoid", "AutoJumpEnabled", "bool", false),
        MemoryProp("UseJumpPower", "Humanoid", "UseJumpPower", "bool", false),
        MemoryProp("BreakJointsOnDeath", "Humanoid", "BreakJointsOnDeath", "bool", false),
        MemoryProp("EvaluateStateMachine", "Humanoid", "EvaluateStateMachine", "bool", false),
        MemoryProp("RequiresNeck", "Humanoid", "RequiresNeck", "bool", false),
    },
    BasePart = {
        PrimitiveProp("Material", "Material", "int", false),
        PrimitiveProp("AngularVelocity", "AssemblyAngularVelocity", "vector3", false),
        PrimitiveFlag("Anchored", "Anchored", false),
        PrimitiveFlag("CanTouch", "CanTouch", false),
        PrimitiveFlag("CanQuery", "CanQuery", false),
        MemoryProp("Transparency", "BasePart", "Transparency", "float", false),
        MemoryProp("Reflectance", "BasePart", "Reflectance", "float", false),
        MemoryProp("Massless", "BasePart", "Massless", "bool", false),
        MemoryProp("CastShadow", "BasePart", "CastShadow", "bool", false),
        MemoryProp("Locked", "BasePart", "Locked", "bool", false),
        MemoryProp("Primitive", "BasePart", "Primitive", "uintptr_t", true),
    },
    Camera = {
        MemoryProp("CameraSubject", "Camera", "CameraSubject", "uintptr_t", true),
        MemoryProp("CameraType", "Camera", "CameraType", "int", false),
        MemoryProp("Rotation", "Camera", "Rotation", "matrix3", true),
        MemoryProp("FieldOfView", "Camera", "FieldOfView", "float", false),
        MemoryProp("ImagePlaneDepth", "Camera", "ImagePlaneDepth", "float", true),
    },
    Lighting = {
        MemoryProp("ClockTime", "Lighting", "ClockTime", "float", false),
        MemoryProp("Brightness", "Lighting", "Brightness", "float", false),
        MemoryProp("FogStart", "Lighting", "FogStart", "float", false),
        MemoryProp("FogEnd", "Lighting", "FogEnd", "float", false),
        MemoryProp("GeographicLatitude", "Lighting", "GeographicLatitude", "float", false),
        MemoryProp("Ambient", "Lighting", "Ambient", "color3", false),
        MemoryProp("OutdoorAmbient", "Lighting", "OutdoorAmbient", "color3", false),
        MemoryProp("FogColor", "Lighting", "FogColor", "color3", false),
        MemoryProp("GlobalShadows", "Lighting", "GlobalShadows", "bool", false),
    },
    GuiObject = {
        MemoryProp("Visible", "GuiObject", "Visible", "bool", false),
        MemoryProp("Text", "GuiObject", "Text", "string", false),
        MemoryProp("Image", "GuiObject", "Image", "string", false),
        MemoryProp("Rotation", "GuiObject", "Rotation", "float", false),
        MemoryProp("RichText", "GuiObject", "RichText", "bool", false),
        MemoryProp("ZIndex", "GuiObject", "ZIndex", "int", false),
        MemoryProp("LayoutOrder", "GuiObject", "LayoutOrder", "int", false),
        MemoryProp("BackgroundColor3", "GuiObject", "BackgroundColor3", "color3", false),
        MemoryProp("BorderColor3", "GuiObject", "BorderColor3", "color3", false),
        MemoryProp("TextColor3", "GuiObject", "TextColor3", "color3", false),
        MemoryProp("BackgroundTransparency", "GuiObject", "BackgroundTransparency", "float", false),
    },
    Sound = {
        MemoryProp("SoundId", "Sound", "SoundId", "string", false),
        MemoryProp("Volume", "Sound", "Volume", "float", false),
        MemoryProp("PlaybackSpeed", "Sound", "PlaybackSpeed", "float", false),
        MemoryProp("Looped", "Sound", "Looped", "bool", false),
        MemoryProp("RollOffMaxDistance", "Sound", "RollOffMaxDistance", "float", false),
        MemoryProp("RollOffMinDistance", "Sound", "RollOffMinDistance", "float", false),
        MemoryProp("SoundGroup", "Sound", "SoundGroup", "uintptr_t", true),
    },
    ParticleEmitter = {
        MemoryProp("Rate", "ParticleEmitter", "Rate", "float", false),
        MemoryProp("Speed", "ParticleEmitter", "Speed", "float", false),
        MemoryProp("Lifetime", "ParticleEmitter", "Lifetime", "float", false),
        MemoryProp("Rotation", "ParticleEmitter", "Rotation", "float", false),
        MemoryProp("RotSpeed", "ParticleEmitter", "RotSpeed", "float", false),
        MemoryProp("Drag", "ParticleEmitter", "Drag", "float", false),
        MemoryProp("SpreadAngle", "ParticleEmitter", "SpreadAngle", "vector2", false),
        MemoryProp("Acceleration", "ParticleEmitter", "Acceleration", "vector3", false),
        MemoryProp("Brightness", "ParticleEmitter", "Brightness", "float", false),
        MemoryProp("VelocityInheritance", "ParticleEmitter", "VelocityInheritance", "float", false),
        MemoryProp("LightEmission", "ParticleEmitter", "LightEmission", "float", false),
        MemoryProp("LightInfluence", "ParticleEmitter", "LightInfluence", "float", false),
        MemoryProp("Texture", "ParticleEmitter", "Texture", "string", false),
    },
    Beam = {
        MemoryProp("Width0", "Beam", "Width0", "float", false),
        MemoryProp("Width1", "Beam", "Width1", "float", false),
        MemoryProp("CurveSize0", "Beam", "CurveSize0", "float", false),
        MemoryProp("CurveSize1", "Beam", "CurveSize1", "float", false),
        MemoryProp("TextureSpeed", "Beam", "TextureSpeed", "float", false),
        MemoryProp("TextureLength", "Beam", "TextureLength", "float", false),
        MemoryProp("Brightness", "Beam", "Brightness", "float", false),
        MemoryProp("LightEmission", "Beam", "LightEmission", "float", false),
        MemoryProp("LightInfluence", "Beam", "LightInfluence", "float", false),
        MemoryProp("ZOffset", "Beam", "ZOffset", "float", false),
        MemoryProp("Attachment0", "Beam", "Attachment0", "uintptr_t", true),
        MemoryProp("Attachment1", "Beam", "Attachment1", "uintptr_t", true),
        MemoryProp("Texture", "Beam", "Texture", "string", false),
    },
    Tool = {
        MemoryProp("Grip", "Tool", "Grip", "cframe", true),
        MemoryProp("TextureId", "Tool", "TextureId", "string", false),
        MemoryProp("Tooltip", "Tool", "Tooltip", "string", false),
        MemoryProp("Enabled", "Tool", "Enabled", "bool", false),
        MemoryProp("CanBeDropped", "Tool", "CanBeDropped", "bool", false),
        MemoryProp("RequiresHandle", "Tool", "RequiresHandle", "bool", false),
        MemoryProp("ManualActivationOnly", "Tool", "ManualActivationOnly", "bool", false),
    },
}

local header = table.concat({
    "",
    "------------------------------------------",
    "Galax Dex: External Explorer",
    "Status: Loaded",
    "------------------------------------------"
}, "\n")

print(header)

if _G.GalaxDex then
    _G.GalaxDex.alive = false
    setrobloxinput(true)
    pcall(function()
        if _G.GalaxDex.pool then
            for _, lst in pairs(_G.GalaxDex.pool) do
                for _, d in ipairs(lst) do pcall(function() d:Remove() end) end
            end
        end
        if _G.GalaxDex.iconPool then
            for _, lst in pairs(_G.GalaxDex.iconPool) do
                for _, d in ipairs(lst) do pcall(function() d:Remove() end) end
            end
        end
    end)
end

_G.GalaxDex = {
    pool = { sq = {}, tx = {}, ln = {}, ci = {} },
    iconPool = {},
    alive = true
}

local Theme = {
    Background = Color3.fromRGB(12, 12, 18),
    Topbar = Color3.fromRGB(16, 16, 24),
    Section = Color3.fromRGB(20, 20, 30),
    Border = Color3.fromRGB(35, 35, 50),
    BorderBright = Color3.fromRGB(60, 60, 85),
    Text = Color3.fromRGB(235, 235, 240),
    SubText = Color3.fromRGB(120, 120, 135),
    Accent = Color3.fromRGB(10, 132, 255),
    AccentHover = Color3.fromRGB(80, 160, 255),
    Danger = Color3.fromRGB(255, 69, 58),
    Success = Color3.fromRGB(48, 209, 88),
    Red = Color3.fromRGB(255, 95, 86),
    Yellow = Color3.fromRGB(255, 189, 46),
    Green = Color3.fromRGB(39, 201, 63),
    White = Color3.new(1, 1, 1),
    Glass = 0.75,
    GlassStrong = 0.86,
    GlassSubtle = 0.68,
    GlassTopbar = 0.42,
}

local ThemeAccent = { H = 0.58, S = 0.96, V = 1 }

local function LerpColor(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

local function HSVToColor3(h, s, v)
    h = (h % 1) * 6
    s = math.clamp(s or 0, 0, 1)
    v = math.clamp(v or 0, 0, 1)

    local i = math.floor(h)
    local f = h - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    if i == 0 then return Color3.new(v, t, p) end
    if i == 1 then return Color3.new(q, v, p) end
    if i == 2 then return Color3.new(p, v, t) end
    if i == 3 then return Color3.new(p, q, v) end
    if i == 4 then return Color3.new(t, p, v) end
    return Color3.new(v, p, q)
end

local function ApplyThemeAccent()
    Theme.Accent = HSVToColor3(ThemeAccent.H, ThemeAccent.S, ThemeAccent.V)
    Theme.AccentHover = LerpColor(Theme.Accent, Theme.White, 0.28)
end

ApplyThemeAccent()

local SelectedEsp = {
    Enabled = true,
    TipHeightScale = 0.75,
    TextSize = 11,
    MinTextSize = 8,
    LabelScaleDistance = 100,
    MinDistance = 3,
    PaddingX = 8,
    Height = 20,
    Gap = 5,
    ChamsAlpha = 0.92
}

local BoxEdges = {
    {1, 2}, {2, 4}, {4, 3}, {3, 1},
    {5, 6}, {6, 8}, {8, 7}, {7, 5},
    {1, 5}, {2, 6}, {3, 7}, {4, 8}
}

local DrawingPool = _G.GalaxDex.pool
local PoolIndex = { sq = 0, tx = 0, ln = 0, ci = 0 }
local DrawingTypeMap = { sq = 'Square', tx = 'Text', ln = 'Line', ci = 'Circle' }
local ClassIconBaseUrl = "https://raw.githubusercontent.com/WhyMayko/Matcha-Scripts/refs/heads/main/Debug/Galax-Dex/"
local ClassIconCache = {}
local ClassIconQueue = {}
local ClassIconWorkerRunning = false
local ClassIconDrawingPool = _G.GalaxDex.iconPool
local ClassIconDrawingIndex = {}

local function IsInstanceValid(inst)
    if not inst then return false end
    local ok, res = pcall(function() return inst.Parent ~= nil or inst == game end)
    return ok and res
end

local function ReadMemoryRaw(memType, address, offset, expectedType)
    local ok, val = pcall(memory_read, memType, address + offset)
    return ok and type(val) == expectedType and val or nil
end

local function WriteMemoryRaw(memType, address, offset, value)
    pcall(memory_write, memType, address + offset, value)
end

local function ReadMemoryByte(address, offset) return ReadMemoryRaw("byte", address, offset, "number") end
local function WriteMemoryByte(address, offset, value) WriteMemoryRaw("byte", address, offset, value) end
local function ReadMemoryFloat(address, offset) return ReadMemoryRaw("float", address, offset, "number") end
local function WriteMemoryFloat(address, offset, value) WriteMemoryRaw("float", address, offset, value) end
local function ReadMemoryInt(address, offset) return ReadMemoryRaw("int", address, offset, "number") end
local function WriteMemoryInt(address, offset, value) WriteMemoryRaw("int", address, offset, value) end
local function ReadMemoryPtr(address, offset) return ReadMemoryRaw("uintptr_t", address, offset, "number") end
local function WriteMemoryPtr(address, offset, value) WriteMemoryRaw("uintptr_t", address, offset, value) end

local function ReadMemoryVector2(address, offset)
    local x = ReadMemoryFloat(address, offset)
    local y = ReadMemoryFloat(address, offset + 4)
    return x and y and Vector2.new(x, y) or nil
end

local function WriteMemoryVector2(address, offset, value)
    if typeof(value) ~= "Vector2" then return end
    WriteMemoryFloat(address, offset, value.X)
    WriteMemoryFloat(address, offset + 4, value.Y)
end

local function ReadMemoryVector3(address, offset)
    local x = ReadMemoryFloat(address, offset)
    local y = ReadMemoryFloat(address, offset + 4)
    local z = ReadMemoryFloat(address, offset + 8)
    return x and y and z and Vector3.new(x, y, z) or nil
end

local function WriteMemoryVector3(address, offset, value)
    if typeof(value) ~= "Vector3" then return end
    WriteMemoryFloat(address, offset, value.X)
    WriteMemoryFloat(address, offset + 4, value.Y)
    WriteMemoryFloat(address, offset + 8, value.Z)
end

local function ReadMemoryColor3(address, offset)
    local r = ReadMemoryFloat(address, offset)
    local g = ReadMemoryFloat(address, offset + 4)
    local b = ReadMemoryFloat(address, offset + 8)
    return r and g and b and Color3.new(r, g, b) or nil
end

local function WriteMemoryColor3(address, offset, value)
    if typeof(value) ~= "Color3" then return end
    WriteMemoryFloat(address, offset, value.R)
    WriteMemoryFloat(address, offset + 4, value.G)
    WriteMemoryFloat(address, offset + 8, value.B)
end

local function FormatDecimal(value)
    local n = tonumber(value) or 0
    if math.abs(n) < 0.05 then n = 0 end
    return string.format("%.1f", n)
end

local function ReadMemoryUDim2String(address, offset)
    local xScale = ReadMemoryFloat(address, offset)
    local xOffset = ReadMemoryInt(address, offset + 4)
    local yScale = ReadMemoryFloat(address, offset + 8)
    local yOffset = ReadMemoryInt(address, offset + 12)
    if xScale and xOffset and yScale and yOffset then
        return string.format("{%s, %d}, {%s, %d}", FormatDecimal(xScale), xOffset, FormatDecimal(yScale), yOffset)
    end
    return nil
end

local function ReadMemoryMatrix3String(address, offset)
    local values = {}
    for i = 0, 8 do
        local v = ReadMemoryFloat(address, offset + (i * 4))
        if not v then return nil end
        values[#values + 1] = FormatDecimal(v)
    end
    return table.concat(values, ", ")
end

local function ReadMemoryCFrameString(address, offset)
    local values = {}
    for i = 0, 11 do
        local v = ReadMemoryFloat(address, offset + (i * 4))
        if not v then return nil end
        values[#values + 1] = FormatDecimal(v)
    end
    return table.concat(values, ", ")
end

local function FormatPointer(ptr)
    if type(ptr) ~= "number" or ptr == 0 then return "0x0" end
    return string.format("0x%X", ptr)
end

local function MemoryReadByType(address, offset, memType)
    if not address or not offset then return nil end
    if memType == "float" then return ReadMemoryFloat(address, offset) end
    if memType == "double" then return ReadMemoryRaw("double", address, offset, "number") end
    if memType == "int" then return ReadMemoryInt(address, offset) end
    if memType == "byte" then return ReadMemoryByte(address, offset) end
    if memType == "bool" then
        local b = ReadMemoryByte(address, offset)
        if b ~= nil then return b ~= 0 end
        return nil
    end
    if memType == "uint64" then return ReadMemoryPtr(address, offset) end
    if memType == "string" then return ReadMemoryRaw("string", address, offset, "string") end
    if memType == "uintptr_t" then return ReadMemoryPtr(address, offset) end
    if memType == "vector2" then return ReadMemoryVector2(address, offset) end
    if memType == "vector3" then return ReadMemoryVector3(address, offset) end
    if memType == "color3" then return ReadMemoryColor3(address, offset) end
    if memType == "udim2" then return ReadMemoryUDim2String(address, offset) end
    if memType == "matrix3" then return ReadMemoryMatrix3String(address, offset) end
    if memType == "cframe" then return ReadMemoryCFrameString(address, offset) end
    return nil
end

local function MemoryWriteByType(address, offset, memType, value)
    if not address or not offset then return false end
    if memType == "float" and tonumber(value) then
        WriteMemoryFloat(address, offset, tonumber(value)); return true
    elseif memType == "double" and tonumber(value) then
        WriteMemoryRaw("double", address, offset, tonumber(value)); return true
    elseif memType == "int" and tonumber(value) then
        WriteMemoryInt(address, offset, math.floor(tonumber(value))); return true
    elseif memType == "byte" and tonumber(value) then
        WriteMemoryByte(address, offset, math.floor(tonumber(value))); return true
    elseif memType == "bool" then
        WriteMemoryByte(address, offset, (value == true or value == "true" or value == 1 or value == "1") and 1 or 0); return true
    elseif memType == "string" then
        WriteMemoryRaw("string", address, offset, tostring(value)); return true
    elseif memType == "uintptr_t" and tonumber(value) then
        WriteMemoryPtr(address, offset, tonumber(value)); return true
    elseif memType == "vector3" and typeof(value) == "Vector3" then
        WriteMemoryVector3(address, offset, value); return true
    elseif memType == "vector2" and typeof(value) == "Vector2" then
        WriteMemoryVector2(address, offset, value); return true
    elseif memType == "color3" and typeof(value) == "Color3" then
        WriteMemoryColor3(address, offset, value); return true
    end
    return false
end

local function GetOffset(class, field, default)
    if OffsetTables[class] and OffsetTables[class][field] then
        local val = OffsetTables[class][field]
        if type(val) == "number" and val >= 0 then
            return val
        end
    end
    return default
end

local function ExecuteSafely(f, ...)
    local ok, res = pcall(f, ...)
    if ok then return res end
    return nil
end

local function ShowNotification(msg)
    pcall(function() notify(msg, "Galax Dex", 3) end)
end

local function CreateTreeNode(inst, depth)
    local hasChildren = false
    local childCount = 0
    pcall(function()
        childCount = #inst:GetChildren()
        hasChildren = childCount > 0
    end)

    return {
        Instance = inst,
        Name = ExecuteSafely(function() return inst.Name end) or "???",
        ClassName = ExecuteSafely(function() return inst.ClassName end) or "???",
        Address = ExecuteSafely(function() return inst.Address end),
        Depth = depth,
        Expanded = false,
        Children = {},
        HasChildren = hasChildren,
        ChildCount = childCount,
        LastChildCheck = 0,
        TargetKind = nil,
        TargetKindChecked = false,
        Visible = true
    }
end

local GalaxyState = {
    IsVisible = true,
    CurrentTab = "Explorer",
    Selected = nil,
    SearchQuery = "",
    TreeRoot = nil,
    SearchRoot = nil,
    LastTreeRefresh = 0,
    LastSearchRefresh = 0,
    PropLines = {},
    FocusedElement = nil,
    ScrollY = 0,
    MaxScrollY = 0,
    SearchScrollY = 0,
    SearchMaxScrollY = 0,
    PropertyScroll = 0,
    PropertyScrollY = 0,
    IsDraggingScroll = false,
    IsDraggingSearchScroll = false,
    IsDraggingPropertyScroll = false,
    IsDraggingLayoutSplit = false,
    LayoutSplitRatio = 340 / 592,
    ScrollKeyHold = {},
    CustomNames = {},
    CustomNamesByAddress = {},
    LastEditTime = 0,
    LastPropertyUpdate = 0,
    LastInputTime = 0,
    ResolvedTarget = nil,
    DiagnosticCooldown = {},
    KeyStates = {},
    KeyHoldStart = {},
    IsMouseClicked = false,
    IsRightMouseClicked = false,
    ContextMenu = nil,
    FocusRects = {},
    LastRobloxInputBlocked = false,
    MenuToggleKey = 0x70,
    MenuToggleName = "F1",
    CapturingKeybind = false,
    KeybindCaptureStarted = 0,
    SuppressMenuToggleUntilRelease = false,
    PendingUnload = false,
    SpectateTarget = nil,
    SpectateSubject = nil,
    LastSelectedCheck = 0,
    SelectedPhysicalPart = nil,
    SelectedVisualCache = {},
    InactiveSince = nil
}

local CurrentTab = "Explorer"

local function InvalidateResolvedTarget()
    GalaxyState.ResolvedTarget = nil
end

local function ClearSelectedVisualCache()
    GalaxyState.SelectedVisualCache = {}
end

local InputKeys = {
    [0x08] = "BACK",
    [0x0D] = "ENTER",
    [0x20] = " ",
    [0xBE] = ".",
    [0xBC] = ",",
    [0xBD] = "-",
    [0xBB] = "=",
    [0xDB] = "[",
    [0xDD] = "]",
    [0xBA] = ";",
    [0xDE] = "'",
    [0xDC] = "\\",
    [0xBF] = "/"
}
for i = 0, 9 do InputKeys[0x30 + i] = tostring(i) end
for i = 0, 9 do InputKeys[0x60 + i] = tostring(i) end
for i = 0, 25 do InputKeys[0x41 + i] = string.char(0x41 + i) end

local KeybindOptions = {
    { 0x70, "F1" }, { 0x71, "F2" }, { 0x72, "F3" }, { 0x73, "F4" },
    { 0x74, "F5" }, { 0x75, "F6" }, { 0x76, "F7" }, { 0x77, "F8" },
    { 0x78, "F9" }, { 0x79, "F10" }, { 0x7A, "F11" }, { 0x7B, "F12" },
    { 0x10, "SHIFT" }, { 0x11, "CTRL" }, { 0x12, "ALT" },
    { 0x09, "TAB" }, { 0x14, "CAPS" }, { 0x2D, "INSERT" }, { 0x2E, "DELETE" },
    { 0x24, "HOME" }, { 0x23, "END" }, { 0x21, "PGUP" }, { 0x22, "PGDN" },
    { 0x25, "LEFT" }, { 0x26, "UP" }, { 0x27, "RIGHT" }, { 0x28, "DOWN" }
}
for i = 0, 9 do KeybindOptions[#KeybindOptions + 1] = { 0x30 + i, tostring(i) } end
for i = 0, 25 do KeybindOptions[#KeybindOptions + 1] = { 0x41 + i, string.char(0x41 + i) } end

local function GetPressedKeybind()
    for _, item in ipairs(KeybindOptions) do
        if iskeypressed(item[1]) then return item[1], item[2] end
    end
    return nil, nil
end

local function GetInstanceAddress(inst)
    return ExecuteSafely(function() return inst.Address end)
end

local function GetDisplayName(inst)
    local address = GetInstanceAddress(inst)
    return (GalaxyState.CustomNames and GalaxyState.CustomNames[inst]) or
        (GalaxyState.CustomNamesByAddress and address and GalaxyState.CustomNamesByAddress[address]) or
        ExecuteSafely(function() return inst.Name end) or "???"
end

local function DescribeInstance(inst)
    if not inst then return "nil" end

    local className = ExecuteSafely(function() return inst.ClassName end) or typeof(inst)
    local name = GetDisplayName(inst)
    local path = ExecuteSafely(function() return inst:GetFullName() end) or name
    local address = FormatPointer(ExecuteSafely(function() return inst.Address end))
    return string.format("%s [%s] @%s", path, className, address)
end

local function DescribeValue(value)
    if value == nil then return "nil" end
    local kind = typeof(value)
    if kind == "Instance" or ExecuteSafely(function() return value.ClassName end) then
        return DescribeInstance(value)
    end
    return string.format("%s (%s)", tostring(value), kind)
end

local function BuildDiagnosticContext(extra)
    local context = {}
    if GalaxyState.Selected then
        context.Selected = GalaxyState.Selected
    end
    if GalaxyState.SelectedNode then
        context.SelectedNode = (GalaxyState.SelectedNode.Name or "???") .. " [" .. (GalaxyState.SelectedNode.ClassName or "???") .. "]"
    end
    if extra then
        for k, v in pairs(extra) do
            context[k] = v
        end
    end
    return context
end

local function ReportGalaxError(reason, context)
    local lines = { "Galax Dex: " .. tostring(reason) }
    local order = {
        "Action", "Reason", "Selected", "SelectedNode", "Target", "TargetClass", "TargetPath",
        "TargetAddress", "ResolvedKind", "ResolvedPart", "LocalCharacter", "LocalRoot",
        "Property", "PropertyType", "Expected", "Received", "Value", "Memory", "Error"
    }
    local used = {}

    context = context or {}
    for _, key in ipairs(order) do
        local value = context[key]
        if value ~= nil then
            lines[#lines + 1] = key .. ": " .. DescribeValue(value)
            used[key] = true
        end
    end
    for key, value in pairs(context) do
        if not used[key] then
            lines[#lines + 1] = tostring(key) .. ": " .. DescribeValue(value)
        end
    end

    local message = table.concat(lines, "\n")
    local key = tostring(reason) .. "|" .. tostring(context.Action) .. "|" .. tostring(context.Property)
    local now = os.clock()
    if not GalaxyState.DiagnosticCooldown[key] or now - GalaxyState.DiagnosticCooldown[key] > 0.35 then
        GalaxyState.DiagnosticCooldown[key] = now
        ShowNotification("Galax Error: " .. tostring(reason))
        print(message)
        task.spawn(function()
            error(message, 0)
        end)
    end
    return nil
end

local function RunGalaxAction(actionName, callback, context)
    local ok, result = pcall(callback)
    if ok then return result end
    return ReportGalaxError("Action failed", BuildDiagnosticContext({
        Action = actionName,
        Error = result,
        Context = context
    }))
end

local function RefreshNodeIdentity(node, inst)
    if not node or not inst then return end
    node.Instance = inst
    node.Address = GetInstanceAddress(inst)
    node.Name = GetDisplayName(inst)
    node.ClassName = ExecuteSafely(function() return inst.ClassName end) or "???"
    node.TargetKind = nil
    node.TargetKindChecked = false
end

local function IsSelectedNode(node)
    if not node or not GalaxyState.Selected then return false end
    if GalaxyState.SelectedNode == node or GalaxyState.Selected == node.Instance then return true end

    local selectedAddress = GetInstanceAddress(GalaxyState.Selected)
    return selectedAddress ~= nil and selectedAddress ~= 0 and node.Address == selectedAddress
end

local ExplorerOrder = {
    ["Workspace"] = 1,
    ["Players"] = 2,
    ["Lighting"] = 3,
    ["MaterialService"] = 4,
    ["ReplicatedFirst"] = 5,
    ["ReplicatedStorage"] = 6,
    ["ServerScriptService"] = 7,
    ["ServerStorage"] = 8,
    ["StarterGui"] = 9,
    ["StarterPack"] = 10,
    ["StarterPlayer"] = 11,
    ["SoundService"] = 12,
}

GalaxyState.SearchRoot = CreateTreeNode({ Name = "Results", ClassName = "Folder" }, 0)

local function GetClassName(inst)
    return ExecuteSafely(function() return inst.ClassName end) or ""
end

local function IsBasePart(inst)
    if not IsInstanceValid(inst) then return false end
    local class = GetClassName(inst)
    if not BasePartClasses[class] then return false end

    local pos = ExecuteSafely(function() return inst.Position end)
    local size = ExecuteSafely(function() return inst.Size end)
    return typeof(pos) == "Vector3" and typeof(size) == "Vector3"
end

local function ResolveObjectTarget(target)
    if not IsInstanceValid(target) then return nil end

    local class = GetClassName(target)
    if class == "Player" then
        local character = ExecuteSafely(function() return target.Character end)
        local info = character and ResolveObjectTarget(character) or nil
        if not info then return { Kind = target == LocalPlayer and "LocalPlayer" or "Player", Source = target, ClassName = class } end
        info.Kind = target == LocalPlayer and "LocalPlayer" or "Player"
        info.Player = target
        info.Source = target
        return info
    end

    if class == "Model" then
        local humanoid = ExecuteSafely(function() return target:FindFirstChildOfClass("Humanoid") end)
        local modelName = ExecuteSafely(function() return target.Name end)
        local matchedPlayer = modelName and ExecuteSafely(function() return Players:FindFirstChild(modelName) end) or nil
        local kind = humanoid and "NPC" or "Model"
        if matchedPlayer then kind = matchedPlayer == LocalPlayer and "LocalPlayer" or "Player" end

        local primary = ExecuteSafely(function() return target.PrimaryPart end)
        if primary and IsBasePart(primary) then
            return { Kind = kind, Part = primary, Humanoid = humanoid, Player = matchedPlayer, Source = target, ClassName = class }
        end

        return humanoid and { Kind = kind, Humanoid = humanoid, Player = matchedPlayer, Source = target, ClassName = class } or nil
    end

    if IsBasePart(target) then
        return { Kind = "Part", Part = target, Source = target, ClassName = class }
    end

    local firstPart = ExecuteSafely(function() return target:FindFirstChildWhichIsA("BasePart") end)
    if firstPart and IsBasePart(firstPart) then
        return { Kind = "Container", Part = firstPart, Source = target, ClassName = class }
    end

    return nil
end

local function GetResolvedTarget(target)
    local address = GetInstanceAddress(target)
    local cached = GalaxyState.ResolvedTarget
    if cached and cached.Target == target and cached.Address == address and cached.Info and cached.Info.Part then
        return cached.Info
    end

    local info = ResolveObjectTarget(target)
    GalaxyState.ResolvedTarget = {
        Target = target,
        Address = address,
        Info = info
    }
    return info
end

local function GetSelectedPhysicalPart(target)
    local info = GetResolvedTarget(target)
    return info and info.Part or nil
end

local function ClearSelectedState()
    GalaxyState.Selected = nil
    GalaxyState.SelectedNode = nil
    GalaxyState.SelectedPhysicalPart = nil
    ClearSelectedVisualCache()
    GalaxyState.PropLines = {}
    InvalidateResolvedTarget()
end

local function MarkSelectedChanged()
    GalaxyState.SelectedPhysicalPart = nil
    ClearSelectedVisualCache()
    GalaxyState.LastSelectedCheck = 0
    InvalidateResolvedTarget()
end

local function UpdateSelectedState(forceRefresh)
    local selected = GalaxyState.Selected
    if not selected then
        GalaxyState.SelectedPhysicalPart = nil
        ClearSelectedVisualCache()
        if GalaxyState.ResolvedTarget then InvalidateResolvedTarget() end
        return nil
    end

    if not IsInstanceValid(selected) then
        ClearSelectedState()
        return nil
    end

    if forceRefresh then InvalidateResolvedTarget() end
    if GalaxyState.SelectedNode then RefreshNodeIdentity(GalaxyState.SelectedNode, selected) end

    local part = GetSelectedPhysicalPart(selected)
    GalaxyState.SelectedPhysicalPart = part
    return part
end

local function RememberInstanceName(inst, name)
    if not inst then return end
    if not GalaxyState.CustomNames then GalaxyState.CustomNames = {} end
    if not GalaxyState.CustomNamesByAddress then GalaxyState.CustomNamesByAddress = {} end
    GalaxyState.CustomNames[inst] = tostring(name)
    local address = GetInstanceAddress(inst)
    if address then GalaxyState.CustomNamesByAddress[address] = tostring(name) end
end

local function RefreshLoadedNodeName(inst, name)
    local address = GetInstanceAddress(inst)
    local function visit(node)
        if not node then return end
        if node.Instance == inst or (address and node.Address == address) then
            node.Name = tostring(name)
            node.Address = address
            node.TargetKind = nil
            node.TargetKindChecked = false
        end
        for _, child in ipairs(node.Children or {}) do visit(child) end
    end
    visit(GalaxyState.TreeRoot)
    visit(GalaxyState.SearchRoot)
end

local function FindPlayerForCharacter(character)
    if not character then return nil end
    local players = ExecuteSafely(function() return Players:GetChildren() end) or {}
    for _, player in ipairs(players) do
        if ExecuteSafely(function() return player.Character end) == character then
            return player
        end
    end
    local characterName = ExecuteSafely(function() return character.Name end)
    return characterName and ExecuteSafely(function() return Players:FindFirstChild(characterName) end) or nil
end

local function GetRenameLinks(target)
    local className = GetClassName(target)
    if className == "Player" then
        return {
            Player = target,
            Character = ExecuteSafely(function() return target.Character end)
        }
    end
    if className == "Model" and ExecuteSafely(function() return target:FindFirstChildOfClass("Humanoid") end) then
        local player = FindPlayerForCharacter(target)
        if player then
            return {
                Player = player,
                Character = target
            }
        end
    end
    return nil
end

local function ApplyRenameLinks(source, links, name)
    if not links then return end
    local targets = { links.Player, links.Character }
    for _, inst in ipairs(targets) do
        if inst and inst ~= source and IsInstanceValid(inst) then
            inst.Name = tostring(name)
            RememberInstanceName(inst, name)
            RefreshLoadedNodeName(inst, name)
        end
    end
end

local function GetNodeTargetKind(node)
    if not node or node.TargetKindChecked then return node and node.TargetKind or nil end
    if node.ClassName ~= "Model" and node.ClassName ~= "Player" then
        node.TargetKindChecked = true
        return nil
    end

    local kind
    if node.ClassName == "Player" then
        kind = (LocalPlayer and node.Name == LocalPlayer.Name) and "LocalPlayer" or "Player"
    elseif node.ClassName == "Model" then
        if LocalPlayer and node.Name == LocalPlayer.Name then
            kind = "LocalPlayer"
        elseif ExecuteSafely(function() return Players:FindFirstChild(node.Name) end) then
            kind = "Player"
        elseif ExecuteSafely(function() return node.Instance:FindFirstChildOfClass("Humanoid") end) then
            kind = "NPC"
        end
    end

    node.TargetKind = kind
    node.TargetKindChecked = true
    return node.TargetKind
end

local function GetCameraPosition()
    local cam = workspace.CurrentCamera
    if not cam then return nil end

    local pos = cam.Position
    if pos and typeof(pos) == "Vector3" then return pos end
    return nil
end

local ToggleSpectate

local function GetLocalHumanoidRootPart()
    local character = ExecuteSafely(function() return LocalPlayer.Character end)
    return character and ExecuteSafely(function() return character:FindFirstChild("HumanoidRootPart") end) or nil
end

local function GetLocalHumanoid()
    local character = ExecuteSafely(function() return LocalPlayer.Character end)
    return character and ExecuteSafely(function() return character:FindFirstChildOfClass("Humanoid") end) or nil
end

local function FindAncestorHumanoid(target)
    local current = target
    while current and current ~= game do
        local humanoid = ExecuteSafely(function() return current:FindFirstChildOfClass("Humanoid") end)
        if humanoid then return humanoid, current end
        current = ExecuteSafely(function() return current.Parent end)
    end
    return nil, nil
end

local function ResolveSpectateSubject(target)
    if not IsInstanceValid(target) then return nil, nil end

    local className = GetClassName(target)
    if className == "Humanoid" then
        return target, ExecuteSafely(function() return target.Parent end)
    end

    local info = GetResolvedTarget(target)
    if info and info.Humanoid then return info.Humanoid, info.Source or target end
    if info and info.Part then return info.Part, info.Source or target end

    local humanoid, source = FindAncestorHumanoid(target)
    if humanoid then return humanoid, source end

    return nil, nil
end

local function GetCameraSubjectAddress()
    local camAddr = GetInstanceAddress(workspace.CurrentCamera)
    local camSubOffset = GetOffset("Camera", "CameraSubject", 232)
    if not camAddr or camAddr == 0 or not camSubOffset then return nil, nil, nil end
    return ReadMemoryPtr(camAddr, camSubOffset), camAddr, camSubOffset
end

local function SetCameraSubject(subject)
    local subjectAddr = GetInstanceAddress(subject)
    local _, camAddr, camSubOffset = GetCameraSubjectAddress()
    if not subjectAddr or subjectAddr == 0 or not camAddr then return false end
    WriteMemoryPtr(camAddr, camSubOffset, subjectAddr)
    return true
end

local function IsSpectatingTarget(target)
    local subject = ResolveSpectateSubject(target)
    local subjectAddr = GetInstanceAddress(subject)
    local currentSubAddr = GetCameraSubjectAddress()
    return subjectAddr and subjectAddr ~= 0 and currentSubAddr == subjectAddr
end

local function ClearSpectateState()
    GalaxyState.SpectateTarget = nil
    GalaxyState.SpectateSubject = nil
end

local function Unspectate(reason, silent)
    local humanoid = GetLocalHumanoid()
    if humanoid then SetCameraSubject(humanoid) end
    ClearSpectateState()
    if not silent then ShowNotification(reason or "Unspectated") end
end

ToggleSpectate = function(target)
    local subject, source = ResolveSpectateSubject(target)
    if not subject then return ShowNotification("No Subject") end

    if IsSpectatingTarget(target) then
        Unspectate()
        return
    end

    if SetCameraSubject(subject) then
        GalaxyState.SpectateTarget = target
        GalaxyState.SpectateSubject = subject
        ShowNotification("Spectating: " .. (ExecuteSafely(function() return (source or target).Name end) or "Target"))
    end
end

local function UpdateSpectateState(forceRefresh)
    local subject = GalaxyState.SpectateSubject
    if not subject then return end

    local target = GalaxyState.SpectateTarget
    if not IsInstanceValid(subject) or not IsInstanceValid(target) then
        Unspectate("Spectate Ended", true)
        return
    end

    if forceRefresh then InvalidateResolvedTarget() end
    local resolvedSubject = ResolveSpectateSubject(target)
    local subjectAddr = GetInstanceAddress(subject)
    local resolvedAddr = GetInstanceAddress(resolvedSubject)
    local currentSubAddr = GetCameraSubjectAddress()
    if not resolvedAddr or resolvedAddr == 0 or resolvedAddr ~= subjectAddr then
        Unspectate("Spectate Ended", true)
        return
    end

    if not subjectAddr or subjectAddr == 0 or currentSubAddr ~= subjectAddr then
        ClearSpectateState()
    end
end

local function TeleportPlayer(target, selectedPart)
    if not target then
        return ReportGalaxError("Teleport failed", BuildDiagnosticContext({
            Action = "Teleport",
            Reason = "No selected target"
        }))
    end

    local hrp = GetLocalHumanoidRootPart()
    if not hrp then
        return ReportGalaxError("Teleport failed", BuildDiagnosticContext({
            Action = "Teleport",
            Reason = "LocalPlayer.Character.HumanoidRootPart was not found",
            LocalCharacter = ExecuteSafely(function() return LocalPlayer.Character end),
            LocalRoot = hrp
        }))
    end

    local info = GetResolvedTarget(target)
    local part = selectedPart or (info and info.Part)
    if not part then
        return ReportGalaxError("Teleport failed", BuildDiagnosticContext({
            Action = "Teleport",
            Reason = "Selected target did not resolve to a physical BasePart",
            Target = target,
            TargetClass = ExecuteSafely(function() return target.ClassName end),
            TargetPath = ExecuteSafely(function() return target:GetFullName() end),
            TargetAddress = FormatPointer(GetInstanceAddress(target)),
            ResolvedKind = info and info.Kind or "nil",
            ResolvedPart = info and info.Part or nil
        }))
    end

    local pos = part and ExecuteSafely(function() return part.Position end)
    if not pos or typeof(pos) ~= "Vector3" then
        return ReportGalaxError("Teleport failed", BuildDiagnosticContext({
            Action = "Teleport",
            Reason = "Resolved part has no valid Vector3 Position",
            Target = target,
            ResolvedKind = info and info.Kind or "nil",
            ResolvedPart = part,
            Expected = "Vector3",
            Received = pos
        }))
    end

    local ok, err = pcall(function()
        hrp.Position = pos + Vector3.new(0, 5, 0)
    end)
    if ok then
        ShowNotification("Teleported!")
    else
        return ReportGalaxError("Teleport failed", BuildDiagnosticContext({
            Action = "Teleport",
            Reason = "Failed to write LocalPlayer HumanoidRootPart.Position",
            LocalRoot = hrp,
            Target = target,
            ResolvedPart = part,
            Value = pos,
            Error = err
        }))
    end
end

local function BringObject(target)
    if not target then
        return ReportGalaxError("Bring failed", BuildDiagnosticContext({
            Action = "Bring",
            Reason = "No selected target"
        }))
    end

    local hrp = GetLocalHumanoidRootPart()
    if not hrp then
        return ReportGalaxError("Bring failed", BuildDiagnosticContext({
            Action = "Bring",
            Reason = "LocalPlayer.Character.HumanoidRootPart was not found",
            LocalCharacter = ExecuteSafely(function() return LocalPlayer.Character end)
        }))
    end

    local targetPos = hrp.Position
    local count = 0
    local failures = 0
    local lastError

    if IsBasePart(target) then
        local ok, err = pcall(function() target.Position = targetPos end)
        if ok then
            count = count + 1
        else
            failures = failures + 1
            lastError = err
        end
    end

    local descendants = ExecuteSafely(function() return target:GetDescendants() end)
    if descendants then
        for _, p in ipairs(descendants) do
            if IsBasePart(p) then
                local ok, err = pcall(function() p.Position = targetPos end)
                if ok then
                    count = count + 1
                else
                    failures = failures + 1
                    lastError = err
                end
            end
        end
    end

    if count == 0 then
        return ReportGalaxError("Bring failed", BuildDiagnosticContext({
            Action = "Bring",
            Reason = failures > 0 and "All BasePart position writes failed" or "Selected target has no movable BasePart descendants",
            Target = target,
            Error = lastError
        }))
    end

    if failures > 0 then
        ReportGalaxError("Bring partial failure", BuildDiagnosticContext({
            Action = "Bring",
            Reason = "Some BasePart position writes failed",
            Target = target,
            Value = count .. " moved / " .. failures .. " failed",
            Error = lastError
        }))
    end

    if count > 1 then
        ShowNotification("Brought " .. count .. " parts")
    elseif count == 1 then
        ShowNotification("Brought!")
    else
        ShowNotification("Nothing to bring")
    end
end

local function DeleteObject(target)
    if not target then
        return ReportGalaxError("Delete failed", BuildDiagnosticContext({
            Action = "Delete",
            Reason = "No selected target"
        }))
    end

    local partsCount = 0
    local failures = 0
    local lastError

    local function vanish(obj)
        if IsBasePart(obj) then
            local ok, err = pcall(function()
                obj.Size = Vector3.new(0, 0, 0)
                obj.Position = Vector3.new(0, -50000, 0)
                obj.CanCollide = false
            end)
            if ok then
                partsCount = partsCount + 1
            else
                failures = failures + 1
                lastError = err
            end
        end
    end

    local descendants = ExecuteSafely(function() return target:GetDescendants() end)
    if descendants then
        for _, p in ipairs(descendants) do
            vanish(p)
        end
    end
    vanish(target)

    if failures > 0 then
        ReportGalaxError("Delete partial failure", BuildDiagnosticContext({
            Action = "Delete",
            Reason = "Some vanish operations failed",
            Target = target,
            Value = partsCount .. " parts changed / " .. failures .. " failed",
            Error = lastError
        }))
    end

    if partsCount > 1 then
        ShowNotification("Deleted " .. partsCount .. " parts")
    else
        ShowNotification("Deleted!")
    end
end

local PopulateNodeChildren
local UpdatePropertyPanel

local function PerformSearch()
    local query = GalaxyState.SearchQuery:lower()

    if #query < 1 then
        GalaxyState.SearchRoot.Children = {}
        CurrentTab = "Explorer"
        GalaxyState.CurrentTab = "Explorer"
        return
    end

    CurrentTab = "Search"
    GalaxyState.CurrentTab = "Search"
    GalaxyState.SearchRoot.Children = {}
    GalaxyState.SearchScrollY = 0

    task.spawn(function()
        local ok, err = pcall(function()
            ShowNotification("Searching...")
            local results = {}
            local count = 0
            local objectsChecked = 0

            local function scan(root)
                if count >= 200 then return end
                local children = ExecuteSafely(function() return root:GetChildren() end)
                if not children then return end

                for _, c in ipairs(children) do
                    objectsChecked = objectsChecked + 1
                    if objectsChecked % 400 == 0 then
                        task.wait()
                    end

                    if count >= 200 then break end

                    local name = ExecuteSafely(function() return c.Name:lower() end) or ""
                    local isMatch = false

                    if query:find("%.") then
                        local path = ExecuteSafely(function() return c:GetFullName():lower() end) or ""
                        if path:find(query, 1, true) then isMatch = true end
                    else
                        if name:find(query, 1, true) then isMatch = true end
                    end

                    if isMatch then
                        table.insert(results, CreateTreeNode(c, 1))
                        count = count + 1
                    end
                    scan(c)
                end
            end

            scan(game)
            GalaxyState.SearchRoot.Children = results
            CurrentTab = "Search"
            GalaxyState.CurrentTab = "Search"

            if count >= 200 then
                ShowNotification("Limit: 200 Results!")
            else
                ShowNotification("Search Finished: " .. count .. " items")
            end
        end)

        if not ok then
            ReportGalaxError("Search failed", BuildDiagnosticContext({
                Action = "Search",
                Value = query,
                Error = err
            }))
        end
    end)
end

local function ClearSearch()
    GalaxyState.SearchQuery = ""
    GalaxyState.SearchRoot.Children = {}
    GalaxyState.SearchScrollY = 0
    GalaxyState.SearchMaxScrollY = 0
    CurrentTab = "Explorer"
    GalaxyState.CurrentTab = "Explorer"
end

local function RefreshExplorer()
    ClearSearch()
    GalaxyState.TreeRoot = CreateTreeNode(game, 0)
    PopulateNodeChildren(GalaxyState.TreeRoot)
    GalaxyState.TreeRoot.Expanded = true
    ClearSelectedState()
    GalaxyState.ScrollY = 0
    GalaxyState.PropertyScroll = 0
    GalaxyState.PropertyScrollY = 0
    UpdatePropertyPanel()
    ShowNotification("Refreshed")
end

local function ClearDrawingPool()
    for type in pairs(PoolIndex) do PoolIndex[type] = 0 end
    for iconName in pairs(ClassIconDrawingIndex) do ClassIconDrawingIndex[iconName] = 0 end
end

local function HideUnusedDrawings()
    for type, list in pairs(DrawingPool) do
        local lastUsed = PoolIndex[type] or 0
        for i = lastUsed + 1, #list do list[i].Visible = false end
    end
    for iconName, list in pairs(ClassIconDrawingPool) do
        local lastUsed = ClassIconDrawingIndex[iconName] or 0
        for i = lastUsed + 1, #list do list[i].Visible = false end
    end
end

local WindowWidth, WindowHeight = 500, 700
local MinWindowWidth, MinWindowHeight = 360, 460
local HeaderHeight = 34
local WindowPosition = Vector2.new(150, 80)
local IsVisible = true

local function SetGalaxDexVisible(visible)
    visible = visible == true
    if IsVisible == visible then return end
    IsVisible = visible
    ShowNotification(IsVisible and "Opened" or "Minimized")
end

local function ToggleGalaxDexVisible()
    SetGalaxDexVisible(not IsVisible)
end

local PreviousMouseState = false
local PreviousRightMouseState = false
local PreviousMenuKey = false
local IsDragging = false
local DragOffset = Vector2.new(0, 0)
GalaxyState.ResizeMode = nil
GalaxyState.ResizeStartMouse = Vector2.new(0, 0)
GalaxyState.ResizeStart = { X = 0, Y = 0, W = WindowWidth, H = WindowHeight }

GalaxyState.SnapToStep = function(value, step)
    return math.floor((value or 0) / step + 0.5) * step
end

GalaxyState.GetWindowResizeMode = function(x, y, w, h)
    local edge, corner = 10, 18
    local mx, my = Mouse.X, Mouse.Y
    local topLeft = mx >= x - edge and mx <= x + corner and my >= y - edge and my <= y + corner
    local topRight = mx >= x + w - corner and mx <= x + w + edge and my >= y - edge and my <= y + corner
    local bottomLeft = mx >= x - edge and mx <= x + corner and my >= y + h - corner and my <= y + h + edge
    local bottomRight = mx >= x + w - corner and mx <= x + w + edge and my >= y + h - corner and my <= y + h + edge
    local left = mx >= x - edge / 2 and mx <= x + edge / 2 and my >= y and my <= y + h
    local right = mx >= x + w - edge / 2 and mx <= x + w + edge / 2 and my >= y and my <= y + h
    local top = mx >= x and mx <= x + w and my >= y - edge / 2 and my <= y + edge / 2
    local bottom = mx >= x and mx <= x + w and my >= y + h - edge / 2 and my <= y + h + edge / 2

    if topLeft then return "TopLeft" end
    if topRight then return "TopRight" end
    if bottomLeft then return "BottomLeft" end
    if bottomRight then return "BottomRight" end
    if left then return "Left" end
    if right then return "Right" end
    if top then return "Top" end
    if bottom then return "Bottom" end
    return nil
end

GalaxyState.ApplyWindowResize = function(mode)
    local startMouse = GalaxyState.ResizeStartMouse
    local start = GalaxyState.ResizeStart
    local dx = Mouse.X - startMouse.X
    local dy = Mouse.Y - startMouse.Y
    local x, y, w, h = start.X, start.Y, start.W, start.H

    if mode:find("Right") then
        w = math.max(MinWindowWidth, start.W + dx)
    elseif mode:find("Left") then
        w = math.max(MinWindowWidth, start.W - dx)
        x = start.X + (start.W - w)
    end

    if mode:find("Bottom") then
        h = math.max(MinWindowHeight, start.H + dy)
    elseif mode:find("Top") then
        h = math.max(MinWindowHeight, start.H - dy)
        y = start.Y + (start.H - h)
    end

    WindowWidth, WindowHeight = math.floor(w + 0.5), math.floor(h + 0.5)
    WindowPosition = Vector2.new(math.floor(x + 0.5), math.floor(y + 0.5))
end

local function GetDrawingFromPool(type)
    local drawingType = DrawingTypeMap[type]
    if not drawingType then return nil end

    local list = DrawingPool[type]
    if not list then
        list = {}
        DrawingPool[type] = list
    end

    PoolIndex[type] = PoolIndex[type] or 0
    PoolIndex[type] = PoolIndex[type] + 1

    local drawing = list[PoolIndex[type]]
    if not drawing then
        drawing = Drawing.new(drawingType)
        list[PoolIndex[type]] = drawing
    end

    return drawing
end

local GUI_BASE_ZINDEX = 100

local function RenderSquare(x, y, w, h, color, filled, cornerRadius, zIndex, transparency)
    if w <= 0 or h <= 0 then return end
    local drawing = GetDrawingFromPool('sq')
    drawing.Position = Vector2.new(x, y)
    drawing.Size = Vector2.new(w, h)
    drawing.Color = color
    drawing.Filled = filled ~= false
    if transparency then
        drawing.Transparency = transparency
    elseif drawing.Filled then
        if color == Theme.Background or color == Theme.Section or color == Theme.Topbar then
            drawing.Transparency = Theme.Glass
        elseif color == Theme.Border or color == Theme.BorderBright then
            drawing.Transparency = Theme.GlassStrong
        else
            drawing.Transparency = 0.92
        end
    else
        drawing.Transparency = 1
    end
    drawing.Corner = cornerRadius or 0
    drawing.ZIndex = (zIndex or 1) + GUI_BASE_ZINDEX
    drawing.Visible = true
end

local function RenderText(content, x, y, color, size, font, zIndex, centered)
    local drawing = GetDrawingFromPool('tx')
    drawing.Text = tostring(content)
    drawing.Position = Vector2.new(x, y)
    drawing.Color = color
    drawing.Size = size or 13
    drawing.Font = font or Drawing.Fonts.System
    drawing.Outline = false
    drawing.ZIndex = (zIndex or 1) + 5 + GUI_BASE_ZINDEX
    drawing.Center = centered == true
    drawing.Visible = true
end

local function EstimateTextWidth(text, size)
    text = tostring(text or "")
    local scale = (size or 11) * 0.55
    local units = 0
    for i = 1, #text do
        local c = text:sub(i, i)
        if c == " " then
            units = units + 0.45
        elseif c == "." or c == "," or c == "'" or c == ":" or c == ";" then
            units = units + 0.35
        elseif c == "[" or c == "]" or c == "(" or c == ")" then
            units = units + 0.55
        elseif c == "I" or c == "i" or c == "l" or c == "t" then
            units = units + 0.58
        elseif c == "W" or c == "M" or c == "w" or c == "m" then
            units = units + 1.25
        elseif c:match("%u") then
            units = units + 1.05
        else
            units = units + 0.9
        end
    end
    return units * scale
end

local function FitTextToWidth(text, maxWidth, size)
    text = tostring(text or "")
    if maxWidth <= 0 then return "" end
    if EstimateTextWidth(text, size) <= maxWidth then return text end

    local suffix = "..."
    local suffixWidth = EstimateTextWidth(suffix, size)
    local available = maxWidth - suffixWidth
    if available <= 0 then return suffix end

    local result = ""
    for i = 1, #text do
        local nextText = text:sub(1, i)
        if EstimateTextWidth(nextText, size) > available then break end
        result = nextText
    end
    return result .. suffix
end

local function RenderLine(startX, startY, endX, endY, color, zIndex, thickness, transparency)
    local drawing = GetDrawingFromPool('ln')
    drawing.From = Vector2.new(startX, startY)
    drawing.To = Vector2.new(endX, endY)
    drawing.Color = color
    drawing.Thickness = thickness or 1
    drawing.Transparency = transparency or 1
    drawing.ZIndex = (zIndex or 1) + GUI_BASE_ZINDEX
    drawing.Visible = true
end

local function RemoveDrawingPool(pool)
    for _, list in pairs(pool or {}) do
        for _, drawing in ipairs(list) do
            if drawing then
                drawing.Visible = false
                pcall(function() drawing:Remove() end)
            end
        end
    end
end

local function UnloadGalaxDex()
    if GalaxyState.SpectateSubject then Unspectate(nil, true) end
    ShowNotification("Unloaded")
    if _G.GalaxDex then _G.GalaxDex.alive = false end
    setrobloxinput(true)
    RemoveDrawingPool(DrawingPool)
    RemoveDrawingPool(ClassIconDrawingPool)
    if _G.GalaxDex then
        _G.GalaxDex.pool = { sq = {}, tx = {}, ln = {}, ci = {} }
        _G.GalaxDex.iconPool = {}
    end
end

local function RenderCircle(x, y, radius, color, zIndex, filled, thickness, transparency)
    local drawing = GetDrawingFromPool('ci')
    drawing.Position = Vector2.new(x, y)
    drawing.Radius = radius
    drawing.Color = color
    drawing.Filled = filled ~= false
    drawing.Thickness = thickness or 1
    drawing.Transparency = transparency or 1
    drawing.ZIndex = (zIndex or 1) + GUI_BASE_ZINDEX
    drawing.Visible = true
end

local RenderClassIcon

local function RenderTreeArrow(x, y, expanded, hovered)
    local iconName = expanded and "Collapse" or "Expand"
    RenderClassIcon(iconName, x - 8, y - 8, 16, 16, 8, hovered and 1 or 0.92)
end

local function GetClassIconName(className, kind)
    if kind == "LocalPlayer" or kind == "Player" then return "Player" end
    if kind == "NPC" then return "Player" end
    if className and className ~= "" then return className end
    return "Folder"
end

local function IsPngData(data)
    return type(data) == "string"
        and data:byte(1) == 137
        and data:byte(2) == 80
        and data:byte(3) == 78
        and data:byte(4) == 71
        and data:byte(5) == 13
        and data:byte(6) == 10
        and data:byte(7) == 26
        and data:byte(8) == 10
end

local ClassIconWarmSlots = {
    Folder = 40,
    Model = 40,
    Part = 40,
    MeshPart = 28,
    Humanoid = 24,
    Player = 20,
    Script = 18,
    LocalScript = 18,
    ModuleScript = 18,
    Frame = 24,
    TextLabel = 24,
    ImageLabel = 24,
    TextButton = 16,
    ImageButton = 16,
    BoolValue = 16,
    StringValue = 16,
    NumberValue = 16,
    IntValue = 16,
    ObjectValue = 16,
    RemoteEvent = 14,
    RemoteFunction = 14,
    UICorner = 14,
    UIStroke = 14,
    UIAspectRatioConstraint = 14,
    UIGradient = 10,
    Attachment = 12,
    Sound = 12,
    Tool = 12,
    Instance = 20,
    Expand = 40,
    Collapse = 40,
    Search = 8,
    Clear = 8,
    Refresh = 8,
    Settings = 4,
    ColorPicker = 4,
    Reference = 12,
    Warning = 12,
    Lock = 12,
    Modified = 12
}

local ClassIconAliases = {
    Expand = "ui/Expand.png",
    Collapse = "ui/Collapse.png",
    Search = "general/FindAll.png",
    Clear = "ui/CloseWidget.png",
    Refresh = "ui/Recent.png",
    Settings = "general/Settings.png",
    ColorPicker = "general/ColorPicker.png",
    Info = "general/Help.png",
    Player = "general/Player.png",
    Copy = "general/Copy.png",
    Delete = "general/Delete.png",
    Struct = "general/Struct.png",
    Move = "general/Move.png",
    UIOn = "general/UIOn.png",
    UIOff = "general/UIOff.png",
    Warning = "general/Warning.png",
    Reference = "general/Reference.png",
    Lock = "general/Lock.png",
    Modified = "general/Modified.png",
    TeleportService = "instance/TeleportService.png",
    Camera = "instance/Camera.png",
    Path = "instance/Path.png",
    ScriptDocument = "instance/ScriptDocument.png",
    Instance = "instance/Instance.png"
}

local function GetClassIconPath(iconName)
    return ClassIconAliases[iconName] or ("instance/" .. iconName .. ".png")
end

local function WarmClassIcon(iconName, data)
    local list = ClassIconDrawingPool[iconName]
    if not list then
        list = {}
        ClassIconDrawingPool[iconName] = list
    end
    local count = ClassIconWarmSlots[iconName] or 2
    for i = 1, count do
        if not list[i] then
            local drawing = Drawing.new("Image")
            drawing.Data = data
            drawing.Size = Vector2.new(16, 16)
            drawing.Position = Vector2.new(-1000, -1000)
            drawing.Transparency = 1
            drawing.Rounding = 0
            drawing.Visible = false
            list[i] = drawing
        end
    end
end

local function StartClassIconWorker()
    if ClassIconWorkerRunning then return end
    ClassIconWorkerRunning = true
    task.spawn(function()
        local processed = 0
        while _G.GalaxDex and _G.GalaxDex.alive and #ClassIconQueue > 0 do
            local iconName = table.remove(ClassIconQueue, 1)
            local icon = ClassIconCache[iconName]
            if icon and icon.Loading and not icon.Failed and not icon.Data then
                local ok, data = pcall(function()
                    return game:HttpGet(ClassIconBaseUrl .. GetClassIconPath(iconName))
                end)
                if not (_G.GalaxDex and _G.GalaxDex.alive) then break end
                if ok and IsPngData(data) then
                    icon.Data = data
                    WarmClassIcon(iconName, data)
                else
                    icon.Failed = true
                end
                icon.Loading = false
                processed = processed + 1
                task.wait()
            end
        end
        ClassIconWorkerRunning = false
    end)
end

local function RequestClassIcon(iconName)
    if not iconName or iconName == "" then return nil end
    local icon = ClassIconCache[iconName]
    if icon then
        if icon.Data then return icon.Data end
        if icon.Failed and iconName ~= "Instance" then return RequestClassIcon("Instance") end
        return nil
    end

    icon = { Data = nil, Loading = true, Failed = false }
    ClassIconCache[iconName] = icon
    table.insert(ClassIconQueue, iconName)
    StartClassIconWorker()
    return nil
end

RenderClassIcon = function(iconName, x, y, w, h, zIndex, transparency, rounding)
    local data = RequestClassIcon(iconName)
    if not data then return false end

    local list = ClassIconDrawingPool[iconName]
    if not list then
        list = {}
        ClassIconDrawingPool[iconName] = list
    end

    ClassIconDrawingIndex[iconName] = (ClassIconDrawingIndex[iconName] or 0) + 1
    local drawing = list[ClassIconDrawingIndex[iconName]]
    if not drawing then
        drawing = Drawing.new("Image")
        drawing.Data = data
        list[ClassIconDrawingIndex[iconName]] = drawing
    end

    drawing.Position = Vector2.new(x, y)
    drawing.Size = Vector2.new(w, h)
    drawing.Transparency = transparency or 1
    drawing.Rounding = rounding or 0
    drawing.ZIndex = (zIndex or 1) + GUI_BASE_ZINDEX
    drawing.Visible = true
    return true
end

local StartupIconNames = {
    "Expand",
    "Collapse",
    "Search",
    "Clear",
    "Refresh",
    "Settings",
    "ColorPicker"
}

local StartupIconsStarted = false
local function StartStartupIcons()
    if StartupIconsStarted then return end
    StartupIconsStarted = true
    for _, iconName in ipairs(StartupIconNames) do
        RequestClassIcon(iconName)
    end
end

local function GetViewportSize()
    local cam = workspace.CurrentCamera
    local viewport = cam and cam.ViewportSize
    if viewport and typeof(viewport) == "Vector2" then return viewport end
    return Vector2.new(1920, 1080)
end

local function GetClassIconLoadStats()
    local loaded, total = 0, 0
    for _, icon in pairs(ClassIconCache) do
        total = total + 1
        if icon.Data or icon.Failed then
            loaded = loaded + 1
        end
    end
    return loaded, total
end

local function AreClassIconsLoaded()
    local loaded, total = GetClassIconLoadStats()
    return total > 0 and loaded >= total and #ClassIconQueue == 0 and not ClassIconWorkerRunning
end

local function IsMouseOver(x, y, w, h)
    return Mouse.X >= x and Mouse.X <= x + w and Mouse.Y >= y and Mouse.Y <= y + h
end

local function IsMouseAllowedFor(owner, id)
    if GalaxyState.IsDraggingLayoutSplit then
        return owner == "LayoutSplit"
    end
    if GalaxyState.ContextMenu then
        return owner == "ContextMenu"
    end
    if GalaxyState.FocusedElement then
        return owner == "TextInput" and id == GalaxyState.FocusedElement
    end
    return true
end

local function IsMouseBlockedFor(owner)
    return not IsMouseAllowedFor(owner)
end

local function RememberFocusRect(id, x, y, w, h)
    GalaxyState.FocusRects[id] = { X = x, Y = y, W = w, H = h }
end

local function IsInsideFocusedRect()
    local id = GalaxyState.FocusedElement
    local rect = id and GalaxyState.FocusRects[id]
    return rect and IsMouseOver(rect.X, rect.Y, rect.W, rect.H)
end

local function GetInstancePath(instance)
    if not instance then return "nil" end
    local ok, fullName = pcall(function() return instance:GetFullName() end)
    if not ok then return "game" end
    local path, parts = "game", {}
    for part in fullName:gmatch("[^%.]+") do table.insert(parts, part) end
    for i = 2, #parts do
        local p = parts[i]
        path = path .. (p:match("^[%a_][%w_]*$") and ("." .. p) or ('["' .. p .. '"]'))
    end
    return path
end

local function CreateInteractiveButton(x, y, w, h, label, accentColor, symbol, zIndex, owner, iconName)
    local hovered = (not IsMouseBlockedFor(owner)) and IsMouseOver(x, y, w, h)
    local background = Theme.Section
    local border = Theme.BorderBright
    local z = zIndex or 8

    if hovered then
        background = Color3.fromRGB(25, 40, 65)
        border = Theme.AccentHover
    end

    RenderSquare(x, y, w, h, background, true, 4, z)
    RenderSquare(x, y, w, h, border, false, 4, z + 1)

    if symbol == "Set" then
        RenderLine(x + 5, y + 9, x + 8, y + 13, Theme.White, z + 4)
        RenderLine(x + 8, y + 13, x + 14, y + 5, Theme.White, z + 4)
    elseif symbol == "Reset" then
        RenderCircle(x + 9, y + 9, 4, Theme.White, z + 4, false, 1)
    elseif iconName and RenderClassIcon(iconName, x + 7, y + math.floor((h - 16) / 2), 16, 16, z + 3, hovered and 1 or 0.92) then
        RenderText(FitTextToWidth(label, w - 36, 11), x + 29, y + math.floor((h - 12) / 2),
            hovered and Theme.White or Theme.Text, 11, Drawing.Fonts.System, z + 2)
    elseif label then
        RenderText(FitTextToWidth(label, w - 10, 11), x + w / 2, y + h / 2 - 1,
            hovered and Theme.White or Theme.Text, 11, Drawing.Fonts.System, z + 2, true)
    end

    if GalaxyState.IsMouseClicked and hovered then
        GalaxyState.IsMouseClicked = false
        return true
    end
    return false
end

local function CreateToolbarIconButton(x, y, size, iconName, zIndex, owner, focusId, drawBackground, iconSize)
    local hovered = IsMouseAllowedFor(owner, focusId) and IsMouseOver(x, y, size, size)
    local z = zIndex or 8
    local bg = hovered and Color3.fromRGB(25, 40, 65) or Color3.fromRGB(21, 21, 31)
    local border = hovered and Theme.AccentHover or Theme.Border
    local drawBg = drawBackground ~= false

    if drawBg then
        RenderSquare(x, y, size, size, bg, true, 5, z, Theme.GlassStrong)
        RenderSquare(x, y, size, size, border, false, 5, z + 1)
    end

    local imgSize = iconSize or math.max(12, size - 8)
    local imgX = x + (size - imgSize) / 2
    local imgY = y + (size - imgSize) / 2
    RenderClassIcon(iconName, imgX, imgY, imgSize, imgSize, z + 3, hovered and 1 or 0.9)

    if GalaxyState.IsMouseClicked and hovered then
        GalaxyState.IsMouseClicked = false
        return true
    end
    return false
end

local function RenderAccentColorPicker(x, y, w, zIndex)
    local z = zIndex or 84
    local pad = 8
    local areaX, areaY = x + pad, y + pad
    local areaW, areaH = w - pad * 2, 76
    local barY, barH = areaY + areaH + 8, 10
    local mouseDown = ismouse1pressed()

    if GalaxyState.IsMouseClicked and IsMouseOver(areaX, areaY, areaW, areaH) then
        GalaxyState.ColorPickerDrag = "SV"
    elseif GalaxyState.IsMouseClicked and IsMouseOver(areaX, barY, areaW, barH) then
        GalaxyState.ColorPickerDrag = "Hue"
    end
    if not mouseDown then GalaxyState.ColorPickerDrag = nil end

    if GalaxyState.ColorPickerDrag == "SV" then
        ThemeAccent.S = math.clamp((Mouse.X - areaX) / areaW, 0, 1)
        ThemeAccent.V = math.clamp(1 - ((Mouse.Y - areaY) / areaH), 0, 1)
        ApplyThemeAccent()
    elseif GalaxyState.ColorPickerDrag == "Hue" then
        ThemeAccent.H = math.clamp((Mouse.X - areaX) / areaW, 0, 1)
        ApplyThemeAccent()
    end

    RenderSquare(x, y, w, areaH + barH + pad * 3, Theme.Background, true, 6, z, Theme.GlassStrong)
    RenderSquare(x, y, w, areaH + barH + pad * 3, Theme.BorderBright, false, 6, z + 1)

    local cols, rows = 18, 10
    local cellW, cellH = areaW / cols, areaH / rows
    for row = 0, rows - 1 do
        local value = 1 - (row / (rows - 1))
        for col = 0, cols - 1 do
            local sat = col / (cols - 1)
            RenderSquare(areaX + col * cellW, areaY + row * cellH, cellW + 1, cellH + 1,
                HSVToColor3(ThemeAccent.H, sat, value), true, 0, z + 2, 1)
        end
    end
    RenderSquare(areaX, areaY, areaW, areaH, Theme.Border, false, 4, z + 3)

    local cursorX = areaX + ThemeAccent.S * areaW
    local cursorY = areaY + (1 - ThemeAccent.V) * areaH
    RenderCircle(cursorX, cursorY, 4, Theme.White, z + 5, false, 1.5, 1)

    local segments = 36
    local segW = areaW / segments
    for i = 0, segments - 1 do
        RenderSquare(areaX + i * segW, barY, segW + 1, barH, HSVToColor3(i / segments, 1, 1), true, 0, z + 2, 1)
    end
    RenderSquare(areaX, barY, areaW, barH, Theme.Border, false, 3, z + 3)
    local hueX = areaX + ThemeAccent.H * areaW
    RenderLine(hueX, barY - 2, hueX, barY + barH + 2, Theme.White, z + 5, 1.5, 1)

    return y + areaH + barH + pad * 3
end

local function RenderSelectedChams(baseCFrame, basePos, size)
    if not baseCFrame or typeof(baseCFrame) ~= "CFrame" then return nil, nil end
    if not size or typeof(size) ~= "Vector3" then return nil, nil end

    local halfRight, halfY, halfLook = size.X * 0.5, size.Y * 0.5, size.Z * 0.5
    local function corner(x, y, z)
        return basePos + (baseCFrame.RightVector * z) + (baseCFrame.UpVector * y) + (baseCFrame.LookVector * x)
    end

    local worldCorners = {
        corner(-halfLook, -halfY, -halfRight),
        corner( halfLook, -halfY, -halfRight),
        corner(-halfLook,  halfY, -halfRight),
        corner( halfLook,  halfY, -halfRight),
        corner(-halfLook, -halfY,  halfRight),
        corner( halfLook, -halfY,  halfRight),
        corner(-halfLook,  halfY,  halfRight),
        corner( halfLook,  halfY,  halfRight)
    }

    local screenCorners = {}
    local minX, minY, maxX = math.huge, math.huge, -math.huge
    local lines = {}
    for i = 1, 8 do
        local screen, onScreen = WorldToScreen(worldCorners[i])
        if onScreen then
            screenCorners[i] = screen
            minX = math.min(minX, screen.X)
            minY = math.min(minY, screen.Y)
            maxX = math.max(maxX, screen.X)
        end
    end

    for _, edge in ipairs(BoxEdges) do
        local a, b = screenCorners[edge[1]], screenCorners[edge[2]]
        if a and b then
            lines[#lines + 1] = { a.X, a.Y, b.X, b.Y }
        end
    end

    if minX < math.huge and maxX > minX then
        return (minX + maxX) / 2, minY, lines
    end
    return nil, nil
end

local function RenderSelectedEspFrame(frame)
    if not frame then return false end
    for _, line in ipairs(frame.Lines or {}) do
        RenderLine(line[1], line[2], line[3], line[4], Theme.Accent, 81, 1, SelectedEsp.ChamsAlpha)
    end

    RenderSquare(frame.LabelX, frame.Y, frame.LabelW, frame.H, Theme.Section, true, 5, 82, Theme.Glass)
    RenderSquare(frame.LabelX, frame.Y, frame.LabelW, frame.H, Theme.BorderBright, false, 5, 83, Theme.GlassStrong)
    RenderText(frame.Label, frame.LabelX + (frame.LabelW / 2), frame.TextY, Theme.White, frame.TextSize,
        Drawing.Fonts.System, 84, true)

    RenderSquare(frame.DistanceX, frame.Y, frame.DistanceW, frame.H, Theme.Section, true, 5, 82, Theme.Glass)
    RenderSquare(frame.DistanceX, frame.Y, frame.DistanceW, frame.H, Theme.Border, false, 5, 83, Theme.GlassStrong)
    RenderText(frame.Distance, frame.DistanceX + (frame.DistanceW / 2), frame.TextY, Theme.SubText, frame.TextSize,
        Drawing.Fonts.System, 84, true)
    return true
end

local function RenderSelectedEsp(target, espPart)
    if not SelectedEsp.Enabled or not IsInstanceValid(target) then
        GalaxyState.SelectedVisualCache.Esp = nil
        return
    end
    espPart = espPart or GetSelectedPhysicalPart(target)
    if not espPart then
        RenderSelectedEspFrame(GalaxyState.SelectedVisualCache.Esp)
        return
    end

    local basePos = ExecuteSafely(function() return espPart.Position end)
    local cameraPos = GetCameraPosition()
    if not basePos or not cameraPos then
        RenderSelectedEspFrame(GalaxyState.SelectedVisualCache.Esp)
        return
    end

    local distance = (cameraPos - basePos).Magnitude
    if distance < SelectedEsp.MinDistance then
        GalaxyState.SelectedVisualCache.Esp = nil
        return
    end

    local size = ExecuteSafely(function() return espPart.Size end)
    local baseCFrame = ExecuteSafely(function() return espPart.CFrame end)
    if not baseCFrame or typeof(baseCFrame) ~= "CFrame" then
        RenderSelectedEspFrame(GalaxyState.SelectedVisualCache.Esp)
        return
    end
    local boxCenterX, boxTopY, lines = RenderSelectedChams(baseCFrame, basePos, size)

    local targetHeight = (size and typeof(size) == "Vector3") and math.max(size.Y, 1) or 2
    local tipWorld = basePos + Vector3.new(0, targetHeight * SelectedEsp.TipHeightScale, 0)
    local tipScreen, tipVisible = WorldToScreen(tipWorld)
    if not tipVisible then
        tipScreen, tipVisible = WorldToScreen(basePos)
        if not tipVisible then
            RenderSelectedEspFrame(GalaxyState.SelectedVisualCache.Esp)
            return
        end
    end

    local labelSize = math.floor(math.clamp(
        SelectedEsp.TextSize * (SelectedEsp.LabelScaleDistance / math.max(distance, 10)),
        SelectedEsp.MinTextSize,
        SelectedEsp.TextSize
    ) + 0.5)
    local label = GetDisplayName(target)
    if #label > 32 then label = label:sub(1, 29) .. "..." end
    local distanceLabel = tostring(math.floor(distance)) .. "m"

    local labelPaddingX = math.max(6, labelSize * 0.7)
    local labelWidth = (#label * labelSize * 0.56) + (labelPaddingX * 2)
    local distanceWidth = (#distanceLabel * labelSize * 0.56) + (labelPaddingX * 2)
    local labelHeight = math.max(16, labelSize + 9)
    local sectionGap = SelectedEsp.Gap
    local totalWidth = labelWidth + sectionGap + distanceWidth
    local anchorX = boxCenterX or tipScreen.X
    local anchorY = boxTopY or tipScreen.Y
    local bgY = anchorY - labelHeight - 7
    local labelBgX = anchorX - (totalWidth / 2)
    local distanceBgX = labelBgX + labelWidth + sectionGap
    local textY = bgY + (labelHeight / 2) - 1

    GalaxyState.SelectedVisualCache.Esp = {
        Lines = lines,
        Label = label,
        Distance = distanceLabel,
        LabelX = labelBgX,
        DistanceX = distanceBgX,
        Y = bgY,
        LabelW = labelWidth,
        DistanceW = distanceWidth,
        H = labelHeight,
        TextY = textY,
        TextSize = labelSize
    }
    RenderSelectedEspFrame(GalaxyState.SelectedVisualCache.Esp)
end

local function RenderSelectedUiFrame(frame)
    if not frame then return false end
    RenderSquare(frame.X, frame.Y, frame.W, frame.H, Color3.fromRGB(25, 40, 65), true, 0, -100, 0.5)
    RenderSquare(frame.X, frame.Y, frame.W, frame.H, Theme.Accent, false, 0, -99, 1)
    return true
end

local function RenderSelectedUi(target)
    if not IsInstanceValid(target) then
        GalaxyState.SelectedVisualCache.Ui = nil
        return
    end

    local absPos = ExecuteSafely(function() return target.AbsolutePosition end)
    local absSize = ExecuteSafely(function() return target.AbsoluteSize end)
    if absPos and absSize and typeof(absPos) == "Vector2" and typeof(absSize) == "Vector2" and
        absSize.X > 0 and absSize.Y > 0 then
        GalaxyState.SelectedVisualCache.Ui = {
            X = absPos.X,
            Y = absPos.Y,
            W = absSize.X,
            H = absSize.Y
        }
    end

    RenderSelectedUiFrame(GalaxyState.SelectedVisualCache.Ui)
end

local function RenderSelectedVisualCache()
    RenderSelectedUiFrame(GalaxyState.SelectedVisualCache.Ui)
    RenderSelectedEspFrame(GalaxyState.SelectedVisualCache.Esp)
end

local function HandleKeyboardScroll(id, currentValue, maxValue, step, isActive)
    GalaxyState.ScrollKeyHold = GalaxyState.ScrollKeyHold or {}
    if not isActive or maxValue <= 0 or GalaxyState.FocusedElement or GalaxyState.ContextMenu then
        GalaxyState.ScrollKeyHold[id .. "_Up"] = nil
        GalaxyState.ScrollKeyHold[id .. "_Down"] = nil
        return math.clamp(currentValue, 0, maxValue)
    end

    local now = os.clock()

    local function applyKey(keyName, keyCode, direction, value)
        local stateKey = id .. "_" .. keyName
        local isDown = iskeypressed(keyCode)
        local hold = GalaxyState.ScrollKeyHold[stateKey]

        if isDown then
            if not hold then
                GalaxyState.ScrollKeyHold[stateKey] = { Started = now, LastStep = now }
                return math.clamp(value + direction * step, 0, maxValue)
            elseif now - hold.Started >= 0.5 and now - hold.LastStep >= 0.06 then
                hold.LastStep = now
                return math.clamp(value + direction * step, 0, maxValue)
            end
        else
            GalaxyState.ScrollKeyHold[stateKey] = nil
        end

        return value
    end

    currentValue = applyKey("Up", 0x26, -1, currentValue)
    currentValue = applyKey("Down", 0x28, 1, currentValue)
    return currentValue
end

PopulateNodeChildren = function(node, knownChildren, timestamp)
    node.Children = node.Children or {}
    local success, children = true, knownChildren
    if not children then
        success, children = pcall(function() return node.Instance:GetChildren() end)
    end
    if success then
        node.ChildCount = #children
        node.HasChildren = node.ChildCount > 0
        node.LastChildCheck = timestamp or os.clock()

        local existingByInstance = {}
        local existingByAddress = {}
        local existingByName = {}
        for _, childNode in ipairs(node.Children) do
            if childNode.Instance then
                existingByInstance[childNode.Instance] = childNode
            end
            if childNode.Address then
                existingByAddress[childNode.Address] = childNode
            end
            local key = childNode.ClassName .. "\0" .. childNode.Name
            existingByName[key] = childNode
        end

        local newChildren = {}
        for _, child in ipairs(children) do
            local existingNode = existingByInstance[child]
            if not existingNode then
                local childAddress = GetInstanceAddress(child)
                existingNode = childAddress and existingByAddress[childAddress]
            end
            if not existingNode then
                local key = child.ClassName .. "\0" .. child.Name
                existingNode = existingByName[key]
                if existingNode then
                    local wasSelected = (GalaxyState.Selected == existingNode.Instance) or
                    (GalaxyState.SelectedNode == existingNode)
                    if wasSelected then
                        GalaxyState.Selected = child
                        GalaxyState.SelectedNode = existingNode
                        MarkSelectedChanged()
                    end
                    existingByName[key] = nil -- Consume it to avoid duplicate mapping
                end
            end

            if existingNode then
                if GalaxyState.SelectedNode == existingNode or GalaxyState.Selected == existingNode.Instance then
                    GalaxyState.Selected = child
                    GalaxyState.SelectedNode = existingNode
                    MarkSelectedChanged()
                end
                RefreshNodeIdentity(existingNode, child)
                table.insert(newChildren, existingNode)
            else
                local childNode = CreateTreeNode(child, node.Depth + 1)
                RefreshNodeIdentity(childNode, child)
                table.insert(newChildren, childNode)
            end
        end

        table.sort(newChildren, function(a, b)
            if node.Instance == game then
                local o1 = ExplorerOrder[a.ClassName] or 99
                local o2 = ExplorerOrder[b.ClassName] or 99
                if o1 ~= o2 then return o1 < o2 end
            end
            if a.ClassName ~= b.ClassName then return a.ClassName < b.ClassName end
            return a.Name:lower() < b.Name:lower()
        end)

        local nameCounts = {}
        for _, childNode in ipairs(newChildren) do
            local key = childNode.ClassName .. "\0" .. childNode.Name
            nameCounts[key] = (nameCounts[key] or 0) + 1
        end

        local nameIndices = {}
        for _, childNode in ipairs(newChildren) do
            local key = childNode.ClassName .. "\0" .. childNode.Name
            if nameCounts[key] > 1 then
                nameIndices[key] = (nameIndices[key] or 0) + 1
                childNode.Suffix = " [" .. nameIndices[key] .. "]"
            else
                childNode.Suffix = nil
            end
        end

        node.Children = newChildren
    end
end

local function FormatPropertyValue(value, valueType)
    if value == nil then return "nil" end
    if typeof(value) == "Vector3" then return FormatDecimal(value.X) .. ", " .. FormatDecimal(value.Y) .. ", " .. FormatDecimal(value.Z) end
    if typeof(value) == "Vector2" then return FormatDecimal(value.X) .. ", " .. FormatDecimal(value.Y) end
    if typeof(value) == "Color3" then
        return string.format("RGB(%d, %d, %d)", math.floor(value.R * 255),
            math.floor(value.G * 255), math.floor(value.B * 255))
    end
    if typeof(value) == "UDim2" then
        return string.format("{%s, %d}, {%s, %d}", FormatDecimal(value.X.Scale), value.X.Offset,
            FormatDecimal(value.Y.Scale), value.Y.Offset)
    end
    if typeof(value) == "CFrame" then
        local rx, ry, rz = value:ToEulerAnglesXYZ()
        return FormatDecimal(math.deg(rx)) .. ", " .. FormatDecimal(math.deg(ry)) .. ", " .. FormatDecimal(math.deg(rz))
    end
    if type(value) == "number" then
        if valueType == "int" or valueType == "byte" or valueType == "uint64" then
            return tostring(math.floor(value))
        end
        return FormatDecimal(value)
    end
    if type(value) == "table" then return "Table" end
    if type(value) == "function" then return "Function" end

    local ok, str = pcall(tostring, value)
    if not ok or type(str) ~= "string" then str = "???" end
    return #str > 30 and str:sub(1, 27) .. "..." or str
end

local function GetPropertyValueType(value, defaultType)
    local kind = typeof(value)
    if kind == "Vector3" then return "vector3" end
    if kind == "Vector2" then return "vector2" end
    if kind == "Color3" then return "color3" end
    if kind == "UDim2" then return "udim2" end
    if kind == "CFrame" then return "cframe" end
    if kind == "boolean" or kind == "bool" or type(value) == "boolean" then return "boolean" end
    return defaultType or type(value)
end

local function IsBooleanType(propType)
    return propType == "boolean" or propType == "bool"
end

local function SplitCommaValues(value)
    local parts = {}
    local text = tostring(value or "")
    local start = 1
    while true do
        local commaPos = text:find(",", start, true)
        if not commaPos then
            parts[#parts + 1] = text:sub(start):match("^%s*(.-)%s*$")
            break
        end
        parts[#parts + 1] = text:sub(start, commaPos - 1):match("^%s*(.-)%s*$")
        start = commaPos + 1
    end
    return parts
end

local function ComponentCountForType(propType)
    return propType == "vector2" and 2 or 3
end

local function BuildComponentStrings(valueText, propType)
    local parts = {}
    if propType == "color3" then
        for n in tostring(valueText or ""):gmatch("[-%d%.]+") do
            parts[#parts + 1] = n
        end
    else
        parts = SplitCommaValues(valueText)
    end

    local count = ComponentCountForType(propType)
    for i = 1, count do
        if parts[i] == nil then parts[i] = "0" end
    end
    for i = #parts, count + 1, -1 do
        parts[i] = nil
    end
    return parts
end

local function BuildComponentEditValue(components, propType)
    if propType == "color3" then
        return "RGB(" .. table.concat(components, ", ") .. ")"
    end
    return table.concat(components, ", ")
end

local function GetComponentStrings(propData)
    if propData and propData.Components then return propData.Components end
    if not propData then return {} end
    propData.Components = BuildComponentStrings(propData.EditValue, propData.Type)
    return propData.Components
end

local function GetDirectSpecsForClass(className)
    local directSpecs = {}
    local directNames = {}

    local function add_specs(specsList)
        for _, spec in ipairs(specsList or {}) do
            if not directNames[spec.Name] then
                directNames[spec.Name] = true
                directSpecs[#directSpecs + 1] = spec
            end
        end
    end

    add_specs(DirectPropertySpecs[className])
    if BasePartClasses[className] then add_specs(DirectPropertySpecs.BasePart) end
    if GuiObjectClasses[className] then add_specs(DirectPropertySpecs.GuiObject) end
    if ValueBaseClasses[className] then add_specs(DirectPropertySpecs.ValueBase) end

    return directSpecs, directNames
end

local function BuildPropertyLines(props)
    local directProps, memoryProps = {}, {}
    for _, prop in ipairs(props or {}) do
        if prop.Memory then
            memoryProps[#memoryProps + 1] = prop
        else
            directProps[#directProps + 1] = prop
        end
    end

    local lines = {}
    if #directProps > 0 then
        lines[#lines + 1] = { IsHeader = true, Name = "Properties", Icon = "Reference" }
        for _, prop in ipairs(directProps) do lines[#lines + 1] = prop end
    end
    if #memoryProps > 0 then
        lines[#lines + 1] = { IsHeader = true, Name = "Memory", Icon = "Warning" }
        for _, prop in ipairs(memoryProps) do lines[#lines + 1] = prop end
    end
    return lines
end

UpdatePropertyPanel = function()
    local props = {}
    local target = GalaxyState.Selected
    if not IsInstanceValid(target) then
        ClearSelectedState()
        return
    end

    local function add_val(prop, val, source, realProp, readOnly, isAttribute, memoryMeta, valueType)
        if val == nil then return end
        for i = #props, 1, -1 do if props[i].Name == prop then table.remove(props, i) end end
        local propType = GetPropertyValueType(val, valueType)
        local strVal = FormatPropertyValue(val, propType)
        local components = nil
        if propType == "vector3" or propType == "vector2" or propType == "color3" then
            components = BuildComponentStrings(strVal, propType)
        end
        table.insert(props, {
            Name = prop,
            Value = strVal,
            Original = strVal,
            EditValue = strVal,
            Components = components,
            IsReadOnly = readOnly or false,
            Type = propType,
            IsBoolean = IsBooleanType(propType),
            IsVector = (propType == "vector3" or propType == "vector2"),
            IsColor = (propType == "color3"),
            IsVirtual = (source ~= target),
            VirtualTarget = source,
            VirtualProp = realProp or prop,
            IsAttribute = isAttribute or false,
            Memory = memoryMeta
        })
    end

    local className = ExecuteSafely(function() return target.ClassName end) or ""
    local targetName = GetDisplayName(target)
    local targetAddress = GetInstanceAddress(target)
    local primitiveAddress

    add_val("Name", targetName, target, "Name", false)
    props[#props].Direct = true
    add_val("ClassName", className, target, "ClassName", true)
    add_val("Address", FormatPointer(targetAddress), target, "Address", true, false, nil, "string")

    local function add_memory(prop, offsetClass, offsetField, memType, readOnly, baseAddress, displayType)
        local address = baseAddress or targetAddress
        local offset = GetOffset(offsetClass, offsetField)
        local val = MemoryReadByType(address, offset, memType)
        if val == nil then return end
        if memType == "uintptr_t" then
            val = FormatPointer(val)
            readOnly = true
            displayType = "string"
        elseif memType == "udim2" or memType == "matrix3" or memType == "cframe" then
            readOnly = true
            displayType = "string"
        end
        add_val(prop, val, target, prop, readOnly, false, {
            Address = address,
            Offset = offset,
            Type = memType,
            OffsetClass = offsetClass,
            OffsetField = offsetField
        }, displayType or memType)
    end

    local function primitive_address()
        if primitiveAddress ~= nil then return primitiveAddress end
        local primitiveOffset = GetOffset("BasePart", "Primitive")
        if not targetAddress or not primitiveOffset then return nil end
        primitiveAddress = ReadMemoryPtr(targetAddress, primitiveOffset) or false
        return primitiveAddress
    end

    local function add_primitive(prop, offsetField, memType, readOnly)
        local prim = primitive_address()
        if not prim or prim == 0 then return end
        add_memory(prop, "Primitive", offsetField, memType, readOnly, prim)
    end

    local function add_primitive_flag(prop, flagField, readOnly)
        local prim = primitive_address()
        local flagsOffset = GetOffset("Primitive", "Flags")
        local mask = GetOffset("PrimitiveFlags", flagField)
        if not prim or not flagsOffset or not mask then return end
        local flags = ReadMemoryByte(prim, flagsOffset)
        if flags == nil then return end
        add_val(prop, bit32.band(flags, mask) ~= 0, target, prop, readOnly, false, {
            Address = prim,
            Offset = flagsOffset,
            Type = "flag",
            Mask = mask,
            OffsetClass = "PrimitiveFlags",
            OffsetField = flagField
        }, "boolean")
    end

    local function add_direct_spec(spec, forceReadOnly)
        local ok, val
        if spec.Reader then
            ok, val = pcall(spec.Reader, target)
        else
            ok, val = pcall(function() return target[spec.Name] end)
        end
        if not ok or val == nil then return end
        add_val(spec.Name, val, target, spec.Name, forceReadOnly or spec.ReadOnly, false, nil, GetPropertyValueType(val))
        props[#props].Direct = not spec.Reader
    end

    local directSpecs, nativeDirectNames = GetDirectSpecsForClass(className)

    local specs = PropertyOffsetSpecs[className]
    if not specs and BasePartClasses[className] then
        specs = PropertyOffsetSpecs.BasePart
    elseif not specs and GuiObjectClasses[className] then
        specs = PropertyOffsetSpecs.GuiObject
    end

    for _, spec in ipairs(directSpecs) do
        add_direct_spec(spec, className == "ObjectValue" and spec.Name == "Value")
    end

    for _, spec in ipairs(specs or {}) do
        if nativeDirectNames[spec.Name] then
            -- Matcha exposes this property directly; avoid a duplicate memory read.
        elseif spec.Kind == "primitive" then
            add_primitive(spec.Name, spec.OffsetField, spec.Type, spec.ReadOnly)
        elseif spec.Kind == "flag" then
            add_primitive_flag(spec.Name, spec.OffsetField, spec.ReadOnly)
        else
            add_memory(spec.Name, spec.OffsetClass, spec.OffsetField, spec.Type, spec.ReadOnly)
        end
    end

    local attrs = ExecuteSafely(function() return target:GetAttributes() end)
    if attrs and type(attrs) == "table" then
        for k, v in pairs(attrs) do
            local attrName, attrVal
            if type(k) == "string" then
                attrName = k
                attrVal = v
            elseif type(k) == "number" and type(v) == "string" then
                attrName = v
                attrVal = ExecuteSafely(function() return target:GetAttribute(v) end)
            end

            if attrName then
                add_val(attrName, attrVal, target, attrName, false, true)
            end
        end
    end

    GalaxyState.PropLines = BuildPropertyLines(props)
end

local function ApplyProp(foc)
    if not foc or foc:sub(1, 5) ~= "Prop_" then return end
    local parts = {}
    for p in foc:gmatch("[^_]+") do table.insert(parts, p) end
    local idx = tonumber(parts[2])
    local pData = idx and GalaxyState.PropLines[idx]
    if not pData or pData.IsHeader or not GalaxyState.Selected then
        return ReportGalaxError("Property apply failed", BuildDiagnosticContext({
            Action = "Apply Property",
            Reason = "Property data or selected target is missing",
            Property = foc
        }))
    end

    if pData.IsReadOnly then
        return ReportGalaxError("Property apply failed", BuildDiagnosticContext({
            Action = "Apply Property",
            Reason = "Attempted to write a read-only property",
            Property = pData.Name,
            PropertyType = pData.Type,
            Value = pData.EditValue
        }))
    end

    if pData and GalaxyState.Selected then
        local ok, err = pcall(function()
            local val = pData.EditValue
            local tObj = pData.IsVirtual and pData.VirtualTarget or GalaxyState.Selected
            local tProp = pData.IsVirtual and pData.VirtualProp or pData.Name
            if not tObj then error("Target object is nil") end
            if not tProp then error("Target property is nil") end
            local renameLinks = (tProp == "Name" and pData.Direct and not pData.IsAttribute) and GetRenameLinks(tObj) or nil

            if IsBooleanType(pData.Type) or pData.IsBoolean then
                val = (val == true or val == "true" or val == 1 or val == "1")
            elseif pData.Type == "string" then
                val = tostring(val)
            elseif pData.IsVector then
                local components = pData.Components or BuildComponentStrings(val, pData.Type)
                if pData.Type == "vector3" then
                    val = Vector3.new(tonumber(components[1]) or 0, tonumber(components[2]) or 0, tonumber(components[3]) or 0)
                elseif pData.Type == "vector2" then
                    val = Vector2.new(tonumber(components[1]) or 0, tonumber(components[2]) or 0)
                elseif pData.Type == "userdata" then
                    local _, commaCount = pData.Original:gsub(",", "")
                    if commaCount == 2 then
                        val = Vector3.new(tonumber(components[1]) or 0, tonumber(components[2]) or 0, tonumber(components[3]) or 0)
                    else
                        val = Vector2.new(tonumber(components[1]) or 0, tonumber(components[2]) or 0)
                    end
                end
            elseif pData.IsColor or pData.Type == "color3" or (pData.Type == "userdata" and pData.Original:find("RGB", 1, true)) then
                local components = pData.Components or BuildComponentStrings(val, "color3")
                val = Color3.fromRGB(tonumber(components[1]) or 0, tonumber(components[2]) or 0, tonumber(components[3]) or 0)
            elseif tonumber(val) then
                val = tonumber(val)
            end
            if pData.IsAttribute then
                local wrote, writeErr = pcall(function()
                    tObj:SetAttribute(tProp, val)
                end)
                if not wrote then error("SetAttribute failed: " .. tostring(writeErr)) end
            elseif pData.Direct then
                local wrote, writeErr = pcall(function()
                    tObj[tProp] = val
                end)
                if not wrote then error("Direct property write failed: " .. tostring(writeErr)) end
                ApplyRenameLinks(tObj, renameLinks, val)
            else
                local didMemWrite = false
                local mem = pData.Memory
                if mem and mem.Address and mem.Offset then
                    if mem.Type == "flag" then
                        local flags = ReadMemoryByte(mem.Address, mem.Offset)
                        if flags ~= nil and mem.Mask then
                            if val == true or val == "true" or val == 1 or val == "1" then
                                flags = bit32.bor(flags, mem.Mask)
                            else
                                flags = bit32.band(flags, bit32.bnot(mem.Mask))
                            end
                            WriteMemoryByte(mem.Address, mem.Offset, flags)
                            didMemWrite = true
                        end
                    else
                        didMemWrite = MemoryWriteByType(mem.Address, mem.Offset, mem.Type, val)
                    end

                    if didMemWrite and pData.Name == "WalkSpeed" and tonumber(val) then
                        local oCheck = GetOffset("Humanoid", "WalkspeedCheck")
                        local humAddress = ExecuteSafely(function() return tObj.Address end)
                        if oCheck and humAddress then
                            WriteMemoryFloat(humAddress, oCheck, tonumber(val))
                        end
                    end
                end

                if not didMemWrite then
                    error("No writer succeeded for property " .. tostring(pData.Name))
                end
            end
        end)

        if not ok then
            ReportGalaxError("Property apply failed", BuildDiagnosticContext({
                Action = "Apply Property",
                Property = pData.Name,
                PropertyType = pData.Type,
                Value = pData.EditValue,
                Target = pData.IsVirtual and pData.VirtualTarget or GalaxyState.Selected,
                Memory = pData.Memory and ((pData.Memory.Type or "?") .. " " .. FormatPointer(pData.Memory.Address) .. " + " .. tostring(pData.Memory.Offset)) or "none",
                Error = err
            }))
        else
            GalaxyState.LastEditTime = os.clock()

            local newVal = pData.EditValue
            if pData.Type == "string" then newVal = tostring(newVal) end
            pData.Value = FormatPropertyValue(newVal, pData.Type)
            pData.EditValue = pData.Value

            if pData.Name == "Name" then
                RememberInstanceName(GalaxyState.Selected, newVal)
                RefreshLoadedNodeName(GalaxyState.Selected, newVal)
                MarkSelectedChanged()
                GalaxyState.LastTreeRefresh = 0
            end

            GalaxyState.LastPropertyUpdate = pData.Name == "Name" and 0 or os.clock() + 0.5
            ShowNotification("Set " .. pData.Name)
        end
    end
end

local function NavigateToInstance(target)
    if not target then return end
    CurrentTab = "Explorer"

    if not GalaxyState.TreeRoot or GalaxyState.TreeRoot.Instance ~= game then
        GalaxyState.TreeRoot = CreateTreeNode(game, 0)
        GalaxyState.TreeRoot.Expanded = true
    end
    if not GalaxyState.TreeRoot.Children or #GalaxyState.TreeRoot.Children == 0 then PopulateNodeChildren(GalaxyState
        .TreeRoot) end

    local path = {}
    local current = target.Parent
    while current and current ~= game do
        if ExecuteSafely(function() return current.ClassName == "DataModel" end) then break end
        table.insert(path, 1, current)
        current = current.Parent
    end

    local node = GalaxyState.TreeRoot
    for i, ancestor in ipairs(path) do
        local aName = ExecuteSafely(function() return ancestor.Name end) or "???"
        local aClass = ExecuteSafely(function() return ancestor.ClassName end) or "???"
        if not node.Children or #node.Children == 0 then PopulateNodeChildren(node) end
        local found = nil
        for _, child in ipairs(node.Children or {}) do
            if child.Instance == ancestor or (child.Name == aName and child.ClassName == aClass) then
                child.Expanded = true; found = child; break
            end
        end
        if found then
            node = found
        else
            break
        end
    end

    local tName = ExecuteSafely(function() return target.Name end) or "Object"
    local tClass = ExecuteSafely(function() return target.ClassName end) or "???"
    local targetAddress = GetInstanceAddress(target)
    if not node.Children or #node.Children == 0 then PopulateNodeChildren(node) end

    local targetNode = nil
    for _, child in ipairs(node.Children or {}) do
        if child.Instance == target or (targetAddress and child.Address == targetAddress) or
            (child.Name == tName and child.ClassName == tClass) then
            child.Expanded = true
            if child.HasChildren and (#(child.Children or {}) == 0) then PopulateNodeChildren(child) end
            GalaxyState.Selected = child.Instance
            GalaxyState.SelectedNode = child
            MarkSelectedChanged()
            targetNode = child
            break
        end
    end

    if not GalaxyState.Selected then
        GalaxyState.Selected = target
        MarkSelectedChanged()
    end

    local function GetFlattenedIndex(nodes, goal, count)
        for _, n in ipairs(nodes) do
            count = count + 1
            if n.Instance == goal then return count, true end
            if n.Expanded and n.Children then
                local res, found = GetFlattenedIndex(n.Children, goal, count)
                count = res
                if found then return count, true end
            end
        end
        return count, false
    end

    local idx, found = GetFlattenedIndex(GalaxyState.TreeRoot.Children, GalaxyState.Selected, 0)
    if found then
        local targetY = (idx - 1) * 20
        local scroll = (CurrentTab == "Search") and GalaxyState.SearchScrollY or GalaxyState.ScrollY
        if not (targetY >= scroll and (targetY + 20) <= (scroll + 340)) then
            if CurrentTab == "Search" then
                GalaxyState.SearchScrollY = math.max(0, targetY - 100)
            else
                GalaxyState.ScrollY = math.max(0, targetY - 100)
            end
        end
        ShowNotification("Located: " .. tName)
    end
    UpdatePropertyPanel()
end

local function AddSelectedActionButtons(buttons, selectedPart, includeGoto)
    if not GalaxyState.Selected then return end

    local spectateSubject = ResolveSpectateSubject(GalaxyState.Selected)
    if spectateSubject then
        local isSpectating = IsSpectatingTarget(GalaxyState.Selected)
        table.insert(buttons, {
            n = isSpectating and "Unspectate" or "Spectate",
            i = isSpectating and "UIOff" or "UIOn",
            f = function() ToggleSpectate(GalaxyState.Selected) end
        })
    end

    if selectedPart then
        table.insert(buttons, { n = "Teleport", i = "TeleportService", f = function() TeleportPlayer(GalaxyState.Selected, selectedPart) end })
        table.insert(buttons, { n = "Bring", i = "Move", f = function() BringObject(GalaxyState.Selected) end })
        table.insert(buttons, { n = "Delete", i = "Delete", f = function() DeleteObject(GalaxyState.Selected) end })
    end

    if includeGoto then
        table.insert(buttons, { n = "Goto Path", i = "Struct", f = function() NavigateToInstance(GalaxyState.Selected) end })
    end

    table.insert(buttons, {
        n = "Copy Path",
        i = "Copy",
        f = function()
            pcall(setclipboard, GetInstancePath(GalaxyState.Selected)); ShowNotification("Copied Path")
        end
    })
    table.insert(buttons, {
        n = "Copy Name",
        i = "Copy",
        f = function()
            pcall(setclipboard, ExecuteSafely(function() return GalaxyState.Selected.Name end) or "")
            ShowNotification("Copied Name")
        end
    })
end

local function OpenSettingsMenu(x, y)
    GalaxyState.ContextMenu = {
        Type = "Settings",
        X = x,
        Y = y
    }
    GalaxyState.FocusedElement = nil
    GalaxyState.ColorPickerOpen = false
    GalaxyState.ColorPickerDrag = nil
    GalaxyState.IsDraggingScroll = false
    GalaxyState.IsDraggingSearchScroll = false
    GalaxyState.IsDraggingPropertyScroll = false
end

local function QuickSearchTarget(label)
    if label == "Workspace" then return workspace end
    if label == "Replicated" then return game:GetService("ReplicatedStorage") end
    if label == "Character" then return ExecuteSafely(function() return LocalPlayer.Character end) end
    if label == "StarterGui" then return game:GetService("StarterGui") end
    if label == "LocalPlayer" then return LocalPlayer end
    if label == "Players" then return game:GetService("Players") end
    return nil
end

local function RunQuickSearch(label)
    local target = QuickSearchTarget(label)
    if target then
        RunGalaxAction("Quick Search: " .. label, function()
            NavigateToInstance(target)
        end, { Target = target })
    else
        ReportGalaxError("Quick search failed", BuildDiagnosticContext({
            Action = "Quick Search: " .. label,
            Reason = "Target instance is nil"
        }))
    end
end

local function DisplayExplorerTree(nodes, x, logicalY, startY, endY, containerWidth, scrollY)
    if not nodes then return logicalY end
    for _, node in ipairs(nodes) do
        if IsInstanceValid(node.Instance) then
        local screenY = startY + logicalY - scrollY
        if screenY >= startY and screenY < endY then
            local isSelected = IsSelectedNode(node)
            local mouseBlocked = IsMouseBlockedFor("Explorer")
            local hovered = (not mouseBlocked) and IsMouseOver(x, screenY, containerWidth, 20)
            local rowX, rowW = x + 2, containerWidth - 2

            if isSelected then
                RenderSquare(rowX, screenY, rowW, 20, Theme.Accent, true, 2, 5)
            elseif hovered then
                RenderSquare(rowX, screenY, rowW, 20, Color3.fromRGB(25, 40, 65), true, 2, 5)
                RenderSquare(rowX, screenY, rowW, 20, Theme.AccentHover, false, 2, 6)
            end

            local arrowX = x + (node.Depth * 14) + 8
            local arrowY = screenY + 10
            local arrowHovered = (not mouseBlocked) and IsMouseOver(arrowX - 8, screenY, 16, 20)

            if node.HasChildren then
                RenderTreeArrow(arrowX, arrowY, node.Expanded, arrowHovered)
                if GalaxyState.IsMouseClicked and arrowHovered then
                    node.Expanded = not node.Expanded
                    if node.Expanded then PopulateNodeChildren(node) end
                    GalaxyState.IsMouseClicked = false
                end
            end

            local kind = GetNodeTargetKind(node)
            local displayName = node.Name .. (node.Suffix or "")
            local tagName = node.ClassName or "Instance"
            if kind == "LocalPlayer" then
                tagName = "LocalPlayer"
            elseif kind == "Player" then
                tagName = "Player"
            elseif kind == "NPC" then
                tagName = "NPC / Mob"
            end
            local tagText = "[ " .. tagName .. " ]"
            local nameX = arrowX + 32
            local tagRight = x + containerWidth - 10
            local tagWidth = EstimateTextWidth(tagText, 11) * (0.775 + math.min(#tagText, 22) * 0.00536)
            local tagX = tagRight - tagWidth
            local maxNameChars = math.max(8, math.floor((tagRight - tagWidth - nameX - 8) / 6))
            local name = displayName
            if #name > maxNameChars then name = name:sub(1, math.max(1, maxNameChars - 3)) .. "..." end
            local iconName = GetClassIconName(node.ClassName, kind)
            local renderedIcon = RenderClassIcon(iconName, arrowX + 12, screenY + 2, 16, 16, 6, isSelected and 1 or 0.92)
            if not renderedIcon and iconName ~= "Instance" then
                RenderClassIcon("Instance", arrowX + 12, screenY + 2, 16, 16, 6, isSelected and 1 or 0.92)
            end
            RenderText(name, nameX, screenY + 4, isSelected and Theme.White or Theme.Text, 11, Drawing.Fonts.System, 6)
            RenderText(tagText, tagX, screenY + 4, isSelected and Theme.White or Theme.SubText, 11,
                Drawing.Fonts.System, 6)

            if not mouseBlocked and GalaxyState.IsMouseClicked and hovered and not arrowHovered then
                local isSelecting = (GalaxyState.Selected ~= node.Instance)
                GalaxyState.Selected = isSelecting and node.Instance or nil
                GalaxyState.SelectedNode = isSelecting and node or nil
                MarkSelectedChanged()
                GalaxyState.PropertyScroll = 0
                GalaxyState.PropertyScrollY = 0
                GalaxyState.ContextMenu = nil
                UpdatePropertyPanel(); GalaxyState.IsMouseClicked = false
            end

            if not mouseBlocked and GalaxyState.IsRightMouseClicked and hovered and not arrowHovered then
                GalaxyState.Selected = node.Instance
                GalaxyState.SelectedNode = node
                MarkSelectedChanged()
                GalaxyState.PropertyScroll = 0
                GalaxyState.PropertyScrollY = 0
                UpdatePropertyPanel()
                GalaxyState.ContextMenu = {
                    X = Mouse.X,
                    Y = Mouse.Y,
                    IncludeGoto = (CurrentTab == "Search")
                }
                GalaxyState.IsDraggingScroll = false
                GalaxyState.IsDraggingSearchScroll = false
                GalaxyState.IsDraggingPropertyScroll = false
                GalaxyState.IsRightMouseClicked = false
            end
        end
        logicalY = logicalY + 20
        if node.Expanded and node.Children then
            logicalY = DisplayExplorerTree(node.Children, x, logicalY,
                startY, endY, containerWidth, scrollY)
        end
        end -- IsInstanceValid
    end
    return logicalY
end

local function RenderSettingsMenu()
    local menu = GalaxyState.ContextMenu
    if not menu or menu.Type ~= "Settings" then return false end

    local width = 236
    local pickerOpen = GalaxyState.ColorPickerOpen == true
    local height = pickerOpen and 372 or 252
    local viewport = GetViewportSize()
    local x = math.clamp(menu.X or Mouse.X, 8, math.max(8, viewport.X - width - 8))
    local y = math.clamp(menu.Y or Mouse.Y, 8, math.max(8, viewport.Y - height - 8))
    local hoveredMenu = IsMouseOver(x, y, width, height)

    RenderSquare(x, y, width, height, Theme.Section, true, 7, 80, Theme.Glass)
    RenderSquare(x, y, width, height, Theme.BorderBright, false, 7, 92)

    if (GalaxyState.IsMouseClicked or GalaxyState.IsRightMouseClicked) and not hoveredMenu then
        GalaxyState.ContextMenu = nil
        GalaxyState.CapturingKeybind = false
        GalaxyState.ColorPickerOpen = false
        GalaxyState.ColorPickerDrag = nil
        GalaxyState.IsMouseClicked = false
        GalaxyState.IsRightMouseClicked = false
        return true
    end

    RenderClassIcon("Settings", x + 12, y + 8, 16, 16, 84, 0.96)
    RenderText("Settings", x + 34, y + 10, Theme.Text, 12, Drawing.Fonts.System, 84)

    local keyText = GalaxyState.CapturingKeybind and "Press key..." or ("Keybind: " .. (GalaxyState.MenuToggleName or "F1"))
    local keyW = math.min(width - 24, math.max(92, (#keyText * 7) + 22))
    if CreateInteractiveButton(x + (width - keyW) / 2, y + 31, keyW, 26, keyText, Theme.Accent, nil, 84, "ContextMenu") then
        GalaxyState.CapturingKeybind = true
        GalaxyState.KeybindCaptureStarted = os.clock()
    end

    local pad, gap = 10, 8
    local cursorY = y + 66
    RenderText("Accent", x + 12, cursorY + 5, Theme.SubText, 10, Drawing.Fonts.System, 84)
    RenderSquare(x + width - 64, cursorY, 22, 22, Theme.Accent, true, 5, 84, 1)
    RenderSquare(x + width - 64, cursorY, 22, 22, Theme.Border, false, 5, 85)
    if CreateToolbarIconButton(x + width - 36, cursorY, 22, "ColorPicker", 84, "ContextMenu", nil, true, 14) then
        GalaxyState.ColorPickerOpen = not GalaxyState.ColorPickerOpen
    end

    cursorY = cursorY + 33
    if GalaxyState.ColorPickerOpen then
        cursorY = RenderAccentColorPicker(x + pad, cursorY, width - pad * 2, 84) + 12
    end

    RenderText("Quick Search", x + 12, cursorY, Theme.SubText, 10, Drawing.Fonts.System, 84)
    local quickLabels = { "Workspace", "Replicated", "Character", "StarterGui", "LocalPlayer", "Players" }
    local quickIcons = {
        Workspace = "Workspace",
        Replicated = "ReplicatedStorage",
        Character = "Player",
        StarterGui = "StarterGui",
        LocalPlayer = "Player",
        Players = "Players"
    }
    local btnW = (width - pad * 2 - gap) / 2
    local btnH = 24
    local startY = cursorY + 16
    for i, label in ipairs(quickLabels) do
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        local bx = x + pad + col * (btnW + gap)
        local by = startY + row * 30
        if CreateInteractiveButton(bx, by, btnW, btnH, label, Theme.Accent, nil, 84, "ContextMenu", quickIcons[label]) then
            GalaxyState.ContextMenu = nil
            RunQuickSearch(label)
        end
    end

    if CreateInteractiveButton(x + pad, y + height - 36, width - pad * 2, 26, "Unload", Theme.Danger, nil, 84, "ContextMenu", "Delete") then
        GalaxyState.ContextMenu = nil
        GalaxyState.PendingUnload = true
    end

    if hoveredMenu and GalaxyState.IsRightMouseClicked then
        GalaxyState.IsRightMouseClicked = false
    end
    return true
end

local function RenderContextMenu(selectedPart)
    local menu = GalaxyState.ContextMenu
    if menu and menu.Type == "Settings" then
        RenderSettingsMenu()
        return
    end
    if not menu or not GalaxyState.Selected then return end

    local buttons = {}
    AddSelectedActionButtons(buttons, selectedPart, menu.IncludeGoto == true)
    if #buttons == 0 then
        GalaxyState.ContextMenu = nil
        return
    end

    local itemH, pad = 24, 8
    local width = 150
    local height = (#buttons * itemH) + pad * 2
    local viewport = GetViewportSize()
    local x = math.clamp(menu.X or Mouse.X, 8, math.max(8, viewport.X - width - 8))
    local y = math.clamp(menu.Y or Mouse.Y, 8, math.max(8, viewport.Y - height - 8))
    local hoveredMenu = IsMouseOver(x, y, width, height)

    RenderSquare(x, y, width, height, Theme.Section, true, 7, 80, Theme.Glass)
    RenderSquare(x, y, width, height, Theme.BorderBright, false, 7, 92)

    if (GalaxyState.IsMouseClicked or GalaxyState.IsRightMouseClicked) and not hoveredMenu then
        GalaxyState.ContextMenu = nil
        GalaxyState.IsMouseClicked = false
        GalaxyState.IsRightMouseClicked = false
        return
    end

    local itemY = y + pad
    for _, button in ipairs(buttons) do
        if CreateInteractiveButton(x + pad, itemY, width - pad * 2, itemH - 3, button.n, Theme.Accent, nil, 84, "ContextMenu", button.i) then
            GalaxyState.ContextMenu = nil
            RunGalaxAction(button.n, button.f)
            GalaxyState.IsMouseClicked = false
            GalaxyState.IsRightMouseClicked = false
            break
        end
        itemY = itemY + itemH
    end

    if hoveredMenu and GalaxyState.IsRightMouseClicked then
        GalaxyState.IsRightMouseClicked = false
    end
end

local function GetTreeHeight(nodes)
    local height = 0
    for _, node in ipairs(nodes or {}) do
        height = height + 20
        if node.Expanded and node.Children then height = height + GetTreeHeight(node.Children) end
    end
    return height
end

GalaxyState.TreeRoot = CreateTreeNode(game, 0)
PopulateNodeChildren(GalaxyState.TreeRoot)
GalaxyState.TreeRoot.Expanded = true
UpdatePropertyPanel()

do
    local viewport = GetViewportSize()
    WindowPosition = Vector2.new(
        math.max(10, (viewport.X - WindowWidth) / 2),
        math.max(10, (viewport.Y - WindowHeight) / 2)
    )
end

task.spawn(function()
    while _G.GalaxDex.alive do
        task.wait()

        if GalaxyState.CapturingKeybind and os.clock() - (GalaxyState.KeybindCaptureStarted or 0) > 0.12 then
            local key, name = GetPressedKeybind()
            if key then
                GalaxyState.MenuToggleKey = key
                GalaxyState.MenuToggleName = name
                GalaxyState.CapturingKeybind = false
                GalaxyState.SuppressMenuToggleUntilRelease = true
                PreviousMenuKey = true
                ShowNotification("Keybind: " .. name)
            end
        end

        local menuToggleKey = GalaxyState.MenuToggleKey or 0x70
        local rawMenuKeyPressed = iskeypressed(menuToggleKey)
        if GalaxyState.SuppressMenuToggleUntilRelease then
            if not rawMenuKeyPressed then
                GalaxyState.SuppressMenuToggleUntilRelease = false
                PreviousMenuKey = false
            end
        else
            local MenuKeyPressed = (not GalaxyState.CapturingKeybind) and rawMenuKeyPressed
            if MenuKeyPressed and not PreviousMenuKey then
                ToggleGalaxDexVisible()
            end
            PreviousMenuKey = MenuKeyPressed
        end

        local activeNow = isrbxactive()
        if not activeNow then
            GalaxyState.InactiveSince = GalaxyState.InactiveSince or os.clock()
            setrobloxinput(true)
            GalaxyState.LastRobloxInputBlocked = false
            if os.clock() - GalaxyState.InactiveSince > 0.15 then
                ClearDrawingPool()
                HideUnusedDrawings()
            end
            continue
        end
        GalaxyState.InactiveSince = nil

        local IsMousePressed = ismouse1pressed()
        GalaxyState.IsMouseClicked = IsMousePressed and not PreviousMouseState
        PreviousMouseState = IsMousePressed
        local IsRightMousePressed = ismouse2pressed()
        GalaxyState.IsRightMouseClicked = IsRightMousePressed and not PreviousRightMouseState
        PreviousRightMouseState = IsRightMousePressed

        local now = os.clock()
        if now - (GalaxyState.LastSelectedCheck or 0) > 0.25 then
            GalaxyState.LastSelectedCheck = now
            UpdateSelectedState(not IsVisible)
            UpdateSpectateState(not IsVisible)
        end
        local selectedPhysicalPart = GalaxyState.SelectedPhysicalPart

        local shouldBlockRobloxInput = GalaxyState.FocusedElement ~= nil
        setrobloxinput(not shouldBlockRobloxInput)
        if shouldBlockRobloxInput and not GalaxyState.LastRobloxInputBlocked then
            task.wait(0.1)
            mouse1click()
        end
        GalaxyState.LastRobloxInputBlocked = shouldBlockRobloxInput



        if not IsVisible then
            ClearDrawingPool()
            if selectedPhysicalPart then
                RenderSelectedEsp(GalaxyState.Selected, selectedPhysicalPart)
            end
            HideUnusedDrawings()
            continue
        end

        local PosX, PosY = WindowPosition.X, WindowPosition.Y
        GalaxyState.FocusRects = {}

        if GalaxyState.FocusedElement then
            local currentVal, setter
            if GalaxyState.FocusedElement == "SearchInput" then
                currentVal, setter = GalaxyState.SearchQuery, function(v) GalaxyState.SearchQuery = v end
            elseif GalaxyState.FocusedElement:sub(1, 5) == "Prop_" then
                local parts = {}
                for p in GalaxyState.FocusedElement:gmatch("[^_]+") do table.insert(parts, p) end
                local idx = tonumber(parts[2])
                local pData = idx and GalaxyState.PropLines[idx]
                if pData then
                    if pData.IsVector or pData.IsColor then
                        local subIdx = tonumber(parts[3]) or 0
                        local components = GetComponentStrings(pData)
                        currentVal = components[subIdx + 1] or "0"
                        setter = function(v)
                            components[subIdx + 1] = v
                            pData.EditValue = BuildComponentEditValue(components, pData.Type)
                        end
                    else
                        currentVal, setter = pData.EditValue, function(v) pData.EditValue = v end
                    end
                end
            end

            if currentVal and setter then
                if iskeypressed(0x11) or iskeypressed(0xA2) or iskeypressed(0xA3) then
                    if iskeypressed(0x43) and (not GalaxyState.LastCopyTime or os.clock() - GalaxyState.LastCopyTime > 0.3) then
                        pcall(setclipboard, currentVal); ShowNotification("Copied"); GalaxyState.LastCopyTime = os.clock()
                    end
                else
                    for k, char in pairs(InputKeys) do
                        local isDown = iskeypressed(k)
                        local wasDown = GalaxyState.KeyStates[k]

                        if isDown then
                            if not wasDown then
                                GalaxyState.KeyStates[k] = true
                                GalaxyState.KeyHoldStart[k] = os.clock()
                                GalaxyState.LastKeyTime = os.clock()

                                if k == 0x08 then
                                    setter(currentVal:sub(1, -2))
                                elseif k == 0x0D then
                                    if GalaxyState.FocusedElement == "SearchInput" then
                                        PerformSearch()
                                    else
                                        ApplyProp(GalaxyState.FocusedElement)
                                    end
                                    GalaxyState.FocusedElement = nil
                                else
                                    local shift = iskeypressed(0x10) or iskeypressed(0xA0) or iskeypressed(0xA1)
                                    setter(currentVal .. (shift and char or char:lower()))
                                end
                                break
                            elseif k == 0x08 and (os.clock() - GalaxyState.KeyHoldStart[k] > 0.4) and (not GalaxyState.LastKeyTime or os.clock() - GalaxyState.LastKeyTime > 0.05) then
                                GalaxyState.LastKeyTime = os.clock()
                                setter(currentVal:sub(1, -2))
                                break
                            end
                        else
                            GalaxyState.KeyStates[k] = false
                        end
                    end
                end
            end
        end

        if GalaxyState.IsMouseClicked then
            local isOverWindow = IsMouseOver(PosX, PosY, WindowWidth, WindowHeight)
            if GalaxyState.FocusedElement then
                -- Focused text inputs handle outside-click close after the current frame records their rect.
            elseif not isOverWindow then
                GalaxyState.FocusedElement = nil
            end
        end

        if iskeypressed(0x11) and not GalaxyState.FocusedElement and not GalaxyState.ContextMenu and GalaxyState.Selected then
            if iskeypressed(0x43) and (not GalaxyState.LastGlobalCopyTime or os.clock() - GalaxyState.LastGlobalCopyTime > 0.4) then
                local targetName = ExecuteSafely(function() return GalaxyState.Selected.Name end)
                if targetName then
                    pcall(setclipboard, targetName)
                    ShowNotification("Copied: " .. targetName)
                    GalaxyState.LastGlobalCopyTime = os.clock()
                end
            elseif iskeypressed(0x58) and (not GalaxyState.LastGlobalPathTime or os.clock() - GalaxyState.LastGlobalPathTime > 0.4) then
                local targetPath = GetInstancePath(GalaxyState.Selected)
                if targetPath then
                    pcall(setclipboard, targetPath)
                    ShowNotification("Path Copied!")
                    GalaxyState.LastGlobalPathTime = os.clock()
                end
            end
        end

        ClearDrawingPool()
        if GalaxyState.Selected and IsInstanceValid(GalaxyState.Selected) then
            RenderSelectedVisualCache()
        end

        local RedDotX, DotY = PosX + 18, PosY + HeaderHeight / 2
        local YellowDotX = PosX + 32
        local TopSettingsSize = 22
        local TopSettingsX = PosX + WindowWidth - 34
        local TopSettingsY = PosY + (HeaderHeight - TopSettingsSize) / 2
        local TopRefreshSize = 22
        local TopRefreshX = TopSettingsX - TopRefreshSize - 8
        local TopRefreshY = PosY + (HeaderHeight - TopRefreshSize) / 2
        local overTopbarControl = IsMouseOver(TopRefreshX, TopRefreshY, TopRefreshSize, TopRefreshSize)
            or IsMouseOver(TopSettingsX, TopSettingsY, TopSettingsSize, TopSettingsSize)
            or IsMouseOver(RedDotX - 7, DotY - 7, 14, 14)
            or IsMouseOver(YellowDotX - 7, DotY - 7, 14, 14)
        local hoveredResizeMode = GalaxyState.GetWindowResizeMode(PosX, PosY, WindowWidth, WindowHeight)

        if not IsMouseBlockedFor(nil) and GalaxyState.IsMouseClicked and hoveredResizeMode and not overTopbarControl then
            GalaxyState.ResizeMode = hoveredResizeMode
            GalaxyState.ResizeStartMouse = Vector2.new(Mouse.X, Mouse.Y)
            GalaxyState.ResizeStart = { X = PosX, Y = PosY, W = WindowWidth, H = WindowHeight }
            IsDragging = false
            GalaxyState.IsMouseClicked = false
        end

        if not GalaxyState.ResizeMode and not IsMouseBlockedFor(nil) and GalaxyState.IsMouseClicked and
            IsMouseOver(PosX, PosY, WindowWidth, HeaderHeight) and not overTopbarControl then
            IsDragging = true; DragOffset = Vector2.new(Mouse.X - PosX, Mouse.Y - PosY)
        end
        if not IsMousePressed then
            IsDragging = false
            GalaxyState.ResizeMode = nil
        end
        if GalaxyState.ResizeMode then
            GalaxyState.ApplyWindowResize(GalaxyState.ResizeMode)
            PosX, PosY = WindowPosition.X, WindowPosition.Y
        elseif IsDragging then
            WindowPosition = Vector2.new(Mouse.X - DragOffset.X, Mouse.Y - DragOffset.Y)
            PosX, PosY = WindowPosition.X, WindowPosition.Y
        end
        RedDotX, DotY = PosX + 18, PosY + HeaderHeight / 2
        YellowDotX = PosX + 32
        TopSettingsX = PosX + WindowWidth - 34
        TopSettingsY = PosY + (HeaderHeight - TopSettingsSize) / 2
        TopRefreshX = TopSettingsX - TopRefreshSize - 8
        TopRefreshY = PosY + (HeaderHeight - TopRefreshSize) / 2

        RenderSquare(PosX, PosY, WindowWidth, WindowHeight, Theme.Background, true, 13, 1, Theme.GlassSubtle)
        RenderSquare(PosX, PosY, WindowWidth, WindowHeight, Theme.BorderBright, false, 13, 2)
        RenderSquare(PosX, PosY, WindowWidth, HeaderHeight, Theme.Topbar, true, 13, 10, Theme.GlassTopbar)
        RenderCircle(RedDotX, DotY, 4, Theme.Red, 12)
        RenderCircle(YellowDotX, DotY, 4, Theme.Yellow, 12)
        RenderText("Galax Dex", PosX + 48, PosY + HeaderHeight / 2 - 6, Theme.Text, 12, Drawing.Fonts.System, 12)
        local resizeGuideMode = GalaxyState.ResizeMode or hoveredResizeMode
        if resizeGuideMode then
            local guideColor = GalaxyState.ResizeMode and Theme.Accent or Theme.BorderBright
            local guideAlpha = GalaxyState.ResizeMode and 1 or 0.72
            local margin = 10
            if resizeGuideMode:find("Left") then
                RenderLine(PosX, PosY + margin, PosX, PosY + WindowHeight - margin, guideColor, 13, 1, guideAlpha)
            end
            if resizeGuideMode:find("Right") then
                RenderLine(PosX + WindowWidth - 1, PosY + margin, PosX + WindowWidth - 1,
                    PosY + WindowHeight - margin, guideColor, 13, 1, guideAlpha)
            end
            if resizeGuideMode:find("Top") then
                RenderLine(PosX + margin, PosY, PosX + WindowWidth - margin, PosY, guideColor, 13, 1, guideAlpha)
            end
            if resizeGuideMode:find("Bottom") then
                RenderLine(PosX + margin, PosY + WindowHeight - 1, PosX + WindowWidth - margin,
                    PosY + WindowHeight - 1, guideColor, 13, 1, guideAlpha)
            end
        end
        if not IsMouseBlockedFor(nil) and GalaxyState.IsMouseClicked and IsMouseOver(RedDotX - 7, DotY - 7, 14, 14) then
            UnloadGalaxDex()
            break
        end
        if not IsMouseBlockedFor(nil) and GalaxyState.IsMouseClicked and IsMouseOver(YellowDotX - 7, DotY - 7, 14, 14) then
            SetGalaxDexVisible(false)
            GalaxyState.IsMouseClicked = false
        end
        if CreateToolbarIconButton(TopRefreshX, TopRefreshY, TopRefreshSize, "Refresh", 12, nil, nil, true, 14) then
            RunGalaxAction("Refresh", RefreshExplorer)
        end
        if CreateToolbarIconButton(TopSettingsX, TopSettingsY, TopSettingsSize, "Settings", 12, nil, nil, true, 14) then
            OpenSettingsMenu(TopSettingsX - 210, PosY + HeaderHeight + 6)
        end

        local ContainerX, ListWidth = PosX + 14, WindowWidth - 28
        local SearchY, SearchHeight = PosY + HeaderHeight + 10, 30
        local BtnSize, BtnGap = 22, 5
        local ClearX = ContainerX + ListWidth - BtnSize - 5
        local SearchBtnX = ClearX - BtnSize - BtnGap
        local TextX = ContainerX + 10
        local searchFocused = GalaxyState.FocusedElement == "SearchInput"

        RenderSquare(ContainerX, SearchY, ListWidth, SearchHeight, Theme.Section, true, 6, 4, Theme.GlassStrong)
        RenderSquare(ContainerX, SearchY, ListWidth, SearchHeight, searchFocused and Theme.Accent or Theme.BorderBright, false, 6, 5)
        RenderText(GalaxyState.SearchQuery == "" and "Search..." or FitTextToWidth(GalaxyState.SearchQuery, SearchBtnX - TextX - 8, 11),
            TextX, SearchY + SearchHeight / 2 - 6,
            GalaxyState.SearchQuery == "" and Theme.SubText or Theme.Text, 11, Drawing.Fonts.System, 6)
        RememberFocusRect("SearchInput", ContainerX, SearchY, SearchBtnX - ContainerX - 4, SearchHeight)

        if IsMouseAllowedFor("TextInput", "SearchInput") and GalaxyState.IsMouseClicked and
            IsMouseOver(ContainerX, SearchY, SearchBtnX - ContainerX - 4, SearchHeight) then
            GalaxyState.FocusedElement = "SearchInput"
            GalaxyState.IsMouseClicked = false
        end

        if CreateToolbarIconButton(SearchBtnX, SearchY + 4, BtnSize, "Search", 7, "TextInput", "SearchInput") then
            RunGalaxAction("Search", PerformSearch)
        end
        if CreateToolbarIconButton(ClearX, SearchY + 4, BtnSize, "Clear", 7, "TextInput", "SearchInput") then
            RunGalaxAction("Clear Search", function()
                ClearSearch()
                UpdatePropertyPanel()
                ShowNotification("Search Cleared")
            end)
        end

        local ContentY = SearchY + SearchHeight + 10
        local viewingSearch = CurrentTab == "Search"
        local treeNodes = viewingSearch and GalaxyState.SearchRoot.Children or GalaxyState.TreeRoot.Children
        local TreeStartY, SplitterHeight, PanelWidth = ContentY, 10, ListWidth
        local MinTreeHeight, MinPropertyHeight = 80, 96
        local AvailableHeight = math.max(MinTreeHeight + SplitterHeight + MinPropertyHeight,
            WindowHeight - (ContentY - PosY) - 14)
        local SplitArea = AvailableHeight - SplitterHeight
        local MaxTreeHeight = math.max(MinTreeHeight, SplitArea - MinPropertyHeight)
        local TreeHeight = math.clamp(GalaxyState.SnapToStep(SplitArea * (GalaxyState.LayoutSplitRatio or (340 / 592)), 20),
            MinTreeHeight, MaxTreeHeight)
        local SplitterY = TreeStartY + TreeHeight
        local splitHovered = IsMouseAllowedFor("LayoutSplit") and IsMouseOver(ContainerX, SplitterY, ListWidth, SplitterHeight)

        if splitHovered and GalaxyState.IsMouseClicked then
            GalaxyState.IsDraggingLayoutSplit = true
            GalaxyState.IsMouseClicked = false
        end
        if not IsMousePressed then GalaxyState.IsDraggingLayoutSplit = false end
        if GalaxyState.IsDraggingLayoutSplit then
            TreeHeight = math.clamp(GalaxyState.SnapToStep(Mouse.Y - TreeStartY, 20), MinTreeHeight, MaxTreeHeight)
            GalaxyState.LayoutSplitRatio = TreeHeight / SplitArea
            SplitterY = TreeStartY + TreeHeight
        end

        local TreeEndY = SplitterY
        local BottomY = SplitterY + SplitterHeight
        local PropertyHeight = math.max(MinPropertyHeight, WindowHeight - (BottomY - PosY) - 14)

        RenderSquare(ContainerX, TreeStartY, ListWidth, TreeHeight, Theme.Section, true, 6, 4)
        RenderSquare(ContainerX, TreeStartY, ListWidth, TreeHeight, Theme.Border, false, 6, 5)
        RenderSquare(ContainerX, BottomY, PanelWidth, PropertyHeight, Theme.Section, true, 6, 4)
        RenderSquare(ContainerX, BottomY, PanelWidth, PropertyHeight, Theme.Border, false, 6, 5)
        local SplitHandleW = math.min(86, ListWidth * 0.35)
        local SplitHandleX = ContainerX + (ListWidth - SplitHandleW) / 2
        RenderSquare(SplitHandleX, SplitterY + 2, SplitHandleW, SplitterHeight - 4,
            Theme.Section, true, 4, 7, Theme.GlassSubtle)
        RenderSquare(SplitHandleX, SplitterY + 2, SplitHandleW, SplitterHeight - 4,
            GalaxyState.IsDraggingLayoutSplit and Theme.Accent or Theme.BorderBright, false, 4, 8,
            GalaxyState.IsDraggingLayoutSplit and 0.85 or 0.55)
        RenderLine(PosX + WindowWidth - 15, PosY + WindowHeight - 5, PosX + WindowWidth - 5,
            PosY + WindowHeight - 15, GalaxyState.ResizeMode and Theme.AccentHover or Theme.BorderBright, 9, 1, 0.6)
        RenderLine(PosX + WindowWidth - 10, PosY + WindowHeight - 5, PosX + WindowWidth - 5,
            PosY + WindowHeight - 10, GalaxyState.ResizeMode and Theme.AccentHover or Theme.BorderBright, 9, 1, 0.5)

        local ScrollTrackX = ContainerX + ListWidth - 14
        local ScrollTrackY = TreeStartY + 6
        local ScrollTrackHeight = TreeHeight - 12
        local TotalContentHeight = GetTreeHeight(treeNodes)
        local activeMaxScrollY = math.max(0, TotalContentHeight - TreeHeight)
        local activeScrollY = viewingSearch and GalaxyState.SearchScrollY or GalaxyState.ScrollY
        activeScrollY = math.clamp(math.floor(activeScrollY / 20 + 0.5) * 20, 0, activeMaxScrollY)

        local ScrollThumbHeight = math.max(20,
            (ScrollTrackHeight / math.max(1, TotalContentHeight)) * ScrollTrackHeight)
        if TotalContentHeight <= ScrollTrackHeight then ScrollThumbHeight = ScrollTrackHeight end

        local dragFlag = viewingSearch and "IsDraggingSearchScroll" or "IsDraggingScroll"
        if not IsMouseBlockedFor(nil) and GalaxyState.IsMouseClicked and IsMouseOver(ScrollTrackX - 3, ScrollTrackY, 14, ScrollTrackHeight) then
            GalaxyState[dragFlag] = true
            GalaxyState.IsMouseClicked = false
        end
        if not IsMousePressed then
            GalaxyState.IsDraggingScroll = false
            GalaxyState.IsDraggingSearchScroll = false
        end

        if GalaxyState[dragFlag] and activeMaxScrollY > 0 then
            local pct = math.clamp(
                (Mouse.Y - ScrollTrackY - (ScrollThumbHeight / 2)) / (ScrollTrackHeight - ScrollThumbHeight), 0, 1)
            local maxLines = activeMaxScrollY / 20
            activeScrollY = math.floor(pct * maxLines + 0.5) * 20
        end

        activeScrollY = HandleKeyboardScroll(viewingSearch and "Search" or "Explorer", activeScrollY, activeMaxScrollY, 20,
            IsMouseOver(ContainerX, TreeStartY, ListWidth, TreeHeight))

        if viewingSearch then
            GalaxyState.SearchMaxScrollY = activeMaxScrollY
            GalaxyState.SearchScrollY = activeScrollY
        else
            GalaxyState.MaxScrollY = activeMaxScrollY
            GalaxyState.ScrollY = activeScrollY
        end

        local ScrollThumbY = ScrollTrackY +
            (activeMaxScrollY > 0 and (activeScrollY / activeMaxScrollY) * (ScrollTrackHeight - ScrollThumbHeight) or 0)

        local TotalProperties = #GalaxyState.PropLines
        local PropertyTopPad, PropertyBottomPad = 10, 8
        local PropertyRowHeight, PropertyHeaderHeight = 32, 32
        local PropertyVisibleHeight = math.max(1, PropertyHeight - PropertyTopPad - PropertyBottomPad)
        local PropertyHeights, PropertyContentHeight = {}, 0
        for idx, item in ipairs(GalaxyState.PropLines) do
            local lineHeight = (item and item.IsHeader) and PropertyHeaderHeight or PropertyRowHeight
            PropertyHeights[idx] = lineHeight
            PropertyContentHeight = PropertyContentHeight + lineHeight
        end

        local MaxScrollIndex = 0
        if PropertyContentHeight > PropertyVisibleHeight then
            local usedHeight = 0
            for idx = TotalProperties, 1, -1 do
                local lineHeight = PropertyHeights[idx] or PropertyRowHeight
                if usedHeight + lineHeight > PropertyVisibleHeight then
                    MaxScrollIndex = idx
                    break
                end
                usedHeight = usedHeight + lineHeight
            end
        end
        GalaxyState.PropertyScroll = math.clamp(math.floor((GalaxyState.PropertyScroll or 0) + 0.5), 0, MaxScrollIndex)
        GalaxyState.PropertyScrollY = GalaxyState.PropertyScroll

        local PropertyScrollTrackX = ContainerX + PanelWidth - 14
        local PropertyScrollTrackY = BottomY + 5
        local PropertyScrollTrackHeight = PropertyHeight - 10
        local PropertyScrollThumbHeight = math.max(20,
            (PropertyVisibleHeight / math.max(1, PropertyContentHeight)) * PropertyScrollTrackHeight)
        if PropertyContentHeight <= PropertyVisibleHeight then PropertyScrollThumbHeight = PropertyScrollTrackHeight end

        if not IsMouseBlockedFor(nil) and GalaxyState.IsMouseClicked and IsMouseOver(PropertyScrollTrackX - 3, PropertyScrollTrackY, 14, PropertyScrollTrackHeight) then
            GalaxyState.IsDraggingPropertyScroll = true
            GalaxyState.IsMouseClicked = false
        end
        if not IsMousePressed then GalaxyState.IsDraggingPropertyScroll = false end

        if GalaxyState.IsDraggingPropertyScroll and MaxScrollIndex > 0 then
            local pct = math.clamp(
                (Mouse.Y - PropertyScrollTrackY - (PropertyScrollThumbHeight / 2)) / (PropertyScrollTrackHeight - PropertyScrollThumbHeight), 0, 1)
            GalaxyState.PropertyScroll = math.floor(pct * MaxScrollIndex + 0.5)
        end

        GalaxyState.PropertyScroll = HandleKeyboardScroll("Property", GalaxyState.PropertyScroll, MaxScrollIndex, 1,
            IsMouseOver(ContainerX, BottomY, PanelWidth, PropertyHeight))
        GalaxyState.PropertyScrollY = GalaxyState.PropertyScroll

        local PropertyScrollThumbY = PropertyScrollTrackY +
            (MaxScrollIndex > 0 and (GalaxyState.PropertyScroll / MaxScrollIndex) * (PropertyScrollTrackHeight - PropertyScrollThumbHeight) or 0)

        RenderSquare(PropertyScrollTrackX, PropertyScrollTrackY, 9, PropertyScrollTrackHeight, Theme.Background, true, 4, 10)
        local propertyThumbBg = GalaxyState.IsDraggingPropertyScroll and Theme.Accent or Theme.BorderBright
        local propertyThumbBorder = GalaxyState.IsDraggingPropertyScroll and Theme.AccentHover or Color3.fromRGB(90, 90, 120)
        RenderSquare(PropertyScrollTrackX, PropertyScrollThumbY, 9, PropertyScrollThumbHeight, propertyThumbBorder, true, 4, 11)
        RenderSquare(PropertyScrollTrackX + 1, PropertyScrollThumbY + 1, 7, PropertyScrollThumbHeight - 2, propertyThumbBg, true, 3, 12)

        RenderSquare(ScrollTrackX, ScrollTrackY, 9, ScrollTrackHeight, Theme.Background, true, 4, 10)
        local thumbBg = GalaxyState[dragFlag] and Theme.Accent or Theme.BorderBright
        local thumbBorder = GalaxyState[dragFlag] and Theme.AccentHover or Color3.fromRGB(90, 90, 120)
        RenderSquare(ScrollTrackX, ScrollThumbY, 9, ScrollThumbHeight, thumbBorder, true, 4, 11)
        RenderSquare(ScrollTrackX + 1, ScrollThumbY + 1, 7, ScrollThumbHeight - 2, thumbBg, true, 3, 12)

        local propY = BottomY + PropertyTopPad
        local propEndY = BottomY + PropertyHeight - PropertyBottomPad
        local propIndex = GalaxyState.PropertyScroll + 1
        local drawnProperties = 0
        while propIndex <= TotalProperties and propY < propEndY and drawnProperties < TotalProperties do
            local pData = GalaxyState.PropLines[propIndex]
            if pData then
                local lineHeight = PropertyHeights[propIndex] or PropertyRowHeight
                if propY + lineHeight > propEndY then break end
                if pData.IsHeader then
                    local headerY = propY + math.floor((lineHeight - 16) / 2)
                    RenderClassIcon(pData.Icon, ContainerX + 10, headerY + 1, 14, 14, 7, 0.92)
                    RenderText(pData.Name, ContainerX + 31, headerY + 3, Theme.Text, 11, Drawing.Fonts.System, 7)
                    propY = propY + lineHeight
                else
                local inputX, inputY, inputW, inputH = ContainerX + 10, propY + 10, PanelWidth - 28, 18
                local stateIcon = pData.IsReadOnly and "Lock" or "Modified"
                local stateAlpha = pData.IsReadOnly and 0.78 or 0.92

                RenderText(FitTextToWidth(pData.Name, inputW, 10), inputX, propY, Theme.SubText, 10,
                    Drawing.Fonts.System, 6)

                local propKey = "Prop_" .. propIndex
                local isFocused = GalaxyState.FocusedElement == propKey
                local bgColor = pData.IsReadOnly and Color3.fromRGB(20, 20, 30) or
                    (isFocused and Color3.fromRGB(15, 15, 25) or Color3.fromRGB(25, 25, 35))

                if pData.IsBoolean or IsBooleanType(pData.Type) then
                    local toggleSize = inputH
                    local textBoxW = 55
                    local toggleX = inputX + textBoxW + 6
                    local toggleY = inputY

                    RenderSquare(inputX, inputY, textBoxW, inputH, Color3.fromRGB(20, 20, 30), true, 4, 6, Theme.GlassStrong)
                    RenderSquare(inputX, inputY, textBoxW, inputH, Theme.Border, false, 4, 7)
                    RenderText(FitTextToWidth(pData.EditValue, textBoxW - 25, 10), inputX + 6, inputY + 3,
                        Theme.SubText, 10, Drawing.Fonts.System, 8)
                    RenderClassIcon(stateIcon, inputX + textBoxW - 15, inputY + 3, 12, 12, 8, stateAlpha)

                    local isTrue = (pData.EditValue == true or pData.EditValue == "true")
                    local toggleBg = isTrue and Theme.Accent or Color3.fromRGB(25, 25, 35)
                    local toggleBorder = isTrue and Theme.BorderBright or Theme.Border

                    RenderSquare(toggleX, toggleY, toggleSize, toggleSize, toggleBg, true, 4, 12)
                    RenderSquare(toggleX, toggleY, toggleSize, toggleSize, toggleBorder, false, 4, 13)

                    if not IsMouseBlockedFor(nil) and not pData.IsReadOnly and GalaxyState.IsMouseClicked then
                        if IsMouseOver(toggleX, toggleY, toggleSize, toggleSize) then
                            local nextVal = isTrue and "false" or "true"
                            pData.EditValue = nextVal
                            ApplyProp(propKey)
                            task.spawn(UpdatePropertyPanel)
                            GalaxyState.IsMouseClicked = false
                        end
                    end
                elseif pData.IsVector or pData.IsColor then
                    local components = GetComponentStrings(pData)
                    local count = ComponentCountForType(pData.Type)
                    local subW = (inputW - (count - 1) * 4) / count

                    for subIdx = 0, count - 1 do
                        local subX = inputX + subIdx * (subW + 4)
                        local subKey = propKey .. "_" .. subIdx
                        local isSubFocused = GalaxyState.FocusedElement == subKey
                        local subBg = isSubFocused and Color3.fromRGB(15, 15, 25) or Color3.fromRGB(25, 25, 35)
                        local isLastComponent = subIdx == count - 1

                        RenderSquare(subX, inputY, subW, inputH, subBg, true, 4, 6, Theme.GlassStrong)
                        RenderSquare(subX, inputY, subW, inputH, isSubFocused and Theme.Accent or Theme.Border, false,
                            4, 7)
                        RenderText(FitTextToWidth(components[subIdx + 1] or "0", subW - (isLastComponent and 24 or 8), 10),
                            subX + 4, inputY + 3, Theme.Text, 10, Drawing.Fonts.System, 8)
                        if isLastComponent then
                            RenderClassIcon(stateIcon, subX + subW - 15, inputY + 3, 12, 12, 8, stateAlpha)
                        end
                        RememberFocusRect(subKey, subX, inputY, subW, inputH)

                        if IsMouseAllowedFor("TextInput", subKey) and GalaxyState.IsMouseClicked and IsMouseOver(subX, inputY, subW, inputH) then
                            if GalaxyState.FocusedElement ~= subKey then
                                GalaxyState.FocusedElement = subKey
                            end
                            GalaxyState.IsMouseClicked = false
                        end
                    end
                else
                    RenderSquare(inputX, inputY, inputW, inputH, bgColor, true, 4, 6, Theme.GlassStrong)
                    RenderSquare(inputX, inputY, inputW, inputH, isFocused and Theme.Accent or Theme.Border, false, 4,
                        7)
                    RenderText(FitTextToWidth(pData.EditValue, inputW - 30, 10), inputX + 6, inputY + 3,
                        pData.IsReadOnly and Theme.SubText or Theme.Text, 10, Drawing.Fonts.System, 8)
                    RenderClassIcon(stateIcon, inputX + inputW - 15, inputY + 3, 12, 12, 8, stateAlpha)
                    RememberFocusRect(propKey, inputX, inputY, inputW, inputH)

                    if IsMouseAllowedFor("TextInput", propKey) and not pData.IsReadOnly and GalaxyState.IsMouseClicked and IsMouseOver(inputX, inputY, inputW, inputH) then
                        if GalaxyState.FocusedElement ~= propKey then
                            GalaxyState.FocusedElement = propKey
                        end
                        GalaxyState.IsMouseClicked = false
                    end
                end

                propY = propY + lineHeight
                end
            end
            propIndex = propIndex + 1
            drawnProperties = drawnProperties + 1
        end

        DisplayExplorerTree(treeNodes, ContainerX, 0, TreeStartY + 1, TreeEndY - 1, ListWidth - 16, activeScrollY)

        if GalaxyState.Selected and IsInstanceValid(GalaxyState.Selected) then
            RenderSelectedUi(GalaxyState.Selected)
            RenderSelectedEsp(GalaxyState.Selected, GalaxyState.SelectedPhysicalPart)
        end

        RenderContextMenu(GalaxyState.SelectedPhysicalPart)
        if GalaxyState.PendingUnload then
            UnloadGalaxDex()
            break
        end

        HideUnusedDrawings()
        if GalaxyState.FocusedElement and (GalaxyState.IsMouseClicked or GalaxyState.IsRightMouseClicked) then
            if not IsInsideFocusedRect() then
                GalaxyState.FocusedElement = nil
            end
            GalaxyState.IsMouseClicked = false
            GalaxyState.IsRightMouseClicked = false
        elseif GalaxyState.IsMouseClicked then
            GalaxyState.FocusedElement = nil
        end
        GalaxyState.IsMouseClicked = false
        GalaxyState.IsRightMouseClicked = false

        if IsVisible then
            local currentTime = os.clock()
            local isTyping = (GalaxyState.FocusedElement ~= nil)

            if isTyping then GalaxyState.LastInputTime = currentTime end

            local isCoolingDown = GalaxyState.LastEditTime and (currentTime - GalaxyState.LastEditTime < 0.5)
            local isInteracting = IsDragging or GalaxyState.ResizeMode or GalaxyState.IsDraggingLayoutSplit or
                GalaxyState.IsDraggingScroll or GalaxyState.IsDraggingSearchScroll or
                GalaxyState.IsDraggingPropertyScroll or IsMousePressed
            if isInteracting then
                GalaxyState.LastInteractionTime = currentTime
            end
            local canScan = not isTyping and not isCoolingDown and not isInteracting and
                (not GalaxyState.LastInputTime or currentTime - GalaxyState.LastInputTime > 0.1) and
                (not GalaxyState.LastInteractionTime or currentTime - GalaxyState.LastInteractionTime > 0.15)

            if canScan then
                if CurrentTab == "Explorer" and GalaxyState.Selected then
                    if not IsInstanceValid(GalaxyState.Selected) then
                        ClearSelectedState()
                    elseif not GalaxyState.LastPropertyUpdate or currentTime - GalaxyState.LastPropertyUpdate > 0.25 then
                        pcall(UpdatePropertyPanel)
                        GalaxyState.LastPropertyUpdate = currentTime
                    end
                end

                if not GalaxyState.LastTreeRefresh or currentTime - GalaxyState.LastTreeRefresh > 0.35 then
                    local checksLeft = 20
                    local function ScanAndRefreshNode(node)
                        if checksLeft <= 0 or not node or not node.Instance then return end

                        if not node.Expanded then
                            if not node.LastChildCheck or currentTime - node.LastChildCheck > 2.0 then
                                local children = ExecuteSafely(function() return node.Instance:GetChildren() end)
                                if children then
                                    node.ChildCount = #children
                                    node.HasChildren = node.ChildCount > 0
                                    node.LastChildCheck = currentTime
                                    checksLeft = checksLeft - 1
                                end
                            end
                            return
                        end

                        local real = ExecuteSafely(function() return node.Instance:GetChildren() end) or {}
                        checksLeft = checksLeft - 1
                        local realCount = #real
                        local needsRefresh = (realCount ~= (node.ChildCount or #(node.Children or {}))) or
                            (realCount ~= #(node.Children or {}))
                        if not needsRefresh and currentTime - (node.LastDeepCheck or 0) > 3.0 then
                            local childSet = {}
                            for _, childNode in ipairs(node.Children or {}) do
                                if not IsInstanceValid(childNode.Instance) then
                                    needsRefresh = true
                                    break
                                end
                                childSet[childNode.Instance] = true
                            end
                            if not needsRefresh then
                                for _, inst in ipairs(real) do
                                    if not childSet[inst] then
                                        needsRefresh = true
                                        break
                                    end
                                end
                            end
                            node.LastDeepCheck = currentTime
                        end

                        if needsRefresh then
                            PopulateNodeChildren(node, real, currentTime)
                        else
                            node.ChildCount = realCount
                            node.HasChildren = realCount > 0
                            node.LastChildCheck = currentTime
                            for _, childNode in ipairs(node.Children or {}) do
                                if childNode.Instance and IsInstanceValid(childNode.Instance) then
                                    RefreshNodeIdentity(childNode, childNode.Instance)
                                end
                            end
                        end

                        if node.Children then
                            for _, child in ipairs(node.Children) do
                                if checksLeft <= 0 then break end
                                ScanAndRefreshNode(child)
                            end
                        end
                    end

                    if GalaxyState.TreeRoot then
                        ScanAndRefreshNode(GalaxyState.TreeRoot)
                    end

                    GalaxyState.LastTreeRefresh = currentTime
                end
            end
        end
    end
end)

task.spawn(function()
    task.wait()
    StartStartupIcons()
end)
