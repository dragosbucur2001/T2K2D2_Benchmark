-- \set startDate '''2015-09-17 00:00:00'''
-- \set endDate '''2015-09-18 00:00:00'''
-- \set startHour 0
-- \set endHour 23
-- \set startDay 17
-- \set endDay 18
-- \set startMonth 9
-- \set endMonth 9
-- \set startYear 2015
-- \set endYear 2015
-- \set startX 20
-- \set endX 40
-- \set startY -100
-- \set endY 100
-- \set gender '''female'''
-- \set k1 1.6
-- \set b 0.75
-- \set top 10
-- \set words ('''think''')
-- \set words ('''think''','''today''')
-- \set words ('''think''','''today''','''friday''')



-- top-K keywords  TFIDF by gender & date - ok
with
    noDocs as (select distinct id_document 
                from document_facts f 
                    inner join author_dimension ad on ad.id_author = f.id_author
                    inner join time_dimension td on td.id_time = f.id_time
                where ad.gender='female'
                    and td.full_date between '2015-09-17 00:00:00' and '2015-09-18 00:00:00'
                )
select wd.word, sum(f.tf) * (1+ln((select count(id_document) from noDocs)/count(distinct f.id_document))) TFIDF
    from 
        document_facts f
        inner join time_dimension td on td.id_time = f.id_time
        inner join author_dimension ad on ad.id_author = f.id_author
        inner join word_dimension wd on wd.id_word = f.id_word
    where
        ad.gender = 'female'
        and td.full_date between '2015-09-17 00:00:00' and '2015-09-18 00:00:00'
    group by wd.word
    order by 2 desc
    limit 10;

