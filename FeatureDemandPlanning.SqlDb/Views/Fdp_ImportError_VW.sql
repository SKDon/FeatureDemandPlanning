
CREATE VIEW [dbo].[Fdp_ImportError_VW] AS

	SELECT 
		  I.FdpImportId
		, E.ImportQueueId
		, E.FdpImportErrorId
		, E.LineNumber
		, T.FdpImportErrorTypeId
		, T.[Type]
		, E.ErrorMessage
		, E.ErrorOn
		
	FROM Fdp_ImportError	 AS E
	JOIN Fdp_Import			 AS I ON E.ImportQueueId		= I.ImportQueueId
	JOIN Fdp_ImportErrorType AS T ON E.FdpImportErrorTypeId = T.FdpImportErrorTypeId	

