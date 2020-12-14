;将焦点聚焦到左边的窗口
^+h::
MouseMove, 480, 600,0
MouseGetPos,,, hwnd
WinActivate, ahk_id %hwnd%
return

;将焦点聚焦到右边的窗口
^+l::
MouseMove, 1440, 600,0
MouseGetPos,,, hwnd
WinActivate, ahk_id %hwnd%
return