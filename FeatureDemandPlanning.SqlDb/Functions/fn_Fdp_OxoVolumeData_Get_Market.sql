CREATE FUNCTION [dbo].[fn_Fdp_OxoVolumeData_Get_Market] 
(
    @OxoDocId		INT
  , @MarketGroupId	INT
  , @MarketId		INT
  , @ModelIds		NVARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN 
(
	WITH Models AS
	(
		SELECT 
			Model_Id AS ModelId 
		FROM dbo.FN_SPLIT_MODEL_IDS(@ModelIds)
	)
	SELECT 
		  D.FeatureId	AS Feature_Id
		, 0				AS Pack_Id
		, D.ModelId		AS Model_Id
		, D.TrimId		AS Trim_Id
		, D.Volume
		, D.PercentageTakeRate
    FROM 
    Fdp_OxoVolumeDataItem	AS D	WITH(NOLOCK) 
    JOIN Models				AS M	WITH(NOLOCK) ON D.ModelId	= M.ModelId
    JOIN Fdp_OxoDoc			AS FO	ON D.FdpOxoDocId			= FO.FdpOxoDocId
	WHERE 
	FO.OxoDocId = @OxoDocId
	AND
	D.MarketId = @MarketId
	AND 
	D.IsActive = 1
)
