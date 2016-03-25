CREATE PROCEDURE [dbo].[Fdp_FeatureMapping_Save]
	  @ImportFeatureCode	NVARCHAR(20)
	, @DocumentId			INT
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
				  DocumentId = @DocumentId
				  AND
				  (@FeatureId IS NULL OR FeatureId = @FeatureId)
				  AND
				  (@FeaturePackId IS NULL OR FeaturePackId = @FeaturePackId)
				  AND
				  IsActive = 1)
				  
		INSERT INTO Fdp_FeatureMapping
		(
			  ImportFeatureCode
			, DocumentId
			, ProgrammeId
			, Gateway
			, FeatureId
			, FeaturePackId
			, CreatedBy
		)
		SELECT
			  @ImportFeatureCode
			, D.Id
			, D.Programme_Id
			, D.Gateway
			, @FeatureId
			, @FeaturePackId
			, @CDSId
		FROM
		OXO_Doc AS D
		WHERE
		D.Id = @DocumentId
		
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