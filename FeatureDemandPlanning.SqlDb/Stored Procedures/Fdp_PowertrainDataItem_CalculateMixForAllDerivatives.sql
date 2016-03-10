CREATE PROCEDURE [dbo].[Fdp_PowertrainDataItem_CalculateMixForAllDerivatives]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT = NULL
	, @CDSId				NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;

	-- We need derivative identifiers and this routine adds them as necessary

	EXEC Fdp_OxoDerivative_Update @FdpVolumeHeaderId = @FdpVolumeHeaderId;

	DECLARE @DataForDerivative AS TABLE
	(
		  Id							INT PRIMARY KEY IDENTITY(1,1)
		, FdpVolumeHeaderId				INT
		, MarketId						INT
		, DerivativeCode				NVARCHAR(20)
		, FdpOxoDerivativeId			INT NULL
		, FdpDerivativeId				INT NULL
		, TotalVolume					INT
		, PercentageTakeRate			DECIMAL(5, 4)
		, FdpTakeRateSummaryId			INT NULL
	)
	DECLARE @DerivativeMix AS TABLE
	(
		  FdpVolumeHeaderId				INT
		, MarketId						INT
		, DerivativeCode				NVARCHAR(20)
		, FdpOxoDerivativeId			INT NULL
		, FdpDerivativeId				INT NULL
		, TotalVolume					INT
		, PercentageTakeRate			DECIMAL(5, 4)
		, FdpPowertrainDataItemId		INT NULL
	)
	DECLARE @Market AS TABLE
	(
		MarketId INT
	);

	INSERT INTO @Market (MarketId)
	SELECT 
		DISTINCT MarketId 
	FROM
	Fdp_VolumeDataItem_VW AS D
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR D.MarketId = @MarketId);
	
	-- Add all volume data existing rows to our data table
	
	INSERT INTO @DataForDerivative
	(
		  FdpVolumeHeaderId
		, MarketId
		, DerivativeCode
		, FdpOxoDerivativeId
		, FdpDerivativeId
		, TotalVolume
		, PercentageTakeRate
		, FdpTakeRateSummaryId
	)

	SELECT
		  H.FdpVolumeHeaderId
		, D.MarketId
		, D.DerivativeCode
		, D.FdpOxoDerivativeId
		, D.FdpDerivativeId
		, ISNULL(S.TotalVolume, 0) AS Volume
		, ISNULL(S.PercentageTakeRate, 0) AS PercentageTakeRate
		, S.FdpTakeRateSummaryId
    FROM
    Fdp_VolumeHeader_VW								AS H
	CROSS APPLY @Market								AS M
	JOIN Fdp_AllDerivativesByMarket_VW				AS D	ON	H.FdpVolumeHeaderId	= D.FdpVolumeHeaderId
															AND M.MarketId			= D.MarketId
    LEFT JOIN Fdp_TakeRateSummaryByModelAndMarket_VW AS S	ON	H.FdpVolumeHeaderId = S.FdpVolumeHeaderId
															AND D.MarketId			= S.MarketId
															AND D.DerivativeCode	= S.BMC
    WHERE
    H.FdpVolumeHeaderId = @FdpVolumeHeaderId
    AND
    (@MarketId IS NULL OR D.MarketId = @MarketId);

	INSERT INTO @DerivativeMix
	(
		  FdpVolumeHeaderId
		, MarketId
		, DerivativeCode
		, FdpOxoDerivativeId
		, FdpDerivativeId
		, TotalVolume
		, PercentageTakeRate
		, FdpPowertrainDataItemId
	)
	SELECT 
		  D.FdpVolumeHeaderId
		, D.MarketId
		, D.DerivativeCode
		, D.FdpOxoDerivativeId
		, D.FdpDerivativeId
		, SUM(D.TotalVolume) AS TotalVolume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(D.TotalVolume), 
		  dbo.fn_Fdp_VolumeByMarket_Get(D.FdpVolumeHeaderId, D.MarketId, NULL)) AS PercentageTakeRate
		, MAX(CUR.FdpPowertrainDataItemId) AS FdpPowertrainDataItemId
	FROM 
	@DataForDerivative	AS D
	LEFT JOIN Fdp_PowertrainDataItem AS CUR ON	D.DerivativeCode	= CUR.DerivativeCode
											AND D.FdpVolumeHeaderId = CUR.FdpVolumeHeaderId
											AND D.MarketId			= CUR.MarketId
	GROUP BY
	  D.FdpVolumeHeaderId
	, D.MarketId
	, D.DerivativeCode
	, D.FdpOxoDerivativeId
	, D.FdpDerivativeId
    
	-- Update existing entries

	UPDATE D SET 
		  Volume = D1.TotalVolume
		, PercentageTakeRate = D1.PercentageTakeRate

	FROM Fdp_PowertrainDataItem AS D
	JOIN @DerivativeMix AS D1 ON D.FdpPowertrainDataItemId = D1.FdpPowertrainDataItemId
	WHERE
	D.FdpPowertrainDataItemId IS NOT NULL
	AND
	(
		D.Volume <> D1.TotalVolume
		OR
		D.PercentageTakeRate <> D1.PercentageTakeRate
	)
	
	-- Add new derivative mix entries
	INSERT INTO Fdp_PowertrainDataItem
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, MarketId
		, DerivativeCode
		, FdoOxoDerivativeId
		, FdpDerivativeId
		, Volume
		, PercentageTakeRate
	)
	SELECT 
		  @CDSId
		, D.FdpVolumeHeaderId
		, D.MarketId
		, D.DerivativeCode
		, D.FdpOxoDerivativeId
		, D.FdpDerivativeId
		, D.TotalVolume
		, D.PercentageTakeRate
	FROM
	@DerivativeMix AS D
	WHERE
	D.FdpPowertrainDataItemId IS NULL;


END