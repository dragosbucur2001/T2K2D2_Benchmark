-- \set startDate '''2015-09-17 00:00:00'''
-- \set endDate '''2015-09-18 00:00:00'''
-- \set xStart 20
-- \set xEnd 40
-- \set yStart -100
-- \set yEnd 100
-- \set gender '''male'''
-- \set k1 1.6
-- \set b 0.75
-- \set top 10

with 
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
                                                        where g.type = 'male'
                                                            and d.document_date between '2015-09-17 00:00:00' and '2015-09-18 00:00:00')
                                group by v.id_word
                        ),
        q_noDocs as (select d.id id
                        from documents d
                            inner join documents_authors da
                                inner join authors a
                                    inner join genders g
                                    on a.id_gender = g.id
                                on da.id_author = a.id
                            on d.id = da.id_document
                        where g.type = 'male'                          
                            and d.document_date between '2015-09-17 00:00:00' and '2015-09-18 00:00:00')

    select q2.word word, sum(q2.tfidf) stfidf 
        from
            (select d.id id, w.word word, -- v.id_word, v.tf, q_dl.docLen, q_wcd.wordCountDocs,
                  v.tf * (1 + ln((select count(id) from q_noDocs)/q_wcd.wordCountDocs)) tfidf
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
                inner join q_wordCountDocs q_wcd
                on q_wcd.id_word =  v.id_word
            where g.type = 'male'
                and d.document_date between '2015-09-17 00:00:00' and '2015-09-18 00:00:00') q2
        group by q2.word
        order by 2 desc
        limit 10;



