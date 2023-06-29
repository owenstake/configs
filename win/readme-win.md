
This scripts is for setup win system.

# Usage

```powershell
.\make-win.ps1 all     # compile
.\make-win.ps1 install # install to current system

.\make-win.ps1 clean     # clean compiled output
.\make-win.ps1 uninstall # uninstall
```

# wsl

```powershell
# install wsl2
wsl --install

# import vhdx ubt system
wsl --import-in-place ubt-test D:\xx.vhdx

# show ubt path
Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss" -Recurse
```

