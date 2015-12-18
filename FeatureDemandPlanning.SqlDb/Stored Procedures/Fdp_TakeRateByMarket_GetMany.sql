CREATE PROCEDURE dbo.Fdp_TakeRateByMarket_GetMany
	  @MarketId		INT
	, @DocumentId	INT
	, @NewTakeRate	DECIMAL(5, 3) = NULL
AS
	SET NOCOUNT ON;
	
	-- Work out the total volume across all markets
	
	DECLARE @TotalVolume INT;
	DECLARE @NewVolume INT;
	
	SELECT 
		@TotalVolume = SUM(TotalVolume)
	FROM 
	Fdp_TakeRateSummaryByMarket_VW AS T
	WHERE
	T.DocumentId = @DocumentId;
	
	-- Apply the new take to this volume to work out volume for the market
	SELECT @NewVolume = @TotalVolume * @NewTakeRate;

	-- Now calculate the volume based on the percentage take for all models
	EXEC Fdp_VolumeByMarket_GetMany @DocumentId = @DocumentId, @MarketId = @MarketId, @NewVolume = @NewVolume;