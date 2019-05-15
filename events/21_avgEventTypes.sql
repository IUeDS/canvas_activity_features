/* Computes average number of different event types in sessions including course event */
WITH
  eventsBySession AS (
    SELECT 
      SUBSTR(JSON_EXTRACT_SCALAR(event,"$[actor][id]"),-7,7) AS user_id,
      SUBSTR(JSON_EXTRACT_SCALAR(event,"$[session][id]"),-32,32) AS session_id,
      SUBSTR(JSON_EXTRACT_SCALAR(event,"$[group][extensions]['com.instructure.canvas'][entity_id]"),-7,7) AS course_id,
      JSON_EXTRACT_SCALAR(event,"$[type]") AS eventType,
      COUNT(DISTINCT id) AS numberOfEvents
    FROM
      event_store.events
    WHERE
      SUBSTR(JSON_EXTRACT_SCALAR(event, "$[actor][id]"),-7,7) IS NOT NULL
      AND EXTRACT(DATE FROM event_time) BETWEEN '2019-01-07' AND '2019-01-21'
      AND JSON_EXTRACT_SCALAR(event, "$[actor][type]") = "Person"
      AND SUBSTR(JSON_EXTRACT_SCALAR(event,"$[group][extensions]['com.instructure.canvas'][entity_id]"),-7,7) IS NOT NULL
    GROUP BY 
      SUBSTR(JSON_EXTRACT_SCALAR(event,"$[actor][id]"),-7,7),
      SUBSTR(JSON_EXTRACT_SCALAR(event,"$[session][id]"),-32,32),
      SUBSTR(JSON_EXTRACT_SCALAR(event,"$[group][extensions]['com.instructure.canvas'][entity_id]"),-7,7),
      JSON_EXTRACT_SCALAR(event,"$[type]")), 
  eventCountBySession AS (
    SELECT user_id,
      session_id, 
      course_id,
      COUNT(DISTINCT eventType) AS eventTypes
    FROM eventsBySession
    GROUP BY user_id,
      session_id, 
      course_id)

SELECT user_id,
  course_id,
  AVG(eventTypes)
FROM eventCountBySession
GROUP BY user_id,
  course_id
