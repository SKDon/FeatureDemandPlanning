CREATE FUNCTION [OXO_GetVariantName] 
(
  @p_format nvarchar(500),
  @p_shape nvarchar(50),
  @p_door nvarchar(50),
  @p_wheelbase nvarchar(50),
  @p_size decimal(5,2),
  @p_fueltype nvarchar(50),
  @p_cylinder nvarchar(50),
  @p_turbo nvarchar(50),
  @p_power int,
  @p_drive nvarchar(50),
  @p_gear nvarchar(50),
  @p_trim nvarchar(50),
  @p_trimlevel nvarchar(50),
  @p_kd bit,
  @p_withBR bit = 0
)
RETURNS nvarchar(2000)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @retVal nvarchar(2000); 
	DECLARE @temp nvarchar(20)='';
	DECLARE @kd nvarchar(2)='';
	
	SET @retVal = @p_format;
	SET @retVal = Replace(@retVal, '[sh]', ISNULL(@p_shape, '') + ' ');
	SET @retVal = Replace(@retVal, '[dr]', ISNULL(@p_door, '')  + ' ');
--	IF (@p_wheelbase != 'SWB')
		SET @retVal = Replace(@retVal, '[wb]', ISNULL(@p_wheelbase, '')  + ' ');
--	ELSE
--		SET @retVal = Replace(@retVal, '[wb]', ' ');
	IF (@p_fueltype = 'Diesel')
		SET @temp = 'D';
	IF (@p_trim = '-')	
		Set @p_trim = '';
	IF (@p_KD = 1)
		Set @kd = 'KD';
		
	SET @retVal = Replace(@retVal, '[sz]', CONVERT(nvarchar(50), CAST(@p_size AS Decimal(10, 1))) + @temp  + ' ');
	SET @retVal = Replace(@retVal, '[cy]', ISNULL(@p_cylinder, '')  + ' ');
	SET @retVal = Replace(@retVal, '[tb]', ISNULL(@p_turbo, '')  + ' ');  
	SET @retVal = Replace(@retVal, '[pw]', CAST(@p_power AS nvarchar(50))  + ' ');
	SET @retVal = Replace(@retVal, '[dv]', ISNULL(@p_drive, '')  + ' ');
	SET @retVal = Replace(@retVal, '[gr]', Replace(ISNULL(@p_gear, ''), 'speed', 'Spd')  + ' ');
	SET @retVal = Replace(@retVal, '[tr]', ISNULL(@p_trim, '')  + ' ');
	SET @retVal = Replace(@retVal, '[tl]', '(' + ISNULL(@p_trimlevel, '') + @kd + ') ');
	
	IF (@p_withBR = 0)
		SET @retVal = Replace(@retVal, '#', '');
	
	-- Return the result of the function
	RETURN RTrim(LTrim(@retVal));

END
