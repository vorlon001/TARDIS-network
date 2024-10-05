
### DIAG 12
```
node140# show ip bgp vrf BLUE
BGP table version is 22, local router ID is 2.2.2.254, vrf id 4
Default local pref 100, local AS 65000
Status codes:  s suppressed, d damped, h history, u unsorted, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>  1.1.1.0/24       0.0.0.0                  0         32768 ?
                      192.168.202.142@0<
                                             0    100      0 ?
 *                    1.1.1.100                0             0 65001 ?
 *>  2.2.2.0/24       0.0.0.0                  0         32768 ?
                      192.168.202.142@0<
                                             0    100      0 ?
 *>  3.3.3.3/32       2.2.2.2                  0             0 65001 ?
                      192.168.202.142@0<
                                             0    100      0 65001 ?
 *>  192.168.200.0/24 1.1.1.100                0             0 65001 ?
                      192.168.202.142@0<
                                             0    100      0 65001 ?

Displayed 4 routes and 9 total paths
node140#

node142# show ip bgp vrf BLUE
BGP table version is 8, local router ID is 2.2.2.254, vrf id 4
Default local pref 100, local AS 65000
Status codes:  s suppressed, d damped, h history, u unsorted, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>  1.1.1.0/24       0.0.0.0                  0         32768 ?
                      192.168.201.140@0<
                                             0    100      0 ?
 *                    1.1.1.100                0             0 65001 ?
 *>  2.2.2.0/24       0.0.0.0                  0         32768 ?
                      192.168.201.140@0<
                                             0    100      0 ?
 *>  3.3.3.3/32       2.2.2.2                  0             0 65001 ?
                      192.168.201.140@0<
                                             0    100      0 65001 ?
 *>  192.168.200.0/24 1.1.1.100                0             0 65001 ?
                      192.168.201.140@0<
                                             0    100      0 65001 ?

Displayed 4 routes and 9 total paths
node142# show ip bgp vrf BLUE summary

IPv4 Unicast Summary:
BGP router identifier 2.2.2.254, local AS number 65000 VRF BLUE vrf-id 4
BGP table version 8
RIB entries 7, using 896 bytes of memory
Peers 1, using 24 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
1.1.1.100       4      65001        34        29        8    0    0 00:05:24            3        4 N/A

Total number of neighbors 1
node142#

node143# show ip bgp vrf BLUE
BGP table version is 6, local router ID is 2.2.2.254, vrf id 4
Default local pref 100, local AS 65000
Status codes:  s suppressed, d damped, h history, u unsorted, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>  1.1.1.0/24       0.0.0.0                  0         32768 ?
                      192.168.201.140@0<
                                             0    100      0 ?
                      192.168.202.142@0<
                                             0    100      0 ?
 *>  2.2.2.0/24       0.0.0.0                  0         32768 ?
                      192.168.201.140@0<
                                             0    100      0 ?
                      192.168.202.142@0<
                                             0    100      0 ?
     3.3.3.3/32       192.168.201.140@0<
                                             0    100      0 65001 ?
                      192.168.202.142@0<
                                             0    100      0 65001 ?
     192.168.200.0/24 192.168.201.140@0<
                                             0    100      0 65001 ?
                      192.168.202.142@0<
                                             0    100      0 65001 ?

Displayed 4 routes and 10 total paths
node143# show ip bgp vrf BLUE summary
% No BGP neighbors found in VRF BLUE
node143#


```


