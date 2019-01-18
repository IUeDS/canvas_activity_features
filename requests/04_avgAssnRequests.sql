/* Computes average number of requests (proxy for number of page views) in which an enrollment accessed an assignment */
CREATE OR REPLACE TABLE
  data4ml.feature04_afterWeek15 AS
WITH
  numAssnRequests AS ( --subquery calculates number of reqeusts by an enrollment within a section
  SELECT
    course_id,
    user_id,
    session_id,
    COUNT(id) AS AssnRequests
  FROM
    canvas_data.requests
  WHERE
    timestamp_day BETWEEN '2018-08-20'
    AND '2018-09-10'
    AND course_id IS NOT NULL
    AND user_id IS NOT NULL
    AND web_application_controller='assignments'
    AND NOT (url LIKE '%assignments/syllabys%/')
    AND web_application_action = 'show'
  GROUP BY
    course_id,
    user_id,
    session_id
  ORDER BY
    course_id,
    user_id)
SELECT
  course_id,
  user_id,
  AVG(AssnRequests) AS avgAssnRequests
FROM
  numAssnRequests
GROUP BY
  course_id,
  user_id
