hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start theme-shell.service")
    hl.exec_cmd("udiskie")
    hl.exec_cmd("hypr-layout-notify")
end)

hl.bind("SUPER + CTRL + W", hl.dsp.exec_cmd("theme-motion-toggle"))
hl.bind("SUPER + SHIFT + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("dms ipc call notifications toggle"))
