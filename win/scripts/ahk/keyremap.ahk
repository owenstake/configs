#SingleInstance force
#MaxHotkeysPerInterval 200
#NoEnv
#MenuMaskKey vkE8

; #Include %A_ScriptDir%\lib
#include %A_LineFile%\..\lib\functionStr.ahk
#include %A_LineFile%\..\lib\lib-keyremap.ahk
#include %A_LineFile%\..\etc\key-conf.ahk
#include *i %A_LineFile%\..\custom.ahk

SendMode Input

;========================================================
;====== Main ============================================
;========================================================
; Global keymap setting
; key => vim move hjkl
For key, value in KeySendMap {
    Hotkey, %key%, DoKeySend
}

; App keymap setting
For appExe, conf in AppsConf {
    appMatcher := GetAppMatcher(appExe)
    ; Key => app . Register App hotkey
    key := conf["shortcut"]
    Hotkey, %key%, DoKeyToApp
    ; Normal Mode
    If (conf["KeyMapInNoramalMode"]) {
        AppsConf[appExe]["NormalEnabled"] := true
        GroupAdd, NornalModeGroup, %appMatcher%
        Hotkey, If, WinActiveAndInInsertMode("ahk_group NornalModeGroup")
            Hotkey, ~Esc, EnterNormalMode
            Hotkey, ^[,   EnterNormalMode
        Hotkey, If
        Hotkey, If, WinActiveAndInNormalMode("ahk_group NornalModeGroup")
            Hotkey, i, EnterInsertMode
        Hotkey, If
        Hotkey, If, WinActiveAndInNormalMode("ahk_group NornalModeGroup")
            keyMapStr := conf["KeyMapInNoramalMode"]
            If (keyMapStr) {
                keyMap  := %keyMapStr%
                moveKey := keyMap["MoveKey"]
                For key, in moveKey  {
                    Hotkey, %key%, KeyMapHandler
                }
                editKey := keyMap["EditKey"]
                For key, in editKey  {
                    Hotkey, %key%, KeyMapHandler
                }
            }
        Hotkey, If
    }
    ; Control M
    If (conf["DefaultControl"]) {
        GroupAdd, CtrlMGroup, %appMatcher%
        Hotkey, If, WinActive("ahk_group CtrlMGroup")
            Hotkey, ^m, CtrlMHandler
        Hotkey, If
    }
}

#If, WinActive("ahk_group CtrlMGroup")
#If

; Normal mode
#If, WinActiveAndInNormalMode("ahk_group NornalModeGroup")  ; For "hotkey, If"
#If

; Insert mode
#If, WinActiveAndInInsertMode("ahk_group NornalModeGroup")  ; For "hotkey, If"
#If

#If MouseIsOverTaskbar()
	WheelUp::Send  {Volume_Up}     ; Wheel over taskbar: increase/decrease volume.  One space after send is important
	WheelDown::Send {Volume_Down}
#If

; hotkey
CapsLock::RCtrl
RAlt::Esc
Launch_Mail::LongPressedSpeedUp("Volume_Down")
Browser_Home::LongPressedSpeedUp("Volume_Up")
