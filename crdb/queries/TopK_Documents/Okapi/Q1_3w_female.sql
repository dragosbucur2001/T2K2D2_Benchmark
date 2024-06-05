\set words ('''think''','''today''','''friday''')


with
    q_docLen as (select d.id id, sum(v.count) docLen
                from documents d
                    inner join vocabulary v
                    on v.document_id = d.id
                    inner join documents_authors da
                        inner join authors a
                        on da.id_author = a.id
                    on d.id = da.document_id
                where a.gender = 'female'
                group by d.id),
    q_wordCountDocs as (select v.word_id word_id, count(distinct v.document_id) wordCountDocs
                        from vocabulary v
                        where v.document_id in (select d.id
                                                    from documents d
                                                    inner join documents_authors da
                                                        inner join authors a
                                                        on da.id_author = a.id
                                                    on d.id = da.document_id
                                                    where a.gender = 'female')
                            group by v.word_id),
    q_noDocs as (select d.id id
                    from documents d
                        inner join documents_authors da
                            inner join authors a
                            on da.id_author = a.id
                        on d.id = da.document_id
                    where a.gender = "female")
select q2.id id, sum(q2.okapi) sokapi
        from
            (select d.id id, w.word word, -- v.word_id, v.tf, q_dl.docLen, q_wcd.wordCountDocs,
                    ((v.tf * (1 + ln((select count(id) from q_noDocs)::float/q_wcd.wordCountDocs::float)::float)::float * (1.6 + 1))::float/
                    (v.tf + 1.6 * (1 - 0.75 + 0.75 * q_dl.docLen / (select avg(docLen) from q_docLen)::float)::float)::float)::float okapi
            from documents d
                inner join vocabulary v
                    inner join words w
                    on w.id = v.word_id
                on v.document_id = d.id
                inner join documents_authors da
                    inner join authors a
                    on da.id_author = a.id
                on d.id = da.document_id
                inner join q_docLen q_dl
                on q_dl.id = d.id
                inner join q_wordCountDocs q_wcd
                on q_wcd.word_id =  v.word_id
            where a.gender = "female"
                and w.word in ('think','today','friday')) q2
        group by q2.id
        order by 2 desc, 1
        limit 10;
