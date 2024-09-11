# Neovim config
## Install Neovim
Since we need `neovim >= 0.8`, some package manager(apt...) only have older version. So I recommand to download and install `neovim` manually. Here's the offical [instroduction](https://github.com/neovim/neovim/releases).
<br><br>
Here's a example to install `neovim` on Linux (`wsl` as well).  
I prefer use `Tarball` rather than `AppImage`, so I download file `nvim-linux64.tar.gz` (below any folders you want).  
Extract this `.tar` file : 
```
tar xzvf nvim-linux64.tar.gz
```
You will get a folder `./nvim-linux64/`.   
Then make `nvim` a global command:
```
sudo mv nvim-linux64 /usr/local/nvim
sudo ln -s /usr/local/nvim/bin/nvim /usr/bin/nvim
```
Then you can use `nvim` command globally.
<br><br>
After successfully install `neovim`, run command 
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ZhizhenZhou/dot-config/main/neovim/nvim_config.sh)"
```

And then restart your shell(`zsh`).  
## Install Nerd Font (if you have done this before, you can pass it.)
Enter https://www.nerdfonts.com/font-downloads, download a `Nerd Font`. (I'm using `Hack Nerd Font`.)  
## Install node.js (if you have done this before, you can pass it.)
Install `node.js` to make sure lsp work well.  
Follow the link https://nodejs.org/zh-cn/download/package-manager to install `node.js`. (I'm using `v20.17.0(LTS)`.)  
## import neovim config
make sure you have the path `~/.config/nvm/`, then 
```
git clone https://github.com/ZhizhenZhou/neovim-config.git $HOME/.config/nvim/
```
