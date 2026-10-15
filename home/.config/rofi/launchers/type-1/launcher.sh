#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Launcher (Modi Drun, Run, File Browser, Window)
#
## Available Styles
#
## style-1     style-2     style-3     style-4     style-5
## style-6     style-7     style-8     style-9     style-10
## style-11    style-12    style-13    style-14    style-15

dir="$HOME/.config/rofi/launchers/type-1"
theme='style-6'

## Restyled to match the notification, updates and power menus: 6px rounded
## corners, a 2px light cyan border, faint dividers, the red ❯ arrow on the
## selected app instead of a red fill, and a "⏎ Open · Esc Close" footer
## (both clickable). The "Failed to execute" popup (Enter on something that
## isn't an app) gets the same single border and rounded corners, its text
## centred, instead of style-6's extra red box inside the window.
## style-6.rasi itself is left alone, as those menus build
## on it too. One setting per line: rofi misreads a line that holds two
## quoted values.
look='
window { border: 2px solid;
    border-color: #E0FFFF;
    border-radius: 6px; }
element, textbox, scrollbar, button { border-radius: 0px; }
mainbox { children: [ "inputbar", "listview", "footer" ]; }
inputbar { padding: 0px 0px 10px;
    border: 0px 0px 1px;
    border-color: #3A3A4A; }
element { background-color: transparent;
    text-color: transparent;
    children: [ "textbox-arrow", "element-icon", "element-text" ]; }
textbox-arrow { str: "❯";
    expand: false;
    padding: 0px;
    background-color: transparent;
    text-color: inherit;
    vertical-align: 0.5; }
element-text { text-color: #FFFFFF; }
element selected.normal { background-color: transparent;
    text-color: #C55449; }
element normal.normal, element alternate.normal { background-color: transparent;
    text-color: transparent; }
footer { orientation: horizontal;
    expand: false;
    spacing: 0px;
    padding: 10px 0px 0px;
    background-color: transparent;
    border: 1px 0px 0px;
    border-color: #3A3A4A;
    children: [ "button-open", "textbox-dot", "button-close" ]; }
button-open, textbox-dot, button-close { expand: true;
    horizontal-align: 0.5;
    padding: 4px 6px;
    markup: true;
    background-color: transparent;
    text-color: #FFFFFF; }
button-open { str: "<span alpha='"'"'55%'"'"'>⏎</span> Open";
    action: "kb-accept-entry";
    cursor: pointer; }
textbox-dot { str: "<span alpha='"'"'35%'"'"'>·</span>";
    expand: false;
    padding: 4px 0px; }
button-close { str: "<span alpha='"'"'55%'"'"'>Esc</span> Close";
    action: "kb-cancel";
    cursor: pointer; }
error-message { padding: 14px;
    border: 0px;
    border-radius: 0px;
    background-color: transparent; }
textbox { horizontal-align: 0.5; }
'

## Run
rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi \
    -theme-str "$look"
