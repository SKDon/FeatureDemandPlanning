CREATE PROCEDURE [dbo].[OXO_Gateway_GetMany] 
AS	
	SELECT Gateway AS Name, 
	       Display_Order AS DisplayOrder      
    FROM dbo.OXO_Gateway
    ORDER By Display_Order;

