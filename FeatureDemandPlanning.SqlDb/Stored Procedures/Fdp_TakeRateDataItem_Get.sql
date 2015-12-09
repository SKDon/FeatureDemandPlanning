CREATE PROCEDURE dbo.Fdp_TakeRateDataItem_Get
	@FdpTakeRateDataItemId INT
AS

	SET NOCOUNT ON;

	SELECT
		  FdpVolumeDataItemId
		, CreatedOn
		, CreatedBy
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
		, UpdatedOn
		, UpdatedBy
	FROM
	Fdp_VolumeDataItem AS D
	WHERE
	D.FdpVolumeDataItemId = @FdpTakeRateDataItemId;

	-- Fetch any notes as the second dataset

	SELECT
		  FdpTakeRateDataItemNoteId
		, FdpTakeRateDataItemId
		, EnteredOn
		, EnteredBy
	Note
	FROM
	Fdp_TakeRateDataItemNote
	WHERE
	FdpTakeRateDataItemId = @FdpTakeRateDataItemId
	ORDER BY
	FdpTakeRateDataItemNoteId DESC;