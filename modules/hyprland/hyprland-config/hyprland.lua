require("environment")
require("input")
require("look")
require("animations")
require("keybinds")
require("autostart")
require("host")

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.config({
    dwindle = { preserve_split = true },
    master = { new_status = "master" },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },
})

hl.window_rule({
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    match = { class = "^(code)$" },
    workspace = "special:DEV",
})
