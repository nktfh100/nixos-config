hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

hl.monitor({
    output = "desc:Samsung Electric Company S24E650 H4ZK400022",
    mode = "1920x1080@60.0",
    position = "3840x409",
    scale = 1.0,
    transform = 1,
})
hl.monitor({
    output = "desc:HP Inc. HP N240 6CM8150PB0",
    mode = "1920x1080@60.0",
    position = "1920x1020",
    scale = 1.0,
})
hl.monitor({
    output = "desc:MAG InnoVision C24FXY",
    mode = "1920x1080@75.0",
    position = "0x1020",
    scale = 1.0,
})

hl.config({
    cursor = { default_monitor = "desc:HP Inc. HP N240 6CM8150PB0" },
})

for workspace = 1, 4 do
    hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-2" })
end
