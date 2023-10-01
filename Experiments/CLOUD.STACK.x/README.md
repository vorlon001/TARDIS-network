```

                      
 
              Opensearch-Data-01-hot     Opensearch-Data-02-hot                Opensearch-Data-03-warm   Opensearch-Data-04-warm Opensearch-Data-05-cold  Opensearch-Data-06-cold
                           |                             |                                 |                       |                         |                             |
                           |                             |                                 |                       |                         |                             |
                           |                             |                                 |                       |                         |                             |
                           |                             |                                 |                       |                         |                             |
                           |                             |                                 |                       |                         |                             |
   Opensearch-Master-01    |      Opensearch-Master-02   |      Opensearch-Master-03       |                       |                         |                             |
            |              |              |              |              |                  |                       |                         |                             |
            |              |              |              |              |                  |     logstash01        |     logstash02          |       logstash03            |
            |              |              |              |              |                  |          |            |          |              |          |                  |
            |              |              |              |              |                  |          |            |          |              |          |                  |
            |              |              |              |              |                  |          |            |          |              |          |                  |
            |              |              |              |              |                  |          |            |          |              |          |                  |
            |              |              |              |              |                  |          |            |          |              |          |                  |
            |              |              |              |              |                  |          |            |          |              |          |                  |
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 |
 |                  Patroni01             Patroni02           Patroni03   
 |                      |                    |                    |
 |                      |                    |                    |
 |   VMStore01(node140) | VMStore02(node141) | VMStore03(node142) |  VMSelect01(node140) VMSelect02(node141) VMSelect03(node142) VMInsert01(node140) VMInsert02(node141) VMInsert03(node142)
 |           |          |         |          |         |          |           |                    |                    |                    |                    |                    |
 |           |          |         |          |         |          |           |                    |                    |                    |                    |                    |
 |           |          |         |          |         |          |           |                    |                    |                    |                    |                    |
 |           |          |         |          |         |          |           |                    |                    |                    |                    |                    |
 ----------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
             |            |           |            |          |             |           |           |           |          |            |          |
             |            |           |            |          |             |           |           |           |          |            |          |
             |            |           |            |          |             |           |           |           |          |            |          |
             |            |           |            |          |             |           |           |           |          |            |          |
             |            |           |            |          |             |           |           |           |          |            |          |
             |            |           |            |          |             |           |           |           |          |            |          |
             |            |           |            |          |             |           |           |           |          |            |          |
      Balancer01(node140) |  Balancer02(node141)   |  Balancer03(node142)   |    VMAgent01(node140) |   VMAgent02(node141) |   VMAgent03(node142)  |
    vipIP:192.168.200.184 | vipIP:192.168.200.185  | vipIP:192.168.200.186  |                       |                      |                       |
                          |                        |                        |                       |                      |                       |
                  Prometheus01(node140)   Prometheus02(node142)     Prometheus03(node142)           |                      |                       |
                                                                                                Grafana01               Grafana02              Grafana03

     Data streams:

            VMSelect01, VMSelect02, VMSelect03 =======> VMStore01, VMStore02, VMStore03

            VMInsert01, VMInsert02, VMInsert03 =======> VMStore01, VMStore02, VMStore03

            VMAgent01,  VMAgent02,  VMAgent03  =======> Balancer01, Balancer02, Balancer03 =======> VMInsert01, VMInsert02, VMInsert03 =======> VMStore01, VMStore02, VMStore03

            Prometheus01, Prometheus02, Prometheus03 =======> Balancer01, Balancer02, Balancer03 =======> VMInsert01, VMInsert02, VMInsert03 =======> VMStore01, VMStore02, VMStore03

            Grafana01, Grafana02, Grafana03 =======> Patroni01, Patroni02, Patroni03

            Grafana01, Grafana02, Grafana03 =======> Balancer01, Balancer02, Balancer03 =======> Prometheus01, Prometheus02, Prometheus03

            Grafana01, Grafana02, Grafana03 =======> Balancer01, Balancer02, Balancer03 =======> VMSelect01, VMSelect02, VMSelect03 =======> VMStore01, VMStore02, VMStore03


            WEB Brouser =======> Balancer01, Balancer02, Balancer03 =======> Grafana01, Grafana02, Grafana03 =======>|
                                                                                                                     |
                                  |==========|=======================================================================|
                                  |          |
                                  |          |               
                                  |          |=======>  Balancer01, Balancer02, Balancer03 =======> VMSelect01, VMSelect02, VMSelect03 =======> VMStore01, VMStore02, VMStore03
                                  |
                                  |
                                  |=======> Balancer01, Balancer02, Balancer03 =======> Prometheus01, Prometheus02, Prometheus03

            DNS:
               xxxx.iblog.pro A 192.168.200.184, 192.168.200.185, 192.168.200.186


            Opensearch:

            Opensearch-Master-01, Opensearch-Master-02, Opensearch-Master-03 =======> Opensearch-Data-01-hot, Opensearch-Data-02-hot
                                                                                      Opensearch-Data-03-warm, Opensearch-Data-04-warm
                                                                                      Opensearch-Data-05-cold, Opensearch-Data-06-cold


            Opensearch-Master-01, Opensearch-Master-02, Opensearch-Master-03 =======> Opensearch-Data-01-hot, Opensearch-Data-02-hot =======>|
                                                                                                                                             |
                                                                     |=======================================================================|
                                                                     |
                                                                     |
                                                                     |=======> Opensearch-Data-03-warm, Opensearch-Data-04-warm =======>|
                                                                                                                                        |
                                                                                                                                        |          
                                                          |=============================================================================|
                                                          |                                                                             
                                                          | 
                                                          |=======> Opensearch-Data-05-cold, Opensearch-Data-06-cold

            filebeat (all nodes) =======> Balancer01, Balancer02, Balancer03 =======> logstash01, logstash02, logstash03  =======>|
                    |                                                                            /|\                              |
                    |                                                                             |                               |
                    |                                                                             |                               |
                    |============================================================================>|                               |
                                                                                                                                  |
                                                                                                                                  |
                                                          |=======================================================================|
                                                          |
                                                          |
      |===================================================|
      |
      |
      |
      |=======> Opensearch-Master-01, Opensearch-Master-02, Opensearch-Master-03 =======> Opensearch-Data-01-hot, Opensearch-Data-02-hot =======>|
                                                                                                                                                 |
                                                                                                                                                 |
                                                                         |=======================================================================|
                                                                         |
                                                                         |
                                                                         |=======> Opensearch-Data-03-warm, Opensearch-Data-04-warm =======>|
                                                                                                                                            |
                                                                                                                                            |
                                                              |=============================================================================|
                                                              |
                                                              |
                                                              |=======> Opensearch-Data-05-cold, Opensearch-Data-06-cold


```


