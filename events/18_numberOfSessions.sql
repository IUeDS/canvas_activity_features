/* Counts number of sessions per enrollment */
SELECT
  SUBSTR(JSON_EXTRACT_SCALAR(event,"$[group][extensions]['com.instructure.canvas'][entity_id]"),-7,7) AS course_id,
  SUBSTR(JSON_EXTRACT_SCALAR(event,"$[actor][id]"),-7,7) AS user_id,
  COUNT(DISTINCT SUBSTR(JSON_EXTRACT_SCALAR(event,"$[session][id]"),-32,32)) AS numberOfSessions
FROM
  event_store.events
WHERE
  EXTRACT(DATE FROM event_time) BETWEEN '2019-01-07' AND '2019-01-21'
  SUBSTR(JSON_EXTRACT_SCALAR(event,"$[group][extensions]['com.instructure.canvas'][entity_id]"),-7,7) IS NOT NULL 
  AND SUBSTR(JSON_EXTRACT_SCALAR(event,"$[actor][id]"),-7,7) IS NOT NULL
  AND JSON_EXTRACT_SCALAR(event,"$[actor][type]") = "Person"
GROUP BY
  SUBSTR(JSON_EXTRACT_SCALAR(event,"$[group][extensions]['com.instructure.canvas'][entity_id]"),-7,7),
  SUBSTR(JSON_EXTRACT_SCALAR(event,"$[actor][id]"),-7,7)
