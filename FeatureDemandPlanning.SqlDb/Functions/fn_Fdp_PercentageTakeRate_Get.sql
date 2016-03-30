CREATE FUNCTION [dbo].[fn_Fdp_PercentageTakeRate_Get]
(
	  @Volume INT
	, @TotalVolume INT
)
RETURNS DECIMAL(5,4)
AS
BEGIN
	DECLARE @PercentageTakeRate AS DECIMAL(5, 4);

	IF @Volume IS NULL
		SET @Volume = 0;

	IF @TotalVolume IS NULL
		SET @TotalVolume = 0;

	IF @TotalVolume = 0
		SET @PercentageTakeRate = 0;
	ELSE IF @TotalVolume < @Volume
		SET @PercentageTakeRate = 1;
	ELSE
		SET @PercentageTakeRate = CONVERT(DECIMAL(5, 4), CAST(@Volume AS DECIMAL(12,0)) / CAST(@TotalVolume AS DECIMAL(12,0)))

	IF @PercentageTakeRate > 1
		SET @PercentageTakeRate = 1;

	-- Return the result of the function
	RETURN @PercentageTakeRate

END