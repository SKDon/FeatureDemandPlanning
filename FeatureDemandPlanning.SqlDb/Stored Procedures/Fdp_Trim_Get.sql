CREATE PROCEDURE dbo.Fdp_Trim_Get
	@FdpTrimId INT
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
	FdpTrimId = @FdpTrimId;