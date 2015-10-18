CREATE  PROCEDURE [dbo].[USP_OXO_EMT_GET] 
  @p_Event nvarchar(50)
AS
	
	SELECT 
      Id  AS Id,
      Event  AS Event,  
      Subject  AS Subject,  
      Body  AS Body  
      	     
    FROM dbo.OXO_EMAIL_TEMPLATE
	WHERE Event = @p_Event;

