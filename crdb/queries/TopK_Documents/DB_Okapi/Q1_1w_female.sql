with
    q_docLen as (select d.id id, sum(v.count) docLen
                from documents d
                    inner join vocabulary v
                    on v.id_document = d.id
                    inner join documents_authors da
                        inner join authors a
                            inner join genders g
                            on a.id_gender = g.id
                        on da.id_author = a.id
                    on d.id = da.id_document
                where g.type = 'female'
                group by d.id),
    q_wordCountDocs as (select v.id_word id_word, count(distinct v.id_document) wordCountDocs
                        from vocabulary v
                        where v.id_document in (select d.id
                                                    from documents d
                                                    inner join documents_authors da
                                                        inner join authors a
                                                            inner join genders g
                                                            on a.id_gender = g.id
                                                        on da.id_author = a.id
                                                    on d.id = da.id_document
                                                    where g.type = 'female')
                            group by v.id_word),
    q_noDocs as (select d.id id
                    from documents d
                        inner join documents_authors da
                            inner join authors a
                                inner join genders g
                                on a.id_gender = g.id
                            on da.id_author = a.id
                        on d.id = da.id_document
                    where g.type = 'female')
select q2.id id, sum(q2.okapi) sokapi
        from
            (select d.id id, w.word word, -- v.id_word, v.tf, q_dl.docLen, q_wcd.wordCountDocs,
                    ((v.tf * (1 + ln((select count(id) from q_noDocs)/q_wcd.wordCountDocs)) * (1.6 + 1))/
                    (v.tf + 1.6 * (1 - 0.75 + 0.75 * q_dl.docLen / (select avg(docLen) from q_docLen)))) okapi
            from documents d
                inner join vocabulary v
                    inner join words w
                    on w.id = v.id_word
                on v.id_document = d.id
                inner join documents_authors da
                    inner join authors a
                        inner join genders g
                        on a.id_gender = g.id
                    on da.id_author = a.id
                on d.id = da.id_document
                inner join q_docLen q_dl
                on q_dl.id = d.id
                inner join q_wordCountDocs q_wcd
                on q_wcd.id_word =  v.id_word
            where g.type = 'female'
                and w.word in ('think')) q2
        group by q2.id
        order by 2 desc, 1
        limit 10;

