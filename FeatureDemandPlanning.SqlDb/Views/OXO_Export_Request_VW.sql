


CREATE VIEW [dbo].[OXO_Export_Request_VW] 
AS
SELECT Q.Id, GUID, 
       Doc_Id AS DocId, 
       Prog_Id AS ProgId,
       Requested_By AS RequestedBy,
       Requested_On AS RequestedOn,
       REPLACE(Q.Step, '_', ' ') AS Step,
       Q.Style,
       REPLACE(Q.Status, '_', ' ') AS Status,
       ISNULL(U.First_Names + ' ' + U.Surname + ' (' + U.CDSID + ')', Q.Requested_By) AS UserInfo,
       Doc_Name AS OXODocName
FROM OXO_Export_Queue Q
LEFT OUTER JOIN OXO_System_User U
ON Q.Requested_By = U.CDSID