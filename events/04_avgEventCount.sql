/* Computes average number of events in a session */
WITH
  sessionEventCount AS (
  SELECT
    SUBSTR(JSON_EXTRACT_SCALAR(event,"$[actor][id]"),-7,7) AS user_id,
    SUBSTR(JSON_EXTRACT_SCALAR(event,"$[session][id]"),-32,32) AS session_id,
    SUBSTR(JSON_EXTRACT_SCALAR(event,"$[group][extensions]['com.instructure.canvas'][entity_id]"),-7,7) AS course_id,
    COUNT(DISTINCT id) AS numberOfEvents
  FROM
    event_store.events 
  WHERE
    SUBSTR(JSON_EXTRACT_SCALAR(event,"$[actor][id]"),-7,7) IS NOT NULL
    AND SUBSTR(JSON_EXTRACT_SCALAR(event,"$[session][id]"),-32,32) IS NOT NULL
    AND EXTRACT(DATE FROM event_time) BETWEEN '2019-01-07' AND '2019-01-21'
    AND JSON_EXTRACT_SCALAR(event,"$[actor][type]") = "Person"
  GROUP BY
    SUBSTR(JSON_EXTRACT_SCALAR(event,"$[actor][id]"),-7,7),
    SUBSTR(JSON_EXTRACT_SCALAR(event,"$[session][id]"),-32,32),
    SUBSTR(JSON_EXTRACT_SCALAR(event,"$[group][extensions]['com.instructure.canvas'][entity_id]"),-7,7))

SELECT
  course_id,
  user_id,
  AVG(numberOfEvents) AS avgEventCount
FROM
  sessionEventCount
GROUP BY
  course_id,
  user_id
