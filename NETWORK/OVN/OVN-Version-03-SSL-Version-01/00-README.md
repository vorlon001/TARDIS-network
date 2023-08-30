### Create 4 vm ubuntu 22.04. create vm https://github.com/vorlon001/libvirt-home-labs/tree/v2
- network one: Virtio network device
- network two: e1000
- network three: e1000
- network four: e1000
- all network attach to switch ovs, mode trunk

### Network VM Ubuntu 22.04LTS


```

      node3 (Gateway, 192.168.203.3:VLAN800, UBUNTU 22.04LTS)
                          |
                          |
                          |                                 node3 (FRRouting, BGP, Gateway, 192.168.203.150:VLAN800, UBUNTU 22.04LTS)
                          |                                                       |
                          |                                                       |
                          |                                                       |
                          |                                                       |
                          --------------- VLAN800 ---------------------------------
                                                       |
                                                       |
                                                       |
                                                       |
                                     node180 (VTEP-VPP, 192.168.203.180:VLAN800, UBUNTU 22.04LTS)
                                                       |
                                                       |
                                                       |
                                                       |
                                             --------------------------(VLAN200)---------------------------------------------
                                             |                                                          |                   |
                                             |                                                          |                   |
                                             |                                                          |                   |
                                             |                                                          |                   |
                                             |                                                          |                   |
   node170 (OVN-CENTRAL,OVS, 192.168.200.170:VLAN200, UBUNTU 22.04LTS)                                  |                   |
                                                                                                        |                   |
                                                                                                        |                   |
                                              node170 (OVN-CENTRAL,OVS, 192.168.200.170:VLAN200, UBUNTU 22.04LTS)           |
                                                                                                                            |
                                                                                                                            |
                                                                   node170 (OVN-CENTRAL,OVS,192.168.200.170:VLAN200, UBUNTU 22.04LTS)


```

