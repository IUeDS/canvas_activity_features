/* Computes average time between first access of an assignment and assignment deadline */
WITH
  accesstime AS (
  SELECT
    a.user_id,
    REGEXP_EXTRACT(a.url,r'assignments\/(\d+)') AS assignment_id,
    DATETIME_DIFF(DATETIME(due_at),
      timestamp,
      hour) AS timeBeforeDue,
    a.course_id,
    a.web_application_controller
  FROM
    canvas_data.requests a
  LEFT JOIN
    canvas_data.assignment_dim b
  ON
    CAST(REGEXP_EXTRACT(a.url,r'assignments\/(\d+)') AS INT64) = b.canvas_id
    AND user_id IS NOT NULL
    AND b.submission_types IS NOT NULL
    AND web_application_controller = 'assignments'
    AND b.submission_types NOT IN ('none',
      'not_graded')
    AND b.grading_type <> 'not_graded'
    AND timestamp_day BETWEEN '2018-08-20'
    AND '2018-09-10'
    AND a.course_id IS NOT NULL),
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
