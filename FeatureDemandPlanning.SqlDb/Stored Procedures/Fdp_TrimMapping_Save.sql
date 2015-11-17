CREATE PROCEDURE [dbo].[Fdp_TrimMapping_Save]
	  @ImportTrim	NVARCHAR(200)
	, @ProgrammeId	INT
	, @Gateway		NVARCHAR(100)
	, @TrimId		INT
	, @CDSId		NVARCHAR(16)
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
				  ProgrammeId = @ProgrammeId
				  AND
				  Gateway = @Gateway
				  AND
				  TrimId = @TrimId
				  AND
				  IsActive = 1)
				  
		INSERT INTO Fdp_TrimMapping
		(
			  ImportTrim
			, ProgrammeId
			, Gateway
			, TrimId
			, CreatedBy
		)
		VALUES
		(
			  @ImportTrim
			, @ProgrammeId
			, @Gateway
			, @TrimId
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