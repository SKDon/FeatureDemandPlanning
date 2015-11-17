CREATE PROCEDURE [dbo].[Fdp_TrimMapping_Get]
	@FdpTrimMappingId INT
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
		, UpdatedOn
		, UpdatedBy
		, IsActive
		
	  FROM Fdp_TrimMapping
	  WHERE 
	  FdpTrimMappingId = @FdpTrimMappingId;