#SingleInstance force
#MaxHotkeysPerInterval 200
#NoEnv
#MenuMaskKey vkE8

#Include %A_ScriptDir%
#include *i %A_LineFile%\..\custom.ahk

SendMode Input

; Env
global APPDATA, ProgramData
EnvGet, APPDATA, APPDATA
EnvGet, ProgramData, ProgramData

; Reverse "hjkl "for move.
; Reverse "fb" for terminal move.
; Remain usable key "agy"
global KeySendMap := 
    ( Join
    {
    "!j"  : "{Down}"  ,
    "!k"  : "{Up}"    ,
    "!h"  : "{Left}"  ,
    "!l"  : "{Right}" ,
    "!u"  : "{PgUp}"  ,
    "!d"  : "{PgDn}"  ,
    "!+j" : "^+{Tab}" ,
    "!+k" : "^{Tab}"
    }
    )

; global HotkeyAppMap :=
global AppsConf :=
    ( Join
    {
	"hh.exe"              :  {"Shortcut" : "!a" , "ExePath" : "C:\Windows\hh.exe"                                            } ,
    "chrome.exe"          :  {"Shortcut" : "!c" , "DefaultControl" : "Chrome_RenderWidgetHostHWND1"                          } ,
    "Draw.io.exe"         :  {"Shortcut" : "!g"                                                                              } ,
    "Explorer.exe"        :  {"Shortcut" : "!e" , "Match": "ahk_class CabinetWClass", "ExePath" : "C:\Windows\explorer.exe", "DefaultControl" : "DirectUIHWND2" ,  "KeyMapInNoramalMode" : "ExplorerKeymapInNornalMode" } ,
    "obsidian.exe"        :  {"Shortcut" : "!i"                                                                              } ,
    "mobaxterm.exe"       :  {"Shortcut" : "!m"                                                                              } ,
    "WindowsTerminal.exe" :  {"Shortcut" : "!n"                                                                              } ,
    "powerpoint.exe"      :  {"Shortcut" : "!p"                                                                              } ,
    "qq.exe"              :  {"Shortcut" : "!q"                                                                              } ,
    "wechat.exe"          :  {"Shortcut" : "!r"                                                                              } ,
    "FoxitPDFReader.exe"  :  {"Shortcut" : "!s"  , "DefaultControl" : "FoxitDocWnd1" , "KeyMapInNoramalMode" : "FoxitKeymapInNornalMode" } ,
    "typora.exe"          :  {"Shortcut" : "!t"                                                                              } ,
    "code.exe"            :  {"Shortcut" : "!v"                                                                              } ,
    "word.exe"            :  {"Shortcut" : "!w"                                                                              } ,
    "xshell.exe"          :  {"Shortcut" : "!x"  , "KeyMapInNoramalMode" : "XshellKeymapInNormalMode"                        } ,
    "zotero.exe"          :  {"Shortcut" : "!z"                                                                              } ,

    "Everything.exe" : {"Shortcut" : "!+e"                                                                                             } ,
    "firefox.exe"    : {"Shortcut" : "!+f"                                                                                             } ,
    "v2rayN.exe"     : {"Shortcut" : "!+n"                                                                                             } ,
    "firefox.exe"    : {"Shortcut" : "!+o" , "ExePath" : APPDATA . "\Microsoft\Windows\Start Menu\Programs\Scoop Apps\Tor Browser.lnk" } ,
    "kwmusic.exe"    : {"Shortcut" : "!+u"                                                                                             } ,
    "Excel.exe"      : {"Shortcut" : "!+x"                                                                                             }
    }
    )

global FoxitKeymapInNornalMode :=
	( Join
    {
    "MoveKey" : { 
        "j"  : "{Down}"     ,
        "k"  : "{Up}"       ,
        "u"  : "{PgUp}"     ,
        "d"  : "{PgDn}"     ,
        "+j" : "^+{Tab}"    ,
        "+k" : "^{Tab}"     ,
        "+h" : "!{Left}"    ,
        "+l" : "!{Right}"   ,
        "l"  : "{Alt}re1f"  ,
        "o"  : "{Alt}re1a"  ,
        "q"  : "{Esc}"
        } ,
    "EditKey" : {
        "t"  : "{Alt}rd2"
        } ,
    "CustomHandler" : "FoxitCustomKeymapHandler"
    }
	)
	; "~="  : "^="      ,
	; "~-"  : "^-"      ,
	; "~+=" : "^+="     ,
	; "~+-" : "^+-"
FoxitCustomKeymapHandler(){

}

global ExplorerKeymapInNornalMode :=
    ( Join
    {
        "MoveKey" :
        { 
        "j"     : "{Down}"   ,
        "k"     : "{Up}"     ,
        "h"     : "!{Up}"    ,
        "l"     : "{Enter}"  ,
        "+h"    : "!{Left}"  ,
        "+l"    : "!{Right}" ,
        "g"     : "{Home}"   ,
        "+G"    : "{End}"    ,
        "y & p" : "{Alt}hcp"
        } 
    }
    )

