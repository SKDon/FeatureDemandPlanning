CREATE PROCEDURE [dbo].[Fdp_OxoDoc_Process]
	@FdpOxoDocId INT
AS
BEGIN
	-- Copies data from the Fdp_VolumeHeader / Fdp_VolumeDataItem structure
	-- associating with the specified OXO document(s)
	
	SET NOCOUNT ON;
	
	DECLARE @TotalVolume	INT;
	DECLARE @CreatedBy		NVARCHAR(16);
	DECLARE @CreatedOn		DATETIME;
	
	SELECT 
		  @CreatedBy = CreatedBy
		, @CreatedOn = CreatedOn 
	FROM Fdp_OxoDoc 
	WHERE 
	FdpOxoDocId = @FdpOxoDocId;

    INSERT INTO Fdp_OxoVolumeDataItem
    (
		  Section
		, ModelId
		, FeatureId
		, MarketGroupId
		, MarketId
		, TrimId
		, FdpOxoDocId
		, Volume
		, PercentageTakeRate
		, CreatedBy
		, CreatedOn
		, PackId
    )
    SELECT 
		  'FBM'
		, I.ModelId
		, I.FeatureId
		, I.MarketGroupId
		, I.MarketId
		, I.TrimId
		, D.FdpOxoDocId
		, I.Volume
		, 1.0
		, H.CreatedBy
		, H.CreatedOn
		, I.FeaturePackId
		
    FROM		Fdp_OxoDoc				AS D
    JOIN		Fdp_VolumeHeader		AS H	ON	D.FdpVolumeHeaderId = H.FdpVolumeHeaderId
    JOIN		Fdp_VolumeDataItem		AS I	ON	H.FdpVolumeHeaderId = I.FdpVolumeHeaderId
    LEFT JOIN	Fdp_OxoVolumeDataItem	AS CUR	ON	I.ModelId			= CUR.ModelId
												AND I.FeatureId			= CUR.FeatureId
												AND I.MarketGroupId		= CUR.MarketGroupId
												AND I.MarketId			= CUR.MarketId
												AND I.TrimId			= CUR.TrimId
												AND D.FdpOxoDocId		= CUR.FdpOxoDocId
												AND I.Volume			= CUR.Volume
    WHERE
    (@FdpOxoDocId IS NULL OR D.FdpOxoDocId = @FdpOxoDocId)
    AND
    CUR.FdpOxoVolumeDataItemId IS NULL; -- Don't add duplicate information if we are re-processing
    
    -- Calculate the total volume mix from data
    -- We can only make assumptions here and simply use the maximum volume value
    -- This would assume this is a standard feature for all derivatives that would imply a 100% take rate
    
    SELECT 
		@TotalVolume = MAX(ISNULL(I.Volume, 0))
    FROM Fdp_OxoDoc			AS D
    JOIN Fdp_VolumeHeader	AS H ON D.FdpVolumeHeaderId = H.FdpVolumeHeaderId
    JOIN Fdp_VolumeDataItem AS I ON H.FdpVolumeHeaderId = I.FdpVolumeHeaderId
    WHERE
    D.FdpOxoDocId = @FdpOxoDocId;
    
    IF NOT EXISTS(SELECT TOP 1 1 FROM Fdp_OxoVolume WHERE FdpOxoDocId = @FdpOxoDocId)
    BEGIN
		INSERT INTO Fdp_OxoVolume
		(
			  FdpOxoDocId
			, CreatedBy
			, CreatedOn
			, TotalVolume
		)
		VALUES
		(
			  @FdpOxoDocId
			, @CreatedBy
			, @CreatedOn
			, @TotalVolume
		);
    END
    ELSE
    BEGIN
		UPDATE Fdp_OxoVolume SET 
			  TotalVolume	= @TotalVolume
			, UpdatedBy		= @CreatedBy
			, UpdatedOn		= GETDATE()
		WHERE FdpOxoDocId = @FdpOxoDocId;
    END
END
