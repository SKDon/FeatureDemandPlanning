CREATE PROCEDURE [dbo].[Fdp_UserProgrammes_Save]
	  @CDSId		NVARCHAR(16)
	, @ProgrammeIds	NVARCHAR(MAX)
	, @CreatorCDSID NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpUserId AS INT;
	SELECT TOP 1 @FdpUserId = FdpUserId FROM Fdp_User WHERE CDSId = @CDSId;
	
	DECLARE @Programme AS TABLE
	(
		  FdpUserId			INT
		, ProgrammeId		INT
		, FdpUserActionId	INT
	)
	INSERT INTO @Programme
	(
		  FdpUserId
		, ProgrammeId
		, FdpUserActionId
	)
	SELECT
		  @FdpUserId AS FdpUserId
		, CAST(SUBSTRING(strval, 2, 5) AS INT) AS ProgrammeId
		, CASE LEFT(strval, 1)
			WHEN 'V' THEN 1
			WHEN 'E' THEN 2
			ELSE 0
		  END
		AS FdpUserActionId
	FROM dbo.FN_SPLIT(@ProgrammeIds, N',')
	
	SELECT FdpUserId, ProgrammeId, MAX(FdpUserActionId) AS FdpUserActionId
		FROM @Programme
		GROUP BY
		FdpUserId, ProgrammeId
	
	MERGE INTO Fdp_UserProgrammeMapping AS TARGET
	USING (
		SELECT FdpUserId, ProgrammeId, MAX(FdpUserActionId) AS FdpUserActionId
		FROM @Programme
		GROUP BY
		FdpUserId, ProgrammeId
	) 
	AS SOURCE	ON	TARGET.FdpUserId		= SOURCE.FdpUserId
				AND TARGET.ProgrammeId		= SOURCE.ProgrammeId
				AND TARGET.FdpUserActionId	= SOURCE.FdpUserActionId
				AND TARGET.IsActive			= 1
				
	WHEN MATCHED THEN
		
		UPDATE SET ProgrammeId = SOURCE.ProgrammeId, FdpUserActionId = SOURCE.FdpUserActionId
		
	WHEN NOT MATCHED BY TARGET THEN
	
		INSERT (FdpUserId, ProgrammeId, FdpUserActionId, IsActive) 
		VALUES (FdpUserId, ProgrammeId, FdpUserActionId, 1)
		
	WHEN NOT MATCHED BY SOURCE THEN
	
		DELETE;
	
	EXEC Fdp_UserProgramme_GetMany @CDSId = @CDSId;