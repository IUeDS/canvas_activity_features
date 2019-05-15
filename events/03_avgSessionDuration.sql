/* Computes duration of a web session in which an assignment was accessed for each enrollment */
WITH
  sessionTimeDiff AS (
  SELECT
    SUBSTR(JSON_EXTRACT_SCALAR(event,"$[actor][id]"),-7,7) AS user_id,
    SUBSTR(JSON_EXTRACT_SCALAR(event,"$[session][id]"),-32,32) AS session_id,
    TIMESTAMP_DIFF(LEAD(event_time) OVER (PARTITION BY SUBSTR(JSON_EXTRACT_SCALAR(event,"$[session][id]"),-32,32) ORDER BY event_time),
      event_time,
      second) AS timebetweenEvents,
    SUBSTR(JSON_EXTRACT_SCALAR(event,"$[group][extensions]['com.instructure.canvas'][entity_id]"),-7,7) AS course_id
  FROM
    event_store.events
  WHERE
    SUBSTR(JSON_EXTRACT_SCALAR(event,"$[actor][id]"),-7,7) IS NOT NULL
    AND SUBSTR(JSON_EXTRACT_SCALAR(event,"$[session][id]"),-32,32) IS NOT NULL
    AND EXTRACT(DATE FROM event_time) BETWEEN '2019-01-07' AND '2019-01-21'
    AND JSON_EXTRACT_SCALAR(event,"$[actor][type]") = "Person"),
  sessionSumTime AS (
  SELECT
    course_id,
    user_id,
    session_id,
    SUM(timebetweenEvents) AS sessionDuration
  FROM
    sessionTimeDiff
  WHERE
    timebetweenEvents <= 1500 --ignore periods of inactivity > 25 minutes
  GROUP BY
    course_id,
    user_id,
    session_id)

SELECT
  course_id,
  user_id,
  AVG(sessionDuration) AS avgSessionDuration
FROM
  sessionSumTime
GROUP BY
  course_id,
  user_id
