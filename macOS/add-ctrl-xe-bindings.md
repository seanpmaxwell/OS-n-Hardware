## Add the `ctrl + x` + `ctrl + e` bindings to zsh for better multi-line commands

### Add the commands

Open the file `~/.zshrc` or create it: `nano ~/.zshrc`

Add the following lines:
```txt
autoload -Uz edit-command-line           
zle -N edit-command-line             
bindkey '^X^E' edit-command-line
```

Update the terminal session: `source ~/.zshrc`
