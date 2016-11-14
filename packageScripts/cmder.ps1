$conemuDir = "C:\tools\cmder\vendor\conemu-maximus5\"
$localScriptPath = "$conemuDir\ConEmu.xml"
$gitScriptPath = "$PSScriptRoot\cmder\ConEmu.xml"

function Patch-ConEmuConfig()
{
    $date = get-date -Format "yyyyMMdd_h-m-s"
    $backupLocalScriptPath = "$PSScriptRoot\cmder\ConEmu-$date.xml"
    mv $localScriptPath $backupLocalScriptPath
    cp $gitScriptPath $localScriptPath

    [xml]$oldLocalConfig = Get-Content -Path $backupLocalScriptPath
    [xml]$newLocalConfig = Get-Content -Path $localScriptPath

    $oldTasksUnimported = (Select-Xml -Xml $oldLocalConfig -XPath "/key[@name='Software']/key[@name='ConEmu']/key[@name='.Vanilla']/key[@name='Tasks']").Node
    if ($oldTasksUnimported -eq $null)
    {
      echo "Local ConEmu.xml is missing Tasks, using version from git instead."
      return
    }

    $oldTasks = $newLocalConfig.ImportNode($oldTasksUnimported, $true)
    $newTasks = (Select-Xml -Xml $newLocalConfig -XPath "/key[@name='Software']/key[@name='ConEmu']/key[@name='.Vanilla']/key[@name='Tasks']").Node
    $newTasksParent = (Select-Xml -Xml $newLocalConfig -XPath "/key[@name='Software']/key[@name='ConEmu']/key[@name='.Vanilla']").Node

    $newTasksParent.ReplaceChild($oldTasks, $newTasks) # copy oldtasks into newconfig
    $newLocalConfig.Save($localScriptPath) # write to file
}

if (Test-Path $localScriptPath)
{
    echo "Patching conemu config with changes from git, excluding any tasks defined on this machine. $localScriptPath"
    Patch-ConEmuConfig
}
else
{
    echo "No conemu config currently. Copying conemu config from git to $conemuDir"
    cp $gitScriptPath $localScriptPath
}
