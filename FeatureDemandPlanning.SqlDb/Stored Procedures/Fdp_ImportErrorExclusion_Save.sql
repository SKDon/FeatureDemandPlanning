CREATE PROCEDURE [dbo].[Fdp_ImportErrorExclusion_Save]
	  @ExceptionId	INT
	, @IsExcluded	BIT = 1
	, @Reprocess	BIT = 1
	, @CDSId		NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		
		-- Determine the worktray to which this error belongs so we can reprocess it
		
		DECLARE @FdpImportErrorTypeId	AS INT;
		DECLARE @FdpImportId			AS INT;
		
		SELECT TOP 1 
			  @FdpImportErrorTypeId = FdpImportErrorTypeId
			, @FdpImportId			= FdpImportId
		FROM 
		Fdp_ImportError_VW 
		WHERE 
		FdpImportErrorId = @ExceptionId;
	
		-- Add an exclusion rule
		
		IF NOT EXISTS(  
			SELECT TOP 1 1 
			FROM 
			Fdp_ImportErrorExclusion		AS	EX 
			LEFT JOIN Fdp_ImportError_VW	AS	E WITH (NOLOCK)
											ON  EX.DocumentId			= E.DocumentId
											AND EX.AdditionalData		= E.AdditionalData
											AND EX.FdpImportErrorTypeId	= E.FdpImportErrorTypeId
											AND (EX.SubTypeId IS NULL OR EX.SubTypeId = E.SubTypeId)
			WHERE 
			E.FdpImportErrorId = @ExceptionId
			AND
			EX.IsActive = 1
		)
		BEGIN
			INSERT INTO Fdp_ImportErrorExclusion
			(
				  DocumentId
				, ProgrammeId
				, Gateway
				, FdpImportErrorTypeId
				, SubTypeId
				, ErrorMessage
				, AdditionalData
				, CreatedBy
			)
			SELECT 
				  E.DocumentId
				, E.ProgrammeId
				, E.Gateway
				, E.FdpImportErrorTypeId
				, E.SubTypeId
				, E.ErrorMessage
				, E.AdditionalData
				, @CDSId
			FROM
			Fdp_ImportError_VW AS E WITH (NOLOCK)
			WHERE
			FdpImportErrorId = @ExceptionId;
			
			-- Reprocess any open worktray items for that document, we can further refine it by looking at the error type
			IF @Reprocess = 1
			BEGIN
				EXEC Fdp_ImportData_Process @FdpImportId = @FdpImportId;
			END
	
		END;
	  
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