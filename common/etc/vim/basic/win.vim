
if has('win64') || has('win32')
    let &pythonthreedll  = $scoop .. '\apps\python\3.11.3\python311.dll'
    let &pythonthreehome = $scoop .. '\apps\python\3.11.3\'
endif
