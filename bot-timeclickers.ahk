; must use
; 
; windowed 1280x768
; all settings minimum simple
; keybinds default

SetTitleMatchMode, 2
#NoEnv
#KeyHistory 0
ListLines Off
Process, Priority,,H
SetBatchLines, -1
SetMouseDelay, 1
SetControlDelay -1
SetDefaultMouseSpeed, 0 ; Move the mouse instantly.

global toggle = 0

; game area to search
global x1 = 420
global x2 = 930
global y1 = 230
global y2 = 720
global y1_unsafe = 110
global x2_unsafe = 960

; random interval to warp
global warp_every_minutes_min = 20
global warp_every_minutes_max = 120

return ; required for proper control flow






;;
;; functions
;;

start_bot()
{
    notify("Starting bot...", 1000)
    Menu, Tray, Icon, shell32.dll, 44
    
    start_watchdog()
    start_shooter()
    start_upgrades()
    start_abilities()
    start_warp()
}
stop_bot()
{
    notify("Stopping bot", 1000)
    Menu, Tray, Icon, *

    toggle = 0

    stop_watchdog()
    stop_shooter()
    stop_upgrades()
    stop_abilities()
    stop_warp()
}

start_watchdog()
{
    SetTimer, watchdog, 1000, 9999
}
stop_watchdog()
{
    SetTimer, watchdog, Off
}

start_shooter()
{
    SetTimer, shooter, 100, -1000
}
stop_shooter()
{
    SetTimer, shooter, Off
}

start_upgrades()
{
    SetTimer, upgrades, 5000, -500
}
stop_upgrades()
{
    SetTimer, upgrades, Off
}

start_abilities()
{
    SetTimer, abilities, 5000, -500
}
stop_abilities()
{
    SetTimer, abilities, Off
}

start_warp()
{
    warp_minutes := get_random_warp_minutes()
    notify("Warp in " . warp_minutes . " minutes", 1000)
    SetTimer, warp, % warp_minutes * 1000 * 60 * -1, 500
}
restart_warp()
{
    warp_minutes := get_random_warp_minutes()
    SetTimer, warp, % warp_minutes * 1000 * 60 * -1, 500
}
stop_warp()
{
    SetTimer, warp, Off
}

notify(text, delay := -300)
{
    tooltip, %text%

    if (delay >= 0)
    {
        delay *= -1
    }
    SetTimer, tooltip_hide, %delay%
}

close_popups()
{
    IfWinExist, Sponsored session ahk_class #32770 ahk_exe TeamViewer.exe
    {
        ControlClick, Button4, Sponsored session ahk_class #32770 ahk_exe TeamViewer.exe
    }
}

roll(max)
{
    random, result, 1, %max%
    return result == 1
}

get_random_warp_minutes()
{
    ;return 1
    Random, minutes, %warp_every_minutes_min%, %warp_every_minutes_max%

    if roll(5) {
        minutes *= 2
    }

    if roll(3) {
        minutes += 30
    }

    if roll(6) {
        minutes += 60
    }
    
    if roll(5) {
        minutes /= 5
    }

    return minutes
}


;;
;; labels
;;

tooltip_hide:
    tooltip
    return

watchdog:
    close_popups()
    if !WinActive("ahk_exe TimeClickers.exe")
    {
        WinActivate, ahk_exe TimeClickers.exe
        sleep 500
        if !WinActive("ahk_exe TimeClickers.exe")
        {
            stop_bot()
        }
    }
    return

