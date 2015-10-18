CREATE PROCEDURE [dbo].[USP_OXO_EMT_GETMANY]
 
AS
	
   SELECT 
    Id  AS Id,
    Event  AS Event,  
    Subject  AS Subject,  
    Body  AS Body  
    FROM dbo.OXO_EMAIL_TEMPLATE
    ;