global XshellKeymapInNormalMode :=
    ( Join
    {
    "MoveKey" : { "^+r up" : "{alt}fr" }
    }
    )

ExecWinCmd(cmd, Byref stdout) {
    exec := ComObjCreate("WScript.Shell").Exec(cmd)
    stdout := exec.StdOut.ReadAll()  ; strip tailing "`r`n" in win
	stdout := Trim(stdout, " `r`n")
	stderr := exec.StdErr.ReadAll()
    return stderr
}

GetActiveExplorerPath()
{
	explorerHwnd := WinActive("ahk_class CabinetWClass")
	if (explorerHwnd)
	{
		for window in ComObjCreate("Shell.Application").Windows
		{
			if (window.hwnd==explorerHwnd)
			{
				return window.Document.Folder.Self.Path
			}
		}
	}
}

GetAppPath(app) {
    global APPDATA,ProgramData
	AppSearchPath := 
		( Join
			[   
			ProgramData . "\Microsoft\Windows\Start Menu\Programs\*.lnk" ,
			APPDATA . "\Microsoft\Windows\Start Menu\Programs\*.lnk"
			]
		)
	Loop , % AppSearchPath.Length()
	{
		p := AppSearchPath[A_Index]
		Loop Files, %p%, R  ; Recurse into subfolders.
		{
			; get target
			FileGetShortcut, %A_LoopFileFullPath%, OutTarget
			; filename compare
			basename1 := StrReplace(A_LoopFileName, ".lnk") ; remove ext
			If (basename1 = app) {
				return A_LoopFileFullPath
			}
			; target compare
			basename2 := RegExReplace(OutTarget, ".*\\(\w+)\.exe", "$1")
			; basename2 := StrReplace(OutTarget, ".exe") ; remove ext
			; MsgBox % A_LoopFileFullPath "`n" A_LoopFileName "`n" OutTarget "`n" basename1 "`n" basename2
			If (basename2 = app) {
				; Msgbox % "Matched! " . OutTarget
				return OutTarget
			}
		}
	}
	return
}

GetAppNameByShortcut() {
    For app, conf in AppsConf {
        If (conf["shortcut"] = A_ThisHotkey) {
            return app
        }
    }
}

GetAppMatcher(app) {
    conf := AppsConf[app]
    If (conf["match"]) {
        match := conf["match"]
    } else {
        match := "ahk_exe " app
    }
    return match
}

DoKeyToApp() {
    keywait alt ; avoid trigger alt for app
    appName := GetAppNameByShortcut()
    conf    := AppsConf[appName]
    match   := GetAppMatcher(appName)
    if WinExist(match) {  ; This will be expanded because it is a expression
        if WinActive(match) {
            Send !{Esc}
        } else {
            WinActivate, %match%  ; Command syntax
            If (conf["DefaultControl"]) {
                ; ctrl := conf["DefaultControl"]
                ; Controlclick, %ctrl%, A
            }
        }
    } else {
        if (conf["ExePath"]) {
            run_exe := conf["ExePath"]
        } else {
			appBasename := RegExReplace(appName,"(\w+)\.exe","$1")
            file := GetAppPath(appBasename)
			If (file = "") {
                MsgBox No found appPath for %appName% in system. Please specified a ExePath.
                return
            } else {
                run_exe := file
            }
        }
        Run,%run_exe%
    }
    return
}

DoKeySend() {
    cmd := KeySendMap[A_ThisHotkey]
    Send, %cmd%
    return
}

MouseIsOver(WinTitle) {
    MouseGetPos,,, Win
    Return WinExist(WinTitle . " ahk_id " . Win)
}

MouseIsOverTaskbar() {
	return MouseIsOver("ahk_class Shell_TrayWnd") or MouseIsOver("ahk_class Shell_SecondaryTrayWnd")
}

InInsertMode() {
	ControlGetFocus, OutputVar, A
	return InStr(OutputVar, "Edit")  ; in normal mode
}


InNormalMode() {
    WinGet, appExe, ProcessName, A    ; get current window ahk_exe
	ControlGetFocus, curCtrl, A
    ctrl := AppsConf[appExe]["DefaultControl"]
	; return true && InStr(curCtrl, ctrl)    ; in normal mode
	return AppsConf[appExe]["NormalEnabled"] && InStr(curCtrl, ctrl)    ; in normal mode
}

LongPressedSpeedUp(targetKey) {
	sleepTime := 400
	While GetKeyState(A_ThisHotkey) {
		sleep %sleepTime%
		If (sleepTime > 30) { 
			sleepTime := sleepTime / 2
		}
		send {%targetKey%}
	}
	return
}

;====== Handler ============================================
CtrlMHandler() {
    WinGet, appExe, ProcessName, A    ; get current window ahk_exe
    ctrl := AppsConf[appExe]["DefaultControl"]
    ; ControlGetPos, x, y, w, h, %ctrl%, A
    ; x := x+1
    ; y := y+1
    ; MouseClick, left, %x%, %y%
    Controlclick, %ctrl%, A
    ; Controlclick, , A
}

