
CREATE  PROCEDURE [dbo].[OXO_ExportRequest_New] 
   @p_GUID  nvarchar(500), 
   @p_DocId  int, 
   @p_ProgId  int, 
   @p_Step  nvarchar(50), 
   @p_Style  nvarchar(50), 
   @p_Doc_Name  nvarchar(500), 
   @p_RequestedBy  nvarchar(10), 
   @p_RequestedOn  datetime, 
   @p_Status  nvarchar(50), 
  @p_Id INT OUTPUT
AS
	
  INSERT INTO dbo.OXO_Export_Queue
  (
    GUID,  
    Doc_Id,  
    Prog_Id,  
    Step,  
    Style,
    Doc_Name,
    Requested_By,  
    Requested_On,  
    Status  
          
  )
  VALUES 
  (
    @p_GUID,  
    @p_DocId,  
    @p_ProgId,  
    @p_Step, 
    @p_Style,
    @p_Doc_Name,
    @p_RequestedBy,  
    @p_RequestedOn,  
    @p_Status  
      );

  SET @p_Id = SCOPE_IDENTITY();