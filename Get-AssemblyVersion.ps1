param(
    [Parameter(Mandatory=$true)]
    $assemblies,
    [switch] $wait
)

# from StackOverflow https://stackoverflow.com/a/3269781
Get-ChildItem $assemblies |
    ForEach-Object {
        Write-Host $_.FullName
        try {
            $_ | Add-Member NoteProperty FileVersion ($_.VersionInfo.FileVersion)
            $_ | Add-Member NoteProperty AssemblyVersion (
                [Reflection.AssemblyName]::GetAssemblyName($_.FullName).Version
            )
        } catch {}
        $_
    } |
    Select-Object Name,FileVersion,AssemblyVersion | Write-Host

if ($wait) {
    Read-Host
}