```

              Opensearch-Data-07-hot     Opensearch-Data-08-hot                Opensearch-Data-09-warm   Opensearch-Data-10-warm   Opensearch-Data-11-cold  Opensearch-Data-12-cold
              (region two) |             (region two)    |                     (region two)|             (region two)  |           (region two)   |         (region two)   |
                           |                             |                                 |                           |                          |                        |
                           |                             |                                 |                           |                          |                        |
                           |                             |                                 |                           |                          |                        |
                           |                             |                                 |                           |                          |                        |
                           |                             |                                 |                           |                          |                        |
                           |                             |                                 |                           |                          |                        |
                           |                             |                                 |                           |                          |                        |
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 |
 |            Opensearch-Data-01-hot     Opensearch-Data-02-hot                Opensearch-Data-03-warm   Opensearch-Data-04-warm   Opensearch-Data-05-cold  Opensearch-Data-06-cold
 |            (region one) |             (region one)    |                     (region one)|             (region one)  |           (region one)   |         (region one)   |
 |                         |                             |                                 |                           |                          |                        |
 |                         |                             |                                 |                       -----                     ------                        |
 |                         |                             |                                 |                       |                         |                             |
 |                         |                             |           Opensearch-Master-04  |                       |                         |                             |
 |                         |                             |                   (region two)  |                       |                         |             (region two)    |
 |                         |                             |                            |    |                       |                         |             logstash04      |
 | Opensearch-Master-01    |      Opensearch-Master-02   |      Opensearch-Master-03  |    |                       |                         |                     |       |
 |          |(region one)  |              |(region one)  |              |(region two) |    |     (region one)      |    (region one)         |       (region two)  |       |
 |          |              |              |              |              |             |    |     logstash01        |     logstash02          |       logstash03    |       |
 |          |              |              |              |              |             |    |          |            |          |              |          |          |       |
 |          |              |              |              |              |             |    |          |            |          |              |          |          |       |
 |          |              |              |              |              |             |    |          |            |          |              |          |          |       |
 |          |              |              |              |              |             |    |          |            |          |              |          |          |       |
 |          |              |              |              |              |             |    |          |            |          |              |          |          |       |
 |          |              |              |              |              |             |    |          |            |          |              |          |          |       |
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 |                      |                               |                                      |
 |                      |                               |                                      |
 |                      |                               |                                      |
 |             Patroni04(stanby,region two)    Patroni05(stanby,region two)    Patroni06(stanby,region two)
 |
 |
 |
 |             Patroni01(active,region one)    Patroni02(active,region one)      Patroni03(active,region one)
 |                      |                               |                                         |
 |                      |                               |                                         |
 |                      |                               |                                         |
 |                      |                    ------------            ------------------------------
 |                      |                    |                       |
 |                      |                    |                       |
 |                      |                    |                       |
 |                      |                    |  (region two)         |
 |                      |                    |  VMStore04            |       (region two)
 |                      |                    |       |               |       VMSelect04
 |                      |                    |       |-----------|   |             |
 |                      |                    |                   ||--|             |
 |                      |                    |                   |||---------------|
 |                      |                    |                   |||
 |                      |                    |                   |||                                                                                              (region two)
 |                      |                    |                   |||                                                                                              VMInsert04
 |                      |                    |                   |||                                                                                                    | 
 |                      |                    |                   |||                                                                                                    |
 |   (region one)       | (region one)       | (region two)      ||| (region one)        (region one)        (region two)        (region one)        (region one)       | (region two)
 |   VMStore01(node140) | VMStore02(node141) | VMStore03(node142)||| VMSelect01(node140) VMSelect02(node141) VMSelect03(node142) VMInsert01(node140) VMInsert02(node141)| VMInsert03(node142)
 |           |          |         |          |         |         |||          |                    |                    |                    |                    |     |              |
 |           |          |         |          |         |         |||          |                    |                    |                    |                    |     |              |
 |           |          |         |          |         |         |||          |                    |                    |                    |                    |     |              |
 |           |          |         |          |         |         |||          |                    |                    |                    |                    |     |              |
 ----------- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
             |            |           |            |          |             ||          |           |           |          ||           |          |       |                  |
             |            |           |            |          |             ||          |           |           |          ||           |          |       |                  |
             |            |           |            |          |             ||          |           |           |          ||           |          |  (region two,exaBGP)     |
             |            |           |            |          |             ||          |           |           |          ||           |          |   Balancer03(node142)    |
             |            |           |            |          |             ||          |           |           |          ||           |          |   vipIP:192.168.200.187  |
             |            |           |            |          |             ||          |           |           |          ||           |          |                          |
             |            |           |            |          |             ||          |           |           |          ||           |          |                          |
      (region one,exaBGP) |  (region one,exaBGP)   |  (region two,exaBGP)   ||          |           |           |          ||           |          |                        --|
      Balancer01(node140) |  Balancer02(node141)   |  Balancer03(node142)   ||   VMAgent01(node140) |   VMAgent02(node141) ||  VMAgent03(node142)  |                        |
    vipIP:192.168.200.184 | vipIP:192.168.200.185  | vipIP:192.168.200.186  ||   (region one)       |   (region one)       ||  (region two)        |                        |
                          |                        |                        ||                      |                      ||                      |                        |
                          |                        |                        ||                      |                      ||                      |                        |
                          |                        |                        ||------------|         |                      ||---------|            |                        |
                          |                        |                        |             |         |                      |          |            |                        |
                  Prometheus01(node140)   Prometheus02(node142)     Prometheus03(node142) |         |                      |          |            |                        |
                  (region one)            (region one)              (region two)          |     Grafana01               Grafana02     |        Grafana03               Grafana04
                                                                                          |     (region one)            (region one)  |        (region two)           (region two)
                                                                          ----------------|                                           |
                                                                          |                                                     VMAgent04
                                                                          |                                                     (region two)
                                                                          |
                                                                    Prometheus04
                                                                    (region two)


     Data streams:

            VMSelect01, VMSelect02, VMSelect03, VMSelect04 =======> VMStore01, VMStore02, VMStore03, VMStore04

            VMInsert01, VMInsert02, VMInsert03, VMInsert04 =======> VMStore01, VMStore02, VMStore03, VMStore04

            VMAgent01,  VMAgent02,  VMAgent03, VMAgent04  =======> Balancer01, Balancer02, Balancer03, Balancer04 =======>|
                                                                                                                          |
                                                                                                                          |
                                                  |=======================================================================|
                                                  |
                                                  |
                                                  |=======> VMInsert01, VMInsert02, VMInsert03,VMInsert04 =======> VMStore01, VMStore02, VMStore03,VMStore04

            Prometheus01, Prometheus02, Prometheus03, Prometheus03 =======> Balancer01, Balancer02, Balancer03, Balancer04 =======>|
                                                                                                                                   |
                                                                                                                                   |
                                                  |================================================================================|
                                                  |
                                                  |
                                                  |=======> VMInsert01, VMInsert02, VMInsert03,VMInsert04 =======> VMStore01, VMStore02, VMStore03,VMStore04

            Grafana01, Grafana02, Grafana03, Grafana04  =======> Patroni01, Patroni02, Patroni03 or Patroni04, Patroni05, Patroni06

            Grafana01, Grafana02, Grafana03, Grafana04 =======> Balancer01, Balancer02, Balancer03, Balancer04 =======> Prometheus01, Prometheus02, Prometheus03, Prometheus04

            Grafana01, Grafana02, Grafana03, Grafana04 =======> Balancer01, Balancer02, Balancer03, Balancer04 =======>|
                                                                                                                       |
                                                                                                                       |
                                                  |====================================================================|
                                                  |
                                                  |
                                                  |=======> VMSelect01, VMSelect02, VMSelect03, VMSelect04 =======> VMStore01, VMStore02, VMStore03,VMStore04


            WEB Brouser =======> Balancer01, Balancer02, Balancer03, Balancer04 =======> Grafana01, Grafana02, Grafana03 =======>|
                                                                                                                                 |
                                                                                                                                 |
                                  |==========|===================================================================================|
                                  |          |
                                  |          |
                                  |          |======> Balancer01, Balancer02, Balancer03, Balancer04 =======>|
                                  |                                                                          |
                                  |                                                                          |
                                  |                                                                          |
                                  |          |===============================================================|
                                  |          |
                                  |          |=======> VMSelect01, VMSelect02, VMSelect03, VMSelect04 =======> VMStore01, VMStore02, VMStore03,VMStore04
                                  |
                                  |
                                  |
                                  |======> Balancer01, Balancer02, Balancer03, Balancer04 =======>|
                                                                                                  |
                                                                                                  |
                                                  |===============================================|
                                                  |
                                                  |
                                                  |=======> Prometheus01, Prometheus02, Prometheus03

            DNS:
               xxxx.iblog.pro A 192.168.200.184, 192.168.200.185, 192.168.200.186, 192.168.200.187


            Opensearch:

            Opensearch-Master-01, Opensearch-Master-02, Opensearch-Master-03, Opensearch-Master-04 =======> Opensearch-Data-01-hot, Opensearch-Data-02-hot
                                                                                                            Opensearch-Data-07-hot, Opensearch-Data-08-hot
                                                                                                            Opensearch-Data-03-warm, Opensearch-Data-04-warm
                                                                                                            Opensearch-Data-09-warm, Opensearch-Data-10-warm
                                                                                                            Opensearch-Data-05-cold, Opensearch-Data-06-cold
                                                                                                            Opensearch-Data-11-cold, Opensearch-Data-12-cold


            Opensearch-Master-01, Opensearch-Master-02, Opensearch-Master-03 =======> Opensearch-Data-01-hot, Opensearch-Data-02-hot =======>|
                                                        Opensearch-Master-04          Opensearch-Data-07-hot, Opensearch-Data-08-hot         |
                                                                                                                                             |
                                                                                                                                             |
                                                                                                                                             |
                                                                                                                                             |
                                                                     |=======================================================================|
                                                                     |
                                                                     |
                                                                     |         Opensearch-Data-09-warm, Opensearch-Data-10-warm
                                                                     |=======> Opensearch-Data-03-warm, Opensearch-Data-04-warm =======>|
                                                                                                                                        |
                                                                                                                                        |
                                                          |=============================================================================|
                                                          |
                                                          |
                                                          |=======> Opensearch-Data-05-cold, Opensearch-Data-06-cold
                                                                    Opensearch-Data-11-cold, Opensearch-Data-12-cold



            filebeat (all nodes) =======> Balancer01, Balancer02, Balancer03, Balancer04  =======> logstash01, logstash02, logstash03, logstash04  =======>|
                    |                                                                                                     /|\                              |
                    |                                                                                                      |                               |
                    |                                                                                                      |                               |
                    |=====================================================================================================>|                               |
                                                                                                                                                           |
                                                                                                                                                           |
                                                          |================================================================================================|
                                                          |
                                                          |
      |===================================================|
      |
      |
      |
      |=======> Opensearch-Master-01, Opensearch-Master-02, Opensearch-Master-03 =======> Opensearch-Data-01-hot, Opensearch-Data-02-hot =======>|
                                                            Opensearch-Master-04          Opensearch-Data-07-hot, Opensearch-Data-08-hot         |
                                                                                                                                                 |
                                                                                                                                                 |
                                                                                                                                                 |
                                                                                                                                                 |
                                                                     |===========================================================================|
                                                                     |
                                                                     |         Opensearch-Data-09-warm, Opensearch-Data-10-warm
                                                                     |=======> Opensearch-Data-03-warm, Opensearch-Data-04-warm =======>|
                                                                                                                                        |
                                                                                                                                        |
                                                                                                                                        |
                                                          |=============================================================================|
                                                          |
                                                          |
                                                          |
                                                          |=======> Opensearch-Data-05-cold, Opensearch-Data-06-cold
                                                                    Opensearch-Data-11-cold, Opensearch-Data-12-cold



```
