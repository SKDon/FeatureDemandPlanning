CREATE PROCEDURE [dbo].[Fdp_Validation_NonApplicableFeatures0Percent]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT			 = NULL
	, @CDSId				NVARCHAR(16) = NULL
AS

	SET NOCOUNT ON;

	DECLARE @DocumentId AS INT;
	DECLARE @Markets AS TABLE
	(
		  MarketId			INT
		, MarketGroupId		INT
		, FdpChangesetId	INT NULL
	);
	DECLARE @Models AS TABLE
	(	
		ModelId INT
	);
	DECLARE @FeatureApplicability AS TABLE
	(
		  MarketId	INT
		, FeatureId INT
		, ModelId	INT
		, OxoCode	NVARCHAR(10)
	);
	DECLARE @ModelIdentifiers AS NVARCHAR(MAX);

	SELECT TOP 1 @DocumentId = DocumentId FROM Fdp_VolumeHeader WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId; 

	INSERT INTO @Markets 
	(
		MarketId, 
		MarketGroupId
	) 
	SELECT DISTINCT M.MarketId, M.MarketGroupId
	FROM 
	Fdp_VolumeDataItem_VW AS M
	WHERE
	M.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR M.MarketId = @MarketId)

	-- Note that we don't bother with FdpModel types as there is no feature coding against them

	INSERT INTO @Models (ModelId)
	SELECT DISTINCT M.ModelId
	FROM
	Fdp_TakeRateSummaryByModelAndMarket_VW AS M
	WHERE
	M.FdpVolumeHeaderId = @FdpVolumeHeaderId;

	SELECT @ModelIdentifiers = COALESCE(@ModelIdentifiers+',' ,'') + '[' + CAST(ModelId AS NVARCHAR(10)) + ']' FROM @Models;

	-- If the CDSID has been specified, we look for any changsets for that user to include in validation

	UPDATE M SET FdpChangesetId = C.FdpChangesetId
	FROM @Markets		AS M
	JOIN Fdp_Changeset	AS C	ON C.FdpVolumeHeaderId	= @FdpVolumeHeaderId
								AND M.MarketId			= C.MarketId
								AND C.CreatedBy			= @CDSId
								AND C.IsDeleted			= 0
								AND C.IsSaved			= 0;

	INSERT INTO @FeatureApplicability
	(
		  MarketId
		, ModelId
		, FeatureId
		, OxoCode
	)
	SELECT 
		  M.MarketId
		, FA.Model_Id	AS ModelId
		, FA.Feature_Id AS FeatureId
		, MAX(FA.OXO_Code)	AS OxoCode
	FROM @Markets AS M
	CROSS APPLY dbo.FN_OXO_Data_Get_FBM_Market(@DocumentId, M.MarketGroupId, M.MarketId, @ModelIdentifiers) AS FA
	GROUP BY
	M.MarketId, FA.Model_Id, FA.Feature_Id

	INSERT INTO Fdp_Validation
	(
		  FdpVolumeHeaderId
		, MarketId
		, FdpValidationRuleId
		, Message
		, FdpVolumeDataItemId
		, FdpTakeRateSummaryId
		, FdpTakeRateFeatureMixId
		, FdpChangesetDataItemId
	)
	SELECT 
		  D.FdpVolumeHeaderId
		, D.MarketId
		, 8 -- Non-applicable feature 0%
		, 'Take rate for non-applicable feature ''' + ISNULL(F.BrandDescription, F.[SystemDescription]) + ''' should be 0%'
		, D.FdpVolumeDataItemId
		, NULL
		, NULL
		, C.FdpChangesetDataItemId
	FROM 
	Fdp_VolumeDataItem_VW				AS D
	JOIN OXO_Doc						AS O	ON	D.DocumentId			= O.Id
	JOIN @Markets						AS M	ON	D.MarketId				= M.MarketId
	JOIN @FeatureApplicability			AS FA	ON	D.MarketId				= FA.MarketId
												AND D.ModelId				= FA.ModelId
												AND	D.FeatureId				= FA.FeatureId
												AND FA.OxoCode				LIKE '%NA%'
	JOIN OXO_Programme_Feature_VW		AS F	ON	O.Programme_Id			= F.ProgrammeId
												AND D.FeatureId				= F.ID
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	M.FdpChangesetId		= C.FdpChangesetId
												AND D.FdpVolumeDataItemId	= C.FdpVolumeDataItemId
	LEFT JOIN Fdp_Validation			AS V	ON	D.MarketId				= V.MarketId
												AND D.FdpVolumeDataItemId	= V.FdpVolumeDataItemId
												AND 
												(
													C.FdpChangesetDataItemId IS NULL
													OR
													C.FdpChangesetDataItemId = V.FdpChangesetDataItemId
												)
												AND V.IsActive				= 1					
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR D.MarketId = @MarketId)
	AND
	ISNULL(C.PercentageTakeRate, D.PercentageTakeRate) <> 0 -- 0 %
	AND
	V.FdpValidationId IS NULL

	PRINT 'Not applicable feature failures added: ' + CAST(@@ROWCOUNT AS NVARCHAR(10))