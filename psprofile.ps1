if ($host.Name -eq "ConsoleHost"){
    $ps = $null
    try {
        # On Windows 10, PSReadLine ships with PowerShell
        $ps = [Microsoft.PowerShell.PSConsoleReadline]
    } catch [Exception] {
        # Otherwise, it can be installed from the PowerShell Gallery:
        # https://github.com/lzybkr/PSReadLine#installation
        Import-Module PSReadLine
        $ps = [PSConsoleUtilities.PSConsoleReadLine]
    }

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

    echo "Profile loaded."
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

function Reset-EmacsServer (){
    if (Get-ProcessRunning "emacs")
    {
        Write-Host "Can't reset emacs server while emacs is running" -ForegroundColor Red
        return
    }
    rm ~\.emacs.d\server\server*
}

# If emacs is on this machine add an alias to use emacsclient
if (Get-Command "emacsclient" -ErrorAction SilentlyContinue)
{
    function e ($fileName)
    {
        if ($fileName -eq $null)
        {
            Write-Host "Trying to raise the window."
            emacsclient -n -e "(raise-frame)"
        }
        else
        {
            emacsclient -n "$fileName" --alternate-editor runemacs
        }

        if ($LASTEXITCODE -ne 0)
        {
            Write-Host "Looks like that didn't work. Try Reset-EmacsServer?" -ForegroundColor Yellow
        }
    }

    if (!(Get-ProcessRunning "emacs"))
    {
        Reset-EmacsServer
    }
}
