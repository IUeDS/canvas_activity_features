/* Number of submissions per enrollment */
/* NB: This query does not use the requests table */
SELECT
  assn.course_id,
  subm.user_id,
  COUNT(subm.id) AS submission_count
FROM
  canvas_data.submission_dim AS subm
INNER JOIN
  canvas_data.assignment_dim AS assn
ON
  subm.assignment_id = assn.id
WHERE
  assn.workflow_state = 'published'
  AND subm.workflow_state NOT IN ('unsubmitted',
    'deleted') AND submitted_at >= '2018-08-20'
    AND submitted_at <= '2018-09-10'
GROUP BY
  assn.course_id,
  subm.user_id
