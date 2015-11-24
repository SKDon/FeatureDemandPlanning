CREATE PROCEDURE [dbo].[Fdp_SpecialFeatureMapping_Save]
	  @FeatureCode				NVARCHAR(20)
	, @ProgrammeId				INT
	, @Gateway					NVARCHAR(100)
	, @FdpSpecialFeatureTypeId	INT
	, @CDSId					NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		
		DECLARE @FdpSpecialFeatureId INT;
		
		IF NOT EXISTS(SELECT TOP 1 1 
				  FROM Fdp_SpecialFeature 
				  WHERE 
				  ProgrammeId = @ProgrammeId
				  AND
				  Gateway = @Gateway
				  AND
				  FeatureCode = @FeatureCode
				  AND
				  IsActive = 1)
				  
			INSERT INTO Fdp_SpecialFeature
			(
				  ProgrammeId
				, Gateway
				, FeatureCode
				, FdpSpecialFeatureId
				, CreatedBy
			)
			VALUES
			(
				  @ProgrammeId
				, @Gateway
				, @FeatureCode
				, @FdpSpecialFeatureTypeId
				, @CDSId
			);
			
		SET @FdpSpecialFeatureId = SCOPE_IDENTITY();
	  
		COMMIT TRANSACTION;
		
		EXEC Fdp_SpecialFeature_Get @FdpSpecialFeatureId;
	  
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