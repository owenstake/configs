; Env
global APPDATA, ProgramData
EnvGet, APPDATA, APPDATA
EnvGet, ProgramData, ProgramData
EnvGet, WEIYUN, WEIYUN

global mynote
loop files, %WEIYUN%\*, DR
{
    If (A_LoopFileName = "my_note") {
        mynote := A_LoopFileFullPath
    }
}

torbrowserPath := APPDATA . "\Microsoft\Windows\Start Menu\Programs\Scoop Apps\Tor Browser.lnk" 

; Reverse "hjkl "for move.
; Reverse "fb" for terminal move.
; Remain usable key "agy"
global KeySendMap := { "!j"  : "{Down}"
    , "!k"  : "{Up}"    
    , "!h"  : "{Left}"  
    , "!l"  : "{Right}" 
    , "!u"  : "{PgUp}"  
    , "!d"  : "{PgDn}"  
    , "!+j" : "^+{Tab}" 
    , "!+k" : "^{Tab}"  }

; global HotkeyAppMap :=
global AppsConf := { "hh.exe":{"Shortcut":"!a","ExePath":"C:\Windows\hh.exe"       }
    ,"chrome.exe"          : {"Shortcut" : "!c"
                            , "DefaultControl" : "Chrome_RenderWidgetHostHWND1"    }
    ,"Draw.io.exe"         : {"Shortcut" : "!g"                                    }
    ,"Explorer.exe"        : {"Shortcut" : "!e"
                            , "Match"               : "ahk_class CabinetWClass"
                            , "ExePath"             : "C:\Windows\explorer.exe"
                            , "DefaultControl"      : "DirectUIHWND"
                            , "KeyMapInNoramalMode" : "ExplorerKeymapInNornalMode" }
    ,"obsidian.exe"        : {"Shortcut" : "!i"                                    }
    ,"mobaxterm.exe"       : {"Shortcut" : "!m"                                    }
    ,"WindowsTerminal.exe" : {"Shortcut" : "!n"                                    }
    ,"powerpoint.exe"      : {"Shortcut" : "!p"                                    }
    ,"qq.exe"              : {"Shortcut" : "!q"                                    }
    ,"wechat.exe"          : {"Shortcut" : "!r"                                    }
    ,"FoxitPDFReader.exe"  : {"Shortcut" : "!s"
                            , "DefaultControl" : "FoxitDocWnd1"
                            , "KeyMapInNoramalMode" : "FoxitKeymapInNornalMode"    }
    ,"typora.exe"          : {"Shortcut" : "!t"                                    }
    ,"code.exe"            : {"Shortcut" : "!v"                                    }
    ,"word.exe"            : {"Shortcut" : "!w"                                    }
    ,"xshell.exe"          : {"Shortcut" : "!x"                                    }
    ,"zotero.exe"          : {"Shortcut" : "!z"                                    }
    ,"msedge.exe"          : {"Shortcut" : "!+c"
                            , "DefaultControl" : "Chrome_RenderWidgetHostHWND1"    }
    ,"Everything.exe"      : {"Shortcut" : "!+e"                                   }
    ,"firefox.exe"         : {"Shortcut" : "!+f"                                   }
    ,"firefox.exe"         : {"Shortcut" : "!+o" 
                            , "ExePath" : torbrowserPath                           }
    ,"secUI.exe"           : {"Shortcut" : "!+s"                                   }
    ,"kwmusic.exe"         : {"Shortcut" : "!+u"                                   }
    ,"v2rayN.exe"          : {"Shortcut" : "!+v"                                   }
    ,"Excel.exe"           : {"Shortcut" : "!+x"                                   } }

global FoxitKeymapInNornalMode := { "EditKey" : { "t"  : {"Action":"{Alt}rd2", "help":"Text box"} }
    , "MoveKey" : { "j"  : {"Action":"{Down}"    , "help":""  }
        , "k"  : {"Action":"{Up}"      , "help":""                      }
        , "u"  : {"Action":"{PgUp}"    , "help":""                      }
        , "d"  : {"Action":"{PgDn}"    , "help":""                      }
        , "g"  : {"Action":"^{Home}"   , "help":""                      }
        , "+g" : {"Action":"^{End}"    , "help":""                      }
        , "-"  : {"Action":"^{-}"      , "help":"zoom in"               }
        , "="  : {"Action":"^{=}"      , "help":"zoom out"              }
        , "+j" : {"Action":"^+{Tab}"   , "help":"Navigate to Left tab"  }
        , "+k" : {"Action":"^{Tab}"    , "help":"Navigate to Right tab" }
        , "+h" : {"Action":"!{Left}"   , "help":"History previous"      }
        , "+l" : {"Action":"!{Right}"  , "help":"History next"          }
        , "h"  : {"Action":"+h"        , "help":"highlight"             }
        , "l"  : {"Action":"{Alt}re1f" , "help":"Pencil line"           }
        , "o"  : {"Action":"{Alt}re1a" , "help":"Rectangle"             }
        , "q"  : {"Action":"{Esc}"     , "help":""                      }
        , "s"  : {"Action":"+s"        , "help":"delete line"           }
        , "w"  : {"Action":"^u"        , "help":"underline"             } }
    , "CustomHandler" : "FoxitCustomKeymapHandler" }

FoxitCustomKeymapHandler(){

}

global ExplorerKeymapInNornalMode := { "MoveKey" : { "j" : {"Action":"{Down}", "help":"" }
        ,"k"     : {"Action":"{Up}"                              , "help":""                      }
        ,"h"     : {"Action":"!{Up}"                             , "help":"Up to Dir"             }
        ,"l"     : {"Action":"{Enter}"                           , "help":"Open"                  }
        ,"+h"    : {"Action":"!{Left}"                           , "help":"History previous"      }
        ,"+l"    : {"Action":"!{Right}"                          , "help":"History next"          }
        ,"g"     : {"Action":"{Home}"                            , "help":""                      }
        ,"+G"    : {"Action":"{End}"                             , "help":""                      }
        ,"+A"    : {"Action":"{Alt}hr"                           , "help":"Rename"                }
        ,"+D"    : {"Action":"{Alt}hd{Enter 2}"                  , "help":"Delete to recycle-bin" }
        ,"+Z"    : {"Action":"{Alt}sc"                           , "help":"Zip"                   }
        ,"+X"    : {"Action":"ExtractFile()"                     , "help":"Extract file"          }
        ,"y"     : {"Action":"{Alt}hco"                          , "help":"Copy file"             }
        ,"y & p" : {"Action":"{Alt}hcp"                          , "help":"Copy file path"        }
        ,"z & d" : {"Action":"ExplorerNavigate(""~\Downloads"")" , "help":"Go to Downloads"       }
        ,"z & h" : {"Action":"ExplorerNavigate(""~\"")"          , "help":"Go to Home"            }
        ,"z & n" : {"Action":"ExplorerNavigate(""" mynote """)"  , "help":"Go to note"            }
        ,"z & r" : {"Action":"ExplorerNavigate(""~\Desktop"")"   , "help":"Go to Desktop"         }
        ,"z & w" : {"Action":"ExplorerNavigate(""" WEIYUN """)"  , "help":"Go to Weiyun"          } } }

; global XshellKeymapInNormalMode := { "MoveKey" : { "^+r up" : "{alt}fr" } }

