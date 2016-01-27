CREATE PROCEDURE [dbo].[Fdp_FeatureMapping_Save]
	  @ImportFeatureCode	NVARCHAR(20)
	, @ProgrammeId			INT
	, @Gateway				NVARCHAR(100)
	, @FeatureId			INT = NULL
	, @FeaturePackId		INT = NULL
	, @CDSId				NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		
		DECLARE @FdpFeatureMappingId INT;
		
		IF NOT EXISTS(SELECT TOP 1 1 
				  FROM Fdp_FeatureMapping 
				  WHERE 
				  ImportFeatureCode = @ImportFeatureCode
				  AND
				  ProgrammeId = @ProgrammeId
				  AND
				  Gateway = @Gateway
				  AND
				  (@FeatureId IS NULL OR FeatureId = @FeatureId)
				  AND
				  (@FeaturePackId IS NULL OR FeaturePackId = @FeaturePackId)
				  AND
				  IsActive = 1)
				  
		INSERT INTO Fdp_FeatureMapping
		(
			  ImportFeatureCode
			, ProgrammeId
			, Gateway
			, FeatureId
			, FeaturePackId
			, CreatedBy
		)
		VALUES
		(
			  @ImportFeatureCode
			, @ProgrammeId
			, @Gateway
			, @FeatureId
			, @FeaturePackId
			, @CDSId
		);
		
		SET @FdpFeatureMappingId = SCOPE_IDENTITY();
	  
		COMMIT TRANSACTION;
		
		EXEC Fdp_FeatureMapping_Get @FdpFeatureMappingId;
	  
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