/*
    ======== RESULTS OF "explain analyze (distsql)" =========
  Diagram 1 (subquery): https://cockroachdb.github.io/distsqlplan/decode.html#eJzcV-1u2zgW_b9PccE_lVtGFiVZHwYCuJN4t55J7MJJZzDYCQxFpB1tZNGR5Hyg6GPtC-yTLUjKtiRLTlwMdtAtUES6JA95zzn3Uv6KsocY9dFvo-tP8DCjPIxZAh-vQLsaXgzProHqERXvEcWQrZfaox7ydZJ3RKyY_ffp5FI8r5csyTM5AKPxeDiFnyejMTzyMLhdx0H6IoYeYTKGRz2is80KOFWblJZswWbBOr_jqQINylNKA5X4giWUqfhCbBWIrVQQTmEhNpqMgcqwwoBTOUmGxd_TYnR7vt8-DadDWOj5y4rBKbybs2UQs3fwj-nky2f46Xe5rIPhYfbEUyrpoTzMyizKhMWoolI-YpBTtfPR1fVovJm02VUSXMWTPNfZVIerEjoaV-V7RaAfgu3Oju4tmZLzhNfJ3ln2_yTzIq8Hs1aLD6bO74NVJL2SyUeVcVPxPukb_ynzaZr2qOdzeA8agQ8QJ9pmlbJlRDsKbENxB7rC4iHVK7bsdDoSQ3fgA5COmKWAP6jge9A0Aidg6G6vI4KaeIL3otvEumohclGxe_C40DbRYv_iVf4TCZQyfXvbKQ2J88sFT0KMJyXGrkR_uAZVQi-3cEGwWCSJVutqaTR0LKmwWiWk3nBS5kf5VGsw6sfxOWiF0UQTepffRcn9O1zo9mDuiliZeTI9H07Fqwnnw6szDAQuRpejayAGwijhlI2DJctQ_5-IoBuMVikPWZbxVIS-ygkj-oz6BkZRslrnInyDUchThvpfUR7lMUN9dB3cxmzKAsrSrgCmLA-iWMLubDLYPc5W9-wFYXTG4_UyyfpQYrto2wijq1Ugxk4QRr_8Cnm0ZH2wDL2XqUDIk5wlecSTYsz4z7-LoZQ_ZUBZyCmjffCwZ5nYII4avH3JWQYpC2gfbMuFy-gnNbCYfj6DMIjjrA-2rWKrIEo3k8s4l7-enUGWs5U6LWjsOe9GSd4pTevuL2Dsfn9Bz-72xHbL4BmWbMnTFwjimIdBLk5PjOKE2UMM4WpdJEtM3RHZ3gZ5eMcy4Ot8tc7F7o4p9pMU7IKbg9x8w0hFCymzPFgw1Ccl7UfnqG98w98nP6nKvy3kwa6kN08zGuRsFtHnqhNalHePld3EhmGI__uy-1az6sTYV70Mc0D17bTu_oJG1YnRldsdpbqpe02iE-xLB1VE352jTXSzJjr5XtHNFtE33XuwFzncAbatuc0Luv0nusH1mt3g_e_M4Hf9Y61g6dafaAWrZgXze61gVa1Q3MaD4u9MXGn7JY9BxHdid_9A6s77A52UnrufUzaPnocJrZjBd7eav9kOpOEusKGpJeybgBwWn3TJK5UvJzSLbRrwS5PYRYp7ateVJq0K2zWFrWMU_plHSSGwXRV4U-Gbut5-bBUqX3B-v17Bv3iUAE_6MCB16bcrUHEGKZXKTb1neRDHBROe7W0lLSK-szy6G9g2JsRtuBn0tquhoRlsQQ61AjWpW598wBnsmYXrUhKmTrJjDUN0s8kvpu3t9YbiYG2-6dV8Y7f6ZmeXdcJTylJGK165EStfm9Jgvk9BdicMyNJur2q-mM1zbWB2TtNocZdrA6uDMJqIrAYED0w8sPDAxoMeHjhNvDrmsp1Y4hRGEMOC3JwtV0Cj7B7WWbAQ5oKGC7rAfFNb9n0PW732jzKnRn3vr6TeaaKebKkn7dTjgdvAvue5B9j3zNfYt5qvRddwmwXoYccyj1XArSng_JUKuG9WwMID89hG4tmvMW47zb9Emn-IOD42jD3CbWx5PnZsq5Vyr0a5e8w99XGxSNkiyHna9apsyXvn4_j32XhyPRt_ubgoCLv6cik6SANblsqrma1e7zW2iNfy2dZrYsv3jvamXyPKO4YokUgMt-v5nKVgyK_PEll1KhzLkkVVTWUT3c_l6E5HjFoy_jHJTFm24knG6gXXuFV9pxMiyo7RBVNlnPF1GrLPKQ_lXPU6kUAyQFmWq1FXvYwSOUTEDikLlttOXUYiB5GcdiSrjmQeROq1I5E6knUQya4gGWUko45kH3Ems4xk1pF6R_BUQbLrSM4R2lWQnDqSexDJa-fJrSN5B5H8diSvjuQfRCLGIfFuMJrH_GkWUdRHty71TNefnzBKvBM7cG9PfMsPT1zPt-chNRh1RV3N42CRiZq7uuNPEvb6ZSUqZh7EGcPoMrhn5yxn6TJKoiyPwmLk27e__TcAAP__1SuKRA==
  Diagram 2 (subquery): https://cockroachdb.github.io/distsqlplan/decode.html#eJzcWetu2zj2__5_CoJfak8ZW7zoZiCAO0n-W880TpGkUyx2AkOVGEcbWXIkOZct-lj7AvtkC4qSrQulWm52B7MFikjk4aHO-f3OhfRXmDwEcAI_z67fg4eFF7kBD8G7KzC4OvtwdnINvJHviXffQyDZrAaPIzfahOlQjOXS_395cS6eNysepkk2AWbz-dkl-OViNgePket82QRO_CKmHsHFHDyOfG9RrADHcpPSkq2yhbNJ76JYKnXKIqWJyviShx6X40uxlSO2koPgGCzFRhdz4GXDUgc4zoSyYfH3OJ_dft_n92eXZ2A5Sl_WHByDN7d85QT8DfjL5cWnj-Dnv2bLhgg8LJ6i2Mvc40VuUvZiZrCYla7MHhHIRAens6vr2bwQKnbNHFzVl_m57k35cVWHzuZV-L4D0J_C28Odu7fOzHweRnVn7yj7P2J5btcDqcXiAxlF987az7iSZI_SYlXwPo0K_knyDQaDx1F6C34CAwzegiAcFKskLX1vKJUVLh6CsaC4640qtBwOh5mOkQHeAjwUUlLxWzn4ExgMMDgC2sjUh2JwIJ7ATyLbBCOZQrJF-e7O43JQjOb756_ZP2FAydL9005pSnx_tuBJgPEkwdiF6J8uQZW0l1O4cLBYlDlarquZochYGcJylYC68EnZP5KnAwVR381PwSAnmkhCb9I7P7x_g3LcHsguiCWZLy5Pzy7FKwGnZ1cnCGDwYXY-uwZYgwiGkcfnzooncPI3iCGCFN4guI4jlydJFIvhr5nQzHuGEw1BP1xvUjF8g6AbxRxOvsLUTwMOJ_Da-RLwS-54PB4TiKDHU8cPMtUNNKeNkcX6nr9ABE-iYLMKkwko-R-BLVQQwau1I-bHBmMm1m3bNKhuYl0zydiyGWEmtawjiOCvv4HUX_EJoCMjke9uFKY8TP0ozKe0f_0zn4qjpwR43I087k0ARpphImqbcvLLS8oTEHPHmwBGwLn_sxxfXn48Aa4TBMkE6HJo7fhxIVrWcv7byQlIUr6W0Q8G_Dkd-2E6LImNmws4v28u0Mdis5XzDFZ8FcUvwAmCyHXS7Mu1_POShwC4601uKB6ZwtAvTure8QREm3S9SbOtGYUIZtaXBvOvuPmGoByVVCig_vIC7pzkrgrylMCbbzcIJqmz5HBCSkSancIJ-YYO4xKtbpOH9zT_uxAxsvC95yp3EBDjJbb8DmUQ_Q6PSs_jjzG_9Z_PQq9MGNskW17sTxkFVRhQEAUriPIdgoxxNyGkgJoQRAO_KgihU2lHgxENNtRYsEOY1hCmfRD-JfLDHGBWBbhIEUVi2GbvHOUPUXS_WYO_R34IonACprgO_XYFzL8hg0raJt-T1AmCIjRWSRl807RWfbEnjCGMFcnCHlF1trCaJNgp6aBCLjSuCytpYY3FNpuEeyBJY-6sMo_wZ-5uSkbhkZ20pxOjJZ0QFXkIs-r0KT60XyqhlVTCakRjrUTb6d2EUezxmHsVzTdi5fdEFGx97yR3grE8HhvVTw34bTqYkuFx7C_v0sGUDiGCF8LyKUZTgqYUTRma6mhqKHxPNEk2tfOtLXvEvEAg5as18PzkHmwSZykYCZrgEE1SupnsTcOs46NrBJmG3hMfXMFHr-Fj_JH4WCp88BYfvMVnHoVcAQnVaAckunUIItSyWxCxmQIRDWG9jsjO20bN21aftPtuuYz50kmjeJx1gCVPnVx8ml8vLi8-Xw2GCr9IC6p2tVi1fwkxa7Zg7Qeo8x1zcdXcq0_ni9n8OmdE3Vpdl6m-VjTZDxdNq24xrliM9--LtJYeu9RbF08Lz0kVTdKuPar0y8aI9S6ASNM08V9RAlsqINYUJbCkpqsIFmLj5gJ1f6RJtvdqmWlLxOqsUeO2X_EjWRTXmKEdSgz8nz98HXWevqqHL9KXTDYlyNBok0rUUFOJNZm009HBo1xoXBdWcohlfWrPQ5eu4pCNG_mi-ILXPHC1J5b_QhXWX7dL0ju7JP2gLomYrV1SI8KZrSPdrmf1H-uS9D8SH_NHuyRsd0DCDkKEEq0FEYM0LimYbSGitdfZepdk9smmpbbB7tUkWYomyXrtJsnu0_Bd8mQdhQmvE0i5k1bb6QgLGnFvySUtk2gTu_xjHLmZrHy9yBRlPvV4kspZW77MwmIqSZ1sMxjy9CmK70HgpDx0XybANGxZCIqZJ8dPiyCV1cPjCY99J_D_4ZQPrjIrFMsyb8bc5f5j1qlTDdk6LQkUpaSQ2B2vCokVTwQ9y0IYaZSpb85og5TFnplHxYF7e_G1v-doq-caaVE6pyUER_iQGFTnRMvQm6YaiDFWNVWvm4rrpmplU0nFVK2sSatrIj3oRg6lW34Voqab2cU2TAjScBfbzC0gHWyTFyjNa5XGIbHYr-J-2s9ptNVpva6IKLHyG8Z-9VfJNMIMlalYqzHNqJtKO03F2usQhI1oO0GY3cUQomvIZnYHQ7C9TzpipooiYrxBkmLLiufsfp5je5Mk901Lk7a9hu5FEqxmCc5ST8NajCxsVK3FjezLOlOS3p6SMKur0jtVGc1EvlXVoK_RqQr3yZRmn0joqi90ZHVchI3IIfUFtzXdihbPtm2kE70KqNnPXLZ_H2IRqzXuaVdhIJ1xj7PLAWbqnbVhr9CX6WOvS8TdrtVwaLDFOrCNa5YI89WbEUPJFZM2emdmmIhgs2ZrP1Pb-65eTMEyaFo6VtLFFGboiFpGJ0_26FhtTdWv2hppek3uV_FaI8nZhxbWXvXB1g6rD3pLOpG_odd-iTIR0UnVXKufue3VsBdJOtsI2nmsIcxClL5CG0HVuYRRhePkltXoaoQXbpxrqjUMd5TWRueKu08Oitp6CA6WvKBr6fdpdV09r3dBoBPwHQTonncCFTfp4jh-G0RPC9-DE2jaty43LPtIs26tI-bY2pHFHXrkcUpvictsNztO3AbOMoGTr_DqLnrKXHb9shYn-lsnSDiC5849P-Upj1d-6Cep7-Yz3779378DAAD__2a4sfI=
  Diagram 3 (subquery): https://cockroachdb.github.io/distsqlplan/decode.html#eJzcVVFv4jgQfr9fMfJLk9akBAoLkZC2t3C7OW3DCrhbnU4ImdhJo4YYYge2qvjvJ9tJCRG7t_fY60vjb2a-yffNxLwgsUuRh776i0-wW1EepiyD-zlY88nnyYcFUCeh6pxQDKLYWHsn5EUmbYWV2b_Npg_qudiwTAodAD8IJjP4feoHsOchWRcpyZ9VaA_TAPZOQldVBYxMk1rJK9mKFPKR54aU1FNqgTM8ZhllBo9VK6JaGRBGEKtG0wCohg0HjHSShtX_URl9fb-vnyazCcSOfN4yGMFVxDYkZVfwcTb94wv8-pcuszHsVgeeU20P5aGou6gFq6ixUj9i0KnW2J8v_KBKqrpqg8_5tM9NN83LnRvqB-fj-5cBvQm37ZPdr2ZqzzPeNPu0sv8T5aWuXafxLe46Dn8i20TvitCPRvGlj_fgVPtnls-yrL0jI7gGy4UbSDOrqjJrmVDbkFUW23CrVjykztla2ratOZw-3IBrqyxDfGPAa7AsF1rQdt71bAVa6gmu1W2TOuYK0UVld7KPrQot-5dH_acE1JT-_LVTC6n31wUHNYyDGcbpE31zF1SNvX6FK4NVkTba1DVkXLix9IRNlRp15UndH7On1oVFvQ_GYJWLpi6hK_mYZE9XuJzbrnP6iM0yT2fjyUwdOzCezD9gcOGz_-AvwG0jjDJOWUA2TCDvb-SiJUbbnIdMCJ4r6EUn-PQb8toYJdm2kApeYhTynCHvBclEpgx5KOUhSUGEJIN1EUUsh_atakCZJEmq6aeF9OB9B2HEvrGwkAnPQCYb5kHv3WAjEFY_lBBuiwrt9zS6JjJ8ZAJ4IbeKYji4Qxjl_FCDhgPc7fXR8oiRwcrXFJLEDHluTZc_Rl77iH9e2n0c5ywmkue37rmi-z8_Wu9d-4Kiu-4FQSXY1OM21bjf1dFp6HD_i44ZE1ueCXam4Xud2o1OLfe4xIjRmJm9ELzIQ_Yl56HONcepJtIAZUKaqGsOflaFhMwZ2byOoc7k_pCp8yOmJUZRyg-rhCIPDbvdiAx7pLXur9etOzYYtgbtaNDqs0G3cxetu-v-AKkCEgtl0fyRHzTt4nmrBEYkFQyjB_LExkyyfJNkiZBJWEaOx1_-CQAA__9Gvhhm
  Diagram 4 (main-query): https://cockroachdb.github.io/distsqlplan/decode.html#eJzcWutu4zYW_r9PQejPyAkji9TdQABNk3TrNnEGiadFsR0YikU72tiSI8m5oJjH2hfYJ1uQkm2JomgrDabbDjCJzMsh-X3fOTw6zu9K9rhQBsovw_EP4HESJtMFicHHW6DeXlxenI1BqEUh_RyFEGTrpfqkTZN1nPdoWzn6-5vrK_q8XpI4z1gHGI5GFzfgx-vhCDwl0-BuvQjSV9r1BK5H4EmLwslmBjgtFqlM2RqbBOv8PkkLo0F1SKWj1j4ncUiK9jldKqBLFY3gFMzpQtcjELLmwgY4ZYNYM_19WvZu9_fLDxc3F2Cu5a8rAk7BhxlZBgvyAfzz5vrzJ_Ddr2xaD4LHyXOShgyeMJlmVRTZgWlvASV7hIANVc-Ht-PhaDNosyoDuG6P4cyjWWyuDuhwVKdvD0F_CbR7O7i3YDLM44QHeyfZv8nJy3M9Ys4XH7GWPASriGklY4_FiUXO-6xt9FeIT1XVJy2fgSOgInAMFrG6mVXIMgp7hbENxD3QpxKfhlpNlr1ej9nQbHAMUI-OKgwfF41HQFUROAG65lg92qjSJ3BEo81CK0IIm1SuHjzN1U1ruX75kf2jB6ic9PCwU-mi-2cTnikZzwUZOxf9ywWoivVqCKcA00kM6GIedwxBxGIMF7Mo1RtMqvgUOlUFQv04OgdqKTQahD7k91H88AGWvD3inRMXYr6-Ob-4oR8xOL-4PYMAgcvh1XAMkK5AJU5CMgqWJFMG_1KQ8gUqqzSZkixLUtr0OxswDF-UgQ6VKF6tc9r8BSrTJCXK4Hclj_IFUQbKOLhbkBsShCTtU8MhyYNowczuZOLvHierB_KqQOUsWayXcTYAFbThJn4rULldBbT3RIHKTz-DPFqSATB0DWVFwzSJcxLnURKXffp__1N2pclzBkIyTUISDoALXQNDHdlF591rTjKQkiAcANNwwFX0XdExv_l0BqbBYpENgGkWbasgSjeDq3aufj47A1lOVoU_A5W85P0oznuVYf3mBEIemhMss2_R5ZbBC1iSZZK-gmCxSKZBTneP9HKH2eMCTFfr8rAIa5ie9i7Ip_ckA8k6X61zurqN6XoMgl3jZiNfvkKlaC3JzPJgTpQBqrA_PFcG-lf4NgGgugC2ruzvnHrzNAmDnEyi8KWuhRbmbc3rSjyGuq7T_03iPUPMO9KbvFfNSHjfDus3Jwh5R3qfLdeJd6y5ItoR9JiGarTv9tFGO-ZoR2-lHbfQvongfqNlbxQoxrWqAb-jGhxXrAb324nB63vdpeC8oxQMTgr4rVIw6lIob2S__D2h11rT6SGg7Tuy-78pxb33m3JSee5_SsksermIw6oYPORuOT9YDkhwG5hAFBKaIkBy8lEf7fF8NkBMNtbBTwKyzfIcDbZ5plErwybHsNGF4R-TKC4JNusEbzx849fbhKtk-TJJHtYr8O8kikESD4CPeOq3M5RyD4yq4mzF5ywPFosN2463pbRocUxz2TkamCZEyBHcDFrb1SAIBlsjslBQDOrzgyXKIC9kuq4cAhWe3kkwnuUtRYLBptsIDuXO2oRjccIxW4Wz08s6TtKQpCSsieULnblviEB9PwTZPVUgSftWXX0LMstVH_dO02h-n6u-0VOgck1P5SPoY-gb0Dehb0HfFgCLdWfZjiyySyXQbopuTpYrEEbZA1hnwZyqCwjCcmnzoLjseS40rPa8zOagt_5M6G0R9GgLPWqHHvqOAH3XNiXou3gf-ob4XrQ9W0yABW0Dd2XA4Riw_0wGnDoD49cVGYDLi-_H4PbiasheOxUoIwaLnKDIpcQsOM4-FjxP_IIizk5sD-p6gwQTGq4HbdNopcHlaHC6XF4f5_OUzIM8SftuHUF2GX0c_ToZXY8no8-XlyVaZ9efR-PJzfUvt2pPCJnRDpnl7RWu3ZLQIaFuzUbYQIYHXbP9qvc4tNwuaNGDLEA2DWJwt57NSAp0lpxWYOPxsFFx2dTPY3niK8hzO8dBpHMn8t78gsqVKFi5ymc_WeFBlJvWCxL93xRWeSlS0_JRnJniznmJKC01_n_TUgP_4bQU8bUH1Kn4UElMETqk-lQWmA7MTpuVKQjy2UGJ6pb80huc7mIwoGsLclRHN0o2DhDFxoZMGWxMnxvaJUHFnuQmb9GOg8UJqtGMdmxfrQJqVDHayxjf4I5GWJ4mSTJUcZpkuLIcVXtTklrabERmp_FyYEPPttqx58sGqFPdoOq8xptLSA0ftg6qK1U9uDilyItdnfNjT9c7O_LGPOfH2PHEfoybfrwxIXFjNqRfHyh04vpAXm-eo8ucWXOFyUs5qXERNIrRewTFVynQW8sUaE-dok083qHliXbNoKJIuwv9pvcGyVgsEnKSQVYXyRQmJJLR-3vqksxGf2OpmffJ3uCwJs5zbet9pMLXJVB7YWKPVKz931ocGGsO1gjWzJpGXMd9r7CyuxM4jRhvCisHaEQaTixpbqBZQo247xRO-AIK-lMrKGhPCcWW5gbQd6HvQR_p0EcI-ghDHxnQZ5GuUVx5_6RBnDM4HRnhCyqovaKy71XO-eZfNdi697f_qgF7f_ydji_XoPZ6zbdwO1fodsaBpct2v4M-sqCPRKVlz7ELGFuwdzbgd3LBrdU_6oV8hQh1KhGNkpNk1UdcVeiG-d0AqKrvHamLWPU817DswWAwHI3d4mffx71jNBgMzi_OhlcfL3u9I6zZlc991feOVVVVffNI1xyr2mVqFnJNzzZ1V_dMT3d17Lq7AbuRx7qGqzOPUG2NHgTioGkZjqiOZYgr-h0xx3wNC3UqYlWKmJirYbGybr2Kiamibz9fldpuvFNKbgdD09_0SvkuGPHFINypGHSbpDlJ-xjx-JxAHx0rUBknq5_Kv_JoQGI6ModFb_JXw7QODaaSv9LgCxy4099p3JBslcQZ4aOqcC1eoyeIxlYSzkkRq7NknU7JpzSZsrHFx2tmiDWEJMuLXqf4MIxZF6IrpCRYbr_FqlpCUkt2uyWDt4Sllqx2S4i3ZEgtmTVLetWSzlsyO-wJVy1h3pLVAaeaJZO3ZHfgrmbJ5i05UktuO04Ob8mVWkISGaDG-Ty5Ldxuy2uIU65zhNqP6DZsyZXO7asGPGroCsnFjoz2jaGG3JFc70gieNTQKZJLHlkSYw2XRnLVI4nsUTPSyIWPXInIGtJHcu1zxuo7a6gf7ZG_J8GsqTO5_rEuMdZwACx3ACxxANwQLZZ7AMaywPoFKrNF8jyJQmWgzAJE8MxDJyGxZyemge9OAjO0TgLX9ELbsGc2mSp0QjDP6H14e588M7Pj1xW9zWbBIiNQuQoeyDnJSbqM4ijLo2nZ8_XrP_4XAAD__4mDWxg=

  planning time: 30ms
  execution time: 1m59s
  distribution: local
  vectorized: true
  rows decoded from KV: 30,430,708 (1.4 GiB, 166 gRPC calls)
  cumulative time spent in KV: 1m46s
  maximum memory usage: 111 MiB
  network usage: 68 MiB (7,055 messages)
  max sql temp disk usage: 108 MiB
  sql cpu time: 1m1s
  isolation level: serializable
  priority: normal
  quality of service: regular

  • root
  │
  ├── • top-k
  │   │ nodes: n1
  │   │ actual row count: 10
  │   │ estimated max memory allocated: 10 KiB
  │   │ estimated max sql temp disk usage: 0 B
  │   │ sql cpu time: 345µs
  │   │ estimated row count: 10
  │   │ order: -sum,+id
  │   │ k: 10
  │   │
  │   └── • group (hash)
  │       │ nodes: n1
  │       │ actual row count: 6,965
  │       │ estimated max memory allocated: 3.0 MiB
  │       │ estimated max sql temp disk usage: 0 B
  │       │ sql cpu time: 3ms
  │       │ estimated row count: 29
  │       │ group by: id
  │       │
  │       └── • render
  │           │
  │           └── • hash join
  │               │ nodes: n1
  │               │ actual row count: 6,965
  │               │ estimated max memory allocated: 270 KiB
  │               │ estimated max sql temp disk usage: 0 B
  │               │ sql cpu time: 976µs
  │               │ estimated row count: 51
  │               │ equality: (id_gender) = (id)
  │               │ right cols are key
  │               │
  │               ├── • hash join
  │               │   │ nodes: n1
  │               │   │ actual row count: 6,965
  │               │   │ estimated max memory allocated: 1.6 MiB
  │               │   │ estimated max sql temp disk usage: 0 B
  │               │   │ sql cpu time: 8ms
  │               │   │ estimated row count: 15
  │               │   │ equality: (id_word) = (id_word)
  │               │   │ left cols are key
  │               │   │
  │               │   ├── • render
  │               │   │   │
  │               │   │   └── • group (hash)
  │               │   │       │ nodes: n1
  │               │   │       │ actual row count: 139,841
  │               │   │       │ estimated max memory allocated: 59 MiB
  │               │   │       │ estimated max sql temp disk usage: 36 MiB
  │               │   │       │ sql cpu time: 2.1s
  │               │   │       │ estimated row count: 218,100
  │               │   │       │ group by: id_word
  │               │   │       │
  │               │   │       └── • hash join (semi)
  │               │   │           │ nodes: n1
  │               │   │           │ actual row count: 4,389,643
  │               │   │           │ estimated max memory allocated: 77 MiB
  │               │   │           │ estimated max sql temp disk usage: 99 MiB
  │               │   │           │ sql cpu time: 1.7s
  │               │   │           │ estimated row count: 3,234,024
  │               │   │           │ equality: (id_document) = (id)
  │               │   │           │
  │               │   │           ├── • scan
  │               │   │           │     nodes: n1
  │               │   │           │     actual row count: 8,832,016
  │               │   │           │     KV time: 30.1s
  │               │   │           │     KV contention time: 0µs
  │               │   │           │     KV rows decoded: 8,832,016
  │               │   │           │     KV bytes read: 437 MiB
  │               │   │           │     KV gRPC calls: 44
  │               │   │           │     estimated max memory allocated: 10 MiB
  │               │   │           │     sql cpu time: 12.2s
  │               │   │           │     estimated row count: 8,832,016 (100% of the table; stats collected 15 minutes ago)
  │               │   │           │     table: vocabulary@vocabulary_pkey
  │               │   │           │     spans: FULL SCAN
  │               │   │           │
  │               │   │           └── • hash join
  │               │   │               │ nodes: n1
  │               │   │               │ actual row count: 998,356
  │               │   │               │ estimated max memory allocated: 82 MiB
  │               │   │               │ estimated max sql temp disk usage: 30 MiB
  │               │   │               │ sql cpu time: 696ms
  │               │   │               │ estimated row count: 991,711
  │               │   │               │ equality: (id) = (id_document)
  │               │   │               │ left cols are key
  │               │   │               │
  │               │   │               ├── • scan
  │               │   │               │     nodes: n1
  │               │   │               │     actual row count: 2,000,000
  │               │   │               │     KV time: 6.9s
  │               │   │               │     KV contention time: 0µs
  │               │   │               │     KV rows decoded: 2,000,000
  │               │   │               │     KV bytes read: 93 MiB
  │               │   │               │     KV gRPC calls: 10
  │               │   │               │     estimated max memory allocated: 10 MiB
  │               │   │               │     sql cpu time: 2.8s
  │               │   │               │     estimated row count: 2,000,000 (100% of the table; stats collected 15 minutes ago)
  │               │   │               │     table: documents@documents_document_date_idx
  │               │   │               │     spans: FULL SCAN
  │               │   │               │
  │               │   │               └── • hash join
  │               │   │                   │ nodes: n1
  │               │   │                   │ actual row count: 998,356
  │               │   │                   │ estimated max memory allocated: 16 MiB
  │               │   │                   │ estimated max sql temp disk usage: 0 B
  │               │   │                   │ sql cpu time: 207ms
  │               │   │                   │ estimated row count: 991,711
  │               │   │                   │ equality: (id_author) = (id)
  │               │   │                   │ right cols are key
  │               │   │                   │
  │               │   │                   ├── • scan
  │               │   │                   │     nodes: n1
  │               │   │                   │     actual row count: 2,000,000
  │               │   │                   │     KV time: 6.2s
  │               │   │                   │     KV contention time: 0µs
  │               │   │                   │     KV rows decoded: 2,000,000
  │               │   │                   │     KV bytes read: 78 MiB
  │               │   │                   │     KV gRPC calls: 8
  │               │   │                   │     estimated max memory allocated: 10 MiB
  │               │   │                   │     sql cpu time: 2.7s
  │               │   │                   │     estimated row count: 2,000,000 (100% of the table; stats collected 15 minutes ago)
  │               │   │                   │     table: documents_authors@documents_authors_pkey
  │               │   │                   │     spans: FULL SCAN
  │               │   │                   │
  │               │   │                   └── • lookup join
  │               │   │                       │ nodes: n1
  │               │   │                       │ actual row count: 244,117
  │               │   │                       │ KV time: 744ms
  │               │   │                       │ KV contention time: 0µs
  │               │   │                       │ KV rows decoded: 244,117
  │               │   │                       │ KV bytes read: 9.3 MiB
  │               │   │                       │ KV gRPC calls: 1
  │               │   │                       │ estimated max memory allocated: 20 KiB
  │               │   │                       │ sql cpu time: 959ms
  │               │   │                       │ estimated row count: 244,256
  │               │   │                       │ table: authors@authors_id_gender_idx
  │               │   │                       │ equality: (id) = (id_gender)
  │               │   │                       │
  │               │   │                       └── • scan
  │               │   │                             nodes: n1
  │               │   │                             actual row count: 1
  │               │   │                             KV time: 918µs
  │               │   │                             KV contention time: 0µs
  │               │   │                             KV rows decoded: 1
  │               │   │                             KV bytes read: 44 B
  │               │   │                             KV gRPC calls: 1
  │               │   │                             estimated max memory allocated: 20 KiB
  │               │   │                             sql cpu time: 40µs
  │               │   │                             estimated row count: 1 (50% of the table; stats collected 15 minutes ago)
  │               │   │                             table: genders@genders_type_idx
  │               │   │                             spans: [/'female' - /'female']
  │               │   │
  │               │   └── • lookup join
  │               │       │ nodes: n1
  │               │       │ actual row count: 6,965
  │               │       │ KV time: 878ms
  │               │       │ KV contention time: 0µs
  │               │       │ KV rows decoded: 6,965
  │               │       │ KV bytes read: 1.6 MiB
  │               │       │ KV gRPC calls: 3
  │               │       │ estimated max memory allocated: 2.5 MiB
  │               │       │ sql cpu time: 80ms
  │               │       │ estimated row count: 15
  │               │       │ table: documents@documents_pkey
  │               │       │ equality: (id_document) = (id)
  │               │       │ equality cols are key
  │               │       │
  │               │       └── • lookup join
  │               │           │ nodes: n1
  │               │           │ actual row count: 6,965
  │               │           │ KV time: 549ms
  │               │           │ KV contention time: 0µs
  │               │           │ KV rows decoded: 6,523
  │               │           │ KV bytes read: 159 KiB
  │               │           │ KV gRPC calls: 2
  │               │           │ estimated max memory allocated: 2.6 MiB
  │               │           │ sql cpu time: 65ms
  │               │           │ estimated row count: 15
  │               │           │ table: authors@authors_pkey
  │               │           │ equality: (id_author) = (id)
  │               │           │ equality cols are key
  │               │           │
  │               │           └── • lookup join
  │               │               │ nodes: n1
  │               │               │ actual row count: 6,965
  │               │               │ KV time: 900ms
  │               │               │ KV contention time: 0µs
  │               │               │ KV rows decoded: 6,965
  │               │               │ KV bytes read: 279 KiB
  │               │               │ KV gRPC calls: 2
  │               │               │ estimated max memory allocated: 2.8 MiB
  │               │               │ sql cpu time: 70ms
  │               │               │ estimated row count: 15
  │               │               │ table: documents_authors@documents_authors_pkey
  │               │               │ equality: (id_document) = (id_document)
  │               │               │
  │               │               └── • hash join
  │               │                   │ nodes: n1
  │               │                   │ actual row count: 6,965
  │               │                   │ estimated max memory allocated: 1.6 MiB
  │               │                   │ estimated max sql temp disk usage: 0 B
  │               │                   │ sql cpu time: 38ms
  │               │                   │ estimated row count: 15
  │               │                   │ equality: (id) = (id_document)
  │               │                   │ left cols are key
  │               │                   │
  │               │                   ├── • scan buffer
  │               │                   │     nodes: n1
  │               │                   │     actual row count: 998,356
  │               │                   │     sql cpu time: 599ms
  │               │                   │     estimated row count: 781,901
  │               │                   │     label: buffer 1 (q_doclen)
  │               │                   │
  │               │                   └── • lookup join
  │               │                       │ nodes: n1
  │               │                       │ actual row count: 13,867
  │               │                       │ KV time: 57ms
  │               │                       │ KV contention time: 0µs
  │               │                       │ KV rows decoded: 13,867
  │               │                       │ KV bytes read: 703 KiB
  │               │                       │ KV gRPC calls: 1
  │               │                       │ estimated max memory allocated: 20 KiB
  │               │                       │ sql cpu time: 72ms
  │               │                       │ estimated row count: 41
  │               │                       │ table: vocabulary@vocabulary_id_word_idx
  │               │                       │ equality: (id) = (id_word)
  │               │                       │
  │               │                       └── • scan
  │               │                             nodes: n1
  │               │                             actual row count: 1
  │               │                             KV time: 2ms
  │               │                             KV contention time: 0µs
  │               │                             KV rows decoded: 1
  │               │                             KV bytes read: 43 B
  │               │                             KV gRPC calls: 1
  │               │                             estimated max memory allocated: 20 KiB
  │               │                             sql cpu time: 32µs
  │               │                             estimated row count: 1 (<0.01% of the table; stats collected 15 minutes ago)
  │               │                             table: words@words_word_idx
  │               │                             spans: [/'think' - /'think']
  │               │
  │               └── • scan
  │                     nodes: n1
  │                     actual row count: 1
  │                     KV time: 609µs
  │                     KV contention time: 0µs
  │                     KV rows decoded: 1
  │                     KV bytes read: 44 B
  │                     KV gRPC calls: 1
  │                     estimated max memory allocated: 20 KiB
  │                     sql cpu time: 29µs
  │                     estimated row count: 1 (50% of the table; stats collected 15 minutes ago)
  │                     table: genders@genders_type_idx
  │                     spans: [/'female' - /'female']
  │
  ├── • subquery
  │   │ id: @S1
  │   │ original sql: SELECT d.id AS id, sum(v.count) AS doclen FROM documents AS d INNER JOIN vocabulary AS v ON v.id_document = d.id INNER JOIN documents_authors AS da INNER JOIN authors AS a INNER JOIN genders AS g ON a.id_gender = g.id ON da.id_author = a.id ON d.id = da.id_document WHERE g.type = 'female' GROUP BY d.id
  │   │ exec mode: all rows
  │   │
  │   └── • buffer
  │       │ nodes: n1
  │       │ actual row count: 998,356
  │       │ sql cpu time: 633ms
  │       │ label: buffer 1 (q_doclen)
  │       │
  │       └── • group (hash)
  │           │ nodes: n1
  │           │ actual row count: 998,356
  │           │ estimated max memory allocated: 55 MiB
  │           │ estimated max sql temp disk usage: 18 MiB
  │           │ sql cpu time: 3.5s
  │           │ estimated row count: 781,901
  │           │ group by: id
  │           │
  │           └── • hash join
  │               │ nodes: n1
  │               │ actual row count: 4,389,643
  │               │ estimated max memory allocated: 84 MiB
  │               │ estimated max sql temp disk usage: 46 MiB
  │               │ sql cpu time: 1.6s
  │               │ estimated row count: 4,101,818
  │               │ equality: (id_document) = (id)
  │               │
  │               ├── • scan
  │               │     nodes: n1
  │               │     actual row count: 8,832,016
  │               │     KV time: 30.5s
  │               │     KV contention time: 0µs
  │               │     KV rows decoded: 8,832,016
  │               │     KV bytes read: 437 MiB
  │               │     KV gRPC calls: 44
  │               │     estimated max memory allocated: 10 MiB
  │               │     sql cpu time: 12.6s
  │               │     estimated row count: 8,832,016 (100% of the table; stats collected 15 minutes ago)
  │               │     table: vocabulary@vocabulary_pkey
  │               │     spans: FULL SCAN
  │               │
  │               └── • hash join
  │                   │ nodes: n1
  │                   │ actual row count: 998,356
  │                   │ estimated max memory allocated: 82 MiB
  │                   │ estimated max sql temp disk usage: 30 MiB
  │                   │ sql cpu time: 707ms
  │                   │ estimated row count: 991,711
  │                   │ equality: (id) = (id_document)
  │                   │ left cols are key
  │                   │
  │                   ├── • scan
  │                   │     nodes: n1
  │                   │     actual row count: 2,000,000
  │                   │     KV time: 7s
  │                   │     KV contention time: 0µs
  │                   │     KV rows decoded: 2,000,000
  │                   │     KV bytes read: 93 MiB
  │                   │     KV gRPC calls: 10
  │                   │     estimated max memory allocated: 10 MiB
  │                   │     sql cpu time: 2.8s
  │                   │     estimated row count: 2,000,000 (100% of the table; stats collected 15 minutes ago)
  │                   │     table: documents@documents_document_date_idx
  │                   │     spans: FULL SCAN
  │                   │
  │                   └── • hash join
  │                       │ nodes: n1
  │                       │ actual row count: 998,356
  │                       │ estimated max memory allocated: 16 MiB
  │                       │ estimated max sql temp disk usage: 0 B
  │                       │ sql cpu time: 262ms
  │                       │ estimated row count: 991,711
  │                       │ equality: (id_author) = (id)
  │                       │ right cols are key
  │                       │
  │                       ├── • scan
  │                       │     nodes: n1
  │                       │     actual row count: 2,000,000
  │                       │     KV time: 7.4s
  │                       │     KV contention time: 0µs
  │                       │     KV rows decoded: 2,000,000
  │                       │     KV bytes read: 78 MiB
  │                       │     KV gRPC calls: 8
  │                       │     estimated max memory allocated: 10 MiB
  │                       │     sql cpu time: 3.3s
  │                       │     estimated row count: 2,000,000 (100% of the table; stats collected 15 minutes ago)
  │                       │     table: documents_authors@documents_authors_pkey
  │                       │     spans: FULL SCAN
  │                       │
  │                       └── • lookup join
  │                           │ nodes: n1
  │                           │ actual row count: 244,117
  │                           │ KV time: 896ms
  │                           │ KV contention time: 0µs
  │                           │ KV rows decoded: 244,117
  │                           │ KV bytes read: 9.3 MiB
  │                           │ KV gRPC calls: 1
  │                           │ estimated max memory allocated: 20 KiB
  │                           │ sql cpu time: 1.2s
  │                           │ estimated row count: 244,256
  │                           │ table: authors@authors_id_gender_idx
  │                           │ equality: (id) = (id_gender)
  │                           │
  │                           └── • scan
  │                                 nodes: n1
  │                                 actual row count: 1
  │                                 KV time: 797µs
  │                                 KV contention time: 0µs
  │                                 KV rows decoded: 1
  │                                 KV bytes read: 44 B
  │                                 KV gRPC calls: 1
  │                                 estimated max memory allocated: 20 KiB
  │                                 sql cpu time: 37µs
  │                                 estimated row count: 1 (50% of the table; stats collected 15 minutes ago)
  │                                 table: genders@genders_type_idx
  │                                 spans: [/'female' - /'female']
  │
  ├── • subquery
  │   │ id: @S2
  │   │ original sql: (SELECT count(id) FROM q_nodocs)
  │   │ exec mode: one row
  │   │
  │   └── • group (scalar)
  │       │ nodes: n1
  │       │ actual row count: 1
  │       │ sql cpu time: 54µs
  │       │ estimated row count: 1
  │       │
  │       └── • hash join
  │           │ nodes: n1, n3
  │           │ actual row count: 998,356
  │           │ estimated max memory allocated: 102 MiB
  │           │ estimated max sql temp disk usage: 0 B
  │           │ sql cpu time: 709ms
  │           │ estimated row count: 991,711
  │           │ equality: (id) = (id_document)
  │           │ left cols are key
  │           │
  │           ├── • scan
  │           │     nodes: n3
  │           │     actual row count: 2,000,000
  │           │     KV time: 6.4s
  │           │     KV contention time: 0µs
  │           │     KV rows decoded: 2,000,000
  │           │     KV bytes read: 93 MiB
  │           │     KV gRPC calls: 10
  │           │     estimated max memory allocated: 10 MiB
  │           │     sql cpu time: 3s
  │           │     estimated row count: 2,000,000 (100% of the table; stats collected 15 minutes ago)
  │           │     table: documents@documents_document_date_idx
  │           │     spans: FULL SCAN
  │           │
  │           └── • hash join
  │               │ nodes: n1, n3
  │               │ actual row count: 998,356
  │               │ estimated max memory allocated: 17 MiB
  │               │ estimated max sql temp disk usage: 0 B
  │               │ sql cpu time: 428ms
  │               │ estimated row count: 991,711
  │               │ equality: (id_author) = (id)
  │               │ right cols are key
  │               │
  │               ├── • scan
  │               │     nodes: n1, n3
  │               │     actual row count: 2,000,000
  │               │     KV time: 6.8s
  │               │     KV contention time: 0µs
  │               │     KV rows decoded: 2,000,000
  │               │     KV bytes read: 78 MiB
  │               │     KV gRPC calls: 9
  │               │     estimated max memory allocated: 20 MiB
  │               │     sql cpu time: 3.2s
  │               │     estimated row count: 2,000,000 (100% of the table; stats collected 15 minutes ago)
  │               │     table: documents_authors@documents_authors_pkey
  │               │     spans: FULL SCAN
  │               │
  │               └── • lookup join (streamer)
  │                   │ nodes: n1
  │                   │ actual row count: 244,117
  │                   │ KV time: 778ms
  │                   │ KV contention time: 0µs
  │                   │ KV rows decoded: 244,117
  │                   │ KV bytes read: 9.3 MiB
  │                   │ KV gRPC calls: 8
  │                   │ estimated max memory allocated: 16 MiB
  │                   │ sql cpu time: 1.2s
  │                   │ estimated row count: 244,256
  │                   │ table: authors@authors_id_gender_idx
  │                   │ equality: (id) = (id_gender)
  │                   │
  │                   └── • scan
  │                         nodes: n1
  │                         actual row count: 1
  │                         KV time: 972µs
  │                         KV contention time: 0µs
  │                         KV rows decoded: 1
  │                         KV bytes read: 44 B
  │                         KV gRPC calls: 1
  │                         estimated max memory allocated: 20 KiB
  │                         sql cpu time: 53µs
  │                         estimated row count: 1 (50% of the table; stats collected 15 minutes ago)
  │                         table: genders@genders_type_idx
  │                         spans: [/'female' - /'female']
  │
  └── • subquery
      │ id: @S3
      │ original sql: (SELECT avg(doclen) FROM q_doclen)
      │ exec mode: one row
      │
      └── • group (scalar)
          │ nodes: n1
          │ actual row count: 1
          │ sql cpu time: 43ms
          │ estimated row count: 1
          │
          └── • scan buffer
                nodes: n1
                actual row count: 998,356
                sql cpu time: 565ms
                estimated row count: 781,901
                label: buffer 1 (q_doclen)
*/
