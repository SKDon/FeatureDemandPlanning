CREATE PROCEDURE [dbo].[Fdp_ImportErrorExclusion_GetMany]
	  @ProgrammeId	INT
AS
	SET NOCOUNT ON;
	
	SELECT
		  FdpImportErrorExclusionId
		, CreatedBy
		, CreatedOn
		, ProgrammeId
		, ErrorMessage
	FROM
	Fdp_ImportErrorExclusion
	WHERE
	ProgrammeId = @ProgrammeId;