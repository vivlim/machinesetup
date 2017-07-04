if (!(Test-Path "c:\windows\system32\bash.exe"))
{
    #no wsl on this machine so just exit
    exit
}
if (!(Test-Path "$env:LOCALAPPDATA\wsltty\bin\mintty.exe")) {
    echo "Installing wlstty"
    wget "https://github.com/mintty/wsltty/releases/download/0.7.8.3/wsltty-0.7.8.3-install.exe" -OutFile "$env:TEMP\wslttyinstall.exe"
    . "$env:TEMP\wslttyinstall.exe"
}

# link minttyrc (theme)
if (!(Test-Path "$HOME\.minttyrc")) {
    New-Item -Path "$HOME\.minttyrc" -ItemType SymbolicLink -Value "$PSScriptRoot\wsltty\.minttyrc"
}
