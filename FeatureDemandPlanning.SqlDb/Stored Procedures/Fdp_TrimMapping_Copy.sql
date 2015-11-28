CREATE PROCEDURE [dbo].[Fdp_TrimMapping_Copy] 
	  @FdpTrimMappingId INT
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
	
	INSERT INTO Fdp_TrimMapping
	(
		  CreatedBy
		, ProgrammeId
		, Gateway
		, ImportTrim
		, BMC
		, TrimId
	)
	SELECT 
		  @CDSId
		, M.ProgrammeId
		, G.Gateway
		, M.ImportTrim
		, M.BMC
		, M.TrimId
	FROM
	Fdp_TrimMapping				AS M 
	CROSS APPLY @GatewayList	AS G
	LEFT JOIN Fdp_TrimMapping	AS EXISTING ON M.ImportTrim	= EXISTING.ImportTrim
											AND M.TrimId			= EXISTING.TrimId
											AND M.ProgrammeId		= EXISTING.ProgrammeId
											AND G.Gateway			= EXISTING.Gateway
											AND M.BMC				= EXISTING.BMC
	WHERE
	M.FdpTrimMappingId = @FdpTrimMappingId
	AND 
	EXISTING.FdpTrimMappingId IS NULL