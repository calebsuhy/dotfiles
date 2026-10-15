-- Key bindings: the counterpart of ~/.config/sxhkd/sxhkdrc, same sections
-- and order. Loaded from hyprland.lua.

-- --- APPLICATIONS --- --
-- Terminal
hl.bind("SUPER + Return",
    hl.dsp.exec_cmd("alacritty"))
-- Application Launcher
hl.bind("SUPER + space",
    hl.dsp.exec_cmd("sh ~/.config/rofi/launchers/type-1/launcher.sh"))
-- Scratchpad terminal (its window rules are in hyprland.lua; Hyprland binds
-- don't auto-repeat, so holding the key toggles only once)
hl.bind("SUPER + S",
    hl.dsp.workspace.toggle_special("term"))
-- Claude scratchpad
hl.bind("SUPER + C",
    hl.dsp.workspace.toggle_special("claude"))
-- Take a screenshot with selection
-- (sxhkdrc also had Super+P as "pseudo tiled" below; this one is kept)
hl.bind("SUPER + P",
    hl.dsp.exec_cmd("flameshot gui -p ~/Pictures/captures/"))

-- --- HYPRLAND --- --
-- Reload the configuration (was: make sxhkd reload its configuration files)
hl.bind("SUPER + SHIFT + Escape",
    hl.dsp.exec_cmd("hyprctl reload"))
-- Restart: reload the configuration and restart waybar (was: restart bspwm)
hl.bind("SUPER + SHIFT + R",
    hl.dsp.exec_cmd("hyprctl reload; pkill -x waybar; waybar"))
-- Log out, back to the login screen (to switch to bspwm there; new: bspwm
-- had no key for this)
hl.bind("SUPER + SHIFT + E",
    hl.dsp.exit())
-- Lock screen
hl.bind("SUPER + M",
    hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
-- Close window
hl.bind("SUPER + SHIFT + Q",
    hl.dsp.window.close())
-- Focus/Swap
for key, direction in pairs({ H = "left", J = "down", K = "up", L = "right" }) do
    hl.bind("SUPER + " .. key,
        hl.dsp.focus({ direction = direction }))
    hl.bind("SUPER + SHIFT + " .. key,
        hl.dsp.window.swap({ direction = direction }))
end
-- Set the window state: tiled, floating, (pseudo tiled is taken by the
-- screenshot above), fullscreen
hl.bind("SUPER + T", function()
    hl.dispatch(hl.dsp.window.fullscreen({ action = "unset" }))
    hl.dispatch(hl.dsp.window.float({ action = "disable" }))
end)
hl.bind("SUPER + SHIFT + T",
    hl.dsp.window.float({ action = "enable" }))
hl.bind("SUPER + F",
    hl.dsp.window.fullscreen({ action = "set" }))
-- Manual Tiling: open the next window on this side of the focused one, with
-- a short popup naming the side (Hyprland draws no preview, unlike bspwm).
-- It only works when the focused window is tiled; the popup says so if not.
local function cue(text)
    hl.dispatch(hl.dsp.exec_cmd("notify-send -a preselect -t 1500"
        .. " -h string:x-dunst-stack-tag:preselect '" .. text .. "'"))
end
for key, side in pairs({ H = { "l", "left" }, J = { "d", "below" },
                         K = { "u", "above" }, L = { "r", "right" } }) do
    hl.bind("SUPER + CTRL + " .. key, function()
        local window = hl.get_active_window()
        if window and window.floating then
            cue("Preselect only works on a tiled window")
            return
        end
        hl.dispatch(hl.dsp.layout("preselect " .. side[1]))
        cue("Next window: " .. side[2])
    end)
end
-- Focus or send to the specified desktop
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("SUPER + " .. key,
        hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = i, follow = false }))
end
-- Resize tiled windows and move floating windows
-- Expand a window (Hyprland picks which side moves, from the layout)
for key, size in pairs({ H = { 20, 0 }, J = { 0, 20 }, K = { 0, 20 }, L = { 20, 0 } }) do
    hl.bind("SUPER + ALT + " .. key,
        hl.dsp.window.resize({ x = size[1], y = size[2], relative = true }),
        { repeating = true })
end
-- Contract a window
for key, size in pairs({ H = { -20, 0 }, J = { 0, -20 }, K = { 0, -20 }, L = { -20, 0 } }) do
    hl.bind("SUPER + ALT + SHIFT + " .. key,
        hl.dsp.window.resize({ x = size[1], y = size[2], relative = true }),
        { repeating = true })
end
-- Move a floating window
for key, step in pairs({ left = { -20, 0 }, down = { 0, 20 }, up = { 0, -20 }, right = { 20, 0 } }) do
    hl.bind("SUPER + " .. key,
        hl.dsp.window.move({ x = step[1], y = step[2], relative = true }),
        { repeating = true })
end
-- Move / resize windows by dragging with Super + left / right mouse button
-- (bspwm's defaults)
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- --- CLAUDE VOICE --- --
-- Thumb button (mouse "back", was button8) taps space in terminals (Claude
-- voice, tap mode). non_consuming lets the click still reach other apps, so
-- browser back keeps working. (was ~/.config/sxhkd/ptt.sh)
local voice_windows = { Alacritty = true, scratch_claude = true, scratch_term = true }
hl.bind("mouse:275", function()
    local window = hl.get_active_window()
    if window and voice_windows[window.class] then
        hl.dispatch(hl.dsp.send_shortcut({ mods = "", key = "space" }))
    end
end, { non_consuming = true })
