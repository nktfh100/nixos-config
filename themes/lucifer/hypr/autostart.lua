local shaders = require("shaders")

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start theme-shell.service")
    hl.exec_cmd("udiskie")
    hl.exec_cmd("hypr-layout-notify")
    hl.exec_cmd("lucifer-smoke-mode auto")
end)

hl.bind("SUPER + CTRL + W", hl.dsp.exec_cmd("theme-motion-toggle"))
hl.bind("SUPER + SHIFT + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("dms ipc call notifications toggle"))

hl.window_rule({
    match = { class = ".*" },
    tag = "+shader_close_default:" .. shaders.close,
})

if shaders.open then
    hl.window_rule({
        match = { class = ".*" },
        tag = "+shader_open_default:" .. shaders.open,
    })
    hl.animation({ leaf = "windowsIn", enabled = false })
    hl.animation({ leaf = "fadeIn", enabled = false })
end
