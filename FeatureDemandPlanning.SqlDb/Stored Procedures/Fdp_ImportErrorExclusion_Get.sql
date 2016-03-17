CREATE PROCEDURE [dbo].[Fdp_ImportErrorExclusion_Get] 
	@FdpImportErrorExclusionId INT
AS
	SET NOCOUNT ON;

	SELECT 
		  FdpImportErrorExclusionId
		, E.DocumentId
		, ProgrammeId
		, Gateway
		, ErrorMessage
		, CreatedOn
		, CreatedBy
		, IsActive
		, E.FdpImportErrorTypeId
		, E.SubTypeId
		, T1.[Type] AS TypeDescription
		, ISNULL(T2.[Type], '') AS SubTypeDescription

	FROM Fdp_ImportErrorExclusion AS E
	JOIN Fdp_ImportErrorType AS T1 ON E.FdpImportErrorTypeId = T1.FdpImportErrorTypeId
	LEFT JOIN Fdp_ImportErrorType AS T2 ON E.SubTypeId = T2.FdpImportErrorTypeId
	WHERE 
	FdpImportErrorExclusionId = @FdpImportErrorExclusionId;