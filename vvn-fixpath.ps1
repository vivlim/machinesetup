#Requires -RunAsAdministrator

echo "saving backups"
$systemPath = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine);
$systemPath > "backup-system-path-$([DateTime]::Now.ToString("yyyMMdd-hhmm")).txt"
$systemPath = $systemPath.Replace(";;", ";")

$userPath = [Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User);
$userPath > "backup-user-path-$([DateTime]::Now.ToString("yyyMMdd-hhmm")).txt"
$userPath = $userPath.Replace(";;", ";")

echo "writing to env variables"

[Environment]::SetEnvironmentVariable("PATH", $systemPath, [System.EnvironmentVariableTarget]::Machine);
[Environment]::SetEnvironmentVariable("PATH", $userPath, [System.EnvironmentVariableTarget]::User);