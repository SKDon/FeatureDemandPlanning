CREATE PROCEDURE [dbo].[Fdp_Feature_Save]
	  @FeatureCode			NVARCHAR(20)
	, @ProgrammeId			INT
	, @Gateway				NVARCHAR(100)
	, @FeatureDescription	NVARCHAR(255)
	, @FeatureGroupId		INT
	, @CDSId				NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		
		DECLARE @FdpFeatureId INT;
		
		IF NOT EXISTS(SELECT TOP 1 1 
				  FROM Fdp_Feature 
				  WHERE 
				  ProgrammeId = @ProgrammeId
				  AND
				  Gateway = @Gateway
				  AND
				  FeatureCode = @FeatureCode)
				  
			INSERT INTO Fdp_Feature
			(
				  ProgrammeId
				, Gateway
				, FeatureCode
				, FeatureGroupId
				, FeatureDescription
				, CreatedBy
			)
			VALUES
			(
				  @ProgrammeId
				, @Gateway
				, @FeatureCode
				, @FeatureGroupId
				, @FeatureDescription
				, @CDSId
			);
			
		SET @FdpFeatureId = SCOPE_IDENTITY();
	  
		COMMIT TRANSACTION;
		
		EXEC Fdp_Feature_Get @FdpFeatureId
	  
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