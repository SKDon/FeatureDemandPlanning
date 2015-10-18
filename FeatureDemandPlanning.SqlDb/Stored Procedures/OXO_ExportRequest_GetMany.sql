
CREATE PROCEDURE [dbo].[OXO_ExportRequest_GetMany]
 
AS
	
 	SELECT 
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
    ORDER BY RequestedOn DESC;