CREATE PROCEDURE [dbo].[Fdp_ImportError_Get]
	@ExceptionId INT
AS

	SET NOCOUNT ON;
	
	SELECT 
		  E.FdpImportId
		, E.FdpImportQueueId AS ImportQueueId
		, E.DocumentId
		, E.ProgrammeId
		, E.Gateway
		, E.DocumentId
		, E.FdpImportErrorId
		, E.LineNumber
		, E.FdpImportErrorTypeId
		, E.SubTypeId
		, E.[Type] AS ErrorTypeDescription
		, E.SubType AS SubTypeDescription
		, E.ErrorMessage
		, E.ErrorOn
		, E.IsExcluded
		, E.ImportMarket
		, E.ImportDerivativeCode
		, E.ImportDerivative
		, E.ImportTrim
		, E.ImportFeatureCode
		, E.ImportFeature
		, E.AdditionalData
		
	FROM Fdp_ImportError_VW AS E
	WHERE
	E.FdpImportErrorId = @ExceptionId;