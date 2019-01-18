/* Calculates longest period of inactivity for an enrollment */
WITH
  userDatetime AS (
  SELECT
    course_id,
    user_id,
    DATETIME_DIFF(LEAD(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp),
      timestamp,
      second) AS userDatetimeDiff -- partition by user and order operations by time
  FROM
    canvas_data.requests
  WHERE
    timestamp_day BETWEEN '2018-08-20'
    AND '2018-09-10'
    AND user_id IS NOT NULL
    AND course_id IS NOT NULL)
SELECT
  course_id,
  user_id,
  MAX(userDatetimeDiff) AS largestPeriodOfInactivity
FROM
  userDatetime
GROUP BY
  course_id,
  user_id