shooter:
    SetMouseDelay, -1
    loop, 10
    {
        colorSearch = 0xFF008F ;purple
        PixelSearch, pixX, pixY, %x1%, %y1_unsafe%, %x2_unsafe%, %y2%, %colorSearch%, 0, Fast
        MouseClick,,% pixX+1,% pixY+1
        if(ErrorLevel)
        {
            colorSearch = 0x28FF00 ;green
            PixelSearch, pixX, pixY, %x1%, %y1_unsafe%, %x2_unsafe%, %y2%, %colorSearch%, 0, Fast
            MouseClick,,% pixX+1,% pixY+1
            if(ErrorLevel)
            {
                colorSearch = 0x0000FF ;red
                PixelSearch, pixX, pixY, %x1%, %y1%, %x2%, %y2%, %colorSearch%, 0, Fast
                MouseClick,,% pixX+1,% pixY+1
                if(ErrorLevel)
                {
                    colorSearch = 0xFF6800 ;blue
                    PixelSearch, pixX, pixY, %x1%, %y1%, %x2%, %y2%, %colorSearch%, 0, Fast
                    MouseClick,,% pixX+1,% pixY+1
                    if(ErrorLevel)
                    {
                        colorSearch = 0xFFFFFF ;white
                        PixelSearch, pixX, pixY, %x1%, %y1%, %x2%, %y2%, %colorSearch%, 0, Fast
                        MouseClick,,% pixX+1,% pixY+1
                    }
                }
            }
        }
        PixelSearch, pixX, pixY, % pixX-3, % pixY-3, % pixX, % pixY, %colorSearch%, 0, Fast
        MouseClick,,% pixX+1,% pixY+1
    }
    return

upgrades:
    SendInput asdfg
    return

abilities:
    SendInput {space}07
    return

warp:
    Thread, NoTimers ; do not get interrupted by other timers / threads
    delay_key := A_KeyDelay ; saving current settings to restore them later
    delay_mouse := A_MouseDelay
    SetKeyDelay, 200
    SetMouseDelay, 100

    sleep 5000
    MouseClick,, 1217, 366 ; click warp
    sleep 1000
    MouseClick,, 550, 450 ; accept warp
    sleep 3000

    ; upgrade pistol after warp
    MouseClick,, 1238, 250, 25

    ; spend WC
    MouseClick,, 770, 640, 3 ; starting wave back
    MouseClick,, 700, 640, 3 ; more WC
    MouseClick,, 630, 640, 3 ; more WC chance

    ; close weapon cubes dialog if opened
    MouseClick,, 1014, 366, 3

    ; upgrade perks after warp
    MouseClick,, 1217, 366, 20
    
    ; in case warp was clicked again, cancel it
    MouseClick,, 750, 450, 3

    ; initial weapons, dimension shift, activate abilities, reset cooldowns
    Send asdfgasdfgasdfg7{Space}0

    ; enable rocket launcher idle mode
    sleep 1000
    MouseClick,, 375, 755
    sleep 1000

    ; move mouse to neutral position away from previously pressed button
    MouseClick,, 750, 450

    ; restore previous settings
    SetKeyDelay, %delay_key%
    SetMouseDelay, %delay_mouse%
    Thread, NoTimers, false

    ; reroll random warp time
    restart_warp()
    return






;;
;; hotkeys
;;

#IfWinactive, ahk_exe TimeClickers.exe

    ~RButton::
        SetMouseDelay, 1
        Click 10
        While GetKeyState("RButton", "P")
        {
            Click 10
        }
        return

    F2::
        SetMouseDelay, -1
        Send {click 100}
        return

    F4::
        notify("works")
        return

    F5::
        toggle := !toggle
        if (toggle)
        {
            start_bot()
        }
        else
        {
            stop_bot()
        }
        return 

#IfWinActive

#IfWinActive, AutoHotkey\scripts
    ; Automatically reload this script on save.
    ~^s::
        Tooltip Reloading script
        Sleep 300
        Reload
        return
#IfWinActive

F6::
    loop 20
    {
        loop, 20
        {
            tmp .= get_random_warp_minutes() . " "
        }
        tmp .= "`n"
    }
    notify(tmp, 5000)
    tmp=
    return

F7::
    sleep 500
    MouseClick,, 375, 755
    sleep 500
    return