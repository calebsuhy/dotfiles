-- Hyprland config: the counterpart of ~/.config/bspwm/bspwmrc.
-- Key bindings live in keybinds.lua (the counterpart of sxhkdrc).
-- Check for mistakes without restarting: Hyprland --verify-config
-- (the bspwm setup is backed up in ~/backups/x11-bspwm-2026-10-14)

-- Start waybar (the bar; was polybar), the wallpaper, the autolocker and the
-- password prompt for apps that need admin rights. Runs once at login, not
-- on every config reload.
hl.on("hyprland.start", function()
    -- Start waybar
    hl.exec_cmd("waybar")

    -- Set background
    hl.exec_cmd("hyprpaper")

    -- Set the autolocker (locks after 5 minutes idle; see hypridle.conf)
    hl.exec_cmd("hypridle")

    -- Password prompts for apps that ask for admin rights
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)

-- The monitor: highest refresh rate (165 Hz), no scaling
hl.monitor({
    output   = "",
    mode     = "highrr",
    position = "auto",
    scale    = 1,
})

-- Set the cursor (Bibata at 28px, like ~/.Xresources)
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "28")
hl.env("HYPRCURSOR_SIZE", "28")

-- NVIDIA: use its video decoding and GL libraries
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- Qt apps (Dolphin, Flameshot's settings, ...) take their look from qt6ct:
-- dark, red accent, Papirus-Dark icons (~/.config/qt6ct)
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Names of workspaces (for use in waybar); always shown, even when empty
local desktops = { "terminals", "claude", "firefox", "spotify", "discord" }
for i, name in ipairs(desktops) do
    hl.workspace_rule({ workspace = tostring(i), default_name = name, persistent = true })
end

hl.config({
    general = {
        -- Set the border width for windows
        border_size = 2,

        -- Focused window: light cyan fading diagonally into the red accent;
        -- unfocused: bspwm's default border colour
        col = {
            active_border   = { colors = { "rgb(E0FFFF)", "rgb(C55449)" }, angle = 45 },
            inactive_border = "rgb(30302F)",
        },

        -- 24px gaps everywhere: between windows (12 on each window = 24px
        -- between two) and around the screen edge (bspwm had window_gap 25,
        -- but Hyprland can only split an even number between two windows)
        gaps_in  = 12,
        gaps_out = 24,

        -- Split windows in two like bspwm (each new window halves the
        -- focused one)
        layout = "dwindle",
    },

    decoration = {
        -- Slightly rounded corners (the menus and popups match)
        rounding = 6,

        -- Unfocused windows are a little see-through (92%) and 10% darker,
        -- so the focused one stands out
        active_opacity   = 1.0,
        inactive_opacity = 0.92,
        dim_inactive     = true,
        dim_strength     = 0.1,

        -- No shadows or halos around windows
        shadow = { enabled = false },

        -- Blur whatever shows through unfocused (see-through) windows
        blur = {
            enabled = true,
            size    = 6,
            passes  = 3,
        },

        -- Don't darken everything behind the scratchpads (Super+S /
        -- Super+C): that darkening ignores focus, so a window behind stayed
        -- dark even after clicking into it. The normal unfocused dimming
        -- above handles it instead: whichever window has focus, scratchpad
        -- or the one behind, is the bright one.
        dim_special = 0,

        -- Darken the screen behind Claude's Quick Entry by 30%, like a
        -- spotlight (it keeps focus while open, so this never gets stuck)
        dim_around  = 0.3,
    },

    -- Animations: only the few set up below, all short (see "Animations")
    animations = {
        enabled = true,
    },

    dwindle = {
        -- Keep a split's direction when windows around it close
        preserve_split = true,
    },

    input = {
        kb_layout = "us",

        -- Caps Lock acts as Escape (was XkbOptions "caps:escape" in
        -- /etc/X11/xorg.conf.d/10-keyboard.conf)
        kb_options = "caps:escape",

        -- Set key repeat rate and delay (was xset r rate 175 60)
        repeat_delay = 175,
        repeat_rate  = 60,

        -- The window underneath the cursor becomes the focused window
        follow_mouse = 1,

        -- ...including windows behind an open scratchpad (Super+S / Super+C),
        -- like with tdrop. Works because the scratchpads only hold floating
        -- windows.
        special_fallthrough = true,
    },

    misc = {
        -- No Hyprland logo, splash text or default wallpaper behind ours
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        -- An app may bring its window to the front when asked to (e.g.
        -- clicking a Claude Desktop or Discord notification takes you there)
        focus_on_activate        = true,
    },

    -- No donation or "what's new" popups after updates
    ecosystem = {
        no_donation_nag = true,
        no_update_news  = true,
    },
})

