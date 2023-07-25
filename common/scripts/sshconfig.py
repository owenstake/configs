#!/usr/bin/env python3
from __future__ import print_function
from sshconf import read_ssh_config
from os.path import expanduser
import netifaces

import sys
import os
import json
from pathlib import Path

if len(sys.argv) >= 2:
    proxyJsonFile=sys.argv[1]
    if os.path.exists(proxyJsonFile):
        print(f"Config file is {sys.argv[1]}" )
    else:
        print(f"{proxyJsonFile} is no exists!" )
        exit(-1)
else:
    print("Please specify a proxy config json file.")
    exit(-1)

# Opening JSON file
sshConfigFile=expanduser("~/.ssh/config")

# mkdir -p
dirname = os.path.dirname(sshConfigFile)
Path(dirname).mkdir(parents=True, exist_ok=True)
# touch
Path(sshConfigFile).touch(exist_ok=True)

sshConfig = read_ssh_config(sshConfigFile)

gateways = netifaces.gateways()
default_gateway = gateways['default'][netifaces.AF_INET][0]

with open(proxyJsonFile) as f:
    proxyConfig = json.load(f)
    for key, value in proxyConfig.items():
        host = value["ProxyIp"].replace(";", " ").strip()
        pcmd = "nc -X 5 -x {}:{} %h %p".format(default_gateway,value["Port"])
        rfwd1 = "localhost:3322 localhost:22"
        rfwd2 = "RemoteForward localhost:10809 {}:10809".format(default_gateway)
        k = {
                'ProxyCommand': "nc -X 5 -x {}:{} %h %p".format(default_gateway,value["Port"]), 
                "RemoteForward localhost:3322 localhost:22" : '',
                "RemoteForward localhost:10809 {}:10809".format(default_gateway) : '',
                }
        if host in sshConfig.hosts():
            print("Found {} then update.".format(host))
            sshConfig.remove(host)
            sshConfig.add(host,**k)
            # sshConfig.set(host, ProxyCommand=pcmd)
            # sshConfig.set(host, RemoteForward=rfwd1)
            # sshConfig.set(host, **{rfwd2: ''})
        else:
            print("No found {} then add it.".format(host))
            sshConfig.add(host,**k)
            # sshConfig.add(host,ProxyCommand=pcmd)
            # sshConfig.add(host,ProxyCommand=pcmd)
            # sshConfig.add(host,RemoteForward=rfwd1)
            # sshConfig.add(host, **{rfwd2: ''})

        # for key in sshConfig.hosts():
        #     print(key)

sshConfig.write(sshConfigFile)
