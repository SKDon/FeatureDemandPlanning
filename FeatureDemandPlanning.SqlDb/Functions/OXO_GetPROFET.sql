CREATE FUNCTION OXO_GetPROFET
(
	@p_make			NVARCHAR(50),
	@p_jaq_code     NVARCHAR(50),
	@p_lr_code      NVARCHAR(50)
)
RETURNS NVARCHAR(50)
AS
BEGIN
	
	DECLARE @retVal NVARCHAR(50);
	
	IF (@p_make = 'Jaguar') 
	   BEGIN
		 IF LEN(ISNULL(@p_jaq_code, '')) > 0
		   SET @retVal = @p_jaq_code;  		
	     ELSE
		   SET @retVal = 'XXXX'; 	
	   END
	ELSE
	   BEGIN
		 IF LEN(ISNULL(@p_lr_code, '')) > 0
		   SET @retVal = @p_lr_code;  		
	     ELSE
		   SET @retVal = 'XXXX'; 		   
	   END	
		
	RETURN @retVal;
	
END
