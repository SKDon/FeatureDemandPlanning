CREATE PROCEDURE [dbo].[Fdp_TrimMapping_Save]
	  @ImportTrim		NVARCHAR(200)
	, @DocumentId		INT
	, @ProgrammeId		INT
	, @Gateway			NVARCHAR(100)
	, @TrimId			INT = NULL
	, @FdpTrimId		INT = NULL
	, @CDSId			NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		
		DECLARE @FdpTrimMappingId INT;
		
		IF NOT EXISTS(SELECT TOP 1 1 
				  FROM Fdp_TrimMapping 
				  WHERE 
				  ImportTrim = @ImportTrim
				  AND
				  DocumentId = @DocumentId
				  AND
				  (@TrimId IS NULL OR TrimId = @TrimId)
				  AND
				  (@FdpTrimId IS NULL OR FdpTrimId = @FdpTrimId)
				  AND
				  IsActive = 1)
				  
		INSERT INTO Fdp_TrimMapping
		(
			  ImportTrim
			, DocumentId
			, ProgrammeId
			, Gateway
			, TrimId
			, FdpTrimId
			, CreatedBy
		)
		VALUES
		(
			  @ImportTrim
			, @DocumentId
			, @ProgrammeId
			, @Gateway
			, @TrimId
			, @FdpTrimId
			, @CDSId
		);
		
		SET @FdpTrimMappingId = SCOPE_IDENTITY();
		
		COMMIT TRANSACTION;
		
		EXEC Fdp_TrimMapping_Get @FdpTrimMappingId;
	  
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