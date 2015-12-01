CREATE PROCEDURE [dbo].[Fdp_Trim_Get]
	@FdpTrimId INT
AS
	SET NOCOUNT ON;
	
	SELECT 
		  FdpTrimId
		, ProgrammeId
		, Gateway
		, BMC
		, TrimName AS Name
		, TrimAbbreviation AS Abbreviation
		, TrimLevel AS [Level]
		, CreatedOn
		, CreatedBy
		, UpdatedOn
		, UpdatedBy
		, IsActive
	
	FROM Fdp_Trim
	WHERE 
	FdpTrimId = @FdpTrimId;