```

# not work

# ERROR northd not activate SSL

#   /root/ovn/log/ovn-northd.log
2023-05-30T16:08:35.404Z|00596|stream_ssl|ERR|Private key must be configured to use SSL
2023-05-30T16:08:35.404Z|00597|stream_ssl|ERR|Certificate must be configured to use SSL
2023-05-30T16:08:43.413Z|00598|stream_ssl|ERR|Private key must be configured to use SSL
2023-05-30T16:08:43.413Z|00599|stream_ssl|ERR|Certificate must be configured to use SSL
2023-05-30T16:08:43.413Z|00600|stream_ssl|ERR|Private key must be configured to use SSL
2023-05-30T16:08:43.413Z|00601|stream_ssl|ERR|Certificate must be configured to use SSL
2023-05-30T16:08:51.421Z|00602|stream_ssl|ERR|Private key must be configured to use SSL
2023-05-30T16:08:51.422Z|00603|stream_ssl|ERR|Certificate must be configured to use SSL
2023-05-30T16:08:51.422Z|00604|stream_ssl|ERR|Private key must be configured to use SSL
2023-05-30T16:08:51.422Z|00605|stream_ssl|ERR|Certificate must be configured to use SSL
2023-05-30T16:08:59.429Z|00606|stream_ssl|ERR|Private key must be configured to use SSL
2023-05-30T16:08:59.429Z|00607|stream_ssl|ERR|Certificate must be configured to use SSL
2023-05-30T16:08:59.429Z|00608|stream_ssl|ERR|Private key must be configured to use SSL
2023-05-30T16:08:59.430Z|00609|stream_ssl|ERR|Certificate must be configured to use SSL
2023-05-30T16:09:07.436Z|00610|stream_ssl|ERR|Private key must be configured to use SSL
2023-05-30T16:09:07.436Z|00611|stream_ssl|ERR|Certificate must be configured to use SSL
2023-05-30T16:09:07.436Z|00612|stream_ssl|ERR|Private key must be configured to use SSL
2023-05-30T16:09:07.437Z|00613|stream_ssl|ERR|Certificate must be configured to use SSL
2023-05-30T16:09:15.440Z|00614|stream_ssl|ERR|Private key must be configured to use SSL
2023-05-30T16:09:15.440Z|00615|stream_ssl|ERR|Certificate must be configured to use SSL
2023-05-30T16:09:15.440Z|00616|stream_ssl|ERR|Private key must be configured to use SSL
2023-05-30T16:09:15.440Z|00617|stream_ssl|ERR|Certificate must be configured to use SSL

#  /root/ovn/log/ovsdb-server-nb.log
2023-05-30T16:07:55.362Z|00280|reconnect|WARN|ssl:192.168.200.170:55352: connection dropped (Protocol error)
2023-05-30T16:08:19.388Z|00281|stream_ssl|WARN|SSL_accept: error:0A000126:SSL routines::unexpected eof while reading
2023-05-30T16:08:19.388Z|00282|jsonrpc|WARN|ssl:192.168.200.170:34846: receive error: Protocol error
2023-05-30T16:08:19.388Z|00283|reconnect|WARN|ssl:192.168.200.170:34846: connection dropped (Protocol error)
2023-05-30T16:08:21.317Z|00284|stream_ssl|WARN|SSL_accept: error:0A000126:SSL routines::unexpected eof while reading
2023-05-30T16:08:21.317Z|00285|jsonrpc|WARN|ssl:192.168.200.171:45672: receive error: Protocol error
2023-05-30T16:08:21.317Z|00286|reconnect|WARN|ssl:192.168.200.171:45672: connection dropped (Protocol error)
2023-05-30T16:08:43.413Z|00287|stream_ssl|WARN|SSL_accept: error:0A000126:SSL routines::unexpected eof while reading
2023-05-30T16:08:43.413Z|00288|jsonrpc|WARN|ssl:192.168.200.170:41820: receive error: Protocol error
2023-05-30T16:08:43.414Z|00289|reconnect|WARN|ssl:192.168.200.170:41820: connection dropped (Protocol error)
2023-05-30T16:08:45.343Z|00290|stream_ssl|WARN|SSL_accept: error:0A000126:SSL routines::unexpected eof while reading
2023-05-30T16:08:45.343Z|00291|jsonrpc|WARN|ssl:192.168.200.171:40496: receive error: Protocol error
2023-05-30T16:08:45.343Z|00292|reconnect|WARN|ssl:192.168.200.171:40496: connection dropped (Protocol error)
2023-05-30T16:09:07.437Z|00293|stream_ssl|WARN|SSL_accept: error:0A000126:SSL routines::unexpected eof while reading
2023-05-30T16:09:07.437Z|00294|jsonrpc|WARN|ssl:192.168.200.170:49492: receive error: Protocol error
2023-05-30T16:09:07.437Z|00295|reconnect|WARN|ssl:192.168.200.170:49492: connection dropped (Protocol error)
2023-05-30T16:09:31.458Z|00296|stream_ssl|WARN|SSL_accept: error:0A000126:SSL routines::unexpected eof while reading
2023-05-30T16:09:31.458Z|00297|jsonrpc|WARN|ssl:192.168.200.170:38368: receive error: Protocol error
2023-05-30T16:09:31.458Z|00298|reconnect|WARN|ssl:192.168.200.170:38368: connection dropped (Protocol error)
2023-05-30T16:09:55.484Z|00299|stream_ssl|WARN|SSL_accept: error:0A000126:SSL routines::unexpected eof while reading
2023-05-30T16:09:55.484Z|00300|jsonrpc|WARN|ssl:192.168.200.170:49730: receive error: Protocol error
2023-05-30T16:09:55.484Z|00301|reconnect|WARN|ssl:192.168.200.170:49730: connection dropped (Protocol error)

#  /root/ovn/log/ovsdb-server-sb.log
2023-05-30T16:08:03.371Z|00203|jsonrpc|WARN|ssl:192.168.200.170:47160: receive error: Protocol error
2023-05-30T16:08:03.371Z|00204|reconnect|WARN|ssl:192.168.200.170:47160: connection dropped (Protocol error)
2023-05-30T16:08:27.396Z|00205|stream_ssl|WARN|SSL_accept: error:0A000126:SSL routines::unexpected eof while reading
2023-05-30T16:08:27.396Z|00206|jsonrpc|WARN|ssl:192.168.200.170:53826: receive error: Protocol error
2023-05-30T16:08:27.396Z|00207|reconnect|WARN|ssl:192.168.200.170:53826: connection dropped (Protocol error)
2023-05-30T16:08:51.422Z|00208|stream_ssl|WARN|SSL_accept: error:0A000126:SSL routines::unexpected eof while reading
2023-05-30T16:08:51.422Z|00209|jsonrpc|WARN|ssl:192.168.200.170:37032: receive error: Protocol error
2023-05-30T16:08:51.422Z|00210|reconnect|WARN|ssl:192.168.200.170:37032: connection dropped (Protocol error)
2023-05-30T16:09:15.441Z|00211|stream_ssl|WARN|SSL_accept: error:0A000126:SSL routines::unexpected eof while reading
2023-05-30T16:09:15.441Z|00212|jsonrpc|WARN|ssl:192.168.200.170:54834: receive error: Protocol error
2023-05-30T16:09:15.441Z|00213|reconnect|WARN|ssl:192.168.200.170:54834: connection dropped (Protocol error)
2023-05-30T16:09:39.467Z|00214|stream_ssl|WARN|SSL_accept: error:0A000126:SSL routines::unexpected eof while reading
2023-05-30T16:09:39.467Z|00215|jsonrpc|WARN|ssl:192.168.200.170:52108: receive error: Protocol error
2023-05-30T16:09:39.467Z|00216|reconnect|WARN|ssl:192.168.200.170:52108: connection dropped (Protocol error)
2023-05-30T16:10:03.493Z|00217|stream_ssl|WARN|SSL_accept: error:0A000126:SSL routines::unexpected eof while reading
2023-05-30T16:10:03.493Z|00218|jsonrpc|WARN|ssl:192.168.200.170:56796: receive error: Protocol error
2023-05-30T16:10:03.493Z|00219|reconnect|WARN|ssl:192.168.200.170:56796: connection dropped (Protocol error)
2023-05-30T16:10:27.519Z|00220|stream_ssl|WARN|SSL_accept: error:0A000126:SSL routines::unexpected eof while reading
2023-05-30T16:10:27.519Z|00221|jsonrpc|WARN|ssl:192.168.200.170:57530: receive error: Protocol error
2023-05-30T16:10:27.519Z|00222|reconnect|WARN|ssl:192.168.200.170:57530: connection dropped (Protocol error)


```
