# bash_aliases

These are the Bash Aliases that I found very helpful and the `.bash_aliases` file is something that I include in all of my Linux environments

To add the `.bash_aliases` file in your .bashrc or .zshrc file use the below bash script:

```
if [[ -e $HOME/.bash_aliases ]]; then
  source $HOME/.bash_aliases
fi
```

You can also add command to neofetch for every terminal window:
```
neofetch | lolcat
```


Be careful with the $HOME variable as it is different for different users and may not work for certain users in the system (especially for the root user).

Packages to install on fresh releases:

**For all distros**
```
neofetch
lolcat
```

**For Arch-based Distros**
```
yay
sweet-theme-full-git
candy-icons-git
octopi
exa
variety
```
