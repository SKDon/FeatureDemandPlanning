CREATE FUNCTION dbo.fn_Fdp_ParsedVolume_Get
(
	@Volume AS NVARCHAR(20)
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ParsedVolume AS INT;

	-- Add the T-SQL statements to compute the return value here
	SET @ParsedVolume = CAST(LTRIM(RTRIM(REPLACE(@Volume, ',', ''))) AS INT);

	-- Return the result of the function
	RETURN @ParsedVolume;

END