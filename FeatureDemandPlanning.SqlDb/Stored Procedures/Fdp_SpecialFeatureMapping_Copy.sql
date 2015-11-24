CREATE PROCEDURE [dbo].[Fdp_SpecialFeatureMapping_Copy] 
	  @FdpSpecialFeatureMappingId INT
	, @Gateways NVARCHAR(MAX)
	, @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @GatewayList AS TABLE
	(
		Gateway NVARCHAR(100)
	)
	INSERT INTO @GatewayList
	SELECT * FROM dbo.FN_SPLIT_MODEL_IDS(@Gateways) -- Use model-ids as the function does what we need
	
	INSERT INTO Fdp_SpecialFeature
	(
		  CreatedBy
		, ProgrammeId
		, Gateway
		, FeatureCode
		, FdpSpecialFeatureTypeId
	)
	SELECT 
		  @CDSId
		, S.ProgrammeId
		, G.Gateway
		, S.FeatureCode
		, S.FdpSpecialFeatureTypeId
	FROM
	Fdp_SpecialFeature				AS S 
	CROSS APPLY @GatewayList		AS G
	LEFT JOIN Fdp_SpecialFeature	AS EXISTING ON S.FeatureCode	= EXISTING.FeatureCode
												AND S.ProgrammeId	= EXISTING.ProgrammeId
												AND G.Gateway		= EXISTING.Gateway
	WHERE
	S.FdpSpecialFeatureId = @FdpSpecialFeatureMappingId
	AND 
	EXISTING.FdpSpecialFeatureId IS NULL