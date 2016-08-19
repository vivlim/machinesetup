# check regkey to turn off scaling
$layerspath = "hklm:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers\"
# create it if it doesn't exist.
if(!(Test-Path $layerspath))
{
    echo "This machine doesn't have the AppCompatFlags\Layers key, creating it."
    New-Item -Path $layerspath -Force
}

$layers = Get-Item $layerspath

if ($layers.GetValueNames().Contains("c:\programdata\chocolatey\lib\emacs64\tools\emacs\bin\emacs.exe"))
{
    echo "This machine has the highdpi aware registry flags set on the emacs exes."
}
else
{
    echo "This machine doesn't have the highdpi aware registry flags set on the emacs exes, setting them..."
    $layers | New-ItemProperty -name "c:\programdata\chocolatey\lib\emacs64\tools\emacs\bin\emacs.exe" -value "~ HIGHDPIAWARE"
    $layers | New-ItemProperty -name "c:\programdata\chocolatey\bin\emacs.exe" -value "~ HIGHDPIAWARE"
    $layers | New-ItemProperty -name "c:\programdata\chocolatey\bin\runemacs.exe" -value "~ HIGHDPIAWARE"
}


# attempt to fix emacs.d/server identity. this probably needs more work.
$serverpath = "$env:USERPROFILE/.emacs.d/server"
if (Test-Path $serverpath)
{
    $user = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $acl = Get-ACL $serverpath
    $acl.SetOwner($user.User)
    Set-Acl -Path $serverpath -AclObject $acl
}
