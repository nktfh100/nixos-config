local programs = require("programs")

local mainMod = "SUPER"

local function bind(keys, dispatcher, options)
    hl.bind(mainMod .. " + " .. keys, dispatcher, options)
end

bind("T", hl.dsp.exec_cmd(programs.terminal))
bind("Q", hl.dsp.window.close())
bind("L", hl.dsp.exec_cmd("theme-lock"))
bind("DELETE", hl.dsp.exit())
bind("E", hl.dsp.exec_cmd(programs.fileManager))
bind("V", hl.dsp.window.float({ action = "toggle" }))
bind("R", hl.dsp.exec_cmd(programs.menu))
bind("P", hl.dsp.window.pseudo())
bind("X", hl.dsp.layout("togglesplit"))
bind("F", hl.dsp.window.fullscreen({ action = "toggle" }))
bind("B", hl.dsp.exec_cmd(programs.browser))
bind("SHIFT + R", hl.dsp.reload_config())
bind("C", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -z -o ~/Pictures/Screenshots -m region"))

hl.bind("ALT + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    local function resize(key, x, y)
        hl.bind(key, hl.dsp.window.resize({ x = x, y = y, relative = true }), { repeating = true })
    end

    resize("D", 50, 0)
    resize("A", -50, 0)
    resize("W", 0, -50)
    resize("S", 0, 50)
    hl.bind("escape", hl.dsp.submap("reset"))
end)

for _, direction in ipairs({ "left", "right", "up", "down" }) do
    bind(direction, hl.dsp.focus({ direction = direction }))
end

local moveKeys = { A = "left", D = "right", W = "up", S = "down" }
for key, direction in pairs(moveKeys) do
    bind("SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end

local workspaceCount = 5
for i = 1, workspaceCount do
    bind(i, hl.dsp.focus({ workspace = i }))
    bind("SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

bind("TAB", hl.dsp.workspace.toggle_special("S"))
bind("S", hl.dsp.window.move({ workspace = "special:S", follow = false }))

bind("grave", hl.dsp.workspace.toggle_special("DEV"))
bind("SHIFT + grave", hl.dsp.window.move({ workspace = "special:DEV", follow = false }))

local cycledWorkspaces = 4
local function cycleWorkspace(step)
    return function()
        local current = hl.get_active_workspace().id
        local target = (current - 1 + step) % cycledWorkspaces + 1
        hl.dispatch(hl.dsp.focus({ workspace = target }))
    end
end

bind("D", cycleWorkspace(1))
bind("A", cycleWorkspace(-1))

bind("mouse:272", hl.dsp.window.drag(), { mouse = true })
bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.config({
    binds = {
        scroll_event_delay = 1,
        hide_special_on_workspace_change = true,
    },
})

local function setZoom(getFactor)
    return function()
        local factor = getFactor(hl.get_config("cursor.zoom_factor"))
        hl.config({ cursor = { zoom_factor = math.max(1, factor) } })
    end
end

bind("mouse_up", setZoom(function(zoom) return zoom * 1.1 end))
bind("mouse_down", setZoom(function(zoom) return zoom * 0.9 end))
bind("SHIFT + mouse_up", setZoom(function() return 1 end))
bind("SHIFT + mouse_down", setZoom(function() return 1 end))

local mediaKeys = {
    XF86AudioRaiseVolume = "audio increment 5",
    XF86AudioLowerVolume = "audio decrement 5",
    XF86AudioMute = "audio mute",
    XF86AudioMicMute = "audio micmute",
    XF86MonBrightnessUp = 'brightness increment 5 ""',
    XF86MonBrightnessDown = 'brightness decrement 5 ""',
}
for key, action in pairs(mediaKeys) do
    hl.bind(key, hl.dsp.exec_cmd("dms ipc call " .. action), { locked = true, repeating = true })
end

local playerKeys = {
    XF86AudioNext = "next",
    XF86AudioPause = "play-pause",
    XF86AudioPlay = "play-pause",
    XF86AudioPrev = "previous",
}
for key, action in pairs(playerKeys) do
    hl.bind(key, hl.dsp.exec_cmd("playerctl " .. action), { locked = true })
end
