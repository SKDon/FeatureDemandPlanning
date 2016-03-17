






CREATE VIEW [dbo].[Fdp_ImportError_VW] AS

	SELECT 
		  I.FdpImportId
		, I.ProgrammeId
		, I.Gateway
		, I.DocumentId
		, E.FdpImportQueueId
		, E.FdpImportErrorId
		, E.LineNumber
		, T.FdpImportErrorTypeId
		, E.SubTypeId
		, T.[Type]
		, ISNULL(T2.[Type], '') AS SubType
		, E.ErrorMessage
		, E.ErrorOn
		, E.IsExcluded
		, CASE WHEN E.FdpImportErrorTypeId = 1 THEN E.AdditionalData ELSE NULL END	AS ImportMarket
		, CASE WHEN E.FdpImportErrorTypeId = 2 THEN E.AdditionalData ELSE NULL END	AS ImportFeatureCode
		, '' AS ImportFeature
		, CASE WHEN E.FdpImportErrorTypeId = 3 THEN E.AdditionalData ELSE NULL END	AS ImportDerivativeCode
		, '' AS ImportDerivative
		, CASE WHEN E.FdpImportErrorTypeId = 4 THEN E.AdditionalData ELSE NULL END	AS ImportTrim
		, E.AdditionalData
		
	FROM Fdp_Import			 AS I 
	JOIN Fdp_ImportError	 AS	E	ON	I.FdpImportQueueId		= E.FdpImportQueueId
	JOIN Fdp_ImportErrorType AS T	ON	E.FdpImportErrorTypeId	= T.FdpImportErrorTypeId
	LEFT JOIN Fdp_ImportErrorType AS T2	ON	E.SubTypeId	= T2.FdpImportErrorTypeId	

