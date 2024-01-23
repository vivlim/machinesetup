if ($host.Name -eq "ConsoleHost"){
    $ps = $null
    try {
        # On Windows 10, PSReadLine ships with PowerShell
        $ps = [Microsoft.PowerShell.PSConsoleReadline]
    } catch [Exception] {
        # Otherwise, it can be installed from the PowerShell Gallery:
        # https://github.com/lzybkr/PSReadLine#installation
        #Import-Module PSReadLine
        #$ps = [PSConsoleUtilities.PSConsoleReadLine]
        exit
    }

    try {
        Import-Module ZLocation
        Write-Host -Foreground Green "`n[ZLocation] knows about $((Get-ZLocation).Keys.Count) locations.`n"
    } catch [Exception] {
        Install-Module ZLocation -Scope CurrentUser
        Import-Module ZLocation
        Write-Host "ZLocation installed. You may need to edit $Profile to init *after* starship if present"
    }

    $version = Get-Module PSReadLine | Select-Object -Property Version

    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadlineKeyHandler -Key Tab -Function Complete

    Set-PSReadlineKeyHandler `
      -Chord 'Ctrl+s' `
      -BriefDescription "InsertHeatseekerPathInCommandLine" `
      -LongDescription "Run Heatseeker in the PWD, appending any selected paths to the current command" `
      -ScriptBlock {
          $choices = $(Get-ChildItem -Name -Attributes !D -Recurse | hs)
          $ps::Insert($choices -join " ")
      }

    #echo "Profile loaded."
}

function which ($commandName) {
    $command = Get-Command $commandName -ErrorAction SilentlyContinue
    if (!$command)
    {
        Write-Host "Couldn't find a command named $commandName." -ForegroundColor Red
        return
    }
    return $command.Source
}

function Get-ProcessRunning ($processName){
    return (Get-Process | Where-Object ProcessName -eq "$processName") -ne $null 
}

function Set-Title ($newTitle){
    $host.UI.RawUI.WindowTitle = $newTitle
}


# also bind ctrl+n to cancel lines, workaround for https://github.com/neovim/neovim/issues/13350
Set-PSReadLineKeyHandler -Chord Ctrl+n -Function CopyOrCancelLine
