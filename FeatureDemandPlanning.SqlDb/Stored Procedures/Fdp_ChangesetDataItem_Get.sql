CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_Get]
	  @FdpChangesetDataItemId	AS INT
AS
	SET NOCOUNT ON;
	
	SELECT
		  D.FdpChangesetDataItemId
		, D.CreatedOn
		, D.MarketId
		, CASE 
			WHEN D.ModelId IS NOT NULL THEN 'O' + CAST(D.ModelId AS NVARCHAR(10))
			ELSE 'F' + CAST(D.FdpModelId AS NVARCHAR(10))
		  END
		  AS ModelIdentifier
		, CASE 
			WHEN D.FeatureId IS NOT NULL THEN 'O' + CAST(D.FeatureId AS NVARCHAR(10))
			ELSE 'F' + CAST(D.FdpFeatureId AS NVARCHAR(10))
		  END
		  AS FeatureIdentifier
		, D.PercentageTakeRate
		, D.TotalVolume
		, D.OriginalPercentageTakeRate
		, D.OriginalVolume
	FROM
	Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;