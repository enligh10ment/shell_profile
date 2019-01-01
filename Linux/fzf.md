
```
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

edit your .zshrc file:
  Go to the buttom of the file and you should see ```[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh```
  just add this line below of it: ```export FZF_DEFAULT_OPS="--extended"```
  
  reload your source file: ```source ~/.zshrc```
  
  Key mappings: 
  CTRL + r (fuzzy find through yuor command history)
  CTRL + t (fuzzy find through the current directory)
  If you want to work with multiple files type you command >> CTRL + t >> TAB on every selected file >> hit ENTER
  
  using the extention that we added in our .zshrc file: CTRL + t >> .css$ (it will list all the files that ends with .css)
  
  Another great usecase: e.d ```cd** + TAB >> select your needed file (it will autocomplete it)```
  
  
  
  
  
  
