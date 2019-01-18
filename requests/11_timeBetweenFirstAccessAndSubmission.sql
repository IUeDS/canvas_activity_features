  /* Calculates average time between first access of an assignment and the submission of an assignment by an enrollment */
WITH
  assnAccess AS (
  SELECT
    course_id,
    user_id,
    CAST(REGEXP_EXTRACT(url,r'assignments\/(\d+)') AS INT64) AS assignment_id,
    timestamp
  FROM
    canvas_data.requests
  WHERE
    timestamp_day BETWEEN '2018-08-20'
    AND '2018-09-10'
    AND web_application_controller NOT IN ('submissions',
      'submissions/previews')
    AND course_id IS NOT NULL),
  assnAccSub AS (
  SELECT
    course_id,
    user_id,
    assignment_id,
    MIN(timestamp) AS first_assn_access
  FROM
    assnAccess
  GROUP BY
    course_id,
    user_id,
    assignment_id
  ORDER BY
    user_id,
    assignment_id)
SELECT
  a.course_id,
  a.user_id,
  AVG(DATETIME_DIFF(CAST(b.submitted_at AS DATETIME),
      CAST(a.first_assn_access AS DATETIME),
      minute)) AS timeBetweenFirstAccessAndSubmission
FROM
  assnAccSub a
LEFT JOIN
  canvas_data.submission_dim b
ON
  CAST(a.user_id AS INT64) = b.user_id
  AND CAST(a.assignment_id AS INT64) = CAST(SUBSTR(CAST(b.assignment_id AS STRING),9,LENGTH(CAST(b.assignment_id AS STRING))) AS INT64)
WHERE
  submitted_at IS NOT NULL
GROUP BY
  course_id,
  a.user_id
