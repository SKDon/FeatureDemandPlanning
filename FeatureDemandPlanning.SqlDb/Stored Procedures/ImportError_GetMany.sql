CREATE PROCEDURE [dbo].[ImportError_GetMany]
	@ImportQueueId INT = NULL
AS
	SET NOCOUNT ON;
	
	SELECT
		  E.ImportQueueId
		, E.ImportErrorId
		, E.Error
		, E.ErrorOn
		
	FROM ImportError_VW AS E
	WHERE
	(@ImportQueueId IS NULL OR E.ImportQueueId = @ImportQueueId)
	ORDER BY
	E.ImportErrorId DESC;

