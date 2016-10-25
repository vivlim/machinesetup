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

if (!(Get-Command "git.exe" -ErrorAction SilentlyContinue))
{
    if (Test-Path "C:\Program Files\Git\cmd\git.exe")
    {
        echo "Adding git to path"
        [Environment]::SetEnvironmentVariable("Path", $Env:Path + ";C:\Program Files\Git\cmd\", "Machine")
        refreshenv
    }
    else
    {
        echo "WARNING: Couldn't find Git in the path and also in C:\Program Files\Git\cmd"
    }
}

if (!(test-path $env:USERPROFILE\machinesetup\))
{
    pushd $env:USERPROFILE
    git clone git@github.com:vivvnlim/machinesetup.git
    [Environment]::SetEnvironmentVariable("Path", $Env:Path + ";$env:USERPROFILE\machinesetup\", "Machine")
    popd
    refreshenv
}
else
{
    echo "not sure what to do, \machinesetup\ already exists."
}
