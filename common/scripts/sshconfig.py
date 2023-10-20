#!/usr/bin/env python3
from __future__ import print_function
from sshconf import SshConfig, read_ssh_config
# from os.path import expanduser
import netifaces
import tempfile

import sys
import os
import json
from pathlib import Path

helpMsg="""
This program generates sshconfig file based on proxy.json.
Usage:
  argv[1]: proxy config json file
  argv[2]: ssh config file
"""

if len(sys.argv) < 3:
    print(helpMsg)
    exit(-1)

proxyJsonFile=sys.argv[1]
if not os.path.exists(proxyJsonFile):
    print(f"{proxyJsonFile} is no exists!" )
    exit(-1)

# print(f"Proxy Config file is {sys.argv[1]}" )
sshConfigFile=sys.argv[2]

# Get empty config
file = tempfile.NamedTemporaryFile()
sshConfig = read_ssh_config(file.name)

gateways = netifaces.gateways()
default_gateway = gateways['default'][netifaces.AF_INET][0]

# Opening JSON file
with open(proxyJsonFile) as f:
    proxyConfig = json.load(f)
    for key, value in proxyConfig.items():
        host = value["ProxyIp"].replace(";", " ").strip()
        k = {
                'ProxyCommand': "nc -X 5 -x {}:{} %h %p".format(default_gateway,value["Port"]), 
                "RemoteForward localhost:3322 localhost:22" : '',
                "RemoteForward localhost:10809 {}:10809".format(default_gateway) : '',
                "UserKnownHostsFile=/dev/null":'',
                "StrictHostKeyChecking=no":'',
                }
        sshConfig.add(host,**k)

# mkdir -p and touch
dirname = os.path.dirname(sshConfigFile)
Path(dirname).mkdir(parents=True, exist_ok=True)
Path(sshConfigFile).touch(exist_ok=True)

# ssh config write to file
sshConfig.write(sshConfigFile)