### DIAG 13
```
node143# show ip bgp vrf BLUE 2.2.2.0/24
BGP routing table entry for 2.2.2.0/24, version 6
Paths: (1 available, best #1, vrf BLUE)
  Not advertised to any peer
  Local
    0.0.0.0 from 0.0.0.0 (2.2.2.254)
      Origin incomplete, metric 0, weight 32768, valid, sourced, best (First path received)
      Last update: Sat Oct  5 15:10:26 2024
  
node143# show ip bgp vrf BLUE 3.3.3.3/32
BGP routing table entry for 3.3.3.3/32, version 0
Paths: (2 available, no best path)
  Not advertised to any peer
  Imported from 192.168.100.142:100:3.3.3.3/32
  65001
    2.2.2.2 from 0.0.0.0 (2.2.2.254) vrf default(0) announce-nh-self
      Origin incomplete, metric 0, localpref 100, invalid, sourced, local
      Extended Community: RT:10:100
      Originator: 192.168.200.142, Cluster list: 192.168.200.141
      Remote label: 80
      Last update: Sat Oct  5 15:42:20 2024
  Imported from 192.168.100.140:100:3.3.3.3/32
  65001
    2.2.2.2 from 0.0.0.0 (2.2.2.254) vrf default(0) announce-nh-self
      Origin incomplete, metric 0, localpref 100, invalid, sourced, local
      Extended Community: RT:10:100
      Originator: 192.168.200.140, Cluster list: 192.168.200.141
      Remote label: 80
      Last update: Sat Oct  5 15:42:20 2024
node143#

```



### DIAG 14

```
node142# show ip bgp vrf BLUE 3.3.3.3/32
BGP routing table entry for 3.3.3.3/32, version 13
Paths: (2 available, best #1, vrf BLUE)
  Advertised to non peer-group peers:
  1.1.1.100
  65001
    2.2.2.2 from 1.1.1.100 (192.168.200.130)
      Origin incomplete, metric 0, valid, external, best (First path received)
      Last update: Sat Oct  5 15:42:52 2024
  Imported from 192.168.100.140:100:3.3.3.3/32
  65001
    2.2.2.2 from 0.0.0.0 (2.2.2.254) vrf default(0) announce-nh-self
      Origin incomplete, metric 0, localpref 100, invalid, sourced, local
      Extended Community: RT:10:100
      Originator: 192.168.200.140, Cluster list: 192.168.200.141
      Remote label: 80
      Last update: Sat Oct  5 15:42:20 2024
node142# show ip bgp vrf BLUE 2.2.2.2/24
BGP routing table entry for 2.2.2.0/24, version 2
Paths: (1 available, best #1, vrf BLUE)
  Advertised to non peer-group peers:
  1.1.1.100
  Local
    0.0.0.0 from 0.0.0.0 (2.2.2.254)
      Origin incomplete, metric 0, weight 32768, valid, sourced, best (First path received)
      Last update: Sat Oct  5 15:02:58 2024
node142#

node143# show ip bgp vrf BLUE 2.2.2.0/24
BGP routing table entry for 2.2.2.0/24, version 6
Paths: (1 available, best #1, vrf BLUE)
  Not advertised to any peer
  Local
    0.0.0.0 from 0.0.0.0 (2.2.2.254)
      Origin incomplete, metric 0, weight 32768, valid, sourced, best (First path received)
      Last update: Sat Oct  5 15:10:25 2024
node143# show ip bgp vrf BLUE 3.3.3.3/32
BGP routing table entry for 3.3.3.3/32, version 0
Paths: (2 available, no best path)
  Not advertised to any peer
  Imported from 192.168.100.142:100:3.3.3.3/32
  65001
    2.2.2.2 from 0.0.0.0 (2.2.2.254) vrf default(0) announce-nh-self
      Origin incomplete, metric 0, localpref 100, invalid, sourced, local
      Extended Community: RT:10:100
      Originator: 192.168.200.142, Cluster list: 192.168.200.141
      Remote label: 80
      Last update: Sat Oct  5 15:42:21 2024
  Imported from 192.168.100.140:100:3.3.3.3/32
  65001
    2.2.2.2 from 0.0.0.0 (2.2.2.254) vrf default(0) announce-nh-self
      Origin incomplete, metric 0, localpref 100, invalid, sourced, local
      Extended Community: RT:10:100
      Originator: 192.168.200.140, Cluster list: 192.168.200.141
      Remote label: 80
      Last update: Sat Oct  5 15:42:21 2024
node143#


```
