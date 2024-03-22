# bash_aliases

These are the Bash Aliases that I found very helpful and the .bash_aliases file is something that I include in all of my Linux environments

To add the .bash_aliases file in your .bashrc or .zshrc file use the below bash script:

if [[ -e $HOME/.bash_aliases ]]; then
  source $HOME/.bash_aliases
fi

Be careful with the $HOME variable as it is different for different users and may not work for certain users in the system (especially for the root user).
