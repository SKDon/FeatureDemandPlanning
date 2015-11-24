CREATE PROCEDURE [dbo].[Fdp_ImportErrorExclusion_Get] 
	@FdpImportErrorExclusionId INT
AS
	SET NOCOUNT ON;

	SELECT 
		  FdpImportErrorExclusionId
		, ProgrammeId
		, Gateway
		, ErrorMessage
		, CreatedOn
		, CreatedBy
		, IsActive

	FROM Fdp_ImportErrorExclusion
	WHERE 
	FdpImportErrorExclusionId = @FdpImportErrorExclusionId;