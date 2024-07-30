select * 
from netflix_raw
order by show_id;

describe netflix_raw.title;

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'netflix_raw';

-- delete any null rows
DELETE FROM netflix_raw_copy
WHERE `show_id` IS NULL
AND `type` IS NULL
AND `title` IS NULL
AND `director` IS NULL
AND `cast` IS NULL
AND `country` IS NULL
AND `date_added` IS NULL
AND `release_year` IS NULL
AND `rating` IS NULL
AND `duration` IS NULL
AND `listed_in` IS NULL
AND `description` IS NULL;


-- remove the duplicates
select
show_id,
count(*)
from netflix_raw
group by show_id
having count(*) > 1;

select *
from netflix_raw
where concat(title,`type`) in (
	select
    concat(title, `type`)
	from netflix_raw
	group by title, `type`
	having count(*) > 1
)
order by title;

with duplicate_cte as (
	select *,
	row_number() over(partition by title,`type`) as row_num
	from netflix_raw
)
select *
from duplicate_cte
where row_num>1;

-- Create another table with row_num
CREATE TABLE `netflix_raw_copy` (
	`show_id` varchar(10) primary key,
	`type` varchar(10) NULL,
	`title` nvarchar(200) NULL,
	`director` varchar(250) NULL,
	`cast` varchar(1000) NULL,
	`country` varchar(150) NULL,
	`date_added` varchar(20) NULL,
	`release_year` int NULL,
	`rating` varchar(10) NULL,
	`duration` varchar(10) NULL,
	`listed_in` varchar(100) NULL,
	`description` varchar(500) NULL,
    `row_num` int
) ;

insert into netflix_raw_copy
select *,
	row_number() over(partition by title,`type`) as row_num
	from netflix_raw;
    
select * from netflix_raw_copy;

delete from
netflix_raw_copy
where row_num > 1;

with duplicate_cte as (
	select *,
	row_number() over(partition by title,`type`) as row_num
	from netflix_raw_copy
)
select *
from netflix_raw_copy
where row_num>1;

-- new table for director, listed in, cast, country --
-- create netflix_director table
create table netflix_directors (
    `show_id` varchar(10),
    `director` varchar(250)
);

-- split the director column into multiple rows and copy into netflix_director table
insert into netflix_directors
with recursive SplitValues AS (
    select show_id, SUBSTRING_INDEX(director, ',', 1) AS split_value
    from netflix_raw_copy
    union all
    select show_id, SUBSTRING_INDEX(SUBSTRING_INDEX(director, ',', 1), ',', -1) AS split_value
    from netflix_raw_copy
    where LENGTH(director) > LENGTH(replace(director, ',', ''))
)
select show_id, split_value
from SplitValues;

select * from netflix_directors;

select * 
from netflix_raw_copy
where country like '%,%';

create table netflix_country (
    `show_id` varchar(10),
    `country` varchar(150)
);

-- split the country column into multiple rows and copy into netflix_country table
insert into netflix_country
with recursive SplitValues AS (
    select show_id, SUBSTRING_INDEX(country, ',', 1) AS split_value
    from netflix_raw_copy
    union all
    select show_id, SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', 1), ',', -1) AS split_value
    from netflix_raw_copy
    where LENGTH(country) > LENGTH(replace(country, ',', ''))
)
select show_id, split_value
from SplitValues;

select * from netflix_country;

create table netflix_genre (
    `show_id` varchar(10),
    `listed_in` varchar(100)
);

-- split the listed_in column into multiple rows and copy into netflix_genre table
insert into netflix_genre
with recursive SplitValues AS (
    select show_id, SUBSTRING_INDEX(listed_in, ',', 1) AS split_value
    from netflix_raw_copy
    union all
    select show_id, SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 1), ',', -1) AS split_value
    from netflix_raw_copy
    where LENGTH(listed_in) > LENGTH(replace(listed_in, ',', ''))
)
select show_id, split_value
from SplitValues;

select * from netflix_genre;

create table netflix_cast (
    `show_id` varchar(10),
    `cast` varchar(1000)
);

-- split the cast column into multiple rows and copy into netflix_cast table
insert into netflix_cast
with recursive SplitValues AS (
    select show_id, SUBSTRING_INDEX(cast, ',', 1) AS split_value
    from netflix_raw_copy
    union all
    select show_id, SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', 1), ',', -1) AS split_value
    from netflix_raw_copy
    where LENGTH(cast) > LENGTH(replace(cast, ',', ''))
)
select show_id, split_value
from SplitValues;

select * from netflix_cast;



-- convert date_added column as date
select date_added
from netflix_raw_copy;

describe netflix_raw_copy;

select 
date_added,
DATE_FORMAT(STR_TO_DATE(date_added, '%M %e, %Y'), '%Y-%m-%d') AS formatted_date
from netflix_raw_copy;

UPDATE netflix_raw_copy
SET date_added = DATE_FORMAT(STR_TO_DATE(date_added, '%M %e, %Y'), '%Y-%m-%d');

alter table netflix_raw_copy modify column date_added DATE; 


-- the duarion column if it's null with the rating value
select * 
from netflix_raw_copy
where duration is null;

UPDATE `netflix_raw_copy`
SET `duration` = `rating`
WHERE duration is null;

-- shows the count of movies and tv shows for the director who has directed both
select
nd.director,
COUNT(distinct n.`type`) as distinct_type_count
from netflix_raw_copy as n
join netflix_directors as nd
on n.show_id = nd.show_id
group by nd.director
having distinct_type_count > 1;

select
nd.director,
COUNT(
	distinct
	CASE WHEN n.`type` = 'Movie' THEN n.show_id
    END
) as movie_count,
COUNT(
	distinct
	CASE WHEN n.`type` = 'TV Show' THEN n.show_id
    END
) as tv_show_count
from netflix_raw_copy as n
join netflix_directors as nd
on n.show_id = nd.show_id
where nd.director is not null
group by nd.director
having COUNT(distinct n.`type`) > 1;


-- country with highest comedy movies
select nc.country,
count(distinct n.show_id) as num_of_comedy_movies
from netflix_raw_copy as n
join netflix_country as nc
on n.show_id = nc.show_id
join netflix_genre as ng
on n.show_id = ng.show_id
where ng.listed_in = 'Comedies' and n.type = 'Movie'
group by nc.country
order by num_of_comedy_movies DESC
limit 1;

-- each year which director has the maximum number of releases
select
YEAR(n.date_added) as date_year,
nd.director,
count(distinct n.show_id) as num_of_releases
from netflix_raw_copy as n
join netflix_directors as nd
on n.show_id = nd.show_id
where nd.director is not null and nd.director != ""
group by date_year, nd.director
order by num_of_releases desc;



















