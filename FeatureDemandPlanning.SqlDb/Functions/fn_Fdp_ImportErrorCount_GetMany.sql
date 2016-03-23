CREATE FUNCTION [dbo].[fn_Fdp_ImportErrorCount_GetMany]
(	
	@FdpImportId AS INT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT FdpImportId, COUNT(1) AS ErrorCount, MAX(E.FdpImportErrorTypeId) AS FdpImportErrorTypeId, MAX(E.SubTypeId) AS SubTypeId 
	FROM 
	Fdp_Import				AS	I 
	JOIN Fdp_ImportError	AS	E	ON	I.FdpImportQueueId = E.FdpImportQueueId
	WHERE
	E.IsExcluded = 0
	AND
	(@FdpImportId IS NULL OR FdpImportId = @FdpImportId)
	GROUP BY FdpImportId
)