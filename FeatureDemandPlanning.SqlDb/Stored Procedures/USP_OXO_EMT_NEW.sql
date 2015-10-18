CREATE  PROCEDURE [dbo].[USP_OXO_EMT_NEW]
   @p_Event  nvarchar(50), 
   @p_Subject  nvarchar(4000), 
   @p_Body  ntext, 
  @p_Id INT OUTPUT
AS
	
  INSERT INTO dbo.OXO_EMAIL_TEMPLATE
  (
    Event,  
    Subject,  
    Body  
          
  )
  VALUES 
  (
    @p_Event,  
    @p_Subject,  
    @p_Body  
      );

  SET @p_Id = SCOPE_IDENTITY();

