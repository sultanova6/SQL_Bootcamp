CREATE TABLE IF NOT EXISTS roads (
    node1 VARCHAR,
    node2 VARCHAR,
    cost INTEGER
);

INSERT INTO roads (node1, node2, cost)
VALUES ('a', 'b', 10),
      ('b', 'a', 10),
      ('a', 'd', 20),
      ('d', 'a', 20),
      ('a', 'c', 15),
      ('c', 'a', 15),
      ('c', 'b', 35),
      ('b', 'c', 35),
      ('d', 'b', 25),
      ('b', 'd', 25),
      ('d', 'c', 30),
      ('c', 'd', 30);

WITH RECURSIVE a_traces AS (
    SELECT node1 as tour, node1, node2, cost, cost AS summ
    FROM roads WHERE node1 = 'a'
    UNION ALL
    SELECT one.tour || ', ' || two.node1 AS tour,
           two.node1, two.node2, two.cost, one.summ + two.cost AS summ
    FROM roads AS two
    JOIN a_traces AS one ON two.node1 = one.node2
    WHERE tour NOT LIKE '%' || two.node1 || '%'
),
refresh_a_traces AS (SELECT summ AS total_cost, CONCAT('{', tour, ', a', '}') AS tour
		FROM a_traces
		WHERE LENGTH(tour) = 10 AND node2 = 'a'
		ORDER BY total_cost)

-- SELECT * FROM a_traces;

SELECT total_cost, tour FROM refresh_a_traces
WHERE total_cost = (SELECT MIN(total_cost) FROM refresh_a_traces)
ORDER BY total_cost, tour;

-- DROP TABLE roads;