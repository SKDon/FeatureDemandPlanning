CREATE PROCEDURE [dbo].[Fdp_OxoVolumeDataItem_Save]

	  @FdpOxoVolumeDataItemId	INT				= NULL OUTPUT
	, @Section					NVARCHAR(200)
	, @ModelId					INT
	, @MarketGroupId			INT				= NULL
	, @MarketId					INT
	, @FdpOxoDocId				INT
	, @Volume					INT
	, @PercentageTakeRate		DECIMAL(5, 4)
	, @PackId					INT				= NULL
	, @CDSID					NVARCHAR(16)
AS
	
	SET NOCOUNT ON;

	IF NOT EXISTS(SELECT TOP 1 1 FROM Fdp_OxoVolumeDataItem
				  WHERE
				  @FdpOxoVolumeDataItemId IS NOT NULL
				  AND
				  FdpOxoVolumeDataItemId = @FdpOxoVolumeDataItemId)
	BEGIN

		INSERT INTO Fdp_OxoVolumeDataItem
		(
			  Section
			, ModelId
			, MarketGroupId
			, MarketId
			, FdpOxoDocId
			, Volume
			, PercentageTakeRate
			, CreatedBy
			, PackId
		)
		VALUES
		(
			  'FBM'
			, @ModelId
			, @MarketGroupId
			, @MarketId
			, @FdpOxoDocId
			, @Volume
			, @PercentageTakeRate
			, @CDSID
			, @PackId
		)
	
		SET @FdpOxoVolumeDataItemId = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
	
		UPDATE Fdp_OxoVolumeDataItem SET
			  Volume = @Volume
			, PercentageTakeRate = @PercentageTakeRate
			, LastUpdated = GETDATE()
			, UpdatedBy = @CDSID	
		WHERE
		FdpOxoVolumeDataItemId = @FdpOxoVolumeDataItemId;
	END;
	