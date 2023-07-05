#!/usr/bin/env python3
from __future__ import print_function
from sshconf import read_ssh_config
from os.path import expanduser
import netifaces

import sys
import os
import json
from pathlib import Path

proxyJsonFile=sys.argv[1]

sshConfigFile=expanduser("~/.ssh/config")

# mkdir -p
dirname = os.path.dirname(sshConfigFile)
Path(dirname).mkdir(parents=True, exist_ok=True)
# touch
Path(sshConfigFile).touch(exist_ok=True)

sshConfig = read_ssh_config(sshConfigFile)

gateways = netifaces.gateways()
default_gateway = gateways['default'][netifaces.AF_INET][0]

# Opening JSON file
f = open(proxyJsonFile)
proxyConfig = json.load(f)
for key,value in proxyConfig.items():
    host = value["ProxyIp"].replace(";"," ")
    if host in sshConfig.hosts():
        print("Found {} then update.".format(value["ProxyIp"]))
        pcmd = "nc -X 5 -x {}:{} %h %p".format(default_gateway,value["Port"])
        sshConfig.set(host, ProxyCommand=pcmd)
    else:
        print("No found {} then add it.".format(value["ProxyIp"]))
        pcmd = "nc -X 5 -x {}:{} %h %p".format(default_gateway,value["Port"])
        sshConfig.add(host,ProxyCommand=pcmd)

sshConfig.write(sshConfigFile)

