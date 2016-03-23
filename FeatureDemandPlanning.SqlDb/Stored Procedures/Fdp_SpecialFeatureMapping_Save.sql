CREATE PROCEDURE [dbo].[Fdp_SpecialFeatureMapping_Save]
	  @FeatureCode				NVARCHAR(20)
	, @DocumentId				INT
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
				  DocumentId = @DocumentId
				  AND
				  FeatureCode = @FeatureCode
				  AND
				  IsActive = 1)
				  
			INSERT INTO Fdp_SpecialFeature
			(
				  DocumentId
				, ProgrammeId
				, Gateway
				, FeatureCode
				, FdpSpecialFeatureTypeId
				, CreatedBy
			)
			SELECT
				  D.Id
				, D.Programme_Id
				, D.Gateway
				, @FeatureCode
				, @FdpSpecialFeatureTypeId
				, @CDSId
			FROM
			OXO_Doc AS D
			WHERE
			D.Id = @DocumentId;
			
		SET @FdpSpecialFeatureId = SCOPE_IDENTITY();
	  
		COMMIT TRANSACTION;
		
		EXEC Fdp_SpecialFeatureMapping_Get @FdpSpecialFeatureId;
	  
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