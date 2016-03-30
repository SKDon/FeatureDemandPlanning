CREATE PROCEDURE [dbo].[Fdp_TrimMapping_Get]
	@FdpTrimMappingId INT
AS
	SET NOCOUNT ON;
		
	SELECT 
		  T.FdpTrimMappingId
		, T.ImportTrim
		, T.DocumentId
		, T.ProgrammeId
		, T.Gateway
		, T.TrimId
		, T.FdpTrimId
		, TR.Name
		, TR.[Level]
		, TR.Abbreviation
		, T.BMC
		, TR.DPCK
		, T.CreatedOn
		, T.CreatedBy
		, T.UpdatedOn
		, T.UpdatedBy
		, T.IsActive
		
	  FROM 
	  OXO_Doc AS D
	  JOIN Fdp_TrimMapping AS T ON D.Programme_Id = T.ProgrammeId
	  JOIN OXO_Programme_Trim AS TR ON T.TrimId = TR.Id
	  WHERE 
	  T.FdpTrimMappingId = @FdpTrimMappingId
	  AND
	  ISNULL(D.Archived, 0) = 0
	  
	  UNION
	  
	  SELECT 
		  T.FdpTrimMappingId
		, T.ImportTrim
		, T.DocumentId
		, T.ProgrammeId
		, T.Gateway
		, T.TrimId
		, T.FdpTrimId
		, TR.Name
		, TR.[Level]
		, TR.Abbreviation
		, T.BMC
		, TR.DPCK
		, T.CreatedOn
		, T.CreatedBy
		, T.UpdatedOn
		, T.UpdatedBy
		, T.IsActive
		
	  FROM 
	  OXO_Doc							AS D
	  JOIN Fdp_TrimMapping				AS T	ON	D.Programme_Id	= T.ProgrammeId
	  JOIN OXO_Archived_Programme_Trim	AS TR	ON	D.Id			= TR.Doc_Id
												AND T.TrimId		= TR.Id
	  WHERE 
	  T.FdpTrimMappingId = @FdpTrimMappingId
	  AND
	  D.Archived = 1