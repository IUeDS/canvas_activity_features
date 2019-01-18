  /* Calculates quantity of assignment submissions per enrollment within three different categories: day, evening, night */
WITH
  submHour AS (
  SELECT
    assn.course_id,
    subm.user_id,
    ROUND(EXTRACT(hour
      FROM
        CAST(submitted_at AS timestamp))-4,0) AS hour_subm
  FROM
    canvas_data.submission_dim AS subm
  INNER JOIN
    canvas_data.assignment_dim AS assn
  ON
    subm.assignment_id = assn.id
  WHERE
    assn.workflow_state = 'published'
    AND subm.workflow_state NOT IN ('unsubmitted',
      'deleted')
    AND submitted_at BETWEEN '2018-08-20'
    AND '2018-09-10')
SELECT
  DISTINCT course_id,
  user_id,
  SUM(IF(hour_subm BETWEEN 6
      AND 18,
      1,
      0)) AS timeOfSubmission_day,
  SUM(IF(hour_subm BETWEEN 18
      AND 24,
      1,
      0)) AS timeOfSubmission_evening,
  SUM(IF(hour_subm NOT BETWEEN 6
      AND 24,
      1,
      0)) AS timeOfSubmission_night
FROM
  submHour
GROUP BY
  course_id,
  user_id
ORDER BY
  user_id
