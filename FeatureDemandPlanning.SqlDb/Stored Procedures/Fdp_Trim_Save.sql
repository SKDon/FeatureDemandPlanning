CREATE PROCEDURE [dbo].[Fdp_Trim_Save]
	  @ProgrammeId		INT
	, @Gateway			NVARCHAR(100)
	, @TrimName			NVARCHAR(1000)
	, @TrimAbbreviation NVARCHAR(100)
	, @TrimLevel		NVARCHAR(1000)
	, @DPCK				NVARCHAR(20)
	, @CDSId			NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		
		DECLARE @FdpTrimId INT
		
		IF NOT EXISTS(SELECT TOP 1 1 
				  FROM Fdp_Trim
				  WHERE 
				  ProgrammeId = @ProgrammeId
				  AND
				  Gateway = @Gateway
				  AND
				  TrimName = @TrimName
				  AND
				  IsActive = 1)
				  
		INSERT INTO Fdp_Trim
		(
			  ProgrammeId
			, Gateway
			, TrimName
			, TrimAbbreviation
			, TrimLevel
			, DPCK
			, CreatedBy
		)
		VALUES
		(
			  @ProgrammeId
			, @Gateway
			, @TrimName
			, @TrimAbbreviation
			, @TrimLevel
			, @DPCK
			, @CDSId
		);
		
		SET @FdpTrimId = SCOPE_IDENTITY();
	  
		COMMIT TRANSACTION;
		
		EXEC Fdp_Trim_Get @FdpTrimId;
	  
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