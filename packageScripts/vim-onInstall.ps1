refreshenv

function Update-Vim-Plugins()
{
    git submodule init
    git submodule update
    vim +PluginInstall +qall
}

echo "Setting up vim config."

if (Test-path $env:USERPROFILE/vimfiles/)
{
    echo "vimfiles exists. updating it..."
    pushd $env:USERPROFILE/vimfiles
    git pull origin master

    Update-Vim-Plugins

    popd
}
else
{
    echo "vimfiles doesn't exist. cloning from my github"
    pushd $env:USERPROFILE
    git clone git@github.com:vivvnlim/vimfiles.git
    if (!(Test-path $env:USERPROFILE/vimfiles/))
    {
        echo "cloning failed. falling back to https clone"
        git clone https://github.com/vivvnlim/vimfiles.git
    }
    Update-Vim-Plugins

    popd
}
