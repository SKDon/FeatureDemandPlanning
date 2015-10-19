CREATE PROCEDURE [dbo].[Import_CreateChangeSet]
	  @ImportQueueId INT
	, @ChangeSetId INT OUTPUT
AS

SET NOCOUNT ON

INSERT INTO OXO_Change_Set
(
	  Section
	, Reminder
	, Updated_By
	, Last_Updated
	, Version_Id
)
SELECT
	  T.[Type]
	, 'Import volume data from ''' + Q.FilePath + ''''
	, Q.CreatedBy
	, Q.UpdatedOn
	, 1.0
FROM
ImportQueue		AS Q
JOIN ImportType AS T ON Q.ImportTypeId = T.ImportTypeId
WHERE
Q.ImportQueueId = @ImportQueueId;

SET @ChangeSetId = SCOPE_IDENTITY();

--UPDATE Fdp_VolumeHeader SET ChangeSetId = @ChangeSetId
--WHERE
--ImportQueueId = @ImportQueueId;