-- Animations: everything starts switched off, then only these are on (speed
-- is in tenths of a second). The border colour on focus changes and the bar
-- don't animate.
hl.curve("easeOut", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })
hl.animation({ leaf = "global", enabled = false })
-- new and closed windows fade in / out, both the same
hl.animation({ leaf = "fadeIn",  enabled = true, speed = 2.5, bezier = "easeOut" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.5, bezier = "easeOut" })
-- new windows also grow from 90% of their size, and closed windows shrink back
-- to it, like the menus (the close fade only shows while the shrink runs too,
-- otherwise the window is dropped at once)
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 2.5, bezier = "easeOut", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.5, bezier = "easeOut", style = "popin 90%" })
-- windows making room for a new one (or filling a gap, swapping, going
-- fullscreen) slide and resize into their new spot instead of jumping there
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2.5, bezier = "easeOut" })
-- when focus moves, windows ease into / out of their unfocused see-through
-- and dimmed look instead of switching at once; the darkening behind the
-- scratchpads and Quick Entry eases in too
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 2.5, bezier = "easeOut" })
hl.animation({ leaf = "fadeDim",    enabled = true, speed = 2.5, bezier = "easeOut" })
-- the focused window's cyan-to-red border slowly turns around it, one full
-- turn every 6 seconds, at a steady pace
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.animation({ leaf = "borderangle", enabled = true, speed = 60, bezier = "linear", style = "loop" })
-- switching workspaces slides sideways (direction shows which way you went)
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.5, bezier = "easeOut", style = "slide" })
-- scratchpads (Super+S / Super+C) slide down from the top, drop-down style,
-- and back up when hidden (plain "slidevert" comes up from the bottom; the
-- -100% flips it, measured on screen)
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.5, bezier = "easeOut", style = "slidevert -100%" })
-- rofi menus pop in slightly; notification popups slide in from the right
-- (layer rules below pick the style per kind)
hl.animation({ leaf = "layers",        enabled = true, speed = 2, bezier = "easeOut", style = "popin 90%" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 2, bezier = "easeOut" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.5, bezier = "easeOut" })
hl.layer_rule({ name = "menus-pop-in",       match = { namespace = "^rofi$" },          animation = "popin 90%" })
hl.layer_rule({ name = "notifications-slide", match = { namespace = "^notifications$" }, animation = "slide right" })
-- the bar and wallpaper never animate
hl.layer_rule({ name = "bar-no-anim",        match = { namespace = "^waybar$" },        no_anim = true })
hl.layer_rule({ name = "wallpaper-no-anim",  match = { namespace = "^hyprpaper$" },     no_anim = true })

-- When only one window is on a workspace it fills the screen: no gaps, no
-- border and square corners (bspwm's single_monocle + gapless_monocle +
-- borderless_monocle)
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
hl.window_rule({
    name  = "monocle-no-border",
    match = { float = false, workspace = "w[tv1]" },
    border_size = 0,
    rounding    = 0,
})
hl.window_rule({
    name  = "monocle-no-border-fullscreen",
    match = { float = false, workspace = "f[1]" },
    border_size = 0,
    rounding    = 0,
})

