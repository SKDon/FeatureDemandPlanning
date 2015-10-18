CREATE FUNCTION [OXO_GetNextGateway]
(
	@p_current NVARCHAR(50)
)
RETURNS NVARCHAR(50)
AS
BEGIN
	
	DECLARE @retVal NVARCHAR(50);
	
	IF @p_current = 'FOLD'
	  SET @retVal = 'FOLD';
	ELSE
	 	SELECT Top 1 @retVal = G2.Gateway 
		FROM OXO_Gateway G1
		INNER JOIN OXO_Gateway G2
		ON G2.Display_Order > G1.Display_Order
		WHERE G1.Gateway = @p_current
		ORDER BY G2.Display_Order;
	
		
	RETURN @retVal;
	 
END
