CREATE PROCEDURE [dbo].[Fdp_Trim_Save]
	  @ProgrammeId		INT
	, @Gateway			NVARCHAR(100)
	, @DerivativeCode	NVARCHAR(20)
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
				  BMC = @DerivativeCode
				  AND
				  IsActive = 1)
				  
		INSERT INTO Fdp_Trim
		(
			  ProgrammeId
			, Gateway
			, BMC
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
			, @DerivativeCode
			, @TrimName
			, @TrimAbbreviation
			, @TrimLevel
			, @DPCK
			, @CDSId
		);
		
		SET @FdpTrimId = SCOPE_IDENTITY();
		
		-- Now that we have trim, we have enough information to construct an Fdp_Model entry
		-- This is used for our cross tab data and will show Fdp Models together with OXO models
		
		-- If the derivative exists in OXO_Programme_Model
		
		IF EXISTS(	SELECT TOP 1 1 FROM OXO_Programme_Model 
					WHERE
					Programme_Id = @ProgrammeId
					AND
					BMC = @DerivativeCode
					AND
					Active = 1)
		BEGIN
			INSERT INTO Fdp_Model
			(
				  ProgrammeId
				, Gateway
				, DerivativeCode
				, FdpTrimId
			)
			VALUES
			(
				  @ProgrammeId
				, @Gateway
				, @DerivativeCode
				, @FdpTrimId
			)
		END
		ELSE
		BEGIN
		
			DECLARE @FdpDerivativeId INT;
			
			SELECT @FdpDerivativeId = FdpDerivativeId
			FROM
			Fdp_Derivative
			WHERE
			ProgrammeId = @ProgrammeId
			AND
			Gateway = @Gateway
			AND
			DerivativeCode = @DerivativeCode
			AND
			IsActive = 1
			
			INSERT INTO Fdp_Model
			(
				  ProgrammeId
				, Gateway
				, FdpDerivativeId
				, FdpTrimId
			)
			VALUES
			(
				  @ProgrammeId
				, @Gateway
				, @FdpDerivativeId
				, @FdpTrimId
			)
		END
					
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