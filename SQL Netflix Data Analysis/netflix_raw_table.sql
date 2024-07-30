use netflix_db;

CREATE TABLE `netflix_raw` (
	`show_id` varchar(10) primary key,
	`type` varchar(10),
	`title` nvarchar(200),
	`director` varchar(250),
	`cast` varchar(1000),
	`country` varchar(150),
	`date_added` varchar(20),
	`release_year` int,
	`rating` varchar(10),
	`duration` varchar(10),
	`listed_in` varchar(100),
	`description` varchar(500)
) ;

CREATE TABLE `netflix_raw_copy` (
	`show_id` varchar(10) primary key,
	`type` varchar(10),
	`title` nvarchar(200),
	`director` varchar(250),
	`cast` varchar(1000),
	`country` varchar(150),
	`date_added` varchar(20),
	`release_year` int,
	`rating` varchar(10),
	`duration` varchar(10),
	`listed_in` varchar(100),
	`description` varchar(500)
) ;


