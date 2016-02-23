CREATE PROCEDURE [dbo].[Fdp_Changeset_Get]
	@FdpChangesetId AS INT
AS
	SET NOCOUNT ON;
	
	-- First dataset yields the header details
	
	SELECT TOP 1 
		    C.FdpChangesetId
		  , C.CreatedOn
		  , C.CreatedBy
		  , C.IsDeleted
		  , C.IsSaved
		  , C.Comment
	FROM
	Fdp_Changeset	AS C
	WHERE
	C.FdpChangesetId = @FdpChangesetId
	
	-- Second dataset yields the changes that comprise the dataset
	
	SELECT
		  D.CreatedOn
		, D.MarketId
		, CASE 
			WHEN D.ModelId IS NOT NULL THEN 'O' + CAST(D.ModelId AS NVARCHAR(10))
			ELSE 'F' + CAST(D.FdpModelId AS NVARCHAR(10))
		  END
		  AS ModelIdentifier
		, CASE 
			WHEN D.FeatureId IS NOT NULL THEN 'O' + CAST(D.FeatureId AS NVARCHAR(10))
			WHEN D.FeatureId IS NULL AND D.FeaturePackId IS NOT NULL THEN 'P' + CAST(D.FeaturePackId AS NVARCHAR(10))
			ELSE 'F' + CAST(D.FdpFeatureId AS NVARCHAR(10))
		  END
		  AS FeatureIdentifier
		, D.TotalVolume AS Volume
		, D.PercentageTakeRate * 100 AS PercentageTakeRate
	FROM
	Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	IsDeleted = 0
	ORDER BY
	D.FdpChangesetDataItemId DESC;