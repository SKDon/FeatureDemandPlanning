CREATE FUNCTION dbo.fn_Fdp_ImportErrorCount_Get
(
	@FdpImportId AS INT
)
RETURNS INT
AS
BEGIN
	DECLARE @ErrorCount AS INT;

	SELECT @ErrorCount = COUNT(1) 
	FROM 
	Fdp_Import				AS	I 
	JOIN Fdp_ImportError	AS	E	ON	I.FdpImportQueueId = E.FdpImportQueueId
	WHERE
	E.IsExcluded = 0
	AND
	FdpImportId = @FdpImportId
	GROUP BY FdpImportId
	
	RETURN ISNULL(@ErrorCount, 0);
END