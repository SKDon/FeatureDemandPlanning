CREATE PROCEDURE [dbo].[OXO_OXODoc_Edit] 
   @p_Id INT OUTPUT
  ,@p_Programme_Id int
  ,@p_Gateway    nvarchar(50)
  ,@p_Version_Id  numeric(10,1)
  ,@p_Status  nvarchar(50)
  ,@p_Updated_By  varchar(8) 
  ,@p_Last_Updated  datetime       
AS
	
  UPDATE dbo.OXO_Doc
  SET 
  Programme_Id=@p_Programme_Id, 
  Gateway = @p_Gateway,
  Version_Id = @p_Version_Id,
  Status = @p_Status, 
  Updated_By=@p_Updated_By,  
  Last_Updated=@p_Last_Updated  
  	     
   WHERE Id = @p_Id;

