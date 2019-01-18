/* Counts number of calendar access points from request table; calendar access occcurs outside of a course context */
SELECT
  user_id,
  COUNT(DISTINCT id) AS numberOfCalendarAccess
FROM
  canvas_data.requests
WHERE
  timestamp_day BETWEEN '2018-08-20'
    AND '2018-09-10'
  AND url = '/calendar'
GROUP BY
  user_id
