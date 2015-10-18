
CREATE PROCEDURE [dbo].[OXO_ExportRequest_Edit] 
   @p_Id INT
  ,@p_GUID  nvarchar(500) 
  ,@p_DocId  int 
  ,@p_ProgId  int 
  ,@p_Step  nvarchar(50) 
  ,@p_Style  nvarchar(50) 
  ,@p_Doc_Name nvarchar(500) 
  ,@p_RequestedBy  nvarchar(10) 
  ,@p_RequestedOn  datetime 
  ,@p_Status  nvarchar(50) 
      
AS
	
  UPDATE dbo.OXO_Export_Queue 
    SET 
  GUID=@p_GUID,  
  Doc_Id=@p_DocId,  
  Prog_Id=@p_ProgId,  
  Step=@p_Step,  
  Style=@p_Style,
  Doc_Name = @p_Doc_Name,
  Requested_By=@p_RequestedBy,  
  Requested_On=@p_RequestedOn,  
  Status=@p_Status  
  	     
   WHERE Id = @p_Id;