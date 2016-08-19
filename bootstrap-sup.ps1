if (!(Get-Command "choco.exe" -ErrorAction SilentlyContinue))
{
    echo "Installing Chocolatey"
    iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
    refreshenv
}

if (!(Get-Command "git.exe" -ErrorAction SilentlyContinue))
{
    choco upgrade git -y -params '"/GitAndUnixToolsOnPath"'
    refreshenv
}

if (!(test-path $env:USERPROFILE\machinesetup\))
{
    pushd $env:USERPROFILE
    git clone git@github.com:mjlim/machinesetup.git
    [Environment]::SetEnvironmentVariable("Path", $Env:Path + ";$env:USERPROFILE\machinesetup\", "Machine")
    popd
    refreshenv
}
else
{
    echo "not sure what to do, \machinesetup\ already exists."
}
