# my config files

| 配置文件 | 插件管理工具                               | 套装                                                  | 个性化参考                                                   |
| -------- | ------------------------------------------ | ----------------------------------------------------- | ------------------------------------------------------------ |
| .zshrc   | [zplug](https://github.com/zplug/zplug)    | [oh-my-zsh](https://ohmyz.sh/)                        | [常用插件](https://www.zhihu.com/question/49284484)          |
| .tmux    | [tpm](https://github.com/tmux-plugins/tpm) | [oh-my-tmux](https://github.com/pangliang/oh-my-tmux) | 没啥插件好配置的，定时保存会话不好玩啊，但是能够保存会话布局而已，但是还是无法保存环境变量啊，意义不大。[resurrect](https://linuxtoy.org/archives/tmux-resurrect-and-continuum.html) - 关机保存会话（丢失环境变量） |
| .vimrc   | vim-plug                                   |                                                       | neovim - vscode-like - [benawad](https://gist.github.com/benawad/b768f5a5bbd92c8baabd363b7e79786f)           vim8 - c-style - [ma](https://github.com/ma6174/vim) |

## zsh

plugs - https://www.jianshu.com/p/a94e2c59f244

* zsh - autosuggestions
* zsh - syntax-highlighting
* z for path cd

# install

1. install oh-my-*
2. install depended software
3. install plugin manager
4. clone and cp configure files *.conf

```bash
git clone https://github.com/owenstake/configs.git
chmod +x ./bootstrap.sh
zsh ./bootstrap.sh
```

