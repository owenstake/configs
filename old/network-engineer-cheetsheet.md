



## network manipulation

ebtable
iptable
ip a

### ethtool - nic query or control network driver and hardware settings
```bash
ethtool -n  ens8f0 rx-flow-hash udp4   # show hash policy
```

### nc
[linux网络、存储性能测试](https://blog.csdn.net/qq_20679687/article/details/127652528)

### http method
[curl 构造 PUT/POST类型的http请求](https://blog.csdn.net/qq_20679687/article/details/126834095)
curl -X POST 'localhost:5000/api/post/json' -H 'Content-Type:application/json' -d '{"name":"guo","score":123}'

## server manipulation

### server performance




### process performance
[dpdk-lcore-mask 对 handler线程cpu亲和性的影响](https://blog.csdn.net/qq_20679687/article/details/126499558)
pidstat -t -p $PID # show running cpu

[如何制造更多的major page fault](https://blog.csdn.net/qq_20679687/article/details/126547491)
perf stat -e cpu-clock,page-faults,minor-faults,major-faults -I 1000 $CMD

### process performance monitor
sar

## ovs debug
ovs-vsctl show
ovs-vsctl add-br br-int
ovs-vsctl add-br br-int veth0

ovs-ofctl add-flow br-int
ovs-ofctl dump-flows

ovs-appctl list-commands
ovs-appctl dpif/dump-flows



