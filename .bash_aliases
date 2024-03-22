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
melddiff() {
	meld <(eval "$1") <(eval "$2")
}
vdiff() {
	vimdiff <(eval "$1") <(eval "$2")
}
