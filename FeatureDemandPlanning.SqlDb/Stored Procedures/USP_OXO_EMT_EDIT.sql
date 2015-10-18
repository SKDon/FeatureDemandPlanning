CREATE PROCEDURE [dbo].[USP_OXO_EMT_EDIT] 
   @p_Id INT
  ,@p_Event  nvarchar(50) 
  ,@p_Subject  nvarchar(4000) 
  ,@p_Body  ntext 
      
AS
	
  UPDATE dbo.OXO_EMAIL_TEMPLATE 
    SET 
  Event=@p_Event,  
  Subject=@p_Subject,  
  Body=@p_Body  
  	     
   WHERE Id = @p_Id;

