; replaces the old instance automatically
#SingleInstance force

;====== keyremap ===================================================
    ; keyremap
    CapsLock::RCtrl
    RAlt::Esc
    Launch_Mail::CapsLock
;====== End keyremap ===================================================

;====== control win transparent===================================================
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

;======= DEBUG Active Window =====================================================
    !enter::
        WinGet ow, id, A
        WinGet pp, processPath, A
        WinGet pn, processname, A
        WinGetTitle, oTitle, ahk_id %ow%
        WinGetClass, oClass, ahk_id %ow%
        WinGetText, oText, ahk_id %ow%
        clipboard= %ow%      %oTitle%    %oClass%  %oText%   %pp%  %pn%
        tooltip %clipboard%
        return
;======= End debug active window =====================================================

;======= top win ==================================================
    #enter:: ;最爱代码之窗口置顶
        WinGet ow, id, A
        WinGet pp, processPath, A
        WinGet pn, processname, A
        WinGetTitle, oTitle, ahk_id %ow%
        WinGetClass, oClass, ahk_id %ow%
        WinGetText, oText, ahk_id %ow%
        clipboard= %ow%      %oTitle%    %oClass%  %oText%   %pp%  %pn%
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

;== Arrow key map=======================================================
    LAlt & u::send {PgUp}
    LAlt & d::send {PgDn}
    LAlt & h::send {Left}
    LAlt & j::send {Down}
    LAlt & k::send {Up}
    LAlt & l::send {Right}

    ; LAlt & m::send,{Shift}{Home}
    ; LAlt & m::send,^m
    ; LAlt & m::send {Ctrl}m
;== End Arrow key map=======================================================

;==== Hotkey for app =====================================================
; Notepad - Activate an existing notepad.exe window, or open a new one
    !n::
        WinActiveToggle("notepad.exe", "Notepad") 
        return
; wxwork
    !w::
        WinActiveToggle("WXWork.exe", "C:\Program Files (x86)\WXWork\WXWork.exe") 
        return
; foxit
    !f::
        WinActiveToggle("FoxitReader.exe", "C:\Program Files (x86)\Foxit Software\Foxit Reader\FoxitReader.exe ") 
        return
; qq
    !q::
        WinActiveToggle("QQ.exe", "C:\Program Files (x86)\Tencent\QQ\Bin\QQ.exe") 
        return
; vscode
    !v::
        WinActiveToggle("Code.exe", "C:\Users\zhuangyulin\AppData\Local\Programs\Microsoft VS Code\Code.exe") 
        return
; MobaXterm
        WinActiveToggle("MobaXterm.exe", "C:\Program Files (x86)\Mobatek\MobaXterm\MobaXterm.exe") 
        return
; chrome
    !c::
        ; var1 := "chrome.exe"
        ; var2 := "C:\Program Files (x86)\Google\Chrome Dev\Application\chrome.exe "
        ; WinActiveToggle(var1, var2) 
        WinActiveToggle("chrome.exe", "C:\Program Files (x86)\Google\Chrome Dev\Application\chrome.exe") 
        return
WinActiveToggle(win_exe, run_exe) {
    if WinExist("ahk_exe" win_exe) {
        if WinActive("ahk_exe" win_exe) {
            ; WinClose  ;   Uses the last found window.
            WinHide, ahk_exe %win_exe%
            msgbox closing
        } else {
            WinActivate, ahk_exe %win_exe%
            msgbox activing
        }
    } else {
        msgbox running %run_exe%
        run %run_exe%
    }
    return
}
;==== End Hotkey for app =====================================================


;最钟爱代码之音量随心所欲
;======= 音量随心所欲 ==================================================
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

;======== Copy file path =================================================
    #+c:: ;用快捷键得到当前选中文件的路径
    send ^c
    sleep,200
    clipboard=%clipboard% ;windows 复制的时候，剪贴板保存的是“路径”。只是路径不是字符串，只要转换成字符串就可以粘贴出来了
    tooltip,%clipboard% ;提示文本
    sleep,2000
    tooltip,
    return
;======== End copy file path =================================================

;======== timer =================================================
    #+t:: ;小海原创-无敌工作神器之终极计时器
    var := 0
    InputBox, time, 小海御用计时器, 请输入一个时间（单位是分）
    time := time*60000
    Sleep,%time%
    loop,16
    {
    var += 180
    SoundBeep, var, 500
    }
    msgbox 时间到，啊啊啊！！！红红火火！！！恍恍惚惚！！！
    return
;======== End timer=================================================

;======== Hot strings =================================================
    :*:iid::  ; 此热字串通过后面命令将热字串替换成当前日期和时间.
    FormatTime, CurrentDateTime,, MM月dd ; 形式：小海01月17短片
    ;FormatTime, CurrentDateTime,, MM月dd-HH点-mm-ss ; 形式：小海08月16-11点-43-51短片
    SendInput 小海%CurrentDateTime%短片
    return
    :*:autoh:: ;自动输入AutoHotkey
    clipboard = AutoHotkey
    send,^v
    return
;======== End Hot strings =================================================

;======== google search ================================================
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