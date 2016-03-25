CREATE PROCEDURE [dbo].[Fdp_DerivativeMapping_Delete]
	  @FdpDerivativeMappingId INT
	, @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	BEGIN TRY
		BEGIN TRANSACTION;
		
		DECLARE @FdpImportId AS INT;
		DECLARE @DocumentId AS INT;
		DECLARE @FdpImportErrorTypeId AS INT;
		
		SELECT TOP 1 @DocumentId = DocumentId
		FROM Fdp_DerivativeMapping 
		WHERE FdpDerivativeMappingId = @FdpDerivativeMappingId;
		
		SELECT TOP 1 @FdpImportId = Q.FdpImportId
		FROM
		Fdp_ImportQueue_VW AS Q
		WHERE
		Q.FdpImportStatusId = 4
		AND
		Q.DocumentId = @DocumentId;
	
		UPDATE Fdp_DerivativeMapping SET 
			  IsActive = 0
			, UpdatedOn = GETDATE()
			, UpdatedBy = @CDSId 
		WHERE
		FdpDerivativeMappingId = @FdpDerivativeMappingId;
		
		-- Update any imports that have yet to complete processing and not cancelled re-enabling any of the same errors
		
		EXEC Fdp_ImportData_Process @FdpImportId = @FdpImportId;
		
		COMMIT
		
		EXEC Fdp_DerivativeMapping_Get @FdpDerivativeMappingId;
		
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