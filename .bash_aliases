alias cm='catkin_make'
alias la='ls -al'
alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias np='nano -w PKGBUILD'
alias ls='ls --color=auto'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
alias tree='tree -L 2'
alias fn='functions'
alias dps='docker ps -a'
alias dil='docker image ls'
alias dis='docker image ls'
alias to_clip='xclip -sel clip'
alias toclip='xclip -sel clip'
alias qgc='./QGroundControl.AppImage'
alias QGC='./QGroundControl.AppImage'
alias pingg='ping www.google.com'
alias ping8='ping 8.8.8.8'
alias git_key_refresh='eval $(ssh-agent -s) && ssh-add ~/.ssh/*'
alias git_ssh_refresh='eval $(ssh-agent -s) && ssh-add ~/.ssh/*'
alias ssh_git_refresh='eval $(ssh-agent -s) && ssh-add ~/.ssh/*'
alias key_refresh_git='eval $(ssh-agent -s) && ssh-add ~/.ssh/*'
alias key_git_refresh='eval $(ssh-agent -s) && ssh-add ~/.ssh/*'
alias git_key_check='ssh -T git@github.com'
alias check_git_key='ssh -T git@github.com'
melddiff() {
	meld <(eval "$1") <(eval "$2")
}
vdiff() {
	vimdiff <(eval "$1") <(eval "$2")
}