; AnyKeyWait() { 
;    Input, L, L1 
; }

PlayAltKeySequence(seq) {
    If (!RegExMatch(seq, "iP)^{*alt}", matchObjLen)) {
        ; msgbox It is not alt key sequence
        return
    }
    len := strlen(seq)
    curPos := 1
    ; AnyKeyWait()
    ; BlockInput On
    ; keywait, control
    sleep 300    ; wait for hotkey key release, otherwise alt will disturb.
    ; keywait, shift
    ; send {Lalt} 
    send % substr(seq, 1, matchObjLen)
    curPos += matchObjlen
    while (curPos<=len) {
        remainSeq := substr(seq,curPos,len)
        If (RegExMatch(remainSeq, "iP)^\D\d*", matchObjLen)) {
            sleep 50
            send % substr(remainSeq, 1, matchObjLen)
            ; msgbox % remainSeq " " matchObjLen
            curPos += matchObjLen
        } else {
            msgbox % "Error alt key seq " seq " remain is " remainSeq
            return -1
        }
    }
    ; BlockInput off
    return
}

KeyMapHandler() {
    WinGet, appExe, ProcessName, A    ; get current window ahk_exe
    mapVarName := AppsConf[appExe]["KeyMapInNoramalMode"]
    map        := %mapVarName%
    key        := A_ThisHotkey
    ; move keymap
    If (str := map["MoveKey"][key]) {
        If (InStr(str, "{alt}")) { ; long alt key sequence, need slow down for no missing
            PlayAltKeySequence(str)
            ; send % substr(str,1,8)
            ; sleep 300
            ; send % substr(str,9)
        } else {
            send % str
        }
        ; send % map["MoveKey"][key]
        return
    }
    If (str := map["EditKey"][key]) {
        send % str
        AppsConf[appExe]["NormalEnabled"] := false  ; enter insert mode
        return
    }
    If (map["CustomHandler"]) {
        return
    }
    send % key
    return
}

;========================================================
;====== Main ============================================
;========================================================
; Register App hotkey
; key => app
For appName, conf in AppsConf {
    key := conf["shortcut"]
    Hotkey, %key%, DoKeyToApp
}

; key => vim move hjkl
For key, value in KeySendMap {
    Hotkey, %key%, DoKeySend
}

; Control M
For appName, conf in AppsConf {
    Hotkey, If, WinActive("ahk_group CtrlMGroup")
        If (!conf["DefaultControl"]) {
            continue
        }
        match := GetAppMatcher(appName)
        GroupAdd, CtrlMGroup, %match%
        hotkey, ^m, CtrlMHandler
    Hotkey, If
}

#If WinActive("ahk_group CtrlMGroup")
#If

WinActiveAndInNormalMode(pattern) {
    return WinActive(pattern) && InNormalMode()
}

WinActiveAndInInsertMode(pattern) {
    return WinActive(pattern) && !InNormalMode()
}

EnterNormalMode() {
    WinGet, appExe, ProcessName, A    ; get current window ahk_exe
	AppsConf[appExe]["NormalEnabled"] := true
}

EnterInsertMode() {
    WinGet, appExe, ProcessName, A    ; get current window ahk_exe
	AppsConf[appExe]["NormalEnabled"] := false
    mouseclick,,,,2
}

For appExe, conf in AppsConf {
    If (conf["KeyMapInNoramalMode"]) {
        ; AppsConf[appExe].set("NormalEnabled", "gogo")
        AppsConf[appExe]["NormalEnabled"] := true
        ; msgbox % AppsConf[appExe]["NormalEnabled"]
        match := GetAppMatcher(appExe)
        GroupAdd, NornalModeGroup, %match%

        Hotkey, If, WinActiveAndInInsertMode("ahk_group NornalModeGroup")
        Hotkey, ~Esc, EnterNormalMode
        Hotkey, ^[, EnterNormalMode
        Hotkey, If

        Hotkey, If, WinActiveAndInNormalMode("ahk_group NornalModeGroup")
        Hotkey, i, EnterInsertMode
        Hotkey, If

        Hotkey, If, WinActiveAndInNormalMode("ahk_group NornalModeGroup")
        keyMapStr := conf["KeyMapInNoramalMode"]
        If (keyMapStr) {
            ; msgbox % keyMapStr
            keyMap  := %keyMapStr%
            ; msgbox % keyMap["MoveKey"]["j"]
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
}

#If, WinActiveAndInNormalMode("ahk_group NornalModeGroup")  ; For "hotkey, If"
#If

#If, WinActiveAndInInsertMode("ahk_group NornalModeGroup")  ; For "hotkey, If"
#If

#If MouseIsOverTaskbar()
	WheelUp::Send  {Volume_Up}     ; Wheel over taskbar: increase/decrease volume.  One space after send is important
	WheelDown::Send {Volume_Down}
	return
#If

; hotkey
CapsLock::RCtrl
RAlt::Esc
Launch_Mail::LongPressedSpeedUp("Volume_Down")
Browser_Home::LongPressedSpeedUp("Volume_Up")
