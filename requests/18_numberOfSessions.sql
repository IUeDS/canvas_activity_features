/* Counts number of sessions per enrollment */
SELECT
  course_id,
  user_id,
  COUNT(DISTINCT session_id) AS numberOfSessions
FROM
  canvas_data.requests
WHERE
  timestamp_day BETWEEN '2018-08-20'
    AND '2018-09-10' AND course_id IS NOT NULL
  AND user_id IS NOT NULL
GROUP BY
  course_id,
  user_id
