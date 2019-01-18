/* Calculates total number of tools accessed within Canvas by an enrollment within a session immediately AFTER an assignment object was accessed */
WITH
  nextTool AS (
  SELECT
    user_id,
    web_application_controller,
    session_id,
    url,
    LEAD(CAST(REGEXP_EXTRACT(url,r'courses\/\d+\/(\D+)\/') AS STRING)) OVER (PARTITION BY session_id ORDER BY user_id, timestamp) AS next_tool,
    course_id --partition by session to determine tool use within session
  FROM
    canvas_data.requests
  WHERE
    timestamp_day BETWEEN '2018-08-20'
    AND '2018-09-10'
    AND user_id IS NOT NULL
    AND course_id IS NOT NULL),
  toolCount AS (
  SELECT
    a.course_id,
    a.user_id,
    session_id,
    SUM(IF(a.next_tool = "files",
        1,
        0)) AS landingCount_files,
    SUM(IF(a.next_tool = "assignments",
        1,
        0)) AS landingCount_assignments,
    SUM(IF(a.next_tool LIKE "modules%",
        1,
        0)) AS landingCount_modules,
    SUM(IF(a.next_tool LIKE "pages%",
        1,
        0)) AS landingCount_pages,
    SUM(IF(a.next_tool IS NULL,
        1,
        0)) AS landingCount_null,
    SUM(IF((a.next_tool IS NOT NULL)
        AND (a.next_tool != "files")
        AND (a.next_tool != "assignments")
        AND (a.next_tool NOT LIKE "modules%")
        AND (a.next_tool NOT LIKE "pages%"),
        1,
        0)) AS landingCount_other
  FROM
    nextTool a
  WHERE
    a.web_application_controller = 'assignments'
    AND NOT (a.url LIKE '%assignments/syllabus%')
  GROUP BY
    a.course_id,
    a.user_id,
    session_id)
SELECT
  course_id,
  user_id,
  SUM(landingCount_files) AS landingCount_files,
  SUM(landingCount_assignments) AS landingCount_assignments,
  SUM(landingCount_modules) AS landingCount_modules,
  SUM(landingCount_pages) AS landingCount_pages,
  SUM(landingCount_null) AS landingCount_null,
  SUM(landingCount_other) AS landingCount_other
FROM
  toolCount
GROUP BY
  course_id,
  user_id
