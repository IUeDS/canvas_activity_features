/* Computes average number of requests (proxy for number of page views) in which an enrollment accessed an assignment */
WITH
  theseRequests AS (
  SELECT
    id,
    user_id,
    REGEXP_EXTRACT(url,r'assignments\/(\d+)') AS assignment_id,
    session_id,
    url,
    course_id,
    web_application_action,
    web_application_controller
  FROM
    canvas_data.requests
  WHERE
    timestamp_day BETWEEN '2018-08-20'
    AND '2018-09-10'
    AND course_id IS NOT NULL ),
  sessionsWithAssignmentViews AS (
  SELECT
    DISTINCT session_id,
    course_id
  FROM
    theseRequests
  WHERE
    web_application_controller = 'assignments'
    AND NOT (url LIKE '%assignments/syllabus%')),
  viewsPerSession AS (
  SELECT
    COUNT(a.id) AS cntRequests,
    a.user_id,
    a.course_id,
    b.session_id
  FROM
    theseRequests a
  JOIN
    sessionsWithAssignmentViews b
  ON
    a.session_id = b.session_id
    AND a.course_id = b.course_id
  WHERE
    web_application_action = 'show'
    AND b.course_id IS NOT NULL
  GROUP BY
    a.user_id,
    a.course_id,
    b.session_id )
SELECT
  user_id,
  course_id,
  AVG(cntRequests) AS numberOfRequests
FROM
  viewsPerSession
GROUP BY
  user_id,
  course_id
