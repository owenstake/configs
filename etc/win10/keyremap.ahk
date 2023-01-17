; replaces the old instance automatically
#SingleInstance force

; Basic AHK key remap knowledge
; #win, !alt, ^ctl, +shift, ~do not overwrite

; basic setting

#z::
   hWnd := WinExist("A")
   WinGet, MinMax, MinMax
   if MinMax
      WinRestore
   WinGetPos,, Y_TaskBar,,, ahk_class Shell_TrayWnd
   dX := dW := dH := 0
   VarSetCapacity(RECT, 16, 0)
   if DllCall("Dwmapi\DwmGetWindowAttribute", Ptr, hWnd, UInt, DWMWA_EXTENDED_FRAME_BOUNDS := 9, Ptr, &RECT, UInt, 16) = 0  {
      WinGetPos, X, Y, W, H
      dX := NumGet(RECT, "Int") - X
      dW := X + W - NumGet(RECT, 8, "Int") + dX
      dH := Y + H - NumGet(RECT, 12, "Int")
   }
   WinMove,,, (A_ThisHotkey =  "#z" ? 0 : A_ScreenWidth//2) - dX, 0, A_ScreenWidth//2 + dW, Y_TaskBar + dH
   Return

;====== Basic Keyremap ===================================================
    ; arrow key map
        !u::send {PgUp}
        !d::send {PgDn}
        !h::send {Left}
        !j::send {Down}
        !k::send {Up}
        !l::send {Right}
        !+j::send ^+{Tab}
        !+k::send ^{Tab}
    ; keyremap
        CapsLock::RCtrl
        RAlt::Esc
        Launch_Mail::CapsLock
        #Up::WinMaximize, A

        ; Hide taskbar
        VarSetCapacity(APPBARDATA, A_PtrSize=4 ? 36:48)
        ; Browser_Home::HideShowTaskbar(hide := !hide)
        Scrolllock::HideShowTaskbar(hide := !hide)
            HideShowTaskbar(action) {
                static ABM_SETSTATE := 0xA, ABS_AUTOHIDE := 0x1, ABS_ALWAYSONTOP := 0x2
                    VarSetCapacity(APPBARDATA, size := 2*A_PtrSize + 2*4 + 16 + A_PtrSize, 0)
                    NumPut(size, APPBARDATA), NumPut(WinExist("ahk_class Shell_TrayWnd"), APPBARDATA, A_PtrSize)
                    NumPut(action ? ABS_AUTOHIDE : ABS_ALWAYSONTOP, APPBARDATA, size - A_PtrSize)
                    DllCall("Shell32\SHAppBarMessage", UInt, ABM_SETSTATE, Ptr, &APPBARDATA)
            }
;====== End keyremap ===================================================

;====== APP specified config i.e. chrome foxit ===================================================
    ;====== chrome config ===================================================
        ^m::
        if WinActive("ahk_exe chrome.exe") {
            ; For chrome, nothing control can be focused or detected
            Controlclick, Chrome_RenderWidgetHostHWND1, ahk_exe chrome.exe
        } else {
            send ^m
        }
        return
        ; ^l::
        ; if WinActive("ahk_exe chrome.exe") {
        ;     ; For chrome, nothing control can be focused or detected
        ;     Chrome_CtrlL_Cnt++
        ;     if (Mod(Chrome_CtrlL_Cnt, 2)) {
        ;         Controlclick, Chrome_RenderWidgetHostHWND1, ahk_exe chrome.exe
        ;     } else {
        ;         send ^l
        ;     }
        ; } else {
        ;     send ^l
        ; }
        ; return
    ;====== foxit config ===================================================
        ~j::
        if WinActive("ahk_exe FoxitPDFReader.exe") {  ; This will be expanded because it is a expression
            ControlGetFocus, OutputVar, ahk_exe FoxitPDFReader.exe
            If InStr(OutputVar, "Edit") {
            } else {
                send {Down}
            }
        }
        return
        ~k::
        if WinActive("ahk_exe FoxitPDFReader.exe") {  ; This will be expanded because it is a expression
            ControlGetFocus, OutputVar, ahk_exe FoxitPDFReader.exe
            If InStr(OutputVar, "Edit") {
            } else {
                send {Up}
            }
        }
        return
        ; page up
        ~u::
        if WinActive("ahk_exe FoxitPDFReader.exe") {  ; This will be expanded because it is a expression
            ControlGetFocus, OutputVar, ahk_exe FoxitPDFReader.exe
            If InStr(OutputVar, "Edit") {
            } else {
                send {PgUp}
            }
        }
        return
        ; page down
        ~d::
        if WinActive("ahk_exe FoxitPDFReader.exe") {  ; This will be expanded because it is a expression
            ControlGetFocus, OutputVar, ahk_exe FoxitPDFReader.exe
            If InStr(OutputVar, "Edit") {
            } else {
                send {PgDn}
            }
        }
        return
        ~+J::
        if WinActive("ahk_exe FoxitPDFReader.exe") {  ; This will be expanded because it is a expression
            ControlGetFocus, OutputVar, ahk_exe FoxitPDFReader.exe
            If InStr(OutputVar, "Edit") {
            } else {
                send ^+{Tab}
            }
        }
        return
        ~+K::
        if WinActive("ahk_exe FoxitPDFReader.exe") {  ; This will be expanded because it is a expression
            ControlGetFocus, OutputVar, ahk_exe FoxitPDFReader.exe
            If InStr(OutputVar, "Edit") {
            } else {
                send ^{Tab}
            }
        }
        return
        ; zoom in
        !=::
        if WinActive("ahk_exe FoxitPDFReader.exe") {  ; This will be expanded because it is a expression
            send ^{=}
        }
        return
        ; zoom out
        !-::
        if WinActive("ahk_exe FoxitPDFReader.exe") {  ; This will be expanded because it is a expression
            send ^-
        }
        return
;====== End specified app config ===================================================

;====== Transparent Control win+= win+- ===================================================
    #=:: ;����͸�������ӻ��߼���
        WinGet, ow, id, A
        WinTransplus(ow)
        return
    #-:: ;����͸�������ӻ��߼���
        WinGet, ow, id, A
        WinTransMinus(ow)
        return
    WinTransplus(w){
        WinGet, transparent, Transparent, ahk_id %w%
        if transparent < 255
            transparent := transparent+10
        else
            transparent =
        if transparent
            WinSet, Transparent, %transparent%, ahk_id %w%
        else
            WinSet, Transparent, off, ahk_id %w%
        return
    }
    WinTransMinus(w){
        WinGet, transparent, Transparent, ahk_id %w%
        if transparent
            transparent := transparent-10
        else
            transparent := 240
        WinSet, Transparent, %transparent%, ahk_id %w%
        return
    }
;====== End control win transparent===================================================

;======= DEBUG alt+enter Active Window just like "window spy" =====================================================
    !enter::
        WinGet ow, id, A
        WinGet pp, processPath, A
        WinGet pn, processname, A
        WinGetTitle, oTitle, ahk_id %ow%
        WinGetClass, oClass, ahk_id %ow%
        WinGetText, oText, ahk_id %ow%
        clipboard= %ow%      %oTitle%    %oClass%  %oText%   %pp%  %pn%
        tooltip %clipboard%
        SetTimer, RemoveToolTip, 5000
        return
;======= End debug active window =====================================================

;======= top win win+space ==================================================
    #Space:: ;�����֮�����ö�
        WinGet ow, id, A
        WinGet pp, processPath, A
        WinGet pn, processname, A
        WinGetTitle, oTitle, ahk_id %ow%
        WinGetClass, oClass, ahk_id %ow%
        WinGetText, oText, ahk_id %ow%
        clipboard = %ow%  %oTitle%   %oClass%  %oText%  %pp%  %pn%
        tooltip %clipboard%
        WinTopToggle(ow)
        return
        WinTopToggle(w) {
            WinGetTitle, oTitle, ahk_id %w%
            Winset, AlwaysOnTop, Toggle, ahk_id %w%
            WinGet, ExStyle, ExStyle, ahk_id %w%
            if (ExStyle & 0x8)  ; 0x8 Ϊ WS_EX_TOPMOST.��WinGet�İ�����
                oTop = �ö�
            else
                oTop = ȡ���ö�
            tooltip %oTitle% %oTop%
            SetTimer, RemoveToolTip, 5000
            return
        
            RemoveToolTip:
            SetTimer, RemoveToolTip, Off
            ToolTip
            return
        }

        #x:: ;�رմ���
        send ^w
    return
;======= End top win ==================================================

;======= Hotkey for APP in alpha order alt+app =====================================================
    ; Activate an existing ***.exe window, or open a new one
    ; Ahk help
        Alt & a::   ; "!a" diff "Alt & a", Alt is raw signal, can help us avoid recursive map problem
            WinActiveToggle("hh.exe", "C:\Windows\hh.exe")
            return
    ; Chrome
        Alt & c::
            WinActiveToggle("chrome.exe", "C:\Program Files (x86)\Google\Chrome Dev\Application\chrome.exe")
            return
    ; Drawio
        Alt & d::
            WinActiveToggle("draw.io.exe", "C:\Program Files\draw.io\draw.io.exe")
            return
    ; Explorer
        Alt & e::
            ; Shell := ComObjCreate("Shell.Application")

            ; For Windows In Shell.Windows {
            ;     Path := Windows.Document.Folder.Self.Path

            ;       If (Path = ExplorerPath) {
            ;           MsgBox, Folder is currently open
            ;               Break
            ;       }
            ; }
            WinActiveToggleClass("CabinetWClass", "C:\Windows\explorer.exe")
            ; WinActiveToggle("explorer.exe", "C:\Windows\explorer.exe")
            return
    ; Foxit
        Alt & f::
            WinActiveToggle("FoxitPDFReader.exe", "C:\Program Files (x86)\Foxit Software\Foxit PDF Reader\FoxitPDFReader.exe")
            return
    ; MobaXterm
        Alt & m::
            WinActiveToggle("MobaXterm.exe", "C:\Program Files (x86)\Mobatek\MobaXterm\MobaXterm.exe")
            return
    ; Notepad
    ;   Alt & n::
    ;       WinActiveToggle("notepad.exe", "Notepad")
    ;       return
    ; V2ray
        Alt & n::
            WinActiveToggle("v2rayN.exe", "C:\MY_SOFTWARE\v2rayN-windows-64\v2rayN-Core-64bit\v2rayN.exe")
            return
    ; email Outlook
        Alt & o::
            ; Tor Browser
            WinActiveToggle("firefox.exe", "C:\Users\owen\Desktop\Tor Browser\Browser\firefox.exe")
            ; WinActiveToggle("Foxmail.exe", "C:\Foxmail 7.2\Foxmail.exe")
            ; WinActiveToggle("OUTLOOK.EXE", "C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE")
            return
    ; Ppt
        Alt & p::
            WinActiveToggle("POWERPNT.EXE", "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE")
            return
    ; QQ
        Alt & q::
            WinActiveToggle("QQ.exe", "C:\Program Files (x86)\Tencent\QQ\Bin\QQ.exe")
            return
    ; RWexin
        Alt & r::
            WinActiveToggle("WeChat.exe", "C:\Program Files (x86)\Tencent\WeChat\WeChat.exe")
            return
    ; SecureCRT
        Alt & s::
            WinActiveToggle("SecureCRT_CHS.exe", "C:\Program Files\VanDyke Software\SecureCRT\SecureCRT_CHS.exe")
            return
    ; Typora
        Alt & t::
            WinActiveToggle("Typora.exe", "C:\Program Files\Typora\Typora.exe")
            return
    ; QMusic
        Alt & u::
            WinActiveToggle("QQMusic.exe", "C:\Program Files (x86)\Tencent\QQMusic\QQMusic.exe")
            return
    ; Vscode
        Alt & v::
            WinActiveToggle("Code.exe", "C:\Program Files\Microsoft VS Code\Code.exe")
            return
    ; Word
        Alt & w::
            WinActiveToggle("WINWORD.EXE", "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE")
            return
    ; X Excel
        Alt & x::
            WinActiveToggle("Xshell.exe", "C:\Program Files (x86)\NetSarang\Xshell 7\Xshell.exe")
            return
    ; X Excel
    ;   Alt & x::
    ;       WinActiveToggle("EXCEL.EXE", "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE")
    ;       return

    ; Zotero
        Alt & z::
            WinActiveToggle("zotero.exe", "C:\Program Files (x86)\Zotero\zotero.exe")
            return
    ; ; WindowSpy
    ;     Alt & s::
    ;         run C:\Program Files\AutoHotkey\WindowSpy.ahk
    ;         return
    ; WinActiveToggle for modulization and common interface
        WinActiveToggle(win_exe, run_exe) {
            if WinExist("ahk_exe" win_exe) {  ; This will be expanded because it is a expression
                if WinActive("ahk_exe" win_exe) {
                    ; WinClose  ;   Uses the last found window.
                    ; WinHide("ahk_exe" win_exe)
                    ; WinHide, ahk_exe %win_exe%
                    Send !{Esc}
                    ; msgbox closing
                } else {
                    WinActivate, ahk_exe %win_exe%  ; Command syntax
                    ; msgbox activing
                }
            } else {
                ; msgbox % "running" run_exe     ; ok   This will be expanded because it is a expression
                ; msgbox % %run_exe%           ; fail legacy syntax. This will be expanded because it is a expression
                ; msgbox running %run_exe%     ; ok   expression. This will be expanded because it is a expression
                run %run_exe%
            }
            return
        }

        WinActiveToggleClass(win_class, run_exe) {
            if WinExist("ahk_class" win_class) {  ; This will be expanded because it is a expression
                if WinActive("ahk_class" win_class) {
                    ; WinClose  ;   Uses the last found window.
                    ; WinHide("ahk_exe" win_class)
                    ; WinHide, ahk_exe %win_class%
                    Send !{Esc}
                    ; msgbox closing
                } else {
                    WinActivate, ahk_class %win_class%  ; Command syntax
                    ; msgbox activing
                }
            } else {
                ; msgbox % "running" run_exe     ; ok   This will be expanded because it is a expression
                ; msgbox % %run_exe%           ; fail legacy syntax. This will be expanded because it is a expression
                ; msgbox running %run_exe%     ; ok   expression. This will be expanded because it is a expression
                run %run_exe%
            }
            return
        }
;==== End Hotkey for app =====================================================

;���Ӱ�����֮������������
;======= ������������ scoll in taskbar ==================================================
    ~lbutton & enter:: ;����������������������ʵ�������ļӼ�
        exitapp  
    ~WheelUp::  
        if (existclass("ahk_class Shell_TrayWnd")=1)  
            Send,{Volume_Up}  
        Return  
    ~WheelDown::  
            if (existclass("ahk_class Shell_TrayWnd")=1)  
            Send,{Volume_Down}  
        Return  
    ~MButton::  
        if (existclass("ahk_class Shell_TrayWnd")=1)  
            Send,{Volume_Mute}  
        Return  
    Existclass(class) {  
        MouseGetPos,,,win  
        WinGet,winid,id,%class%  
        if win = %winid%  
            Return,1  
        Else  
            Return,0  
    }
;======= End ������������ ==================================================

;======== Copy file path  win+shift+c =================================================
    #+c:: ;�ÿ�ݼ��õ���ǰѡ���ļ���·��
    send ^c
    sleep,200
    clipboard=%clipboard% ;windows ���Ƶ�ʱ�򣬼����屣����ǡ�·������ֻ��·�������ַ�����ֻҪת�����ַ����Ϳ���ճ��������
    tooltip,%clipboard% ;��ʾ�ı�
    sleep,2000   ; 2 sec
    tooltip,
    return
;======== End copy file path =================================================

;======== timer win+shift+t =================================================
    #+t:: ;С��ԭ��-�޵й�������֮�ռ���ʱ��
    var := 0
    InputBox, time, С�����ü�ʱ��, ������һ��ʱ�䣨��λ�Ƿ֣�
    time := time*60000
    Sleep, %time%
    loop,16 {
        var += 180
        SoundBeep, var, 500
    }
    msgbox ʱ�䵽������������������𣡣����л��㱣�����
    return
;======== End timer=================================================

;======== Hot strings =================================================
    ; :*:iid::  ; �����ִ�ͨ������������ִ��滻�ɵ�ǰ���ں�ʱ��.
    ; FormatTime, CurrentDateTime,, MM��dd ; ��ʽ��С��01��17��Ƭ
    ; ;FormatTime, CurrentDateTime,, MM��dd-HH��-mm-ss ; ��ʽ��С��08��16-11��-43-51��Ƭ
    ; SendInput С��%CurrentDateTime%��Ƭ
    ; return
    ; :*:autoh:: ;�Զ�����AutoHotkey
    ; clipboard = AutoHotkey
    ; send,^v
    ; return
;======== End Hot strings =================================================

;======== google search  win+9 ================================================
    #9:: ;��google�������а������
    run https://www.google.com/search?q=%clipboard%
    tooltip, ������Ҳ������Ҳ��������
    sleep 2000
    tooltip,
    return
;======== End google search ================================================

;======== some example ==================================================
    #1:: ;ѭ�����ʾ��, 0.2s
    loop, 10
    {
        click
        sleep 200
    }
    return

    ; #z::Run https://www.autohotkey.com  ; Win+Z

    InputBox, ov, TEST, input sth
    tooltip %ov%

    WinActivate, ahk_class ConsoleWindowClass

    id := WinExist("A")
    MsgBox % id
;======== End some example ==================================================
