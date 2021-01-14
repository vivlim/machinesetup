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
            $_ | Add-Member NoteProperty FileVersion ($_.VersionInfo.FileVersion.ToString())
            $_ | Add-Member NoteProperty AssemblyVersion (
                [Reflection.AssemblyName]::GetAssemblyName($_.FullName).Version.ToString()
            )
            $_ | Add-Member NoteProperty AssemblyFullName (
                [Reflection.AssemblyName]::GetAssemblyName($_.FullName).FullName
            )
            $_ | Add-Member NoteProperty AssemblyPublicKey (
                ([Reflection.AssemblyName]::GetAssemblyName($_.FullName).GetPublicKey() | ForEach-Object ToString X2) -join ''
            )
        } catch {}
        $_
    } |
    Select-Object Name,FullName,FileVersion,AssemblyVersion,AssemblyFullName,AssemblyPublicKey | ConvertTo-Json

if ($wait) {
    Read-Host
}
