# machine State UPdater
# 2016 vivvnlim

param (
    [ValidateSet("UpdateSelf", "UpdateScoop", "SetExcluded", "UpdateSelfAndScoop")] [String] $action="UpdateSelfAndScoop",
    [switch] $verbose,
    [switch] $updateInstalledPackages
)

$STATEFILE_PATH = "$PSScriptRoot\sup-state.json"
$PACKAGES_PATH = "$PSScriptRoot\packages.csv"

$STATE_FIELDS = "ExcludedPackages", "LastUpdated"

function Debug-Print ($s)
{
    if ($verbose) { echo $s }
}

function State-Ensure-Schema()
{
    ForEach ($field in $STATE_FIELDS)
    {
        $member = $script:state | select -exp $field -ErrorAction SilentlyContinue
        if (!$member)
        {
            $script:state | Add-Member -MemberType NoteProperty -Name $field -Value @() -Force
        }
    }
}

function Load-State()
{
    if (Test-Path $STATEFILE_PATH)
    {
        $script:state = Get-Content $STATEFILE_PATH | ConvertFrom-Json
    }
    else
    {
        echo "State file doesn't exist, this hasn't been run on this machine before."
        $script:state = New-Object -TypeName PSObject
    }

    State-Ensure-Schema
}

function Save-State()
{
    $script:state | ConvertTo-Json > $STATEFILE_PATH
}

function Load-Packages()
{
    if (Test-Path $PACKAGES_PATH)
    {
        $script:packages = Get-Content $PACKAGES_PATH | ConvertFrom-Csv |
          select packagename, category, params,
          @{n='excluded'; e={[bool]($script:state.ExcludedPackages -contains $_.packagename)}}
    }
    else
    {
        echo "Package csv doesn't exist, this is a fatal error!"
        Exit 1
    }
}

function Update-Package($package)
{
    Debug-Print "Updating package $($package.packagename)"

    # If the package name ends with .ps1 then just run the script, don't bother looking for a package
    if ($package.packagename -match '\.ps1')
    {
        Debug-Print "$($package.packagename) ends with .ps1, so skipping scoop and just running the script"
        # replace packagename
        $package.packagename = ($package.packagename -replace '\.ps1', '')
        Update-Package-Run-Script $package
        return
    }

    $packageIsInstalled = scoop list $($package.packagename)
    $packageIsExcluded = $script:state.ExcludedPackages -contains $package.packagename
    if ($packageIsInstalled -ne $null -and $packageIsExcluded)
    {
        Debug-Print "Need to remove package $($package.packagename) since it is installed, but on the exclusion list."
        scoop uninstall $package.packagename
    }
    if (($packageIsInstalled -eq $null) -and !$packageIsExcluded)
    {
        Debug-Print "Package $($package.packagename) will be installed"
        scoop install $package.packagename
        Update-Package-Run-Script $package "-onInstall"
    }
    elseif (($packageIsInstalled -ne $null -and $updateInstalledPackages) -and !$packageIsExcluded)
    {
        Debug-Print "Package $($package.packagename) will be upgraded"
        scoop update $package.packagename
        Update-Package-Run-Script $package "-onInstall"
    }

    Update-Package-Run-Script $package
}

function Update-Package-Run-Script($package, $suffix = "")
{
    $scriptPath = "$PSScriptRoot\packageScripts\$($package.packagename)$suffix.ps1"
    Debug-Print "Looking for an update script in $scriptPath"
    if (Test-Path $scriptPath)
    {
        Debug-Print "Found a script, running it."
        . $scriptPath
    }
}

Load-State
Load-Packages

switch($action)
{
    "UpdateSelfAndScoop"
    {
        Invoke-Expression "$PSScriptRoot\sup.ps1 UpdateSelf"
        if ($LASTEXITCODE -eq 0)
        {
            Invoke-Expression "$PSScriptRoot\sup.ps1 UpdateScoop"
        }
        else
        {
            echo "Not proceeding with scoop update since UpdateSelf failed."
        }
    }
    "UpdateSelf"
    {
        pushd $PSScriptRoot
        git pull
        $gitExitCode = $LASTEXITCODE
        popd

        if ($gitExitCode -ne 0)
        {
            Save-State
            echo "Git encountered an error, please resolve before updating again."
            Exit 1
        }
    }

    "UpdateScoop"
    {
        ForEach ($package in $script:packages)
        {
            Update-Package $package
        }

        $script:state.LastUpdated = Get-Date -UFormat "%s"
    }
    "SetExcluded"
    {
        if ($script:state.ExcludedPackages -eq $null)
        {
            $script:state.ExcludedPackages = @()
        }
        [System.Collections.ArrayList]$exclusionList = $script:state.ExcludedPackages
        $selectedPackages = $script:packages | Out-GridView -passthru -Title "Select packages to toggle whether they are excluded on this machine."
        ForEach ($package in $selectedPackages)
        {
            if ($exclusionList -contains $package.packageName)
            {
                $exclusionList.Remove($package.packageName)
            }
            else
            {
                $exclusionList.Add($package.packageName)
            }
        }

        # dedupe & write back
        $script:state.ExcludedPackages = @($exclusionList | Select -uniq)
    }
}

Save-State
