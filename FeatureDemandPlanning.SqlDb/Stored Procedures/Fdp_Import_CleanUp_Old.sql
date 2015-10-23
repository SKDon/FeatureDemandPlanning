CREATE PROCEDURE [dbo].[Fdp_Import_CleanUp_Old]
	@ImportQueueId INT
AS
BEGIN
	SET NOCOUNT ON;

    DELETE FROM Fdp_ImportError WHERE ImportQueueId = @ImportQueueId;
	DELETE FROM Fdp_Volume WHERE ImportQueueId = @ImportQueueId;
	DELETE FROM Fdp_Import WHERE ImportQueueId = @ImportQueueId;
	
END