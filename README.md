# my config files

| 配置文件 | 插件管理工具                               | 套装                                                  | 个性化参考                                                   |
| -------- | ------------------------------------------ | ----------------------------------------------------- | ------------------------------------------------------------ |
| .zshrc   | [zplug](https://github.com/zplug/zplug)    | [oh-my-zsh](https://ohmyz.sh/)                        | [常用插件](https://www.zhihu.com/question/49284484)          |
| .tmux    | [tpm](https://github.com/tmux-plugins/tpm) | [oh-my-tmux](https://github.com/pangliang/oh-my-tmux) | 没啥插件好配置的，定时保存会话不好玩啊，但是能够保存会话布局而已，但是还是无法保存环境变量啊，意义不大。[resurrect and continuum](https://linuxtoy.org/archives/tmux-resurrect-and-continuum.html) - 关机保存会话（丢失环境变量） |
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

# v2ray terminal proxy

## Reference

* [Ubuntu中v2ray客户端配置实例](https://unixetc.com/post/v2ray-client-configuration-example-in-ubuntu/)
* 原理解释 - [软件_ubuntu(linux)代理神器v2ray和Qv2ray](http://hexo.yuanjh.cn/hexo/353f38a3/)
* ProxyChains -  [ubuntu下终端代理方法](https://www.cnblogs.com/guguobao/p/8878109.html)

## Step

1. install v2ray linux client

```zsh
install - bash <(curl -L -s https://install.direct/go.sh)
```

2. v2ray config - /etc/v2ray/config.json <- from gui config **[v2rayL](https://github.com/jiangxufeng/v2rayL)** 
3. v2ray client start

```zsh
service v2ray stop
service v2ray start
service v2ray restart
service v2ray status
```

4. http proxy config - 注意是小写

   ```zsh
   export proxy="socks5://127.0.0.1:1080"   # or export proxy="http://127.0.0.1:1081"
   export http_proxy=$proxy
   export https_proxy=$proxy
   export ftp_proxy=$proxy
   export no_proxy="localhost, 127.0.0.1, ::1"
   # or 
   # export all_proxy="socks5://127.0.0.1:1080"
   ```

5. test for net

   ```zsh
   netstat -apn | grep v2ray	# local port info 
   curl www.google.com			# test for connectivity
   curl cip.cc					# look proxy info
   ```

6. ProxyChains 

  ```zsh
  sudo apt-get install proxychains
  sudo vim /etc/proxychains.conf   <=  socks5    127.0.0.1    1081
  proxychains curl www.google.com
      ```

      



