CREATE FUNCTION [dbo].[fn_Fdp_PercentageTakeRate_Get]
(
	  @Volume INT
	, @TotalVolume INT
)
RETURNS DECIMAL(5,4)
AS
BEGIN
	DECLARE @PercentageTakeRate AS DECIMAL(5,4);

	IF @Volume IS NULL
		SET @Volume = 0;

	IF @TotalVolume IS NULL
		SET @TotalVolume = 0;

	IF ISNULL(@TotalVolume, 0) = 0
		SET @PercentageTakeRate = 0;
	ELSE
		SET @PercentageTakeRate = @Volume / CAST(@TotalVolume AS DECIMAL(10, 4))

	IF @PercentageTakeRate > 1
		SET @PercentageTakeRate = 1;

	-- Return the result of the function
	RETURN @PercentageTakeRate

END