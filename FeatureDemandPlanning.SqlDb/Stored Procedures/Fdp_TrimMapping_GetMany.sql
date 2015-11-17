CREATE PROCEDURE [dbo].[Fdp_TrimMapping_GetMany]
	  @ProgrammeId	INT				= NULL
	, @Gateway		NVARCHAR(100)	= NULL
	, @CDSId		NVARCHAR(16)
AS
	SET NOCOUNT ON;
		
	SELECT 
		  FdpTrimMappingId
		, ImportTrim
		, ProgrammeId
		, Gateway
		, TrimId
		, CreatedOn
		, CreatedBy
		
	  FROM Fdp_TrimMapping
	  WHERE 
	  (@ProgrammeId IS NULL OR ProgrammeId = @ProgrammeId)
	  AND
	  (@Gateway IS NULL OR Gateway = @Gateway)
	  AND
	  IsActive = 1
	  ORDER BY
	  ImportTrim