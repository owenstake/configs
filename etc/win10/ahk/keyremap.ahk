#SingleInstance force
#MaxHotkeysPerInterval 200
#NoEnv
#Include %A_ScriptDir%
#include *i %A_LineFile%\..\custom.ahk

SendMode Input

; msgbox % "A_LineFile is " A_LineFile

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
    "!u"  : "{PgUp}" ,
    "!d"  : "{PgDn}" ,
    "!+j" : "^+{Tab}" ,
    "!+k" : "^{Tab}"
    }
    )

    ; "!e" : {"match" : "ahk_class CabinetWClass"} ,
    ; "!u" : {"match" : "ahk_exe kwmusic.exe"                                 } ,

global HotkeyAppMap :=
    ( Join
    {
	"!a" : {"match" : "ahk_exe hh.exe", "exe_path" : "C:\Windows\hh.exe"     },
    "!c" : {"match" : "ahk_exe chrome.exe"                                   } ,
    "!d" : {"match" : "ahk_exe Draw.io.exe"                                  } ,
    "!e" : {"match" : "ahk_class CabinetWClass", "exe_path" : "C:\Windows\explorer.exe" } ,
    "!i" : {"match" : "ahk_exe obsidian.exe"                                } ,
    "!m" : {"match" : "ahk_exe mobaxterm.exe"                               } ,
    "!p" : {"match" : "ahk_exe powerpoint.exe"                              } ,
    "!q" : {"match" : "ahk_exe qq.exe"                                      } ,
    "!r" : {"match" : "ahk_exe wechat.exe"                                  } ,
    "!s" : {"match" : "ahk_exe FoxitPDFReader.exe"                          } ,
    "!t" : {"match" : "ahk_exe typora.exe"                                  } ,
    "!v" : {"match" : "ahk_exe code.exe"                                    } ,
    "!w" : {"match" : "ahk_exe word.exe"                                    } ,
    "!x" : {"match" : "ahk_exe xshell.exe"                                  } ,
    "!z" : {"match" : "ahk_exe zotero.exe"                                  } ,

    "!+e" : {"match" : "ahk_exe Everything.exe"                      } ,
    "!+n" : {"match" : "ahk_exe v2rayN.exe"                                  } ,
    "!+o" : {"match" : "ahk_exe firefox.exe", "exe_path" : "C:\Users\owen\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps\Tor Browser.lnk"} ,
    "!+u" : {"match" : "ahk_exe kwmusic.exe"                                 },
    "!+x" : {"match" : "ahk_exe Excel.exe"                                  }
    }
    )

global KeymapInFoxitNornalMode :=
	( Join
	{ 
	"~j"  : "{Down}",
	"~k"  : "{Up}"   ,
	"~u"  : "{PgUp}" ,
	"~d"  : "{PgDn}" ,
	"~+j" : "^+{Tab}",
	"~+k" : "^{Tab}" ,
	"~="  : "^="   ,
	"~-"  : "^-"  ,
	"~+="  : "^+="   ,
	"~+-"  : "^+-"
	}
	)

ExecWinCmd(cmd, Byref stdout) {
    exec := ComObjCreate("WScript.Shell").Exec(cmd)
    stdout := exec.StdOut.ReadAll()  ; strip tailing "`r`n" in win
	stdout := Trim(stdout, " `r`n")
	stderr := exec.StdErr.ReadAll()
    return stderr
}


GetApp(app) {
	patterns := 
		( Join
			[   
			"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\*.lnk" ,
			"C:\Users\owen\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\*.lnk"
			]
		)
	Loop , % patterns.Length()
	{
		p := patterns[A_Index]
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

GetAppExe1(app, Byref stdout) {
	cmd := "powershell.exe -WindowStyle Hidden -c GetAppExe " app
	stderr := ExecWinCmd(cmd, stdout)
    return stderr
}

DoKeyToApp() {
    ham   := HotkeyAppMap[A_ThisHotkey]
    match := ham["match"]
    if WinExist(match) {  ; This will be expanded because it is a expression
        if WinActive(match) {
            Send !{Esc}
        } else {
            WinActivate, %match%  ; Command syntax
        }
    } else {
        if ham["exe_path"] != ""
        {
            run_exe := ham["exe_path"]
        } else {
			app := RegExReplace(match,".*ahk_exe\s+(\w+)\.exe","$1")
            file := GetApp(app)
			If (file = "") {
                MsgBox % "No found app in system. Please specified a exe_path."
                return
            } else {
                run_exe := file
            }
            ; stderr := GetAppExe1(app, stdout)
            ; If stderr !=
            ; {
            ;     MsgBox % "No found app in system. Please specified a exe_path. stderr:`n" stderr
            ;     return
            ; } else {
            ;     run_exe := stdout
            ; }
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

FoxitNornalModeKeyHandler() {
	ControlGetFocus, OutputVar, A
	KeySend := KeymapInFoxitNornalMode[A_ThisHotkey]
	If !InStr(OutputVar, "Edit") { ; in normal mode
		send %KeySend%
	}
	return
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

;========================================================
;====== Main ============================================
;========================================================

; key => app
For key, value in HotkeyAppMap {
    Hotkey, %key%, DoKeyToApp
}

; key => vim key
For key, value in KeySendMap {
    Hotkey, %key%, DoKeySend
}

; 
Hotkey, IfWinActive, ahk_exe FoxitPDFReader.exe
	; msgbox % KeymapInFoxitNornalMode
	For key, target in KeymapInFoxitNornalMode {
		; msgbox % key
		Hotkey, %key%, FoxitNornalModeKeyHandler
	}
Hotkey, IfWinActive

; Hotkey, If, (MouseIsOverTaskbar())
; 	WheelUp::Send  {Volume_Up}     ; Wheel over taskbar: increase/decrease volume.  One space after send is important
; 	WheelDown::Send {Volume_Down}
; Hotkey, If

;====== chrome config ===================================================
#IfWinActive, ahk_exe chrome.exe
	^m::Controlclick, Chrome_RenderWidgetHostHWND1, A
#IfWinActive

#IfWinActive, ahk_exe Explorer.exe
	^m::Controlclick, DirectUIHWND2, A
#IfWinActive

; GroupAdd, CtrlMGroup, ahk_exe chrome.exe
; GroupAdd, CtrlMGroup, ahk_exe firefox.exe
; GroupAdd, CtrlMGroup, ahk_exe Explorer.exe

; hotkey
CapsLock::RCtrl
RAlt::Esc
Launch_Mail::LongPressedSpeedUp("Volume_Down")
Browser_Home::LongPressedSpeedUp("Volume_Up")