-- Scratchpads (Super+S terminal, Super+C Claude): each lives on its own
-- "special" workspace that slides over whatever you're on. The terminal is
-- started the first time the scratchpad is opened (was tdrop), floating at
-- the same size and place as before: centred on the screen.
local scratch_home = {
    scratch_term   = { size = { 1430, 770 }, at = { 565, 335 } },
    scratch_claude = { size = { 1430, 770 }, at = { 565, 335 } },
}
hl.workspace_rule({ workspace = "special:term",
    on_created_empty = "alacritty --class scratch_term" })
-- The Claude scratchpad starts a fresh Claude conversation each time its
-- window is created (first Super+C, or the first one after closing it with
-- Super+Shift+Q); exiting Claude leaves a normal shell there.
hl.workspace_rule({ workspace = "special:claude",
    on_created_empty = [[alacritty --class scratch_claude -e zsh -c 'claude; exec zsh']] })
for class, home in pairs(scratch_home) do
    hl.window_rule({
        name  = class,
        match = { class = "^" .. class .. "$" },
        float = true,
        size  = home.size,
        move  = home.at,
    })
end
-- The "System upgrade" window ("Upgrade all" in the updates menu) floats in
-- the same spot as the terminal scratchpad
hl.window_rule({
    name  = "system_upgrade",
    match = { class = "^system_upgrade$" },
    float = true,
    size  = scratch_home.scratch_term.size,
    move  = scratch_home.scratch_term.at,
})

-- Moving or resizing a scratchpad (Super+drag) is temporary: each time it's
-- shown again it goes back to its home size and place in the centre.
hl.on("workspace.special_active", function(workspace)
    if not workspace then
        return -- a scratchpad was hidden
    end
    for _, window in ipairs(hl.get_windows()) do
        local home = scratch_home[window.class]
        if home and window.workspace and window.workspace.name == workspace.name then
            local target = "address:" .. window.address
            hl.dispatch(hl.dsp.window.resize({ window = target,
                x = home.size[1], y = home.size[2], relative = false }))
            hl.dispatch(hl.dsp.window.move({ window = target,
                x = home.at[1], y = home.at[2], relative = false }))
        end
    end
end)

-- Per-window fixes for new windows (was ~/.config/bspwm/external_rules.sh)
-- Claude Desktop's Quick Entry popup hides itself as soon as it loses focus.
-- It opens mid-screen while the pointer is still down at the tray, so with
-- follow_mouse the first window the mouse crosses steals focus and the popup
-- vanishes. Move the pointer into the popup when it appears. It shares its
-- class with the main window; unlike that one it opens floating (it has a
-- fixed size). The scratchpad rule below leaves it alone (see there).
local function is_quick_entry(window)
    return window.class == "com.anthropic.Claude" and window.floating
end
-- It's a large, mostly transparent window (606x470) with the input bar along
-- its top, so the focus border (and shadow, and blur) would frame a big empty
-- box: draw none. The rest of the screen darkens behind it instead. It also
-- keeps focus while it's open, so moving the mouse away doesn't close it;
-- Esc or a click outside it does (the click rule further down).
hl.window_rule({
    name  = "claude-quick-entry",
    match = { class = "^com\\.anthropic\\.Claude$", float = true },
    stay_focused = true,
    border_size = 0,
    no_shadow   = true,
    no_blur     = true,
    dim_around  = true,
})
hl.on("window.open", function(window)
    if is_quick_entry(window) then
        local at, size = window.at, window.size
        hl.dispatch(hl.dsp.cursor.move({
            x = (at.x or at[1]) + (size.x or size[1]) / 2,
            y = (at.y or at[2]) + (size.y or size[2]) / 2,
        }))
    end
end)

