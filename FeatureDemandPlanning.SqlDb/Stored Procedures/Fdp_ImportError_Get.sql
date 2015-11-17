CREATE PROCEDURE [dbo].[Fdp_ImportError_Get]
	@ExceptionId INT
AS

	SET NOCOUNT ON;
	
	SELECT 
		  E.FdpImportId
		, E.FdpImportQueueId AS ImportQueueId
		, E.ProgrammeId
		, E.Gateway
		, E.FdpImportErrorId
		, E.LineNumber
		, E.FdpImportErrorTypeId
		, E.[Type] AS ErrorTypeDescription
		, E.ErrorMessage
		, E.ErrorOn
		, E.IsExcluded
		, E.ImportMarket
		, E.ImportDerivativeCode
		, E.ImportDerivative
		, E.ImportTrim
		, E.ImportFeatureCode
		, E.ImportFeature
		
	FROM Fdp_ImportError_VW AS E
	WHERE
	E.FdpImportErrorId = @ExceptionId;