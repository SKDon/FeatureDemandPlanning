CREATE PROCEDURE [OXO_ExportRequest_Get] 
  @p_Id int
AS
	
	SELECT 
      Id,
      GUID,  
      DocId,  
      ProgId,  
      Step,  
      RequestedBy,  
      RequestedOn,  
      Status,
      UserInfo,
      OXODocName            	     
    FROM dbo.OXO_Export_Request_VW
	WHERE Id = @p_Id;