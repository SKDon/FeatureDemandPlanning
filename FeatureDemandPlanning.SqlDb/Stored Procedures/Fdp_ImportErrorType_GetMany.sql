CREATE PROCEDURE [dbo].[Fdp_ImportErrorType_GetMany]
	  @FdpImportQueueId INT
	, @CDSId NVARCHAR(16) = NULL
AS
	SET NOCOUNT ON;
	
	DECLARE @CanViewAllWorkflowStates BIT;
	SET @CanViewAllWorkflowStates = 1;
	
	IF @CanViewAllWorkflowStates = 1
	BEGIN
		SELECT DISTINCT
		  T.FdpImportErrorTypeId
		, T.[Type]
		, T.[Description]
		, T.WorkflowOrder
		FROM
		Fdp_ImportError				AS E
		JOIN Fdp_ImportErrorType	AS T ON E.FdpImportErrorTypeId = T.FdpImportErrorTypeId
		ORDER BY
		WorkflowOrder;
	END
	ELSE
	BEGIN
		;WITH DistinctImportErrors AS
		(
			SELECT E.FdpImportErrorTypeId
			FROM Fdp_ImportError AS E
			WHERE
			E.FdpImportQueueId = @FdpImportQueueId
			GROUP BY
			E.FdpImportErrorTypeId
		)
		SELECT TOP 1
		  T.FdpImportErrorTypeId
		, T.[Type]
		, T.[Description]
		, RANK() OVER (ORDER BY T.WorkflowOrder) AS WorkflowOrder
		FROM
		DistinctImportErrors AS E
		JOIN Fdp_ImportErrorType AS T ON E.FdpImportErrorTypeId = T.FdpImportErrorTypeId
		ORDER BY
		WorkflowOrder;
	END