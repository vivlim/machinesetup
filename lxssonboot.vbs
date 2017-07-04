set ws=wscript.createobject("wscript.shell")

' start fish
ws.run "C:\Windows\System32\bash.exe -c 'cd ~; SHELL=/usr/bin/zsh tmux new-session -d'",0

' start emacs as daemon
ws.run "C:\Windows\System32\bash.exe -c 'SHELL=/usr/bin/zsh emacs --daemon'",0

' start sshd
ws.run "C:\Windows\System32\bash.exe -c 'sudo /usr/sbin/sshd -D'",0
