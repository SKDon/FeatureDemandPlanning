CREATE PROCEDURE [dbo].[Fdp_TrimLevels_Get]
	@ProgrammeId INT = NULL
AS
	SET NOCOUNT ON;
	
	SELECT
		  ProgrammeId
		, TrimId
		, TrimName
		, Abbreviation
		
	FROM Fdp_TrimLevels
	WHERE
	(@ProgrammeId IS NULL OR ProgrammeId = @ProgrammeId)
	ORDER BY
	  ProgrammeId
	, [Level];
