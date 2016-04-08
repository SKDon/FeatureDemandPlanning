CREATE PROCEDURE [dbo].[Fdp_TrimMapping_Save]
	  @ImportTrim		NVARCHAR(200)
	, @DocumentId		INT
	, @ProgrammeId		INT
	, @Gateway			NVARCHAR(100)
	, @DerivativeCode	NVARCHAR(40) = NULL
	, @TrimId			INT = NULL
	, @FdpTrimId		INT = NULL
	, @CDSId			NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		
		DECLARE @FdpTrimMappingId INT;
		
		DECLARE @TrimMapping AS TABLE
		(
			  ImportTrim	NVARCHAR(200)
			, DocumentId	INT
			, ProgrammeId	INT
			, Gateway		NVARCHAR(5)
			, BMC			NVARCHAR(5)
			, TrimId		INT
		)
		INSERT INTO @TrimMapping
		(
			  ImportTrim	
			, DocumentId	
			, ProgrammeId	
			, Gateway		
			, BMC			
			, TrimId		
		)
		SELECT
			  @ImportTrim
			, D.Id AS DocumentId
			, D.Programme_Id
			, D.Gateway
			, DV.BMC
			, @TrimId
		FROM
		OXO_Doc AS D
		JOIN Fdp_Derivative_VW		AS DV	ON	D.Id			= DV.DocumentId
		LEFT JOIN Fdp_TrimMapping	AS CUR	ON	D.Id			= CUR.DocumentId
											AND CUR.ImportTrim	= @ImportTrim
											AND CUR.IsActive	= 1
											AND DV.BMC			= CUR.BMC
											AND CUR.TrimId		= @TrimId
		
		WHERE
		D.Id = @DocumentId
		AND
		CUR.FdpTrimMappingId IS NULL;
		
		INSERT INTO Fdp_TrimMapping
		(
			  ImportTrim	
			, DocumentId	
			, ProgrammeId	
			, Gateway		
			, BMC			
			, TrimId		
		)
		SELECT
			  T.ImportTrim
			, T.DocumentId
			, T.ProgrammeId
			, T.Gateway
			, T.BMC
			, T.TrimId
		FROM
		@TrimMapping AS T;
		
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