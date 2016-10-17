machinesetup
======
a collection of powershell scripts to install all the software I want on the machines I use.

setup (windows)
======
paste this into an admin powershell

    set-executionpolicy unrestricted
    wget https://raw.githubusercontent.com/vivvnlim/machinesetup/master/bootstrap-sup.ps1 -outfile $env:temp/bootstrap-sup.ps1
    invoke-expression $env:temp/bootstrap-sup.ps1
