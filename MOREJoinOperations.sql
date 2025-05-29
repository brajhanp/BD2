--Pregunta 1
SELECT id, title
 FROM movie
 WHERE yr=1962;

--Pregunta 2
select yr from movie where title='Citizen Kane';

--Pregunta 3
select id, title, yr from movie where title like 'Star Trek%' order by yr;

--Pregunta 4
select id from actor where name='Glenn Close';

--Pregunta 5
select id from movie where title='Casablanca';

--Pregunta 6 
select a.name from casting c inner join actor a on c.actorid =a.id where movieid=11768;

--Pregunta 7
select a.name from casting c inner join actor a on c.actorid =a.id where movieid=10522;

--Pregunta 8
select title from casting c left join movie m on c.movieid=m.id
where actorid=(select id from actor where name="Harrison Ford");

--Pregunta 9
select title from casting c left join movie m on c.movieid=m.id
where actorid=(select id from actor where name="Harrison Ford") and c.ord != 1;

--Pregunta 10
select m.title, a.name from movie m 
JOIN casting c ON m.id = c.movieid
JOIN actor a ON c.actorid= a.id
where c.ord = 1 and m.yr=1962;

--Pregunta 11
SELECT yr,COUNT(title) FROM
  movie JOIN casting ON movie.id=movieid
        JOIN actor   ON actorid=actor.id
WHERE name='Rock Hudson'
GROUP BY yr
HAVING COUNT(title) > 2;

--Pregunta 12

SELECT title, name
FROM movie
JOIN casting ON (movieid=movie.id AND ord=1)
JOIN actor ON (actorid=actor.id)
WHERE movie.id IN (
    SELECT movieid FROM casting
    WHERE actorid IN(
        SELECT id FROM actor
        WHERE name='Julie Andrews'
    )
);
--Pregunta 13
SELECT a.name
FROM actor a
JOIN casting c ON a.id = c.actorid
WHERE c.ord = 1
GROUP BY a.name
HAVING COUNT(c.movieid) >= 15
ORDER BY a.name ASC;

--Pregunta 14
 SELECT m.title, COUNT(c.actorid) AS actor_count
FROM movie m
LEFT JOIN casting c ON m.id = c.movieid
WHERE m.yr = 1978
GROUP BY m.id, m.title
ORDER BY actor_count DESC, m.title ASC;
--Pregunta 15

