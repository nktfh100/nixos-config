hl.env("LIBVA_DRIVER_NAME", "iHD")
hl.env("XDG_SESSION_TYPE", "wayland")

hl.exec_cmd("systemctl --user restart battery-desktop.service")

hl.monitor({
    output = "desc:Najing CEC Panda FPD Technology CO. ltd 0x004D",
    mode = "1920x1080@144.0",
    position = "1200x1200",
    scale = 1.0,
})
hl.monitor({
    output = "desc:HP Inc. HP E24i G4 CNK22924VL",
    mode = "1920x1200@59.95",
    position = "1200x0",
    scale = 1.0,
})

for workspace = 1, 4 do
    hl.workspace_rule({ workspace = tostring(workspace), monitor = "eDP-1" })
end

hl.config({
    input = {
        sensitivity = -0.5,
        touchpad = { natural_scroll = true },
    },
    cursor = { no_hardware_cursors = true },
})

hl.device({ name = "usb-optical-mouse-", sensitivity = -0.4 })
hl.device({ name = "asup1205:00-093a:2003-touchpad", sensitivity = 0.01 })

hl.bind("XF86Launch3", hl.dsp.exec_cmd("asusctl aura -n"))
