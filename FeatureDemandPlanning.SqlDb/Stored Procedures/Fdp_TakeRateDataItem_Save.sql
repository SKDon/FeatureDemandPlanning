CREATE PROCEDURE [dbo].[Fdp_TakeRateDataItem_Save]
	  @FdpTakeRateDataItemId	INT OUTPUT
	, @DocumentId				INT
	, @ModelId					INT = NULL
	, @FdpModelId				INT = NULL
	, @FeatureId				INT = NULL
	, @FdpFeatureId				INT = NULL
	, @MarketGroupId			INT = NULL
	, @MarketId					INT
	, @Volume					INT = NULL				
	, @PercentageTakeRate		INT = NULL
	, @FeaturePackId			INT = NULL
	, @CDSID					NVARCHAR(16)
AS
	
	SET NOCOUNT ON;

	DECLARE @FdpVolumeHeaderId	AS INT;
	DECLARE @ProgrammeId		AS INT;
	DECLARE @Gateway			AS NVARCHAR(100);
	DECLARE @TrimId				AS INT;
	DECLARE @FdpTrimId			AS INT;
	DECLARE @TotalVolume		AS INT;

	SELECT TOP 1 
		  @FdpVolumeHeaderId	= H.FdpVolumeHeaderId
		, @ProgrammeId			= D.Programme_Id
		, @Gateway				= D.Gateway
	FROM Fdp_VolumeHeader AS H
	JOIN OXO_Doc AS D ON H.DocumentId = D.Id
	WHERE
	DocumentId = @DocumentId;

	-- Need to determine the trim level and total take from the model code

	IF @ModelId IS NOT NULL
	BEGIN
		SELECT @TrimId = Trim_Id
		FROM OXO_Programme_Model
		WHERE
		Programme_Id = @ProgrammeId
		AND 
		Id = @ModelId;

		SELECT @TotalVolume = TotalVolume
		FROM Fdp_TakeRateSummaryByModelAndMarket_VW
		WHERE
		DocumentId = @DocumentId
		AND 
		ModelId = @ModelId;
	END
	ELSE
	BEGIN
		SELECT 
			  @TrimId = TrimId
			, @FdpTrimId = FdpTrimId
		FROM
		Fdp_Model_VW
		WHERE
		ProgrammeId = @ProgrammeId
		AND
		Gateway = @Gateway
		AND
		FdpModelId = @FdpModelId;

		SELECT @TotalVolume = TotalVolume
		FROM Fdp_TakeRateSummaryByModelAndMarket_VW
		WHERE
		DocumentId = @DocumentId
		AND 
		FdpModelId = @FdpModelId;
	END

	-- If updating the volume, we calculate the percentage take rate
	-- If updating the percentage take rate, we calculate the volume
	IF @Volume IS NOT NULL
	BEGIN
		SELECT @PercentageTakeRate = @Volume / CAST(@TotalVolume AS DECIMAL)
	END
	ELSE
	BEGIN
		-- % is always a number between 0 and 1 where 0.5 would equal 50%
		SELECT @Volume = @TotalVolume * @PercentageTakeRate 
	END
	
	IF @FdpTakeRateDataItemId IS NULL
	BEGIN

		INSERT INTO Fdp_VolumeDataItem
		(
			  CreatedBy
			, FdpVolumeHeaderId
			, IsManuallyEntered
			, MarketId
			, MarketGroupId
			, ModelId
			, FdpModelId
			, TrimId
			, FdpTrimId
			, FeatureId
			, FdpFeatureId
			, FeaturePackId
			, Volume
			, PercentageTakeRate
		)
		VALUES
		(
			  @CDSID
			, @FdpVolumeHeaderId
			, 1
			, @MarketId
			, @MarketGroupId
			, @ModelId
			, @FdpModelId
			, @TrimId
			, @FdpTrimId
			, @FeatureId
			, @FdpFeatureId
			, @FeaturePackId
			, @Volume
			, @PercentageTakeRate
		)

		SET @FdpTakeRateDataItemId = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		
		UPDATE Fdp_VolumeDataItem SET
			  IsManuallyEntered = 1
			, Volume = @Volume
			, PercentageTakeRate = @PercentageTakeRate
			, UpdatedBy = @CDSID
			, UpdatedOn = GETDATE()
		WHERE
		FdpVolumeDataItemId = @FdpTakeRateDataItemId;
			
	END

	EXEC Fdp_TakeRateDataItem_Get @FdpTakeRateDataItemId;