-- New windows go to the normal workspace, never into a scratchpad, and are
-- never hidden behind one. While a scratchpad is showing, Hyprland would open
-- new windows (e.g. a terminal from Super+Return) inside it, so they'd float
-- over every workspace; move them to the workspace underneath. Either way,
-- hide the scratchpad so the new window can be seen (scratchpads draw on top
-- of normal windows, which once hid a "allow screenshots?" prompt), like tdrop.
-- Except Claude's Quick Entry: hiding a scratchpad hands focus back to the
-- workspace's last window for a moment, and Quick Entry closes the instant it
-- loses focus. It's a short-lived popup, so it may just stay on top of the
-- scratchpad, where it's visible anyway.
local scratch_classes = { scratch_term = true, scratch_claude = true }
hl.on("window.open", function(window)
    if scratch_classes[window.class] or is_quick_entry(window) then
        return
    end
    local ws = window.workspace
    if ws and ws.special then
        local target = hl.get_active_workspace()
        if target and not target.special then
            hl.dispatch(hl.dsp.window.move({
                window = "address:" .. window.address,
                workspace = target.id,
            }))
        end
    end
    local shown = hl.get_active_special_workspace()
    if shown then
        hl.dispatch(hl.dsp.workspace.toggle_special((shown.name:gsub("^special:", ""))))
    end
end)

-- Popups close when you click outside them, and the click still goes through
-- to what you clicked:
-- - Rofi menus (launcher, notification list, updates menu). Under Wayland
--   rofi is an overlay that keeps the keyboard while it's open and never
--   hears about clicks elsewhere, so Hyprland checks each left click. This
--   includes clicks on the bar: while a rofi menu is open the bar doesn't get
--   clicks at all, so clicking the bell or package icon closes the open menu
--   here (and a second click opens the other one).
-- - Claude's Quick Entry, which keeps focus while open (see above), so a
--   click elsewhere wouldn't otherwise reach it; it gets an Esc instead.
local function inside(box, point)
    return point.x >= box.x and point.x < box.x + box.w
        and point.y >= box.y and point.y < box.y + box.h
end
local function window_box(window)
    local at, size = window.at, window.size
    return { x = at.x or at[1], y = at.y or at[2], w = size.x or size[1], h = size.y or size[2] }
end
hl.bind("mouse:272", function()
    local cursor = hl.get_cursor_pos()
    local menus = hl.get_layers({ namespace = "rofi" })
    if #menus > 0 then
        local clicked_menu = false
        for _, menu in ipairs(menus) do
            clicked_menu = clicked_menu or inside(menu, cursor)
        end
        if not clicked_menu then
            hl.dispatch(hl.dsp.exec_cmd("pkill -x rofi"))
        end
    end
    for _, window in ipairs(hl.get_windows()) do
        if is_quick_entry(window) and window.visible and not inside(window_box(window), cursor) then
            hl.dispatch(hl.dsp.send_shortcut({ mods = "", key = "Escape",
                window = "address:" .. window.address }))
        end
    end
end, { non_consuming = true })

-- flameshot's capture screen (Super+P) covers the whole monitor, bar
-- included, instead of being tiled like a normal window. A "fullscreen" rule
-- doesn't stick (flameshot sets its own window state as it opens), so float
-- it here and make it fullscreen once it's open. Matched by title, so its
-- settings window still opens normally.
hl.window_rule({
    name  = "flameshot-capture",
    match = { class = "^flameshot$", title = "^flameshot$" },
    float       = true,
    border_size = 0,
    no_anim     = true,
})
hl.on("window.open", function(window)
    if window.class == "flameshot" and window.title == "flameshot" then
        hl.dispatch(hl.dsp.window.fullscreen({
            window = "address:" .. window.address,
            action = "set",
            mode   = "fullscreen",
        }))
    end
end)

-- Zathura (PDF viewer) stays solid and full brightness even when it isn't
-- focused, so a PDF stays easy to read behind a scratchpad
hl.window_rule({
    name    = "zathura-solid",
    match   = { class = "^org.pwmt.zathura$" },
    opacity = "1.0 override 1.0 override",
    no_dim  = true,
})

-- Ignore apps asking to be maximized (they'd cover the gaps and the bar)
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})


-- Key bindings (keybinds.lua, next to this file)
require("keybinds")
