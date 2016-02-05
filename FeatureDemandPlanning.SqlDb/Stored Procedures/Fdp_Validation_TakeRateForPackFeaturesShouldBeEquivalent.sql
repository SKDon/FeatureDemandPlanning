CREATE PROCEDURE [dbo].[Fdp_Validation_TakeRateForPackFeaturesShouldBeEquivalent]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT			 = NULL
	, @CDSId				NVARCHAR(16) = NULL
AS

	SET NOCOUNT ON;

	WITH AllFeatures AS
	(
		SELECT 
			  H.FdpVolumeHeaderId
			, H.ProgrammeId
			, S.MarketId
			, S.ModelId
			, S.FdpTakeRateSummaryId
			, FA.FeatureId
			, FA.FeaturePackId
			, FA.OxoCode
			, ISNULL(C.PercentageTakeRate, ISNULL(D.PercentageTakeRate, 0)) AS PercentageTakeRate
		FROM 
		Fdp_VolumeHeader_VW								AS H
		JOIN Fdp_TakeRateSummary						AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
																AND S.ModelId					IS NOT NULL
		CROSS APPLY dbo.fn_Fdp_FeatureApplicability_GetMany(H.FdpVolumeHeaderId, S.MarketId) AS FA
		JOIN OXO_Programme_Feature_VW					AS F	ON	H.ProgrammeId			= F.ProgrammeId
																AND FA.FeatureId			= F.ID
		LEFT JOIN Fdp_VolumeDataItem_VW					AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
																AND S.MarketId				= D.MarketId
																AND S.ModelId				= D.ModelId
																AND F.ID					= D.FeatureId
		LEFT JOIN Fdp_ChangesetDataItem_VW				AS C	ON	S.MarketId				= C.MarketId
																AND F.Id					= C.FeatureId
																AND S.ModelId				= C.ModelId
																AND C.CDSId					= @CDSId
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		(@MarketId IS NULL OR S.MarketId = @MarketId)
		AND
		S.MarketId = FA.MarketId
		AND
		S.ModelId = FA.ModelId
	)
	, PackOnlyFeatures AS
	(
		SELECT
			MarketId, ModelId, FeaturePackId
		FROM
		(
			SELECT DISTINCT F.MarketId, F.ModelId, F.FeaturePackId, MAX(F.OxoCode) AS OxoCode
			FROM
			AllFeatures AS F
			GROUP BY
			F.MarketId, F.ModelId, F.FeaturePackId
			HAVING COUNT(DISTINCT F.OxoCode) = 1
		)
		AS P
		WHERE
		P.OxoCode LIKE '%P%'

	)
	, NonEquivalentPackFeatures AS
	(
		SELECT
			  F.FdpVolumeHeaderId
			, F.ProgrammeId
			, F.MarketId
			, F.ModelId
			, F.FeaturePackId
			, F.FdpTakeRateSummaryId
		FROM
		AllFeatures AS F
		JOIN PackOnlyFeatures AS P ON F.MarketId = P.MarketId
									AND F.ModelId = P.ModelId
									AND F.FeaturePackId = P.FeaturePackId
		GROUP BY
		  F.FdpVolumeHeaderId
		, F.ProgrammeId
		, F.MarketId
		, F.ModelId
		, F.FeaturePackId
		, F.FdpTakeRateSummaryId
		HAVING COUNT(DISTINCT F.PercentageTakeRate) > 1
	)
	INSERT INTO Fdp_Validation
	(
		  FdpVolumeHeaderId
		, MarketId
		, ModelId
		, FeaturePackId
		, FdpValidationRuleId
		, [Message]
		, FdpTakeRateSummaryId
	)
	SELECT 
		  N.FdpVolumeHeaderId
		, N.MarketId
		, N.ModelId
		, N.FeaturePackId
		, 6 -- Pack features 100%
		, 'Take rates for features in pack ''' + P.Pack_Name + ''' should be equivalent'
		, N.FdpTakeRateSummaryId
	FROM 
	NonEquivalentPackFeatures		AS N
	JOIN OXO_Programme_Pack			AS P	ON	N.FeaturePackId		= P.Id
											AND N.ProgrammeId		= P.Programme_Id
	LEFT JOIN Fdp_Validation		AS V	ON	N.FdpVolumeHeaderId = V.FdpVolumeHeaderId
											AND N.ModelId			= V.ModelId
											AND N.FeaturePackId		= V.FeaturePackId
											AND V.IsActive			= 1
	WHERE
	V.FeaturePackId IS NULL

	PRINT 'Pack feature validation failures added: ' + CAST(@@ROWCOUNT AS NVARCHAR(10))