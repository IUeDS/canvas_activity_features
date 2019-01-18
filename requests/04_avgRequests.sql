/* Computes average number of requests (proxy for number of page views) in which an enrollment accessed an assignment */
WITH
  theseRequests AS (
  SELECT
    id,
    user_id,
    REGEXP_EXTRACT(url,r'assignments\/(\d+)') AS assignment_id,
    session_id AS this_session,
    LEAD(session_id) OVER (ORDER BY user_id, timestamp) AS next_session,
    url,
    course_id,
    web_application_action,
    web_application_controller
  FROM
    canvas_data.requests
  WHERE timestamp_day BETWEEN '2018-08-20'
    AND '2018-09-10'
  ORDER BY
    user_id,
    timestamp ),
  sessionsWithAssignmentViews AS (
  SELECT
    DISTINCT this_session
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
    b.this_session
  FROM
    theseRequests a
  JOIN
    sessionsWithAssignmentViews b
  ON
    a.this_session = b.this_session
  WHERE
    a.this_session = a.next_session
    AND web_application_action = 'show'
  GROUP BY
    a.user_id,
    a.course_id,
    b.this_session )
SELECT
  user_id,
  course_id,
  AVG(cntRequests) AS numberOfRequests
FROM
  viewsPerSession
GROUP BY
  user_id,
  course_id
