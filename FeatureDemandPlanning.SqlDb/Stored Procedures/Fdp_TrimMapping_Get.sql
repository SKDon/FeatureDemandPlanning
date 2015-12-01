CREATE PROCEDURE [dbo].[Fdp_TrimMapping_Get]
	@FdpTrimMappingId INT
AS
	SET NOCOUNT ON;
		
	SELECT 
		  T.FdpTrimMappingId
		, T.ImportTrim
		, T.ProgrammeId
		, T.Gateway
		, T.BMC
		, T.TrimId
		, T.FdpTrimId
		, T.MappedTrim AS Name
		, T.[Level]
		, T.Abbreviation
		, T.DPCK
		, T.CreatedOn
		, T.CreatedBy
		, T.UpdatedOn
		, T.UpdatedBy
		, T.IsActive
		
	  FROM Fdp_TrimMapping_VW AS T
	  WHERE 
	  FdpTrimMappingId = @FdpTrimMappingId;