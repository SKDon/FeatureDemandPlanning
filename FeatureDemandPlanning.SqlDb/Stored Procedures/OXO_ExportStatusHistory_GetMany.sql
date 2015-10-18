CREATE PROCEDURE [OXO_ExportStatusHistory_GetMany]
   @p_request_id int
AS
	
 	SELECT R.GUID, 
 	       R.Step, 
 	       R.UserInfo, 
 	       R.OXODocName AS DocName, 
 	       H.Status, 
 		   H.Status_Date AS StatusDate
	FROM OXO_Export_Request_VW R
	INNER JOIN OXO_Export_Status_History H
	ON R.Id = H.Request_Id
	WHERE R.Id = @p_request_id
	ORDER BY H.Id;