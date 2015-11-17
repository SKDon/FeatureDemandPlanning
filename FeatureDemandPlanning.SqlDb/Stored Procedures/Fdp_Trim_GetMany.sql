CREATE PROCEDURE dbo.Fdp_Trim_GetMany
	  @ProgrammeId INT = NULL
	, @Gateway NVARCHAR(100) = NULL
	, @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	SELECT 
		  FdpTrimId
		, ProgrammeId
		, Gateway
		, TrimName
		, TrimAbbreviation
		, TrimLevel
		, CreatedOn
		, CreatedBy
		, UpdatedOn
		, UpdatedBy
		, IsActive
	
	FROM Fdp_Trim
	WHERE 
	(@ProgrammeId IS NULL OR ProgrammeId = @ProgrammeId)
	AND
	(@Gateway IS NULL OR Gateway = @Gateway)
	AND
	IsActive = 1;