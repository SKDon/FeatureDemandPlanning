CREATE PROCEDURE [dbo].[Fdp_ImportErrorExclusion_Delete]
	  @FdpImportErrorExclusionId	INT
	, @CDSId						NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION;
	
		DECLARE @FdpImportId AS INT;
		DECLARE @FdpImportQueueId AS INT;
		DECLARE @DocumentId AS INT;
		DECLARE @FdpImportErrorTypeId AS INT;
		
		SELECT TOP 1 @DocumentId = DocumentId, @FdpImportErrorTypeId = FdpImportErrorTypeId
		FROM Fdp_ImportErrorExclusion 
		WHERE FdpImportErrorExclusionId = @FdpImportErrorExclusionId;
		
		SELECT TOP 1 @FdpImportId = Q.FdpImportId, @FdpImportQueueId = Q.FdpImportQueueId
		FROM
		Fdp_ImportQueue_VW AS Q
		WHERE
		Q.FdpImportStatusId = 4
		AND
		Q.DocumentId = @DocumentId;
		
		UPDATE Fdp_ImportErrorExclusion SET 
			  IsActive = 0,
			  UpdatedOn = GETDATE(),
			  UpdatedBy = @CDSId
		WHERE
		FdpImportErrorExclusionId = @FdpImportErrorExclusionId;

		-- Update any imports that have yet to complete processing and not cancelled re-enabling any of the same errors
		
		IF @FdpImportErrorTypeId = 1
		BEGIN
			EXEC Fdp_ImportData_ProcessMissingMarkets @FdpImportId = @FdpImportId, @FdpImportQueueId = @FdpImportQueueId
		END
		ELSE IF @FdpImportErrorTypeId = 2
		BEGIN
			EXEC Fdp_ImportData_ProcessMissingFeatures @FdpImportId = @FdpImportId, @FdpImportQueueId = @FdpImportQueueId
		END
		ELSE IF @FdpImportErrorTypeId = 3
		BEGIN
			EXEC Fdp_ImportData_ProcessMissingDerivatives @FdpImportId = @FdpImportId, @FdpImportQueueId = @FdpImportQueueId
		END
		ELSE IF @FdpImportErrorTypeId = 4
		BEGIN
			EXEC Fdp_ImportData_ProcessMissingTrim @FdpImportId = @FdpImportId, @FdpImportQueueId = @FdpImportQueueId
		END
		
		COMMIT TRANSACTION;
	
		EXEC Fdp_ImportErrorExclusion_Get @FdpImportErrorExclusionId;
	
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

		DECLARE @ErrorNumber INT = ERROR_NUMBER();
		DECLARE @ErrorLine INT = ERROR_LINE();
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();

		PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
		PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));

		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH