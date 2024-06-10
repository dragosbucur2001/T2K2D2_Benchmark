-- \set startDate '''2015-09-17 00:00:00'''
-- \set endDate '''2015-09-18 00:00:00'''
-- \set xStart 20
-- \set xEnd 40
-- \set yStart -100
-- \set yEnd 100
-- \set gender '''female'''
-- \set k1 1.6
-- \set b 0.75
-- \set top 10
-- \set words ('''think''')

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
                    inner join geo_location gl
                    on d.id_geo_loc = gl.id 
                where g.type = 'female'
                    and gl.X between 20 and 40
                    and gl.Y between -100 and 100
                    and d.document_date between '2015-09-17 00:00:00' and '2015-09-18 00:00:00'
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
                                                    inner join geo_location gl
                                                        on d.id_geo_loc = gl.id 
                                                    where g.type = 'female'
                                                        and gl.X between 20 and 40
                                                        and gl.Y between -100 and 100
                                                        and d.document_date between '2015-09-17 00:00:00' and '2015-09-18 00:00:00')
                            group by v.id_word),
    q_noDocs as (select d.id id
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
                inner join geo_location gl
                on d.id_geo_loc = gl.id 
                inner join q_docLen q_dl
                on q_dl.id = d.id
                inner join q_wordCountDocs q_wcd
                on q_wcd.id_word =  v.id_word
            where g.type = 'female'
                and gl.X between 20 and 40
                and gl.Y between -100 and 100
                and d.document_date between '2015-09-17 00:00:00' and '2015-09-18 00:00:00'
                and w.word in ('think')) q2
        group by q2.id
        order by 2 desc, 1
        limit 10;

/*

  Diagram 1 (subquery): https://cockroachdb.github.io/distsqlplan/decode.html#eJzsWO1uo8jS_v9eRYk_wTNtTDffSJHIJN53vJvYo8Szo9WZyMLQdjjB4ADOh0ZzWecGzpUddQM25sOJ8-PsSmdXuxtTVV3dVfXUUw0_hPQhFGzh22j6GR5mfuyFNIKzGxBvhpfD8yn4UuCz58BHkG5W4qPkxZso6zFZYf3L9eSK_d6saJSlXAGj8Xh4Db9ORmN4jD13vgnd5IWpHmEyhkcp8GflCjjNN6ks2TqbuZvsLk5yp27VpKLYky9p5NNcvmRbuWyrXAinsGQbTcbgc3HuA065ERezv6eFdnu-Pe_xLIw9NwtinqVlWC6bFSq2ScjcfPs8vB6CKIpLKXtZUziFkwVduSE96cHZ-ALEZSg9w6fh9NtwOAYic6Eq93bal622j-Vcj-WtgS-VB5z5bka3tidExlpftvrYAFm2-b8nfMlOY-40Pfj_68nXL_DpDx5GD8HD7ClOfF5lP_bSKhh43Zg2RwT_iYCbihejm-loXBqVZ-M42ffH4VIHRZ6tx1re91H4Cs7-Bs1_DzQV1GwxwaETxXXM7Ajk7wL-lQpYlOeB1Aj-gUjxvbsOeOem_GdeuLaJ8CSVbJBTgSiKj1K2gA8gYvgIYSSWq3KSCPxe7qxESg8GjHA8X9ojiV6vx31IOnwE3GNWueOPufADiCKGPsiSofWYUGS_4AMbYaGUzyW-qNjdfVyKpbTYv3jk_7AAKpG-fZZVVOz8fMETA8dTjqkdYf6PTL3KquptgpWFreHlyXdrWDemDsdFvooBpMxkNavbdvvr9xt3V_QLm2wn2V0Q3Z-gAn4PZEepeU9Ori-G1-yRwMXw5hwBhsvR1WgKWBaQEMU-Hbsrmgr2PwQs3CJhncQeTdM4YaIf3GDkPwu2jIQgWm8yJr5FghcnVLB_CFmQhVSwhak7D-k1dX2aDJhjn2ZuEHK3O7Q7u5-z9T19EZBwHoebVZTaUAFNcRcQkHCzdpmuLyDht98hC1bUBkWWtDQXeHGU0YjjKdfJ__5XoUripxR86sU-9W0wkakQJGM9V85fMppCQl3fBlUx4Cr4lCuW11_OwXPDMLVBVXPZ2g2S0rjq5-r383NIM7rOTwsifc4GQZT1KmaD5gJK75sLNHWgse1W7jOs6CpOXsANea-w02O5OGH6EIK33hTBYiLpLNq5m3l3NIV4k603GdtdJ2w_noKdsDzI7U8k5NKilGnmLqlg40rtRxeCLf9E7ys_3i9_g4-chuQwGLZk0wEIXVKOxQNBsiyz_5p4MMx2OJhNNFS9HEDD1mzQXNCKBmtgHYsFIpltUMDI4rjag8LuFF1QIDUo4PdCgexDoToBnOrD7GUW-M_7CEDwjOBlV_MBI9b-AMt4jw3M1bHFNxBRWoiAGAR-a6s8bla-dHGg6txksG_YWm3MG6a92gqRizPVWl9ftXZ-vdT59l1lVmplJseU-ZcgzGhCk4GyX-NcboPoEPi-kWWFngKRbdsejadmMb9KlXcK6lYlIIE-U29TqSDhUdaQ_rbIVUQI7oxcrUWuHBP5r3EQFfhWO6iuQnG7200B8cs4vt-s4Z9xEEEc2eCw8k_GIDr6NmGVe8GJbdsXZ9NhmTp9m7rKFWFrVG-h3e4I9q4gQhEj740yXaUszdwwLPKtbhuseD6ebS1LQYaltcxevZ1rtWbH7Xwc6LnCaFA3bu07FrI24P9vgZ4lkbSbhCW9lYVVyWoDp2XKdXiWJ-wCqFYDqNoJ0B0uN1Gc-DSh_h4ob9nK10xaUP7ZTe8Y0mky0PZRHtJFJjq4d5oEy7tMdFSGugmLysHIIchRkKMiR0OOjhwDOWZLehWMV9351cr0MjVLcUZXa_CD9B42qbtkUIOWGWi2c0PrEHytAHqtANp7R6BeH4H8Fcsp_s7Y60bb7GPyyuz7LuTvI9-FfuX34EtCF8HzMPKrHWqqZNuIb-5R3NKdKrxtGuLDXZkPuHdOwI4BqGh5HI1a1-vcPQOMWoX1d84AY7_A5SW3vNpu36AP0X-Ts9mKGke387NpatuSlhL96DsRUVWEsdEEgSUp7RzdgoOdk0O34dxoUDc-gIzGtaCbObruSzmb19FC1Ma9oTxWF2rMGmqMP5OYzTZiJltiVl4jZuRYyMEycjBGDiYtqcbGIZ7G7-Lp0uebeFq1VKSQ7jusVauH-WfWwzo8KPVdPUzktKZbMrqzbWivZVsl7R8K8g8m9XzrJrI00nw7xJaOMO5-O8RyLefWMcx5tlwmdOlmcTLAtQ9FnArPxn_MxpPpbPz18pIljw3Br1cM1scxgfpqtjDuyFbrJU61lGOxieufVPBR31RYKCHMN4sFTUAe4Np3lQZ2ZL3ldamUNsNpVP7VcBqfBY76LnBN03UcpbTedK171SHWx6z1qL-keSun8Sbx6Jck9rht_jjhjrjAp2mWa638YRRxFWY7JNRdbbm76gkf9KR1eyJ1T-SgJ2XPk1z1JNc9KQc9qd2ecN2TekR0pOpJqXvSDnoyu_Ok1T3pBz0Z3dGpdU_GEWfai06vezKPwNOeJ7PuyTroCcvd4VkNaB5GOaOaTiA0MIUPA501ejc-b5GwCOOnWeALtuAvzPnCILRvuKbRV8nc68-VOem7Op1jw5MVWV4IbIG7TBkZ3NzFT9zt9GXNWnnhhilFwpV7Ty9oRpNVEAVpFniF5ufP__tPAAAA___M56T1
  Diagram 2 (subquery): https://cockroachdb.github.io/distsqlplan/decode.html#eJzsWv1u4zYS__-eguA_sVvaFinqEwjgbeLeut04iyTbxeE2MLQW4-giS44k5-MWeax7gXuyA0lJ1nei7LZd4FoUXYscDjkzv_nNkN0vML71oQ0_zi_egtulG658FoA352BwPns3O7oA7thz-bfnIhDvNoO78SrcBcmQj6XSP5-dnvDfuw0LklhMgPliMTsDv5zOF-AuXDmfd74TPfKpO3C6AHdjz11mK8Ch3KSwJFe2dHbJdRhJpU5RpDBRGl-zwGVyfM23cvhWchAcgjXf6HQBXDEsdYBDISSG-Z-H6Wx-vpL2cOmHKyfxQuGltZ8tW6ZTfBOfq_n4dnY2A4PBYD1OHrcMHIKDK7ZxfHYwBG8Wx2Cw9scP4KfZxcfZbAGIIgapMtzPPuazI6zIeazkAu44O-DSdRKWyx4QBWsjxRphAyiKLf49EEv2M-Z-Zgj-fnb64T346R_CjCECt8v7MHJFlN1wFRfBIOLGZyUixE8EhOjgeH5-MV9kQtnZBE7K-gRcqqCQ3rqr-L2Mwmdw9hdo_jjQFFCTY0JAJwirmNkTyF8B_J4CmIbnllQI_paMwxtn64nMjcVPGbiminA_zthAUsFgMLgbJ1fgBzDA4EfgB4NslSQJzx1KZRlShmDCCWfljkskMRwOhY6xDn4EeMilpOIf5eAPYDDAYASUsaEN-eCA_wI_8BLmj2VdEovS3Z279SAbTfdPP8U_3ICCpS-vZYUpfn6x4J6D415iak-Y_ydVr7Cq2E3wsPA1Ijxyt5p0reoIXMhVHCCZJ4tezdPt-883oS7NF17ZDpJrL7g5QCn8bsmeUmVOnp4dz874JwHHs_MjBDB4Nz-ZXwCsQASD0GULZ8NiaP8TYoigCi8R3EbhisVxGPHhL0Jo7j5AW0HQC7a7hA9fIrgKIwbtLzDxEp9BG144n312xhyXRROuy2WJ4_lCdQ2U09rIcnvDHiGCR6G_2wSxDQowQiBHHETwfOvw-YlOqYE1yzJ0VTOwphhkYlqUUEM1zRFE8NffQOJtmA3UsR7L71UYJCwQCJRTyn__k05F4X0MXLYKXebaACNFN5BqGXLy82PCYhAxx7UBJeDE-0mOr8_eH4GV4_uxDTQ5tHW8KBMtajn57egIxAnbShIDA_aQTLwgGRbEJvUFjN3UF2gTvtnGeQAbtgmjR-D4IrPEyZX0ePGtD1bbXWoolj747CSraxaDcJdsd4nYmqoQQWF9YTA9xeUTgnJUQiEL9edHcO3E1-UgTzG8fLpEME6cNYM2LgBpfgxt_IRasLTXuwvCyGURc0uaL_nK50QaAPnWia9_Cb2ARRO9fFSfXSWDKR4eRt76OhlM6RAieMptn2I0JWiqoilFUw1NdTQ10NSECLIHttoVoEMo2cStYSBWGgY-zUORsM0WuF58A3axs-bQA_UoqUTbNIfJ0JVqmKhlIKqSnkEipSBplSDprUF6JuGN8jZpKZmmfy45rS4996Gc4Ajw8UJKf4KSdz_BUeH35H3ErryHWeAWs9oyzTx5X57XDflMQUM244ZsfiaLJ7g7a6VAC1wU8GtD1lIi7ajhoZayFRTsI6xXImz0iTDPnjTAZjnAGY9n7J13CmmU34XhzW4L_hV6AQgDnlfV0OcrYHoGESppm_yOE8f3M_7axMXgG3o-8OLYE0oRxg2Mbo3VZko36yDYK-mAQio0qQo3wsIUrt3FzAVxEjFnIzxSZRs8ttrJBustnI-bwEOoWYVPdtB-VKKWqMSoAM38M_ledDc1wic54as54S_CgDX5m-od7G7miOlF75g20ztBpkZqMdEURCzamthmtb4qfTL7zXodsbWThNEEk7Kvjk4_LC6WZ6cfzwfDRs8IG6qWNdetl_OUVTWHfAV-njFYLRt8_uFkOV9c8IagwV5qSD6pMLP51cyMlarJaslk_PLqq_z-7faos98ut9u4LzVbKkG6otapWdWbmZnWmXmvo4OZU6FJVbiRmemE9m-zaRMqLFzDRXaCb9liK6_FD6l2b_ur-rT4sXxsauIeEHgsNHH8BjyaYAUXQUFp73ptIKLqdUgQg6S90vMtW6aiAxFCZFIW7N2-qS39GyaNtFirv3L7NqIglTCTPmH-2fMTFrFoUiE9OW6DwZSATztFUdkhIIpt2_PFhZk-NGRTq0NA86mmq5CmNHEkaSPJmv0UEdJOlGrF_l40WWhhaQtLFthx_xjV1ceeLsBgquduKzzjHNi2ffzmYpY5UM8dWHjRyYUaW2KxOwKlF6NKiyzd1dQma6TcJ6u9mdhSkWFpDdekFiYmDUyc6-hiYik0qQo3MzEihEzEf1_QKxtjrb1105uJm8o1NeI2a9fu7MD9iJuWiJtWEE1bEf0H9Mra7_A2Ylgd3bOKX9M8E11texsxGt5GdKTqfatr99uI9mcGyfrq-4zWeZ_RXnWf0Y2W-4ylaE13TKX2XNV-n7H6sHyxu8ff5XWm_fmzwZwzFm_DIGZVFDVuVb1GjDDHEnPXTGIzDnfRir2PwpWQlZ-nQpHwq8viRM7i9GseZHNx4ojdYMCS-zC6Ab6TsGD1aAPDSO9F2cy94yVZqsobgMtiFnmO7_3bKTpcAjFbJvwZsRXz7jgSNZWDhxQEsiKUSezv3pnEhsUco0UhLKDW-N6t1qKY7SlcyqtK3mT0cF2r52rcKJ3TnIh0_CpuxHpzn6nTuq0UUV69irbqVVtxt63k28DEkG9azTAhZhdMCDUQ1XEHTPI3sU6UUFVrRAlVa57Ltix5Tj66vNx19MUwMboe_CxK0_tGP5g0X0cworhWQQm1kGVUza1lBamaqxTNVUvmKkVVZlWT2gdz5LWYw12YM7oghwlBing6aoOckSdvB-bk62v9Tdao1ZZ0v3IAcD-30Vav9XpgJrr5Grw1N2wttmKFVmylVVtpJ9i0drDhGsNpnar0eprmqmrA1TtVYdp-rBp5GK8tz_VoGt-8yDTXGIPWm29dRzqpIJf0tLVHiSFaR7obr-1EqK4hef1rz_cXdCKm1ZTvpqXXvSb3K3lNq3rN7ASb1QNrVjdslY5sqtW8Xm1lFwt1Xt2JRV5V9ZppyDLqz1DZrbFobY2FnrO2R6HqQG7qiZbmSO9EbvoXA9qRS14AXMvEjV6zWv8eQtFrRs1rr-4pe3VGmql_287IqF0XCNWRZlWKldXT3vZGsCdKvqKFtpChW1_fQlPa7Dla_1-a6ZblMl-rDLi7qcQdXSWuESauNUjPVfrXxMHqjAMtr6s2ll0h0Ah4JgLqCx8qSm4yni4RvPLD-6XnQhs6xNCwcaWN2EqzRtTV2ch0LDxyTWKaCmErlfBtrnxnHUP7Czy_Du-Fyy4etyyG9pXjxwzBE-eGHbOERRsv8OLEW6UzT09_-18AAAD__w3H068=
  Diagram 3 (subquery): https://cockroachdb.github.io/distsqlplan/decode.html#eJzsVlFv2zYQft-vOPDFUiIroprEiQADTWut1dDYhe0tGAbDYERKESKLtkjZCQL_94GkZMtu2nUvQ4G1KBDxu7vveLyPR78gscpRgO6i6UdYzSmPc1bAzQSsSfgpfD8F6mZUrTPqgKgW1tqNeVVIW2G196_j0a36rhaskEIbIBoOwzH8NoqGsOYxua9yUj4r0xpGQ1i7GZ03EdA3SVohO7I5qeQDLw0pabu0DAd4ygrKDJ6qVESlMiD0IVWJRkOgGjYc0NdOGlZ_-7V1t78Ddj7PeUxkxvUppXkTNq9NKkmuaO4-huMQLMtKXfm8ZNCHTsIWJGcdG26GA7DS3H2Cd-H0LgyH4HsaPPfsvfV5Z-1iz9ixt3OgbrPBOSWS7Xw7vocvut51F_fA8wL9v6ND9parvcWGD-PR75_h3Z-6DNuB1XzDS6q7THks2mLQfVNWowj96YB2tQbRZBoNG6dmb1onh3xaLseiMKe1Pjr3QxX-g85-iua_E01LNTtNaOkU_Fgz-wHys4E_UgPr9qz8owG_8l3-SJaZvrlCf5rGvfYibNxmGphRYFnW2pUJnICF4RTywmqizJDIqG3IGqXYcKYGTkzdgyFh27bmcC_hFLCtvAzxqQFPwLIwdMFzexe2Ai31BSfqCctd8y7poDo7WadWg9b566X-pwpoVfr9b1nLpPavAzZKHBujqf3A_J-8eq2o9q8J1RYVo9tjsn3h_cWro3VhopRAmpNsn-ruuv34903T1fdFvWwd-ZAVjx2nlt_K349UcydH40E4VksfBuHkvQMYPkW30RSwhxxUcMqGZMEECv5CGM0ctCx5zITgpYJetENEn1DgOSgrlpVU8MxBMS8ZCl6QzGTOUIBUY3MQMSngvkoSVoJ3phJQJkmWa_pRJQN46yMHsScWV1oGMluwAK56C4Ec9RsS4mV1CN4TGT8wAbySS0Vwfq0YSr5pQ-fOG_8SzbYOMli9SSFJylCAW1VFAxR4W-f7C7tJ05KlRPLyDB_Wc_PHB-sttl-p583FK_XU4HE9-Lga_NU6_KM68L-pY8zEkheCHdTwtUzeUaYu3s4cxGjKjCoEr8qYfS55rH3NcqSJNECZkMaKzSIqGpOQJSOLXRvaTPibTP63mGYOSnK-mWcUBYhcxj459y67CU163fMrEneJd9Hr-j1yTRJCr3AvRiqApEId0eSBbzTt9HmpCkxILpiDbskjGzDJykVWZEJmcW3Zbn_5OwAA__87XOZR
  Diagram 4 (main-query): https://cockroachdb.github.io/distsqlplan/decode.html#eJzsWutu27i2_n-egtCfyg0ta1F3AwHUSTxnMpM4ReJOMTgtDMViXJ_YlmPJuWDQxzovcJ5sg7rYEkXRllt0BnvPxp7U5mWRXOtbF370n0r8OFf6yseL0S_ocRxGkzldone3SL0dXA7ORijUZiH7PgsxijcL9UmbRJtl0mFt-eifb66v2OfNgi6TOO1AF8Ph4Ab9en0xRE_RJLjbzIP1K-t6QtdD9KTNwnExA51mi5SmbIWNg03yJVpnQoPykFJHpX1KlyHN2qdsqYAtlTWiUzRlC10PUZg2ZzLQaToobWb_nua92_1VpEfjeTQJklmUamk6L6aN8y62yJyJ-fjL4GaAVFWdasnriqJT9OaeLoI5fdNB74bnSJ3OtRf002D0cTAYIqKnjabe2fW-bnu7oGf9oG8HhFqxwXEYJHQ79g3RwerqXhccpOv99P9v0im7HnfX00H_fXP94T366Y_0GB2MHsfP0TpMrRxGk7gMhtRurDdDRPoRo3Soen5xO7oYFoOKvaU4qcpL4cKDItPWE6f3Kgr34Owf0Pw40JRQs8VECp1lxGNmF0D-MeDfyYC5eR4JF-AfiRY9BKtZ6rlx-jEznCgjPGtFNMhCgaqqT1pyj94iFdAJmi_VYlYWJGZhJxNWIKWDeizgTEKtEiQ6nU4qQ7PRCYIOG5UJPska3yJVBdRFuuZYHdaosk_oLUthcy3LS-mkfPXgaaoWrfn6-df0f-wApZMenstKXWz_6YRnBo7nDFO7gPkfkvVKs8rVBDMLm5OaJ1utNrqWdVJcZLMYQApNlrW6dbe_v7-l4nJ_YZntTfJltnx4g3P4PZJdSM188vrmfHDDvhJ0Prg9wwjQ5cXVxQiBrmBlGYV0GCxorPT_RwHlM1ZW62hC4zhas6Y_0wEX4YvS17EyW642CWv-jJVJtKZK_08lmSVzqvSVUXA3pzc0COm6xwSHNAlm81TsDu3-7uN49UBfFaycRfPNYhn3UQk0uCgKFKzcrgLW21Ww8tvvKJktaB8ZumbFWcMkWiZ0mSIq69P____yrnX0HKOQTqKQhn3kYtcgWAc767x7TWiM1jQI-8g0HHQ1-ynrmN68P0OTYD6P-8g0s7ZVMFsXg8tyrn4_O0NxQldZWEIqfUl6s2XSKQ3r1SdQ-lCfYJk9iy23CF7Qgi6i9SsK5qm3sN2Dnu8wfpyjyWqTHxaIZrDT3gXJ5AuNUbRJVpuErW4Ttl6qgl1jsZHPX7GStebGjJNgSpU-lKx_ca709a_4OABAFQC1iOTXWvbCIRvXAAhbI23xQLCu6-y_Oh4cVwwHt46GshQJGrbDevUJQjR4Pa8tFojmiKAA2EtxVYHCbhdNUCAcFOBYKJAqFMo5wC9_Gb-OZ-FLFQEYvWD0urN5j4XWbg90KBufeIu2xncwMQSBgDgE_SayPNQtX4iQWD0d0qsOFFobUocRW9sger4nzvX1hdDzeVNnyzeZ2eDMTNqY-efZPKFruu4ZVRtn7X2k-gR92ui6QU8R0fv9_sVw5OYZrOianCJz26Vghb7QyaZkQSC5DbnTg5s17z2_iQmBxvOb3PmNNuf_NZotc5SbDQGvFOh2VU4O9Msoetis0P9GsyWKln3kMxBcD5Hq21u1leqDN_1-__zdaFAo0N4qsFQqbAfxjrRbHaNKKaLkZ0w9pFBX0RYnwXxeJF2zcLP8u2a2dTvPM7DjWYIMbIsjrlX3u50Mieflg3r8YKH3sSNbvfSvAICOZsfNoVizhbHYFKdlz9V5eBY7bAKoxQHUbAToDpebZbQO6ZqGFVB-ZjP3DRGg_Jcg_sKQTtc9q4ryOb1PVB86p-vZ9Eui-iZD3TU7lQ_YJ9g3sG9i38K-jX0H-65AvcS1F836tQr1sm6m4oQuViicxQ9oEwdTBjUkyISuIYyNwlS4zwA2ZwDr2ERo84kwvWr5-b9jdu0QZUDWXsqAn5TsXvJJ6ZY-996v6f3sZbAMyx5quebWEQ_2URB4p4kOy4kg98oszR2ZBxvSILHFeQB4OzfnAIezsH1kDnCqBi5K3aLA3d6kZeG_HrPZDC5Gi-OzDc7WpHmLZ7aujIhpYgCnDgJPM8QxWoCDnRBZTZwN6vGDJcioFQey2NwAGM-0hMGBmLXSodhZE3BcDjjOXxmbXVFsJtvYbOyLzdj3sA869gGwD0SkbUsWquGoUF3IPChUm56JDdJczHqcPdy_0h5e1R6j1xXto8vBzyN0O7i6SMkqBddSqL0zk8gEpFn_jrlP_54l5hAyJ-ItYLvYs0j94giejQGaL46gc1bw2oTTd9Ppmk6DJFr3gGOR0vj4bvjHeHg9Gg8_XF4yvbGQef1hOBrfXH-8VUUXCNs2ZAXGXq2BJr5u25Y4jnj1Eg-w4UpIF551gVa0CzvKHMWTYInuNvf3dI30HnD8C68T013Ur1R5I38e06uBYJ8fQo08OJo9AI4-SNlxP_2bEoSiiqlKHPY-KSlDmhVM-UdxvURaZ0tRsWT8fYsl49uLJeAZA2hFGZTKJTAOYYlzIvjAmqnOIGOU3B9UPpHq7Tb37lZgMLBrCyonRzcOZpW2MmTISMf0uKFtyiYiS-QN2HFAXDYZNexk-2oEEE-5QDPn8gPSNJjyO628bhIp15EVSdpxVZIjDs2uwyvfwIYl0T3PJkAznbDHea39hFfO6Nd81ipoLtAP4bmKUd-Z6Mo0JYoE4Hkc0-W0v0cV4mtPC3BwLChESEKB3tvzjpDK6BWSanUASAOBBmJyi4hL9lok2ANGnlmBVtRKGYw1aqXpjWEWjl8aUonqe-gU-QA57lQfJOw1iOjrzhbYxnam2gVd7_Czje1s0Mvst-jt4zDQ2rkpt6AFy2l_-cdgeHXQuroYs0T0HpZJkL6FgeH1qgOF2K0OrMVZT45dU4hdQ1zktsYuzxnBsaQROEc_ldYCq3vQ--lheHJ1Lgianv69giAY5sGAOiAIVmPc0cHQIkQKKPHt2fhOwZDnkqCZTNoDKFdOQzaBJ83oB9GPksyZPXvsEidpf6UysG64gsTZBjKZhG_Lm7rh9gpJPFQMSw6VhtgjfrFtDRWe5oK_lOcCT15A2y2JR-yDgX0wsQ8W9sHGPjjYBxf7IEoDlrTa1o-ptsW8To2NlFuJ8DQYtOLBKr-g0H_4y5Gju__-L0feN5MhhKfuSDN19wNckYDQFb2tL8J39EXsEx37RMQvWEaOnoZftEBhkHZuaTT85KOtZ_LsJGnFTg6jbrTqEY6XvEl9sc-uDd5bdb5UTc80iJ2X9tnfnk86J8DurYOzi6t3l53OW6LZpe891fdOVFVVffOtrjlWucvULNsEArZFLCAOmMQFZzdgN_JE10h55luorNHByE-Z9drTgg0CUrho_Vad135n1Io1LL0KEI41TJ9Jqq8ChKH89sNVjvfaQaUZwznqBwffRUc8MUZa_RjpNlonLAaYvH662IcTBSujaPVbHwltDx7IHPY4f90K3R9gJT9D5Bkr0oqxuqHxKlrGlI-0wrX4jN0FFm9pOKVZ_I6jzXpC36-jSTo2-3qdCkobQhonWa-XfblYpl3AVljTYLF9Iy5LAqkkq1kS4SURqSSjIkkvS9J5SYZUktksCXhJZovTkbIkg5dkSSW5zXqyeEm2VJLTfDqTl-S02FPldDYvyW2Bp4okl5fkSSWB3nw8rwZNOcpBAnOo41wOdDAlwmqwAjnWQQJ2qKEd5HDndlbRPtScEOSIB0uysxrmQQ56sCXCamAFOe5BAnyo-RDIoQ-uRFgN_CBHP0jgDzX8g9wBWMneiLOaBxC5B3DCKjsjNZwRuQewurRJZ6TmAUTuAUTiAaSeOeQeQCQRn9RAS-QeQCQeoLOEez-PnsezUOkrd97kntzfQTcwJnbXDK27rqsbbpd4gac7rml7E1YN3s-Dacyy_u2X6DkVO3pdsZx9H8xjipWr4IGe04SuF7PlLE5mk7zn69f_-lcAAAD__9qNg1s=


  planning time: 84ms
  execution time: 1m54s
  distribution: local
  vectorized: true
  rows decoded from KV: 27,425,239 (1.2 GiB, 151 gRPC calls)
  cumulative time spent in KV: 1m35s
  maximum memory usage: 161 MiB
  network usage: 77 MiB (6,041 messages)
  max sql temp disk usage: 95 MiB
  sql cpu time: 58.5s
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
  │   │ sql cpu time: 191µs
  │   │ estimated row count: 10
  │   │ order: -sum,+id
  │   │ k: 10
  │   │
  │   └── • group (hash)
  │       │ nodes: n1
  │       │ actual row count: 3,357
  │       │ estimated max memory allocated: 1.7 MiB
  │       │ estimated max sql temp disk usage: 0 B
  │       │ sql cpu time: 2ms
  │       │ estimated row count: 24
  │       │ group by: id
  │       │
  │       └── • render
  │           │
  │           └── • hash join
  │               │ nodes: n1
  │               │ actual row count: 3,357
  │               │ estimated max memory allocated: 310 KiB
  │               │ estimated max sql temp disk usage: 0 B
  │               │ sql cpu time: 538µs
  │               │ estimated row count: 51
  │               │ equality: (id_gender) = (id)
  │               │ right cols are key
  │               │
  │               ├── • hash join
  │               │   │ nodes: n1
  │               │   │ actual row count: 3,357
  │               │   │ estimated max memory allocated: 1.0 MiB
  │               │   │ estimated max sql temp disk usage: 0 B
  │               │   │ sql cpu time: 5ms
  │               │   │ estimated row count: 7
  │               │   │ equality: (id_word) = (id_word)
  │               │   │ left cols are key
  │               │   │
  │               │   ├── • render
  │               │   │   │
  │               │   │   └── • group (hash)
  │               │   │       │ nodes: n1
  │               │   │       │ actual row count: 91,386
  │               │   │       │ estimated max memory allocated: 54 MiB
  │               │   │       │ estimated max sql temp disk usage: 1.0 MiB
  │               │   │       │ sql cpu time: 655ms
  │               │   │       │ estimated row count: 217,960
  │               │   │       │ group by: id_word
  │               │   │       │
  │               │   │       └── • hash join (semi)
  │               │   │           │ nodes: n1
  │               │   │           │ actual row count: 2,196,110
  │               │   │           │ estimated max memory allocated: 74 MiB
  │               │   │           │ estimated max sql temp disk usage: 95 MiB
  │               │   │           │ sql cpu time: 1.6s
  │               │   │           │ estimated row count: 1,465,773
  │               │   │           │ equality: (id_document) = (id)
  │               │   │           │
  │               │   │           ├── • scan
  │               │   │           │     nodes: n1
  │               │   │           │     actual row count: 8,832,016
  │               │   │           │     KV time: 30.5s
  │               │   │           │     KV contention time: 0µs
  │               │   │           │     KV rows decoded: 8,832,016
  │               │   │           │     KV bytes read: 437 MiB
  │               │   │           │     KV gRPC calls: 44
  │               │   │           │     estimated max memory allocated: 10 MiB
  │               │   │           │     sql cpu time: 12.3s
  │               │   │           │     estimated row count: 8,832,016 (100% of the table; stats collected 49 minutes ago)
  │               │   │           │     table: vocabulary@vocabulary_pkey
  │               │   │           │     spans: FULL SCAN
  │               │   │           │
  │               │   │           └── • hash join
  │               │   │               │ nodes: n1
  │               │   │               │ actual row count: 494,326
  │               │   │               │ estimated max memory allocated: 16 MiB
  │               │   │               │ estimated max sql temp disk usage: 0 B
  │               │   │               │ sql cpu time: 156ms
  │               │   │               │ estimated row count: 472,036
  │               │   │               │ equality: (id_author) = (id)
  │               │   │               │ right cols are key
  │               │   │               │
  │               │   │               ├── • hash join
  │               │   │               │   │ nodes: n1
  │               │   │               │   │ actual row count: 993,795
  │               │   │               │   │ estimated max memory allocated: 56 MiB
  │               │   │               │   │ estimated max sql temp disk usage: 0 B
  │               │   │               │   │ sql cpu time: 283ms
  │               │   │               │   │ estimated row count: 951,962
  │               │   │               │   │ equality: (id_document) = (id)
  │               │   │               │   │ right cols are key
  │               │   │               │   │
  │               │   │               │   ├── • scan
  │               │   │               │   │     nodes: n1
  │               │   │               │   │     actual row count: 2,000,000
  │               │   │               │   │     KV time: 6.2s
  │               │   │               │   │     KV contention time: 0µs
  │               │   │               │   │     KV rows decoded: 2,000,000
  │               │   │               │   │     KV bytes read: 78 MiB
  │               │   │               │   │     KV gRPC calls: 8
  │               │   │               │   │     estimated max memory allocated: 10 MiB
  │               │   │               │   │     sql cpu time: 2.7s
  │               │   │               │   │     estimated row count: 2,000,000 (100% of the table; stats collected 49 minutes ago)
  │               │   │               │   │     table: documents_authors@documents_authors_pkey
  │               │   │               │   │     spans: FULL SCAN
  │               │   │               │   │
  │               │   │               │   └── • lookup join
  │               │   │               │       │ nodes: n1
  │               │   │               │       │ actual row count: 993,795
  │               │   │               │       │ KV time: 3.4s
  │               │   │               │       │ KV contention time: 0µs
  │               │   │               │       │ KV rows decoded: 993,795
  │               │   │               │       │ KV bytes read: 46 MiB
  │               │   │               │       │ KV gRPC calls: 5
  │               │   │               │       │ estimated max memory allocated: 1.6 MiB
  │               │   │               │       │ sql cpu time: 4.3s
  │               │   │               │       │ estimated row count: 951,962
  │               │   │               │       │ table: documents@documents_id_geo_loc_idx
  │               │   │               │       │ equality: (id) = (id_geo_loc)
  │               │   │               │       │ pred: (document_date >= '2015-09-17') AND (document_date <= '2015-09-18')
  │               │   │               │       │
  │               │   │               │       └── • filter
  │               │   │               │           │ nodes: n1
  │               │   │               │           │ actual row count: 4,221
  │               │   │               │           │ sql cpu time: 118µs
  │               │   │               │           │ estimated row count: 4,221
  │               │   │               │           │ filter: (x >= 20) AND (x <= 40)
  │               │   │               │           │
  │               │   │               │           └── • scan
  │               │   │               │                 nodes: n1
  │               │   │               │                 actual row count: 7,236
  │               │   │               │                 KV time: 29ms
  │               │   │               │                 KV contention time: 0µs
  │               │   │               │                 KV rows decoded: 7,236
  │               │   │               │                 KV bytes read: 272 KiB
  │               │   │               │                 KV gRPC calls: 1
  │               │   │               │                 estimated max memory allocated: 320 KiB
  │               │   │               │                 sql cpu time: 10ms
  │               │   │               │                 estimated row count: 7,236 (82% of the table; stats collected 49 minutes ago)
  │               │   │               │                 table: geo_location@geo_location_y_idx
  │               │   │               │                 spans: [/-100 - /100]
  │               │   │               │
  │               │   │               └── • lookup join
  │               │   │                   │ nodes: n1
  │               │   │                   │ actual row count: 244,117
  │               │   │                   │ KV time: 694ms
  │               │   │                   │ KV contention time: 0µs
  │               │   │                   │ KV rows decoded: 244,117
  │               │   │                   │ KV bytes read: 9.3 MiB
  │               │   │                   │ KV gRPC calls: 1
  │               │   │                   │ estimated max memory allocated: 20 KiB
  │               │   │                   │ sql cpu time: 945ms
  │               │   │                   │ estimated row count: 244,256
  │               │   │                   │ table: authors@authors_id_gender_idx
  │               │   │                   │ equality: (id) = (id_gender)
  │               │   │                   │
  │               │   │                   └── • scan
  │               │   │                         nodes: n1
  │               │   │                         actual row count: 1
  │               │   │                         KV time: 584µs
  │               │   │                         KV contention time: 0µs
  │               │   │                         KV rows decoded: 1
  │               │   │                         KV bytes read: 44 B
  │               │   │                         KV gRPC calls: 1
  │               │   │                         estimated max memory allocated: 20 KiB
  │               │   │                         sql cpu time: 26µs
  │               │   │                         estimated row count: 1 (50% of the table; stats collected 49 minutes ago)
  │               │   │                         table: genders@genders_type_idx
  │               │   │                         spans: [/'female' - /'female']
  │               │   │
  │               │   └── • lookup join
  │               │       │ nodes: n1
  │               │       │ actual row count: 3,357
  │               │       │ KV time: 322ms
  │               │       │ KV contention time: 0µs
  │               │       │ KV rows decoded: 3,038
  │               │       │ KV bytes read: 74 KiB
  │               │       │ KV gRPC calls: 2
  │               │       │ estimated max memory allocated: 2.4 MiB
  │               │       │ sql cpu time: 30ms
  │               │       │ estimated row count: 6
  │               │       │ table: authors@authors_pkey
  │               │       │ equality: (id_author) = (id)
  │               │       │ equality cols are key
  │               │       │
  │               │       └── • lookup join
  │               │           │ nodes: n1
  │               │           │ actual row count: 3,357
  │               │           │ KV time: 490ms
  │               │           │ KV contention time: 0µs
  │               │           │ KV rows decoded: 3,357
  │               │           │ KV bytes read: 134 KiB
  │               │           │ KV gRPC calls: 2
  │               │           │ estimated max memory allocated: 2.5 MiB
  │               │           │ sql cpu time: 32ms
  │               │           │ estimated row count: 6
  │               │           │ table: documents_authors@documents_authors_pkey
  │               │           │ equality: (id) = (id_document)
  │               │           │
  │               │           └── • lookup join
  │               │               │ nodes: n1
  │               │               │ actual row count: 3,357
  │               │               │ KV time: 157ms
  │               │               │ KV contention time: 0µs
  │               │               │ KV rows decoded: 2,139
  │               │               │ KV bytes read: 80 KiB
  │               │               │ KV gRPC calls: 2
  │               │               │ estimated max memory allocated: 2.4 MiB
  │               │               │ sql cpu time: 38ms
  │               │               │ estimated row count: 6
  │               │               │ table: geo_location@geo_location_id_x_idx
  │               │               │ equality cols are key
  │               │               │ lookup condition: (id_geo_loc = id) AND ((x >= 20) AND (x <= 40))
  │               │               │ pred: (y >= -100) AND (y <= 100)
  │               │               │
  │               │               └── • lookup join
  │               │                   │ nodes: n1
  │               │                   │ actual row count: 3,357
  │               │                   │ KV time: 374ms
  │               │                   │ KV contention time: 0µs
  │               │                   │ KV rows decoded: 3,357
  │               │                   │ KV bytes read: 781 KiB
  │               │                   │ KV gRPC calls: 1
  │               │                   │ estimated max memory allocated: 2.1 MiB
  │               │                   │ sql cpu time: 42ms
  │               │                   │ estimated row count: 14
  │               │                   │ table: documents@documents_pkey
  │               │                   │ equality: (id_document) = (id)
  │               │                   │ equality cols are key
  │               │                   │ pred: (document_date >= '2015-09-17') AND (document_date <= '2015-09-18')
  │               │                   │
  │               │                   └── • hash join
  │               │                       │ nodes: n1
  │               │                       │ actual row count: 3,357
  │               │                       │ estimated max memory allocated: 1.6 MiB
  │               │                       │ estimated max sql temp disk usage: 0 B
  │               │                       │ sql cpu time: 17ms
  │               │                       │ estimated row count: 14
  │               │                       │ equality: (id) = (id_document)
  │               │                       │ left cols are key
  │               │                       │
  │               │                       ├── • scan buffer
  │               │                       │     nodes: n1
  │               │                       │     actual row count: 494,326
  │               │                       │     sql cpu time: 48ms
  │               │                       │     estimated row count: 717,534
  │               │                       │     label: buffer 1 (q_doclen)
  │               │                       │
  │               │                       └── • lookup join
  │               │                           │ nodes: n1
  │               │                           │ actual row count: 13,867
  │               │                           │ KV time: 55ms
  │               │                           │ KV contention time: 0µs
  │               │                           │ KV rows decoded: 13,867
  │               │                           │ KV bytes read: 703 KiB
  │               │                           │ KV gRPC calls: 1
  │               │                           │ estimated max memory allocated: 20 KiB
  │               │                           │ sql cpu time: 71ms
  │               │                           │ estimated row count: 41
  │               │                           │ table: vocabulary@vocabulary_id_word_idx
  │               │                           │ equality: (id) = (id_word)
  │               │                           │
  │               │                           └── • scan
  │               │                                 nodes: n1
  │               │                                 actual row count: 1
  │               │                                 KV time: 2ms
  │               │                                 KV contention time: 0µs
  │               │                                 KV rows decoded: 1
  │               │                                 KV bytes read: 43 B
  │               │                                 KV gRPC calls: 1
  │               │                                 estimated max memory allocated: 20 KiB
  │               │                                 sql cpu time: 36µs
  │               │                                 estimated row count: 1 (<0.01% of the table; stats collected 49 minutes ago)
  │               │                                 table: words@words_word_idx
  │               │                                 spans: [/'think' - /'think']
  │               │
  │               └── • scan
  │                     nodes: n1
  │                     actual row count: 1
  │                     KV time: 708µs
  │                     KV contention time: 0µs
  │                     KV rows decoded: 1
  │                     KV bytes read: 44 B
  │                     KV gRPC calls: 1
  │                     estimated max memory allocated: 20 KiB
  │                     sql cpu time: 29µs
  │                     estimated row count: 1 (50% of the table; stats collected 49 minutes ago)
  │                     table: genders@genders_type_idx
  │                     spans: [/'female' - /'female']
  │
  ├── • subquery
  │   │ id: @S1
  │   │ original sql: SELECT d.id AS id, sum(v.count) AS doclen FROM documents AS d INNER JOIN vocabulary AS v ON v.id_document = d.id INNER JOIN documents_authors AS da INNER JOIN authors AS a INNER JOIN genders AS g ON a.id_gender = g.id ON da.id_author = a.id ON d.id = da.id_document INNER JOIN geo_location AS gl ON d.id_geo_loc = gl.id WHERE (((g.type = 'female') AND (gl.x BETWEEN 20 AND 40)) AND (gl.y BETWEEN -100 AND 100)) AND (d.document_date BETWEEN '2015-09-17 00:00:00' AND '2015-09-18 00:00:00') GROUP BY d.id
  │   │ exec mode: all rows
  │   │
  │   └── • buffer
  │       │ nodes: n1
  │       │ actual row count: 494,326
  │       │ sql cpu time: 106ms
  │       │ label: buffer 1 (q_doclen)
  │       │
  │       └── • group (hash)
  │           │ nodes: n1
  │           │ actual row count: 494,326
  │           │ estimated max memory allocated: 45 MiB
  │           │ estimated max sql temp disk usage: 11 MiB
  │           │ sql cpu time: 1.9s
  │           │ estimated row count: 717,534
  │           │ group by: id
  │           │
  │           └── • hash join
  │               │ nodes: n1
  │               │ actual row count: 2,196,110
  │               │ estimated max memory allocated: 75 MiB
  │               │ estimated max sql temp disk usage: 42 MiB
  │               │ sql cpu time: 1.5s
  │               │ estimated row count: 1,952,388
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
  │               │     estimated row count: 8,832,016 (100% of the table; stats collected 49 minutes ago)
  │               │     table: vocabulary@vocabulary_pkey
  │               │     spans: FULL SCAN
  │               │
  │               └── • hash join
  │                   │ nodes: n1
  │                   │ actual row count: 494,326
  │                   │ estimated max memory allocated: 16 MiB
  │                   │ estimated max sql temp disk usage: 0 B
  │                   │ sql cpu time: 171ms
  │                   │ estimated row count: 475,981
  │                   │ equality: (id_author) = (id)
  │                   │ right cols are key
  │                   │
  │                   ├── • hash join
  │                   │   │ nodes: n1
  │                   │   │ actual row count: 993,795
  │                   │   │ estimated max memory allocated: 56 MiB
  │                   │   │ estimated max sql temp disk usage: 0 B
  │                   │   │ sql cpu time: 282ms
  │                   │   │ estimated row count: 951,962
  │                   │   │ equality: (id_document) = (id)
  │                   │   │ right cols are key
  │                   │   │
  │                   │   ├── • scan
  │                   │   │     nodes: n1
  │                   │   │     actual row count: 2,000,000
  │                   │   │     KV time: 6.3s
  │                   │   │     KV contention time: 0µs
  │                   │   │     KV rows decoded: 2,000,000
  │                   │   │     KV bytes read: 78 MiB
  │                   │   │     KV gRPC calls: 8
  │                   │   │     estimated max memory allocated: 10 MiB
  │                   │   │     sql cpu time: 2.8s
  │                   │   │     estimated row count: 2,000,000 (100% of the table; stats collected 49 minutes ago)
  │                   │   │     table: documents_authors@documents_authors_pkey
  │                   │   │     spans: FULL SCAN
  │                   │   │
  │                   │   └── • lookup join
  │                   │       │ nodes: n1
  │                   │       │ actual row count: 993,795
  │                   │       │ KV time: 4.3s
  │                   │       │ KV contention time: 0µs
  │                   │       │ KV rows decoded: 993,795
  │                   │       │ KV bytes read: 46 MiB
  │                   │       │ KV gRPC calls: 5
  │                   │       │ estimated max memory allocated: 1.6 MiB
  │                   │       │ sql cpu time: 4.9s
  │                   │       │ estimated row count: 951,962
  │                   │       │ table: documents@documents_id_geo_loc_idx
  │                   │       │ equality: (id) = (id_geo_loc)
  │                   │       │ pred: (document_date >= '2015-09-17') AND (document_date <= '2015-09-18')
  │                   │       │
  │                   │       └── • filter
  │                   │           │ nodes: n1
  │                   │           │ actual row count: 4,221
  │                   │           │ sql cpu time: 2ms
  │                   │           │ estimated row count: 4,221
  │                   │           │ filter: (x >= 20) AND (x <= 40)
  │                   │           │
  │                   │           └── • scan
  │                   │                 nodes: n1
  │                   │                 actual row count: 7,236
  │                   │                 KV time: 38ms
  │                   │                 KV contention time: 0µs
  │                   │                 KV rows decoded: 7,236
  │                   │                 KV bytes read: 272 KiB
  │                   │                 KV gRPC calls: 1
  │                   │                 estimated max memory allocated: 320 KiB
  │                   │                 sql cpu time: 16ms
  │                   │                 estimated row count: 7,236 (82% of the table; stats collected 49 minutes ago)
  │                   │                 table: geo_location@geo_location_y_idx
  │                   │                 spans: [/-100 - /100]
  │                   │
  │                   └── • lookup join
  │                       │ nodes: n1
  │                       │ actual row count: 244,117
  │                       │ KV time: 886ms
  │                       │ KV contention time: 0µs
  │                       │ KV rows decoded: 244,117
  │                       │ KV bytes read: 9.3 MiB
  │                       │ KV gRPC calls: 1
  │                       │ estimated max memory allocated: 20 KiB
  │                       │ sql cpu time: 1.2s
  │                       │ estimated row count: 244,256
  │                       │ table: authors@authors_id_gender_idx
  │                       │ equality: (id) = (id_gender)
  │                       │
  │                       └── • scan
  │                             nodes: n1
  │                             actual row count: 1
  │                             KV time: 842µs
  │                             KV contention time: 0µs
  │                             KV rows decoded: 1
  │                             KV bytes read: 44 B
  │                             KV gRPC calls: 1
  │                             estimated max memory allocated: 20 KiB
  │                             sql cpu time: 35µs
  │                             estimated row count: 1 (50% of the table; stats collected 49 minutes ago)
  │                             table: genders@genders_type_idx
  │                             spans: [/'female' - /'female']
  │
  ├── • subquery
  │   │ id: @S2
  │   │ original sql: (SELECT count(id) FROM q_nodocs)
  │   │ exec mode: one row
  │   │
  │   └── • group (scalar)
  │       │ nodes: n1
  │       │ actual row count: 1
  │       │ sql cpu time: 48µs
  │       │ estimated row count: 1
  │       │
  │       └── • hash join
  │           │ nodes: n1, n3
  │           │ actual row count: 494,326
  │           │ estimated max memory allocated: 17 MiB
  │           │ estimated max sql temp disk usage: 0 B
  │           │ sql cpu time: 312ms
  │           │ estimated row count: 472,036
  │           │ equality: (id_author) = (id)
  │           │ right cols are key
  │           │
  │           ├── • hash join
  │           │   │ nodes: n1, n3
  │           │   │ actual row count: 993,795
  │           │   │ estimated max memory allocated: 59 MiB
  │           │   │ estimated max sql temp disk usage: 0 B
  │           │   │ sql cpu time: 588ms
  │           │   │ estimated row count: 951,962
  │           │   │ equality: (id_document) = (id)
  │           │   │ right cols are key
  │           │   │
  │           │   ├── • scan
  │           │   │     nodes: n1, n3
  │           │   │     actual row count: 2,000,000
  │           │   │     KV time: 6.7s
  │           │   │     KV contention time: 0µs
  │           │   │     KV rows decoded: 2,000,000
  │           │   │     KV bytes read: 78 MiB
  │           │   │     KV gRPC calls: 9
  │           │   │     estimated max memory allocated: 20 MiB
  │           │   │     sql cpu time: 3.1s
  │           │   │     estimated row count: 2,000,000 (100% of the table; stats collected 49 minutes ago)
  │           │   │     table: documents_authors@documents_authors_pkey
  │           │   │     spans: FULL SCAN
  │           │   │
  │           │   └── • lookup join (streamer)
  │           │       │ nodes: n3
  │           │       │ actual row count: 993,795
  │           │       │ KV time: 3s
  │           │       │ KV contention time: 0µs
  │           │       │ KV rows decoded: 993,795
  │           │       │ KV bytes read: 46 MiB
  │           │       │ KV gRPC calls: 2
  │           │       │ estimated max memory allocated: 60 MiB
  │           │       │ sql cpu time: 4.5s
  │           │       │ estimated row count: 951,962
  │           │       │ table: documents@documents_id_geo_loc_idx
  │           │       │ equality: (id) = (id_geo_loc)
  │           │       │ pred: (document_date >= '2015-09-17') AND (document_date <= '2015-09-18')
  │           │       │
  │           │       └── • filter
  │           │           │ nodes: n3
  │           │           │ actual row count: 4,221
  │           │           │ sql cpu time: 248µs
  │           │           │ estimated row count: 4,221
  │           │           │ filter: (x >= 20) AND (x <= 40)
  │           │           │
  │           │           └── • scan
  │           │                 nodes: n3
  │           │                 actual row count: 7,236
  │           │                 KV time: 44ms
  │           │                 KV contention time: 0µs
  │           │                 KV rows decoded: 7,236
  │           │                 KV bytes read: 272 KiB
  │           │                 KV gRPC calls: 1
  │           │                 estimated max memory allocated: 320 KiB
  │           │                 sql cpu time: 12ms
  │           │                 estimated row count: 7,236 (82% of the table; stats collected 49 minutes ago)
  │           │                 table: geo_location@geo_location_y_idx
  │           │                 spans: [/-100 - /100]
  │           │
  │           └── • lookup join (streamer)
  │               │ nodes: n1
  │               │ actual row count: 244,117
  │               │ KV time: 761ms
  │               │ KV contention time: 0µs
  │               │ KV rows decoded: 244,117
  │               │ KV bytes read: 9.3 MiB
  │               │ KV gRPC calls: 8
  │               │ estimated max memory allocated: 16 MiB
  │               │ sql cpu time: 1.1s
  │               │ estimated row count: 244,256
  │               │ table: authors@authors_id_gender_idx
  │               │ equality: (id) = (id_gender)
  │               │
  │               └── • scan
  │                     nodes: n1
  │                     actual row count: 1
  │                     KV time: 988µs
  │                     KV contention time: 0µs
  │                     KV rows decoded: 1
  │                     KV bytes read: 44 B
  │                     KV gRPC calls: 1
  │                     estimated max memory allocated: 20 KiB
  │                     sql cpu time: 42µs
  │                     estimated row count: 1 (50% of the table; stats collected 49 minutes ago)
  │                     table: genders@genders_type_idx
  │                     spans: [/'female' - /'female']
  │
  └── • subquery
      │ id: @S3
      │ original sql: (SELECT avg(doclen) FROM q_doclen)
      │ exec mode: one row
      │
      └── • group (scalar)
          │ nodes: n1
          │ actual row count: 1
          │ sql cpu time: 35ms
          │ estimated row count: 1
          │
          └── • scan buffer
                nodes: n1
                actual row count: 494,326
                sql cpu time: 87ms
                estimated row count: 717,534
                label: buffer 1 (q_doclen)
*/


