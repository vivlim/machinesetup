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
        $Env:Path = $Env:Path + ";C:\Program Files\Git\cmd\"
    }
    else
    {
        echo "WARNING: Couldn't find Git in the path and also in C:\Program Files\Git\cmd"
    }
}

if (!(test-path "$env:USERPROFILE\machinesetup\"))
{
    pushd $env:USERPROFILE
    git clone git@github.com:vivvnlim/machinesetup.git
    if (!Test-Path "$env:USERPROFILE/machinesetup/"))
    {
        echo "cloning over ssh failed, falling back to https clone."
        git clone https://github.com/vivvnlim/machinesetup.git
    }
    [Environment]::SetEnvironmentVariable("Path", $Env:Path + ";$env:USERPROFILE\machinesetup\", "Machine")
    popd
    refreshenv
    $Env:Path = $Env:Path + ";$env:USERPROFILE\machinesetup\"
}
else
{
    echo "not sure what to do, \machinesetup\ already exists."
}
