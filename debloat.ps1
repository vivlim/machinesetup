git submodule init
git submodule update
cp $PSScriptRoot/CustomAppsList $PSScriptRoot/Win11Debloat/CustomAppsList
& $PSScriptRoot/Win11Debloat/Win11Debloat.ps1 -RemoveAppsCustom -DisableBing -DisableSuggestions -DisableLockscreenTips -RevertContextMenu -ShowHiddenFolders -ShowKnownFileExt -TaskbarAlignLeft -DisableWidgets -HideChat -Hide3dObjects 
