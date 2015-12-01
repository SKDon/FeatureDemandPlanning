CREATE PROCEDURE [dbo].[Fdp_MarketMapping_Save]
	  @ImportMarket		NVARCHAR(50)
	, @MappedMarketId	INT
	, @ProgrammeId		INT				= NULL
	, @Gateway			NVARCHAR(100)	= NULL
	, @IsGlobalMapping	BIT				= 0
	, @CDSId			NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @FdpMarketMappingId INT;
	
	BEGIN TRY
		
		IF NOT EXISTS(
			SELECT TOP 1 1 
			FROM Fdp_MarketMapping 
			WHERE 
			ImportMarket = @ImportMarket
			AND
			MappedMarketId = @MappedMarketId
			AND
			(
				(@ProgrammeId IS NULL AND ProgrammeId IS NULL)
				OR
				(ProgrammeId = @ProgrammeId)
			)
			AND
			(
				(@Gateway IS NULL AND Gateway IS NULL)
				OR
				(Gateway = @Gateway)
			)
			AND
			IsGlobalMapping = @IsGlobalMapping
			AND
			IsActive = 1
		)
		BEGIN
		
			BEGIN TRANSACTION;
				  
			INSERT INTO Fdp_MarketMapping
			(
				  ImportMarket
				, MappedMarketId
				, ProgrammeId
				, Gateway
				, IsGlobalMapping
				, CreatedBy
			)
			VALUES
			(
				  @ImportMarket
				, @MappedMarketId
				, @ProgrammeId
				, @Gateway
				, @IsGlobalMapping
				, @CDSId
			);
			
			SET @FdpMarketMappingId = SCOPE_IDENTITY();
		  
			COMMIT TRANSACTION;
			
			EXEC Fdp_MarketMapping_Get @FdpMarketMappingId;
			
		END;
	  
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