CREATE PROCEDURE [dbo].[Fdp_DerivativeMapping_Save]
	  @ImportDerivativeCode NVARCHAR(20)
	, @DocumentId			INT
	, @DerivativeCode		NVARCHAR(10) = NULL
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
					  DocumentId = @DocumentId
					  AND
					  (@DerivativeCode IS NULL OR DerivativeCode = @DerivativeCode)
					  AND
					  IsActive = 1)
					  
			INSERT INTO Fdp_DerivativeMapping
			(
				  ImportDerivativeCode
				, DocumentId
				, ProgrammeId
				, Gateway
				, DerivativeCode
				, BodyId
				, EngineId
				, TransmissionId
				, CreatedBy
			)
			SELECT
				  @ImportDerivativeCode
				, D.Id
				, D.Programme_Id
				, D.Gateway
				, @DerivativeCode
				, @BodyId
				, @EngineId
				, @TransmissionId
				, @CDSId
			FROM
			OXO_Doc AS D
			WHERE
			Id = @DocumentId;
			
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