# Features from Requests Data

Queries for extracting features of student activity from Canvas **Requests**, a data source derived directly from Canvas's server logs.  Queries provided in this folder are SQL files, using [BigQuery Standard SQL syntax](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax).  Each query will return a table with three columns: course_id, user_id, and the feature value (e.g., timeOnAssignments).  The feature value is measured for a period of time defined within the query (currently, queries measure feature values for student activity between August 20 and September 10, 2018).

Descriptions of fields in the **Requests** table are listed in [requests_fields.csv](./requests_fields.csv), and in [Canvas Data documentation](https://portal.inshosteddata.com/docs#requests).

## Disclaimer from Instructure
> Disclaimer: The data in the requests table is a 'best effort' attempt, and is not guaranteed to be complete or wholly accurate. This data is meant to be used for rollups and analysis in the aggregate, _not_ in isolation for auditing, or other high-stakes analysis involving examining single users or small samples. As this data is generated from the Canvas logs files, not a transactional database, there are many places along the way data can be lost and/or duplicated (though uncommon). Additionally, given the size of this data, our processes are often done on monthly cycles for many parts of the requests tables, so as errors occur they can only be rectified monthly. 
(From [https://portal.inshosteddata.com/docs#requests](https://portal.inshosteddata.com/docs#requests))

## Queries
This folder contains the following queries:
* [timeOnAssignments](./01_timeOnAssignments.sql)
* [timeBetweenFirstAccessandDeadline](./02_timeBetweenFirstAccessandDeadline.sql)
* [avgSessionDuration](./03_avgSessionDuration.sql)
* [avgRequests](./04_avgRequests.sql)
* [landingCount](./05-10_landingCount.sql)
  * Includes a set of features for different landing pages after viewing an assignment page
* [timeBetweenFirstAccessAndSubmission](./11_timeBetweenFirstAccessAndSubmission.sql)
* [timeOfSubmission](./12-14_timeOfSubmission.sql)
  * Includes 3 features for different categories of time of day
* [numberOfSubmissions](./15_numberOfSubmissions.sql)
* [assignmentViews](./16-17_assignmentViews.sql)
  * Includes two features counting views before and after the assignment deadline
* [numberOfSessions](./18_numberOfSessions.sql)
* [viewsOfCanvasCalendar](./19_viewsOfCanvasCalendar.sql)
* [longestPeriodOfInactivity](./20_longestPeriodOfInactivity.sql)

