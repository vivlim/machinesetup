﻿refreshenv

function Update-Vim-Plugins()
{
    git submodule init
    git submodule update
    nvim +PlugInstall +qall
    nvim +UpdateRemotePlugins +qall
}

echo "Setting up vim config."

if (Test-path $env:USERPROFILE/AppData/Local/nvim/init.vim)
{
    echo "vimfiles exists. updating it..."
    pushd $env:USERPROFILE/AppData/Local/nvim
    git pull origin master

    Update-Vim-Plugins

    popd
}
else
{
    echo "vimfiles doesn't exist. cloning from my github"
    pushd $env:USERPROFILE/AppData/Local/
    git clone git@github.com:vivvnlim/vimfiles.git nvim
    cd nvim
    git checkout master-neovim
    if (!(Test-path $env:USERPROFILE/AppData/Local/nvim/init.vim))
    {
        echo "cloning failed. falling back to https clone"
        popd
        pushd $env:USERPROFILE/AppData/Local/
        git clone https://github.com/vivvnlim/vimfiles.git nvim
        git checkout master-neovim
    }
    Update-Vim-Plugins

    popd
}

if (!(Get-Command "nvim" -ErrorAction SilentlyContinue))
{
    if (Test-Path "C:\tools\neovim\neovim\bin\nvim.exe"){
        echo "Adding neovim to path"
        [Environment]::SetEnvironmentVariable("Path", $Env:Path + ";C:\tools\neovim\neovim\bin\", "Machine")
        refreshenv
        $Env:Path = $Env:Path + ";C:\tools\neovim\neovim\bin\"
    }
}
