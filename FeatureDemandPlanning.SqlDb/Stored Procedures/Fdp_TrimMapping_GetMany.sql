CREATE PROCEDURE [dbo].[Fdp_TrimMapping_GetMany]
	@ProgrammeId INT
AS
	SET NOCOUNT ON;
		
	SELECT 
		  FdpTrimMappingId
		, ImportTrim
		, ProgrammeId
		, TrimId
		
	  FROM Fdp_TrimMapping
	  WHERE 
	  ProgrammeId = @ProgrammeId
	  ORDER BY
	  ImportTrim