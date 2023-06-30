#!/usr/bin/env python3
from __future__ import print_function
from sshconf import read_ssh_config
from os.path import expanduser

import json
import os
from os import environ
from pathlib import Path

sshConfigFile=expanduser("~/.ssh/config")
Path(sshConfigFile).touch(exist_ok=True)

sshConfig = read_ssh_config(sshConfigFile)

if environ.get('WINIP') is not None:
    winip = os.getenv("WINIP", default=None)
    print(f"Env WINIP is {winip}")
else:
    print("Env WINIP no found!")
    exit(-1)

# Opening JSON file
f = open('/mnt/d/.dotfiles/etc/common/proxy.json')
proxyConfig = json.load(f)
for key,value in proxyConfig.items():
    host = value["ProxyIp"].replace(";"," ")
    if host in sshConfig.hosts():
        print("Found {} then update.".format(value["ProxyIp"]))
        pcmd = "nc -X 5 -x {}:{} %h %p".format(winip,value["Port"])
        sshConfig.set(host, ProxyCommand=pcmd)
    else:
        print("No found {} then add it.".format(value["ProxyIp"]))
        pcmd = "nc -X 5 -x {}:{} %h %p".format(winip,value["Port"])
        sshConfig.add(host,ProxyCommand=pcmd)

sshConfig.write(sshConfigFile)

# returns JSON object as
# a dictionary

# print("owen host", c.host("owen.com"))  # print the settings

# assuming you have a host "svu"
# print("svu host", c.host("svu"))  # print the settings
# c.set("svu", Hostname="ssh.svu.local", Port=1234)
# print("svu host now", c.host("svu"))
# c.unset("svu", "port")
# print("svu host now", c.host("svu"))

# c.add("newsvu", Hostname="ssh-new.svu.local", Port=22, User="stud1234")
# print("newsvu", c.host("newsvu"))

# c.rename("newsvu", "svu-new")
# print("svu-new", c.host("svu-new"))

# # overwrite existing file(s)
# c.save()

# # write all to a new file
# c.write(expanduser("~/.ssh/newconfig"))

# # creating a new config file.
# c2 = empty_ssh_config_file()
# c2.add("svu", Hostname="ssh.svu.local", User="teachmca", Port=22)
# c2.write("newconfig")

# c2.remove("svu")  # remove
