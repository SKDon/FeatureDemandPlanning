CREATE PROCEDURE [dbo].[Fdp_ImportErrorExclusion_Save]
	  @ExceptionId	INT
	, @IsExcluded	BIT = 1
	, @CDSId		NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		
		DECLARE @FdpImportQueueId	INT;
		DECLARE @ProgrammeId	INT;
		DECLARE @Message		NVARCHAR(MAX);
		
		SELECT 
			  @FdpImportQueueId	= I.FdpImportQueueId
			, @Message			= E.ErrorMessage
			, @ProgrammeId		= I.ProgrammeId
			
		FROM Fdp_ImportError	AS E
		JOIN Fdp_Import			AS I ON E.FdpImportQueueId = I.FdpImportQueueId
		WHERE 
		E.FdpImportErrorId = @ExceptionId;
		
		-- Update all errors with the same message for that import
		
		UPDATE E SET IsExcluded = @IsExcluded
		FROM Fdp_ImportError AS E
		WHERE
		E.FdpImportQueueId = @FdpImportQueueId
		AND
		E.ErrorMessage = @Message;
	
		-- Add an exclusion rule
		
		IF NOT EXISTS(  SELECT TOP 1 1 FROM Fdp_ImportErrorExclusion
						WHERE 
						ProgrammeId = @ProgrammeId
						AND
						ErrorMessage = @Message)
			
			INSERT INTO Fdp_ImportErrorExclusion
			(
				  ProgrammeId
				, ErrorMessage
				, CreatedBy
			)
			VALUES
			(
				  @ProgrammeId
				, @Message
				, @CDSId
			) 
	  
		COMMIT TRANSACTION;
		
		EXEC Fdp_ImportError_Get @ExceptionId;
	  
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
END;