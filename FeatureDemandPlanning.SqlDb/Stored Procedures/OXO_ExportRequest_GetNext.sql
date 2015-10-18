
CREATE PROCEDURE [dbo].[OXO_ExportRequest_GetNext] 
AS
BEGIN
	
 	SELECT Top 1      
      Id,
      GUID,  
      DocId,  
      ProgId,  
      Step,  
      Style,
      RequestedBy,  
      RequestedOn,  
      Status,
      UserInfo,
      OXODocName            	     
    FROM dbo.OXO_Export_Request_VW
    WHERE Status = 'New Request'
    ORDER BY RequestedOn ASC;
	
END