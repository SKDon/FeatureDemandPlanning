



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
		, T.[Type]
		, E.ErrorMessage
		, E.ErrorOn
		, E.IsExcluded
		, D.[Country Description]	AS ImportMarket
		, D.[Bff Feature Code]		AS ImportFeatureCode
		, D.[Feature Description]	AS ImportFeature
		, D.[Derivative Code]		AS ImportDerivativeCode
		, D.[Trim Pack Description] AS ImportDerivative
		, D.[Trim Pack Description] AS ImportTrim
		
	FROM Fdp_Import			 AS I 
	JOIN Fdp_ImportError	 AS	E	ON	I.FdpImportQueueId		= E.FdpImportQueueId
	JOIN Fdp_ImportErrorType AS T	ON	E.FdpImportErrorTypeId	= T.FdpImportErrorTypeId
	LEFT JOIN Fdp_ImportData		 AS D	ON	I.FdpImportId			= D.FdpImportId
									AND E.LineNumber			= D.LineNumber	

