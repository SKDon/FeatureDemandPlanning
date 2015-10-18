CREATE PROCEDURE [dbo].[Fdp_OxoVolumeDataItem_Get]
	@FdpOxoVolumeDataItemId	INT
AS
	
	SET NOCOUNT ON;

	SELECT 
		  D.FdpOxoVolumeDataItemId
		, D.CreatedBy
		, D.CreatedOn
		, D.FdpOxoDocId
		, D.FeatureId
		, D.IsActive
		, D.LastUpdated
		, D.LastUpdated
		, D.MarketGroupId
		, D.MarketId
		, D.ModelId
		, D.PackId
		, D.PercentageTakeRate
		, D.Section
		, D.TrimId
		, D.UpdatedBy
		, D.Volume
	FROM
	Fdp_OxoVolumeDataItem AS D
	WHERE
	D.FdpOxoVolumeDataItemId = @FdpOxoVolumeDataItemId;
	