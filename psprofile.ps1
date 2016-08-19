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
