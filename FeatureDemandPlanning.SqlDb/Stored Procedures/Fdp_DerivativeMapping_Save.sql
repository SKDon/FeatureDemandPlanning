CREATE PROCEDURE [dbo].[Fdp_DerivativeMapping_Save]
	  @ImportDerivativeCode NVARCHAR(20)
	, @ProgrammeId			INT
	, @Gateway				NVARCHAR(100)
	, @DerivativeCode		NVARCHAR(10)
	, @BodyId				INT
	, @EngineId				INT
	, @TransmissionId		INT
	, @CDSId				NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		
		DECLARE @FdpDerivativeMappingId INT;
	
		IF NOT EXISTS(SELECT TOP 1 1 
					  FROM Fdp_DerivativeMapping 
					  WHERE 
					  ImportDerivativeCode = @ImportDerivativeCode
					  AND
					  ProgrammeId = @ProgrammeId
					  AND
					  Gateway = @Gateway
					  AND
					  DerivativeCode = @DerivativeCode)
					  
			INSERT INTO Fdp_DerivativeMapping
			(
				  ImportDerivativeCode
				, ProgrammeId
				, Gateway
				, DerivativeCode
				, BodyId
				, EngineId
				, TransmissionId
				, CreatedBy
			)
			VALUES
			(
				  @ImportDerivativeCode
				, @ProgrammeId
				, @Gateway
				, @DerivativeCode
				, @BodyId
				, @EngineId
				, @TransmissionId
				, @CDSId
			);
			
		SET @FdpDerivativeMappingId = SCOPE_IDENTITY();
	  
		COMMIT TRANSACTION;
		
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
END;