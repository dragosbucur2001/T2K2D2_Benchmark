select v.id_word id_word, count(distinct v.id_document) wordCountDocs
                        from vocabulary v 
                        where v.id_document in (select d.id
                                                    from documents d
                                                    inner join documents_authors da
                                                        inner join authors a
                                                            inner join genders g
                                                            on a.id_gender = g.id
                                                        on da.id_author = a.id
                                                    on d.id = da.id_document
                                                    inner join geo_location gl
                                                        on d.id_geo_loc = gl.id 
                                                    where g.type = 'female'
                                                        and gl.X between 20 and 40
                                                        and gl.Y between -100 and 100
                                                        and d.document_date between '2015-09-17 00:00:00' and '2015-09-18 00:00:00')
                            group by v.id_word


/*
    ======== RESULTS OF "explain analyze (distsql)" ========
  Diagram: https://cockroachdb.github.io/distsqlplan/decode.html#eJzEW-1u27jS_v9eBaE_TQDa5pf4YaCAu2323ey2TpGku1icLQLVYhyf2pbXktvkFL2scwPnyg70ZUsiRVuuewostrU4IjkzD2eeGapfvPjvuTf0bi5eX7y8BZ_6s_Duc7QOwYsbUPwVgkm0WSZnry5vbi_HpVAYTTYLvUzOU8lULBMKo0kMfr6-egM-RZPgw2YerJ9SgU_gj18uri_qr4LLMTgrFg77szB_sRyN0_dCcDkeX1yDX68ux7uRu2CTPETrXCKoilQGas-nehnq_PkUXI1BkO4jfwieg2m6-NUYhNnjfA7wPBPKHqd_Pi9GK5uvzB7dzaNJkMyiZbbEvHztrhhKF5mn0-RmODs7m_aTp5UGz8Gze70I5vrZOXgxfgXOpvP-I_jp4vaPi4sxICh7yND5bvRpO9rDKB_HaCsQ9ssN3oVBoreyzwjCfg-pHhYAoWH237Psld2I3I2cn4P_v7569xb89OcOEx70llGox8FCx97wHx72oEe999BbraOJjuNonT7-kgldho_eEEFvtlxtkvTxe-hNorX2hl-8ZJbMtTf0boMPc32tg1CvB-lcoU6C2Tybeoee0e6vd6uP-smD3stovlks4yGouAOC3SZvVkE6OuCMcewjjKiPOFeSsAEjvo8oEVQoQgmSPsK9TI5JRCViimEfcznA2FdUSCUUk5gT6gvfg95vv4NkttBDQPsyzn9PomWil5nj8yH0n38XQ-vocwxCPYlCHQ6BVAT6XORDH54SHYO1DsIhYAy8mf2UP59ev30JJsF8Hg9BseAqmK1L0d0cb35_-RLEiV7lZxOc6cdkMFsm51uhQVNY64-msD9Il1kEj2ChF9H6CQTzDMjpjjEqNhb_PQeT1aZQEPdFquCHIJk86BhEm2S1SYZACuJBL9N5-6jYwfuv0Muf5fgo_f_hCTwE8UPd8yPsvf_6HnpxEky1N8QVdF2-8ob4KzwOYLS-jBFLRsaTvXDL5eqAE9hXSnDqC-wjQQZSMcIElbJXxQ_rs674wRBxAamyIYgcjKDqLA4MbcUG5gunwhGxoQhDxGgTR7s9fAuSSANJtBVJu3k3y2gd6rUOazO_T9_cJ2KB4y9B_PBrNFvq9UDWtzrX98nZCJ8_X8-mD8nZiJ170LtKdR9hOCJwROGIwZEPRxyOBBylr-tHPdlUgEOZWsStTiCqcEI6nDoi0YsVCGfxR7CJg2kKPGD6iAmysLtJUNR0E1MCMko6OonUnMQbTpLHHndVX6bI_6Piz7s0997Nwsf68YYgfV450H95eXL-y-tV_j54u9b3s8eLZVg907mlOh1pazKwHGRsOch7DvAAuw9sLtCCFQR-sxxYQXI9DDAY57UBgZ17RcO9qot706NTsgVUd28Zw8vIvSV3hY9fR9HHzQr8M5otQbRMT1XT8ds3vGITma9y5fLfcRLM501flykRd_U9YQxibAnmqk_t0VyaINhN4oBCITRoClthIbPItIl1COJkrYNFZpBmqCE5BWgJ97yFNnAbeAiTTfiUG-0WR2gtjsgmbUA_MtpjYgv3ZBvu6b5wD0cKjjCCI4zhKJut6RLMiSP6yy2oOoV_zLE1_BMouHHqiY8gUayj23jNbarpNvJD3cbqm719WukheH3x8y24uXhzmdV-HjSSN9950-YpwV15mh6VpwVhVkdJSKWFTmGEoZCqNUxj1PQD6xKoX0ynaz0Nkmg9wNzgZNB7Mf7zbnx1ezd-9_p1arg0Fl-9G9_eXV_9cXN2brEZwy50U_8oboPt3MZENicQY_ptZYxRx_BvQPYem8vDbH7z7s3d5fg2DUQ2kyOHxfFR4aSYsmlw5htM0ocCtbMI3KTyuJ0mHmXMcdSLVgPc4JBNCykm8-Re11L5LTxJGYxZYUglb9eTNvWs8yV8OB1Gp2-v9A7sr4BgGQIMouQh4xI7vux3L4IFVFRBxpTJm6hq4U0MmcSpOo-DOm3FBuYLVvrE1CAT6dZQwXk3qYkXAYXPmpDZbeSUXRV0LK7I9--q9JxtlVpXpSucFCWQI2oBE2_Bkgml3RwOIBVCg6awHUQDdqKenMJGLit3cMpOCjkWPaxZpO_a6KPqj7snW63-CMFTpVbvYYR6A4xwrVErO1flAhLKTUgQQYqqeH9xXk7hDC2E8kFdsHOhTlsqdSzsbNAMJunybemnmX1YFzf_PJsneq3XWV-w4uP8-RCcjQj4a4MQ1c8BQcPh8HJ8K4s7jHJo8hyw7ZCt5pHKloCxlPYEbOjPICHtNIM19Pe76F9pVvCWGFmJjbuLIlfD4moMzkZ8a7bKlc6z4XD46sXtRWlAvjVg5XZnK2TtfWSrQ1C7PWr0QnJz2fohjNcbIt0jsaJQKN_SEGuJxMQSibdzuCJxLjRoCtsjMSSEDLL_H9AVUX2_nTFze-AuOJARuKXJFYsNdwvcrBa4_QaieSui_wfVtfgOLXDETt4CJ0q1tcAzqtdogXNIedfs6m6Bix_pJIy_f-dKuCrNYztXqrVzZd4vEcYg6nxxsadzhX-o2-h36Vz53NWFYUd1rqi9C9PSuUKKQerI2WbninbJ2tUuin-azhX1T9-5KuY8oHOFoUJdgb2vc9XOg765cyVO0rly9QqP7FzZQWrtXHHZTNKuzpXo0li91vEqWsa6GS6sazVPQg-n1tfhVOeuiqPNeqLfrqNJJpv_vMomyrwa6jjJR7HIf10uy7E4CbLVvKVOPkfrj2AeJHo5eRqCPOyWjz8Hs2RbotI423es17NgPvtXUM0B9dcyk671RM8-6exS1IcyA3cpUDLEUkL0S3pVSix0nLqzKiQ5sgUa38zixXqZLVO6t2vYHm403mozIwHmlrHj1e_jYwDbEiB8I6QyxqFAvK4rQU1dsRsg_gkAQvqkHSDF_UYLQHxKsjjXDpAdjXAABENEbBDBEGEDJOWaNcPRbnYjB2OE5DfMdoyw4zBi57XSN0oPnzLI0tKjqqpxHIgbIu3n4XCIqHaAUOoCCGECMmcE2d5aO_FBfd-KD2o2assl60HEOFhuq7WfK6P4bIeHULzoEnWj0LKl7qHS-NKPMAWVaCprnAbaVBZVlWU1ZVF1KtmciXUBGzkyHsl2uCkX2jAhEGUUvD1f4f1wyz-NMD-YEAYtLtarWx93s5nfarJOX39QIo8Cmz1htSiLEWsoy5rK-l0YzXEAwbjvCkhOSoMJg0q6IHJYQMJKWc8oVkazs1yybjjjZLkN136wDFZT3Gq10PD-UZVPWyuGcCP-YuJDihshiZCmutwZkkR7SCIG5IQbcuoECZD6LhYtVdEPbwEdRVAR7sAcU-UdhwN0zIY48yuuYrG6-Q3S4LaZPDj9UT9njy0kmh4VlChqucmnRqFNMcRSNLQ1zpZ0gs0CkC2vNHiDck5FUDtwTW5_dPVnZAaXD44jqdLOQgT0iZEaKFScQoQaTDVvWHTQ-BRUlTiKGexLV26gUAkOGWOOk8rJ_uwgoKDM_l0BNRjcbtG67ZRhu6NLQbPudSSII2ualm-6hHliGeeQk0Y6NNLDHm3bC7gujREHz8TOsoZxH-ZXRe1E84C6V0obTKRJ88v1ajYzT5dR09RiE6ZdYpO7ZMCOmsHgv3hP0XA4A3be9BFKTlhuKWHeWpeXTFVtDTayR1tyAgJcmKGF_yIncot_K9KOXHIAcJXEVpNZ7uWKf5pSNZkwTLanaDi8peeqxgk7Ch72bycxpOZnhYRx6KtGJDcDuVvbU7T0ji6PCFNQcPXt_RprZGttYaRL1tOfmRCMguHQwtJSIDlggrcd7dPAhChDY0wwZEQ2NDZPhVvjU7RasDMHEidbwoRAjlxcCfsHVdItUMEmVMol69TBzDdGcVPPXdJRXJqNZKN2OLS6tJRKrvsGflT2ooi1lErGjUNaGPpN3mWSCLe-7ZVhp2LaQdKl8PcW08wVoQ4rprmtmDaaGcVidZuZJ9VdFH7_BgTnxGmz4nbUQVfJITYTna5iazZTX99D734efb6bhd7QkwH-cP9B0Z4M7mWPKU17ChHRY1wzFYb390qk-L2fB9PYG37xbh6iz5n9bp9WOvaG98E81tB7E3zUr3Si14vZchYns0kx8vXr__03AAD__zDeduk=

  planning time: 8ms
  execution time: 35.3s
  distribution: full
  vectorized: true
  rows decoded from KV: 12,077,165 (571 MiB, 66 gRPC calls)
  cumulative time spent in KV: 42.7s
  maximum memory usage: 125 MiB
  network usage: 179 MiB (16,991 messages)
  sql cpu time: 27.8s
  isolation level: serializable
  priority: normal
  quality of service: regular

  • group (hash)
  │ nodes: n1, n3
  │ actual row count: 91,386
  │ estimated max memory allocated: 26 MiB
  │ estimated max sql temp disk usage: 0 B
  │ sql cpu time: 82ms
  │ estimated row count: 217,960
  │ group by: id_word
  │
  └── • hash join (semi)
      │ nodes: n1, n3
      │ actual row count: 2,196,110
      │ estimated max memory allocated: 74 MiB
      │ estimated max sql temp disk usage: 0 B
      │ sql cpu time: 1.5s
      │ estimated row count: 1,465,773
      │ equality: (id_document) = (id)
      │
      ├── • scan
      │     nodes: n1, n3
      │     actual row count: 8,832,016
      │     KV time: 29.2s
      │     KV contention time: 0µs
      │     KV rows decoded: 8,832,016
      │     KV bytes read: 437 MiB
      │     KV gRPC calls: 45
      │     estimated max memory allocated: 20 MiB
      │     sql cpu time: 13.5s
      │     estimated row count: 8,832,016 (100% of the table; stats collected 53 minutes ago)
      │     table: vocabulary@vocabulary_pkey
      │     spans: FULL SCAN
      │
      └── • hash join
          │ nodes: n1, n3
          │ actual row count: 494,326
          │ estimated max memory allocated: 17 MiB
          │ estimated max sql temp disk usage: 0 B
          │ sql cpu time: 352ms
          │ estimated row count: 472,036
          │ equality: (id_author) = (id)
          │ right cols are key
          │
          ├── • hash join
          │   │ nodes: n1, n3
          │   │ actual row count: 993,795
          │   │ estimated max memory allocated: 57 MiB
          │   │ estimated max sql temp disk usage: 0 B
          │   │ sql cpu time: 771ms
          │   │ estimated row count: 951,962
          │   │ equality: (id_document) = (id)
          │   │ right cols are key
          │   │
          │   ├── • scan
          │   │     nodes: n1, n3
          │   │     actual row count: 2,000,000
          │   │     KV time: 8.4s
          │   │     KV contention time: 0µs
          │   │     KV rows decoded: 2,000,000
          │   │     KV bytes read: 78 MiB
          │   │     KV gRPC calls: 9
          │   │     estimated max memory allocated: 20 MiB
          │   │     sql cpu time: 3.7s
          │   │     estimated row count: 2,000,000 (100% of the table; stats collected 53 minutes ago)
          │   │     table: documents_authors@documents_authors_pkey
          │   │     spans: FULL SCAN
          │   │
          │   └── • lookup join (streamer)
          │       │ nodes: n3
          │       │ actual row count: 993,795
          │       │ KV time: 4s
          │       │ KV contention time: 0µs
          │       │ KV rows decoded: 993,795
          │       │ KV bytes read: 46 MiB
          │       │ KV gRPC calls: 2
          │       │ estimated max memory allocated: 60 MiB
          │       │ sql cpu time: 5.4s
          │       │ estimated row count: 951,962
          │       │ table: documents@documents_id_geo_loc_idx
          │       │ equality: (id) = (id_geo_loc)
          │       │ pred: (document_date >= '2015-09-17') AND (document_date <= '2015-09-18')
          │       │
          │       └── • filter
          │           │ nodes: n3
          │           │ actual row count: 4,221
          │           │ sql cpu time: 188µs
          │           │ estimated row count: 4,221
          │           │ filter: (x >= 20) AND (x <= 40)
          │           │
          │           └── • scan
          │                 nodes: n3
          │                 actual row count: 7,236
          │                 KV time: 38ms
          │                 KV contention time: 0µs
          │                 KV rows decoded: 7,236
          │                 KV bytes read: 272 KiB
          │                 KV gRPC calls: 1
          │                 estimated max memory allocated: 320 KiB
          │                 sql cpu time: 17ms
          │                 estimated row count: 7,236 (82% of the table; stats collected 53 minutes ago)
          │                 table: geo_location@geo_location_y_idx
          │                 spans: [/-100 - /100]
          │
          └── • lookup join (streamer)
              │ nodes: n1
              │ actual row count: 244,117
              │ KV time: 1.1s
              │ KV contention time: 0µs
              │ KV rows decoded: 244,117
              │ KV bytes read: 9.3 MiB
              │ KV gRPC calls: 8
              │ estimated max memory allocated: 16 MiB
              │ sql cpu time: 1.6s
              │ estimated row count: 244,256
              │ table: authors@authors_id_gender_idx
              │ equality: (id) = (id_gender)
              │
              └── • scan
                    nodes: n1
                    actual row count: 1
                    KV time: 2ms
                    KV contention time: 0µs
                    KV rows decoded: 1
                    KV bytes read: 44 B
                    KV gRPC calls: 1
                    estimated max memory allocated: 20 KiB
                    sql cpu time: 72µs
                    estimated row count: 1 (50% of the table; stats collected 53 minutes ago)
                    table: genders@genders_type_idx
                    spans: [/'female' - /'female']

*/
