
CALL Sp_Split('a,b,c,d', ',');

    WITH RECURSIVE SplitValues AS (
        SELECT
            show_id,
            SUBSTRING_INDEX(director, ',', 1) AS split_value,
            IF(LOCATE(',', director) > 0, SUBSTRING(director, LOCATE(',', director) + 1), NULL) AS remaining_values
        FROM
            netflix_raw_copy
        UNION ALL
        SELECT
            show_id,
            SUBSTRING_INDEX(remaining_values, ',', 1) AS split_value,
            IF(LOCATE(',', remaining_values) > 0, SUBSTRING(remaining_values, LOCATE(',', remaining_values) + 1), NULL)
        FROM
            SplitValues
        WHERE
            remaining_values IS NOT NULL
    )
    SELECT
        show_id,
        split_value
    FROM
        SplitValues
        order by show_id;
        
select * 
from netflix_raw_copy
where director like '%,%'
order by show_id;

CREATE TABLE netflix_directors (
    `show_id` varchar(10),
    `director` varchar(250)
);

INSERT INTO netflix_directors (show_id, director)
SELECT show_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(director, ',', numbers.n), ',', -1)) AS director
FROM (
    SELECT show_id, director, 1 AS n
    -- UNION ALL SELECT show_id, director, 2
    -- Add more UNION ALL lines for additional splits if needed
) AS numbers
INNER JOIN netflix_raw_copy ON CHAR_LENGTH(director) - CHAR_LENGTH(REPLACE(director, ',', '')) >= numbers.n - 1;

SELECT show_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(director, ',', numbers.n), ',', -1)) AS director
from netflix_raw_copy;

INSERT INTO netflix_directors
WITH RECURSIVE SplitValues AS (
    SELECT show_id, SUBSTRING_INDEX(director, ',', 1) AS split_value
    FROM netflix_raw_copy
    UNION ALL
    SELECT show_id, SUBSTRING_INDEX(SUBSTRING_INDEX(director, ',', 1), ',', -1) AS split_value
    FROM netflix_raw_copy
    WHERE LENGTH(director) > LENGTH(REPLACE(director, ',', ''))
)
SELECT show_id, split_value
FROM SplitValues;

select * from netflix_directors;

-- populate missing values for country
select *
from netflix_raw_copy
where country is null
order by director;


select 
show_id,
m.country
from netflix_raw_copy as nr
inner join 
(
	select 
	director,
	country
	from netflix_country as nc
	inner join netflix_directors as nd
	on nc.show_id = nd.show_id
	group by director, country
) as m on nr.director = m.director
where nr.country is null;

insert into
netflix_country
	select 
	show_id,
	m.country
	from netflix_raw_copy as nr
	inner join
	(
		select
		director,
		country
		from netflix_country as nc
		inner join netflix_directors as nd
		on nc.show_id = nd.show_id
		group by director, country
	) as m on nr.director = m.director
	where nr.country is null;
    
    select *
    from netflix_country
    where country is null;
    
select
nc.show_id,
director,
country
from netflix_country as nc
inner join netflix_directors as nd
on nc.show_id = nd.show_id
where director is not null
group by nc.show_id, director, country
order by director;


insert into netflix_raw_copy (`show_id`, `type`, `title`, `director`, `cast`, `country`, `date_added`, `release_year`, `rating`, `duration`, `listed_in`, `description`)
SELECT date_added
FROM netflix_raw;

insert into netflix_raw_copy
SELECT *
FROM netflix_raw;