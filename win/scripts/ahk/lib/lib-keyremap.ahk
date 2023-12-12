
ExecWinCmd(cmd, Byref stdout) {
    exec := ComObjCreate("WScript.Shell").Exec(cmd)
    stdout := exec.StdOut.ReadAll()  ; strip tailing "`r`n" in win
	stdout := Trim(stdout, " `r`n")
	stderr := exec.StdErr.ReadAll()
    return stderr
}

GetExplorerSelectedItem() {
    hwnd := WinExist("A")
    for Window in ComObjCreate("Shell.Application").Windows {
        if (window.hwnd==hwnd) {
          Selection := Window.Document.SelectedItems
          for Items in Selection
              Path_to_Selection := Items.path
        }
    }
    return Path_to_Selection
}

ExplorerNavigate(FullPath) {
    EnvGet,USERPROFILE,USERPROFILE
    FullPath     := RegExReplace(FullPath,"^~", USERPROFILE)
	explorerHwnd := WinActive("ahk_class CabinetWClass")
	For pExp in ComObjCreate("Shell.Application").Windows
	{
		if (pExp.hwnd = explorerHwnd) {	; matching window found
			pExp.Navigate("file:///" FullPath)
			return
		}
	}
}

ExtractFile() {
    FullFileName := GetExplorerSelectedItem()
    SplitPath, FullFileName, name, dir, ext, name_no_ext, drive
    run, 7z x ""%FullFileName%"" -o""%dir%\%name_no_ext%""
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
	AppSearchPath := [   ProgramData . "\Microsoft\Windows\Start Menu\Programs\*.lnk"
			, APPDATA . "\Microsoft\Windows\Start Menu\Programs\*.lnk" ]

	Loop , % AppSearchPath.Length()
	{
		p := AppSearchPath[A_Index]
		Loop Files, %p%, R  ; Recurse into subfolders.
		{
            lnkFile := A_LoopFileFullPath
			; Get targetFile From LnkFile
			FileGetShortcut, %lnkFile%, targetFile
			; LnkFile compare
            SplitPath, lnkFile,,,, basenameInLnk
			If (basenameInLnk = app) {
				return lnkFile
			}
			; targetFile compare
            SplitPath, targetFile,,,, basenameInOutTarget
			If (basenameInOutTarget = app) {
				return targetFile
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

IsWindow(hWnd){
    WinGet, dwStyle, Style, ahk_id %hWnd%
    if ((dwStyle&0x08000000) || !(dwStyle&0x10000000)) {
        ; 0x08000000 is WS_DISABLED.
        ; 0x10000000 is WS_VISIBLE.
        return false
    }
    WinGet, dwExStyle, ExStyle, ahk_id %hWnd%
    if (dwExStyle & 0x00000080) {
        ; 0x80 is WS_EX_TOOLWINDOW.
        return false
    }
    WinGetClass, szClass, ahk_id %hWnd%
    if (szClass = "TApplication") {
        return false
    }
    return true
}

InMainScreen(this_id) {
    WinGetPos, x, y, , , ahk_id %this_id%
    return x > -100  ;if your primary screen is 0 >..
    ; if (x > -100) {    ;if your primary screen is 0 >..
    ;     ; WinSet, Bottom,, ahk_id %this_id%
    ; }
}

OwenAltTab(match) {
    WinGet, id, list, %match%
    ; WinGet, id, list,,, Program Manager
    WinGet, aid, id, A
    Loop, %id%
    {
        this_id := id%A_Index%
        ; skip current active win
        IfWinActive, ahk_id %this_ID%
            continue
        ; WinGetTitle, title, ahk_id %this_ID%
        If (!IsWindow(WinExist("ahk_id" . this_ID))) {
            continue
        }
        If (!InMainScreen(this_id)) {
            continue
        }
        WinActivate, ahk_id %this_id%
        break
    }
}

DoKeyToApp() {
    keywait alt ; avoid trigger alt for app
    appName := GetAppNameByShortcut()
    conf    := AppsConf[appName]
    match   := GetAppMatcher(appName)
    if WinExist(match) {  ; This will be expanded because it is a expression
        if WinActive(match) {
            ; OwenAltTab("")
            ; OwenAltTab(match)
            Send !{Esc}
            return
        } else {
            OwenAltTab(match)
            ; WinActivate, %match%
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
    Controlclick, %ctrl%, A,,,, NA x1 y1
	; ControlGetFocus, %ctrl%, A
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
            sleep 400
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
    If (!GetKeyState("CapsLock", "P") && action := map["MoveKey"][key]["Action"]) {
        zFuncCallPattern := "^(\w+)\((.*)\)$"
        If (IsFuncCallStr(action)) {
            ret := ParseFuncAndEval(action)
            return ret
        }
        ; long alt key sequence, need slow down for no missing
        If (InStr(action, "{alt}")) {
            PlayAltKeySequence(action)
        } else {
            send % action
        }
        return
    }
    If (action := map["EditKey"][key]["Action"]) {
        send % action
        AppsConf[appExe]["NormalEnabled"] := false  ; enter insert mode
        return
    }
    If (map["CustomHandler"]) {
        return
    }

    sendinput % key
    return
}

WinActiveAndCapsDown(winPattern) {
    return WinActive(winPattern) && GetKeyState("CapsLock", "P") ; capslock + m
}

WinActiveAndInNormalMode(pattern) {
    return WinActive(pattern) && InNormalMode() && !GetKeyState("CapsLock", "P")  ; capslock is remaped
}

WinActiveAndInInsertMode(pattern) {
    return WinActive(pattern) && !InNormalMode() && !GetKeyState("CapsLock", "P")  ; capslock is remaped
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

