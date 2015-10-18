CREATE FUNCTION [dbo].[fn_Fdp_OxoVolumeData_Get_MarketGroup] 
(
    @OxoDocId		INT
  , @MarketGroupId	INT
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
		  D.FeatureId			AS Feature_Id
		, 0						AS Pack_Id
		, D.ModelId				AS Model_Id
		, D.TrimId				AS Trim_Id
		, SUM(D.Volume)			AS Volume
		, 0.0					AS PercentageTakeRate	
    FROM 
    Fdp_OxoVolumeDataItem	AS D	WITH(NOLOCK) 
    JOIN Models				AS M	WITH(NOLOCK) ON D.ModelId	= M.ModelId
    JOIN Fdp_OxoDoc			AS FO	ON D.FdpOxoDocId			= FO.FdpOxoDocId
	WHERE 
	FO.OxoDocId = @OxoDocId
	AND
	(@MarketGroupId IS NULL OR D.MarketGroupId = @MarketGroupId)
	AND 
	D.IsActive = 1
	GROUP BY
	  D.ModelId
	, D.FeatureId
	, D.TrimId
)
