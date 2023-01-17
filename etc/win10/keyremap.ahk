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
    #=:: ;窗口透明化增加或者减弱
        WinGet, ow, id, A
        WinTransplus(ow)
        return
    #-:: ;窗口透明化增加或者减弱
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
    #Space:: ;最爱代码之窗口置顶
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
            if (ExStyle & 0x8)  ; 0x8 为 WS_EX_TOPMOST.在WinGet的帮助中
                oTop = 置顶
            else
                oTop = 取消置顶
            tooltip %oTitle% %oTop%
            SetTimer, RemoveToolTip, 5000
            return
        
            RemoveToolTip:
            SetTimer, RemoveToolTip, Off
            ToolTip
            return
        }

        #x:: ;关闭窗口
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

;最钟爱代码之音量随心所欲
;======= 音量随心所欲 scoll in taskbar ==================================================
    ~lbutton & enter:: ;鼠标放在任务栏，滚动滚轮实现音量的加减
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
;======= End 音量随心所欲 ==================================================

;======== Copy file path  win+shift+c =================================================
    #+c:: ;用快捷键得到当前选中文件的路径
    send ^c
    sleep,200
    clipboard=%clipboard% ;windows 复制的时候，剪贴板保存的是“路径”。只是路径不是字符串，只要转换成字符串就可以粘贴出来了
    tooltip,%clipboard% ;提示文本
    sleep,2000   ; 2 sec
    tooltip,
    return
;======== End copy file path =================================================

;======== timer win+shift+t =================================================
    #+t:: ;小海原创-无敌工作神器之终极计时器
    var := 0
    InputBox, time, 小海御用计时器, 请输入一个时间（单位是分）
    time := time*60000
    Sleep, %time%
    loop,16 {
        var += 180
        SoundBeep, var, 500
    }
    msgbox 时间到，啊啊啊！！！红红火火！！！恍恍惚惚！！！
    return
;======== End timer=================================================

;======== Hot strings =================================================
    ; :*:iid::  ; 此热字串通过后面命令将热字串替换成当前日期和时间.
    ; FormatTime, CurrentDateTime,, MM月dd ; 形式：小海01月17短片
    ; ;FormatTime, CurrentDateTime,, MM月dd-HH点-mm-ss ; 形式：小海08月16-11点-43-51短片
    ; SendInput 小海%CurrentDateTime%短片
    ; return
    ; :*:autoh:: ;自动输入AutoHotkey
    ; clipboard = AutoHotkey
    ; send,^v
    ; return
;======== End Hot strings =================================================

;======== google search  win+9 ================================================
    #9:: ;用google搜索剪切板的内容
    run https://www.google.com/search?q=%clipboard%
    tooltip, 那晚，风也美，人也美。。。
    sleep 2000
    tooltip,
    return
;======== End google search ================================================

;======== some example ==================================================
    #1:: ;循环点击示例, 0.2s
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
