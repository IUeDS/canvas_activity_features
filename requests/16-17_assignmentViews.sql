WITH
  assnAccess AS (
  SELECT
    a.course_id,
    a.user_id,
    CAST(REGEXP_EXTRACT(url,r'assignments\/(\d+)') AS INT64) AS assignment_id,
    b.due_at,
    b.id AS canvas_assignment_id,
    a.timestamp AS this_ts
  FROM
    canvas_data.requests a
  INNER JOIN
    canvas_data.assignment_dim b
  ON
    CAST(REGEXP_EXTRACT(a.url,r'assignments\/(\d+)') AS INT64) = b.canvas_id
  WHERE
    timestamp_day BETWEEN '2018-08-20'
    AND '2018-09-10'
    AND a.course_id IS NOT NULL
  ORDER BY
    user_id,
    timestamp)
SELECT
  course_id,
  user_id,
  COUNTIF(CAST(this_ts AS TIMESTAMP)<due_at) AS numberOfAssignmentAccessPreDeadline,
  COUNTIF(CAST(this_ts AS TIMESTAMP)>due_at) AS numberOfAssignmentAccessPostDeadline
FROM
  assnAccess
GROUP BY
  course_id,
  user_id
