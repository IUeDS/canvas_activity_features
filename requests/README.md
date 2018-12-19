# Features from Requests Data

Queries for extracting features of student activity from Canvas **Requests**, a data source derived directly from Canvas's Apache server logs.

Descriptions of fields in the **Requests** table are listed in [requests_fields.csv](./requests_fields.csv).

## Disclaimer from Instructure
Disclaimer: The data in the requests table is a 'best effort' attempt, and is not guaranteed to be complete or wholly accurate. This data is meant to be used for rollups and analysis in the aggregate, _not_ in isolation for auditing, or other high-stakes analysis involving examining single users or small samples. As this data is generated from the Canvas logs files, not a transactional database, there are many places along the way data can be lost and/or duplicated (though uncommon). Additionally, given the size of this data, our processes are often done on monthly cycles for many parts of the requests tables, so as errors occur they can only be rectified monthly. (From [https://portal.inshosteddata.com/docs#requests](https://portal.inshosteddata.com/docs#requests))
