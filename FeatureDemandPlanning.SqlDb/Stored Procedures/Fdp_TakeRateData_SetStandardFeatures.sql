CREATE PROCEDURE [dbo].[Fdp_TakeRateData_SetStandardFeatures]
	  @FdpVolumeHeaderId	INT
	, @CDSId				NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @Message AS NVARCHAR(MAX);
	DECLARE @UpdateCount AS INT = 0;
	
	-- Create a list of the data items that need to be updated
	
	DECLARE @UpdateFeatures AS TABLE
	(
		  FdpVolumeDataItemId	INT NULL
		, MarketId				INT
		, MarketGroupId			INT NULL
		, ModelId				INT
		, TrimId				INT
		, FeatureId				INT
		, FeaturePackId			INT NULL
		, PercentageTakeRate	DECIMAL(5, 4)
		, Volume				INT
		, FeatureDescription	NVARCHAR(MAX)
	);
	
	WITH ExclusiveFeatureGroups AS
	(
		SELECT 
			  FA.MarketId
			, FA.ModelId
			, F.EFGName
			, COUNT(F.ID) AS NumberOfFeaturesInGroup
			, MAX(CASE WHEN FA.Applicability LIKE '%S%' THEN F.ID ELSE NULL END) AS StandardFeatureId
			, SUM(CASE WHEN FA.Applicability LIKE '%O%' THEN ISNULL(D.Volume, 0) ELSE 0 END) AS OptionalFeatureVolumes
			, CASE
				WHEN SUM(CASE WHEN FA.Applicability LIKE '%O%' THEN ISNULL(D.PercentageTakeRate, 0) ELSE 0 END) > 1 THEN 1
				ELSE SUM(CASE WHEN FA.Applicability LIKE '%O%' THEN ISNULL(D.PercentageTakeRate, 0) ELSE 0 END)
			  END 
			  AS OptionalFeatureTakeRates
			, 1 - 
			  CASE
				WHEN SUM(CASE WHEN FA.Applicability LIKE '%O%' THEN ISNULL(D.PercentageTakeRate, 0) ELSE 0 END) > 1 THEN 1
				ELSE SUM(CASE WHEN FA.Applicability LIKE '%O%' THEN ISNULL(D.PercentageTakeRate, 0) ELSE 0 END)
			  END  
			  AS StandardFeatureTakeRate
		FROM
		Fdp_VolumeHeader_VW				AS H
		JOIN Fdp_FeatureApplicability	AS FA	ON	H.DocumentId		= FA.DocumentId
		JOIN OXO_Programme_Feature_VW	AS F	ON	H.ProgrammeId		= F.ProgrammeId
												AND FA.FeatureId		= F.ID
		LEFT JOIN Fdp_VolumeDataItem_VW AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
												AND FA.MarketId			= D.MarketId
												AND FA.ModelId			= D.ModelId
												AND FA.FeatureId		= D.FeatureId
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		FA.MarketId IS NOT NULL
		AND
		FA.Applicability NOT LIKE '%NA%' -- Non applicable items are not included in the group item count
		AND
		FA.Applicability NOT LIKE '%P%' -- Ignore pack items from the group item count as it may be standard at that trim level, but still in a pack
		GROUP BY 
		FA.MarketId, FA.ModelId, F.EFGName
	)
	
	INSERT INTO @UpdateFeatures
	(
		  FdpVolumeDataItemId
		, MarketId
		, MarketGroupId
		, ModelId
		, TrimId
		, FeatureId
		, FeaturePackId
		, PercentageTakeRate
		, Volume
		, FeatureDescription
	)
	SELECT 
		  D.FdpVolumeDataItemId
		, S.MarketId
		, S.MarketGroupId
		, S.ModelId
		, S.TrimId
		, F.FeatureId
		, F.FeaturePackId
		-- If not in an EFG, the take rate is 100%
		-- Otherwise the take rate is 100% less the take rate of any optional features
		, CASE
			WHEN EX.StandardFeatureId IS NULL THEN 1
			ELSE EX.StandardFeatureTakeRate
		  END
		  AS PercentageTakeRate
		-- If not in an EFG, the volume is equal to the model volume
		-- Otherwise the volume is equal to the model volume less the volume of any optional features
		, CASE
			WHEN EX.StandardFeatureId IS NULL THEN S.TotalVolume
			WHEN S.TotalVolume - EX.OptionalFeatureVolumes > 0 THEN S.TotalVolume - EX.OptionalFeatureVolumes
			ELSE 0
		  END
		  AS Volume
		, ISNULL(F.BrandDescription, F.[SystemDescription]) AS FeatureDescription
	FROM 
	Fdp_VolumeHeader_VW								AS H
	JOIN OXO_Programme_MarketGroupMarket_VW			AS M	ON	H.ProgrammeId			= M.Programme_Id
	JOIN Fdp_TakeRateSummaryByModelAndMarket_VW		AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
															AND M.Market_Id				= S.MarketId
	JOIN Fdp_FeatureApplicability					AS FA	ON	H.DocumentId			= FA.DocumentId
															AND	M.Market_Id				= FA.MarketId
															AND S.ModelId				= FA.ModelId
															AND FA.Applicability		LIKE '%S%'														
	JOIN Fdp_Feature_VW								AS F	ON	FA.FeatureId			= F.FeatureId
															AND H.DocumentId			= F.DocumentId
	LEFT JOIN Fdp_VolumeDataItem_VW					AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
															AND S.MarketId				= D.MarketId
															AND S.ModelId				= D.ModelId
															AND F.FeatureId				= D.FeatureId
	LEFT JOIN ExclusiveFeatureGroups				AS EX	ON	M.Market_Id				= EX.MarketId
															AND S.ModelId				= EX.ModelId
															AND F.FeatureId				= EX.StandardFeatureId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
									
	-- Update the data items accordingly
	
	UPDATE D SET Volume = U.Volume, PercentageTakeRate = U.PercentageTakeRate
	FROM
	Fdp_VolumeDataItem AS D
	JOIN @UpdateFeatures AS U ON D.FdpVolumeDataItemId = U.FdpVolumeDataItemId;
	
	SET @UpdateCount = @UpdateCount + @@ROWCOUNT;
	
	-- Add any data items that we do not have any volume data for. It may have a volume of zero, but we still need a take rate of 100%
	
	INSERT INTO Fdp_VolumeDataItem
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, IsManuallyEntered
		, MarketId
		, MarketGroupId
		, ModelId
		, TrimId
		, FeatureId
		, FeaturePackId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  @CDSId
		, @FdpVolumeHeaderId
		, 0
		, U.MarketId
		, U.MarketGroupId
		, U.ModelId
		, U.TrimId
		, U.FeatureId
		, U.FeaturePackId
		, U.Volume
		, U.PercentageTakeRate
	FROM
	@UpdateFeatures AS U
	WHERE
	FdpVolumeDataItemId IS NULL;
	
	SET @UpdateCount = @UpdateCount + @@ROWCOUNT;
	
	-- Output the results to console
	SET @Message = CAST(@UpdateCount AS NVARCHAR(10)) + ' standard features set to 100 percent';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;