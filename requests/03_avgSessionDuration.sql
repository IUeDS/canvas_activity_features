/* Computes duration of a web session in which an assignment was accessed for each enrollment */
WITH
  assnSessionTimeDiff AS (
  SELECT
    user_id,
    session_id,
    DATETIME_DIFF(LEAD(timestamp) OVER (PARTITION BY session_id ORDER BY timestamp),
      timestamp,
      second) AS timebetweenRequest,
    course_id
  FROM
    canvas_data.requests
  WHERE
    user_id IS NOT NULL
    AND course_id IS NOT NULL
    AND timestamp_day BETWEEN '2018-08-20'
    AND '2018-09-10'
    AND web_application_controller = 'assignments'
    AND NOT (url LIKE '%assignments/syllabus%')),
  assnTimeSession AS (
  SELECT
    course_id,
    user_id,
    session_id,
    SUM(timebetweenRequest) AS sessionDuration
  FROM
    assnSessionTimeDiff
  WHERE
    timebetweenRequest <= 1500 --ignore periods of inactivity > 25 minutes
  GROUP BY
    course_id,
    user_id,
    session_id)
SELECT
  course_id,
  user_id,
  AVG(sessionDuration) AS avgSessionDuration
FROM
  assnTimeSession
GROUP BY
  course_id,
  user_id
