CREATE PROCEDURE [dbo].[Fdp_FeatureMapping_Copy] 
	  @FdpFeatureMappingId INT
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
	
	INSERT INTO Fdp_FeatureMapping
	(
		  CreatedBy
		, ProgrammeId
		, Gateway
		, ImportFeatureCode
		, FeatureId
		, FeaturePackId
	)
	SELECT 
		  @CDSId
		, M.ProgrammeId
		, G.Gateway
		, M.ImportFeatureCode
		, M.FeatureId
		, M.FeaturePackId
	FROM
	Fdp_FeatureMapping				AS M 
	CROSS APPLY @GatewayList		AS G
	LEFT JOIN Fdp_FeatureMapping	AS EXISTING ON M.ImportFeatureCode	= EXISTING.ImportFeatureCode
												AND M.FeatureId			= EXISTING.FeatureId
												AND M.ProgrammeId		= EXISTING.ProgrammeId
												AND G.Gateway			= EXISTING.Gateway
	WHERE
	M.FdpFeatureMappingId = @FdpFeatureMappingId
	AND 
	EXISTING.FdpFeatureMappingId IS NULL
	
	UNION
	
	SELECT 
		  @CDSId
		, M.ProgrammeId
		, G.Gateway
		, M.ImportFeatureCode
		, M.FeatureId
		, M.FeaturePackId
	FROM
	Fdp_FeatureMapping				AS M 
	CROSS APPLY @GatewayList		AS G
	LEFT JOIN Fdp_FeatureMapping	AS EXISTING ON M.ImportFeatureCode	= EXISTING.ImportFeatureCode
												AND M.FeaturePackId		= EXISTING.FeaturePackId
												AND M.ProgrammeId		= EXISTING.ProgrammeId
												AND G.Gateway			= EXISTING.Gateway
	WHERE
	M.FdpFeatureMappingId = @FdpFeatureMappingId
	AND 
	EXISTING.FdpFeatureMappingId IS NULL