/* Compute total time viewing assignments, in seconds */
WITH
  time_on_page AS (
  SELECT
    user_id,
    session_id,
    REGEXP_EXTRACT(url,r'assignments\/(\d+)') AS assignment_id,
    datetime_diff(LEAD(timestamp) OVER (PARTITION BY session_id ORDER BY timestamp),
      timestamp,
      second) AS time_diff,
    --calculates difference between each request operation within a table partitioned by section. Should begin new tally for each session.
    course_id,
    web_application_controller
  FROM
    canvas_data.requests
  WHERE
    timestamp_day BETWEEN '2018-08-20'
    AND '2018-09-10' /* Note, later development will make date a variable input from other component to compute analytic table between specified time range */
    AND user_id IS NOT NULL
    AND course_id IS NOT NULL
    AND url NOT LIKE '%assignments/syllabus%' )

SELECT
  course_id,
  user_id,
  SUM(time_diff) AS timeOnAssignments
FROM
  time_on_page
WHERE
  time_diff <= 1200 -- viewing time greater than 20 minutes is considered to be idle and the start of a new session
  AND web_application_controller = 'assignments' 
GROUP BY
  course_id,
  user_id
ORDER BY
  timeOnAssignments DESC
