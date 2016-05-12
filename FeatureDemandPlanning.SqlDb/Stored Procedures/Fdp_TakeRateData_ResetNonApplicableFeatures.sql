CREATE PROCEDURE [dbo].[Fdp_TakeRateData_ResetNonApplicableFeatures]
	  @FdpVolumeHeaderId	INT
	, @CDSId				NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @Message AS NVARCHAR(MAX);
	
	-- Create a list of the data items that need to be updated
	
	DECLARE @UpdateFeatures AS TABLE
	(
		  FdpVolumeDataItemId	INT
		, MarketId				INT
		, ModelId				INT
		, FeatureId				INT NULL
		, FeaturePackId			INT NULL
		, PercentageTakeRate	DECIMAL(5, 4)
		, Volume				INT
		, FeatureDescription	NVARCHAR(MAX)
	);
	
	INSERT INTO @UpdateFeatures
	(
		  FdpVolumeDataItemId
		, MarketId
		, ModelId
		, FeatureId
		, FeaturePackId
		, PercentageTakeRate
		, Volume
		, FeatureDescription
	)
	SELECT 
		  D.FdpVolumeDataItemId
		, S.MarketId
		, S.ModelId
		, F.ID AS FeatureId
		, NULL AS FeaturePackId
		, D.PercentageTakeRate
		, D.Volume
		, ISNULL(F.BrandDescription, F.[SystemDescription]) AS FeatureDescription
	FROM 
	Fdp_VolumeHeader_VW								AS H
	JOIN OXO_Programme_MarketGroupMarket_VW			AS M	ON	H.ProgrammeId			= M.Programme_Id
	JOIN Fdp_TakeRateSummaryByModelAndMarket_VW		AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
															AND M.Market_Id				= S.MarketId
	JOIN Fdp_FeatureApplicability					AS FA	ON	H.DocumentId			= FA.DocumentId
															AND	M.Market_Id				= FA.MarketId
															AND S.ModelId				= FA.ModelId
															AND FA.Applicability		LIKE '%NA%'														
	JOIN OXO_Programme_Feature_VW					AS F	ON	FA.FeatureId			= F.ID
															AND H.ProgrammeId			= F.ProgrammeId
	JOIN Fdp_VolumeDataItem_VW						AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
															AND S.MarketId				= D.MarketId
															AND S.ModelId				= D.ModelId
															AND F.ID					= D.FeatureId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	S.ModelId = FA.ModelId
	AND
	(
		ISNULL(D.PercentageTakeRate, 0) <> 0
		OR
		ISNULL(D.Volume, 0) <> 0
	)

	UNION

	SELECT 
		  D.FdpVolumeDataItemId
		, S.MarketId
		, S.ModelId
		, NULL AS FeatureId
		, F.FeaturePackId
		, D.PercentageTakeRate
		, D.Volume
		, ISNULL(F.BrandDescription, F.[SystemDescription]) AS FeatureDescription
	FROM 
	Fdp_VolumeHeader_VW								AS H
	JOIN OXO_Programme_MarketGroupMarket_VW			AS M	ON	H.ProgrammeId			= M.Programme_Id
	JOIN Fdp_TakeRateSummaryByModelAndMarket_VW		AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
															AND M.Market_Id				= S.MarketId
	JOIN Fdp_FeatureApplicability					AS FA	ON	H.DocumentId			= FA.DocumentId
															AND	M.Market_Id				= FA.MarketId
															AND S.ModelId				= FA.ModelId
															AND FA.Applicability		LIKE '%NA%'														
	JOIN Fdp_Feature_VW								AS F	ON	FA.FeaturePackId		= F.FeaturePackId
															AND F.FeatureId				IS NULL
															AND H.ProgrammeId			= F.ProgrammeId
	JOIN Fdp_VolumeDataItem_VW						AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
															AND S.MarketId				= D.MarketId
															AND S.ModelId				= D.ModelId
															AND D.FeatureId				IS NULL
															AND F.FeaturePackId			= D.FeaturePackId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	S.ModelId = FA.ModelId
	AND
	(
		ISNULL(D.PercentageTakeRate, 0) <> 0
		OR
		ISNULL(D.Volume, 0) <> 0
	)
		
	-- Update the data items accordingly
	
	UPDATE D SET Volume = 0, PercentageTakeRate = 0
	FROM
	Fdp_VolumeDataItem AS D
	JOIN @UpdateFeatures AS U ON D.FdpVolumeDataItemId = U.FdpVolumeDataItemId;
	
	-- Output the results to console
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' non-applicable features reset to 0';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;