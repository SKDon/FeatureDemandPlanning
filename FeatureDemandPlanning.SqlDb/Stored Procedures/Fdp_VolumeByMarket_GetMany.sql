CREATE PROCEDURE dbo.Fdp_VolumeByMarket_GetMany
	  @MarketId		INT
	, @DocumentId	INT
	, @NewVolume	INT = NULL
AS
	SET NOCOUNT ON;

	;WITH PercentageTakeRates AS
	(
		-- Work out based on the old volume what the percentage take was
		-- We can then apply these percentage takes to the new volume to determine the volumes by derivative
		SELECT 
			  T.DocumentId
			, T.MarketId
			, M.ModelId
			, M.FdpModelId
			, M.TotalVolume
			, M.TotalVolume / CAST(T.TotalVolume AS DECIMAL) AS PercentageTakeRate
		FROM Fdp_TakeRateSummaryByMarket_VW			AS T
		JOIN Fdp_TakeRateSummaryByModelAndMarket_VW AS M ON T.MarketId = M.MarketId
		WHERE 
		T.MarketId = @MarketId
		AND
		T.DocumentId = @DocumentId
	)
	SELECT
		  P.DocumentId
		, P.MarketId
		, P.ModelId
		, P.FdpModelId 
		, CASE 
			WHEN @NewVolume IS NOT NULL THEN CEILING(@NewVolume * P.PercentageTakeRate) 
			ELSE P.TotalVolume
		  END			AS NewVolume
		, P.TotalVolume AS OldVolume
		, P.PercentageTakeRate
	FROM
	PercentageTakeRates	AS P
	JOIN Fdp_TakeRateSummaryByMarket_VW AS T ON P.DocumentId = T.DocumentId
											 AND P.MarketId  = T.MarketId;