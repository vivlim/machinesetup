param (
    [Parameter(Mandatory=$true)][string]$pathToAppend
)

if(!(Test-Path $pathToAppend -PathType Container)) { 
    write-host "The passed path $pathToAppend doesn't seem to be a folder."
    exit 1
}

echo "saving backups"
$userPath = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User);
$userPath > "backup-user-path-$([DateTime]::Now.ToString("yyyMMdd-hhmm")).txt"
$userPath = "$userPath;$pathToAppend"

echo "writing to env variables"
[Environment]::SetEnvironmentVariable("PATH", $userPath, [System.EnvironmentVariableTarget]::User);