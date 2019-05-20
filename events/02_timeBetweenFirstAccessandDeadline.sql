WITH
    accesstime AS (
        SELECT 
    json_extract_scalar(a.event,
        "$[federatedSession][messageParameters][custom_canvas_user_id]") AS user_id,
    json_extract_scalar(a.event, 
        "$[federatedSession][messageParameters][custom_canvas_assignment_id]") AS assignment_id,
    json_extract_scalar(a.event, 
        "$[federatedSession][messageParameters][custom_canvas_course_id]") AS course_id,
    DATETIME(b.due_at) AS due_at,
    PARSE_DATETIME("%Y-%m-%d %H:%M:%S", REPLACE(SUBSTR(json_extract_scalar(a.event, "$[eventTime]"),0, 19),"T", "")) as dt,
    DATETIME_DIFF(DATETIME(b.due_at), 
      PARSE_DATETIME("%Y-%m-%d %H:%M:%S", REPLACE(SUBSTR(json_extract_scalar(a.event, "$[eventTime]"),0, 19),"T", "")),
      hour) AS TimeBeforeDue,
    PARSE_DATE("%Y-%m-%d", SUBSTR(json_extract_scalar(a.event, "$[eventTime]"),0, 10)) AS TIMESTAMP_DAY
FROM `udp-iu-prod.event_store.events` a
INNER JOIN `iu-uits-tlt-la.canvas_data.assignment_dim` b
ON CAST(json_extract_scalar(a.event, "$[federatedSession][messageParameters][custom_canvas_user_id]") AS INT64) = b.canvas_id
    AND type = "AssessmentEvent"
    AND due_at IS NOT NULL
    AND json_extract_scalar(a.event,
            "$[federatedSession][messageParameters][custom_canvas_user_id]") IS NOT NULL
    AND json_extract_scalar(a.event, 
            "$[federatedSession][messageParameters][custom_canvas_assignment_id]") IS NOT NULL
    AND b.submission_types NOT IN ('none', 'not_graded')
    AND b.grading_type <> 'not_graded'),
  maxtimebefore AS (
    SELECT
      course_id,
      user_id,
      assignment_id,
      MAX(timeBeforeDue) AS firstTimeBeforeDue
    FROM
      accesstime
    GROUP BY
      course_id,
      user_id,
      assignment_id)
  SELECT
    course_id,
    user_id,
    AVG(firstTimeBeforeDue) AS timeBetweenFirstAccessandDeadline
  FROM
    maxtimebefore
  GROUP BY
    course_id,
    user_id
  ORDER BY
    timeBetweenFirstAccessandDeadline DESC
