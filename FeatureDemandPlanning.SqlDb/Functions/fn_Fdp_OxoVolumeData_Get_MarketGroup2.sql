CREATE FUNCTION [dbo].[fn_Fdp_OxoVolumeData_Get_MarketGroup2]
(
	@OxoDocId		INT
  , @MarketGroupId	INT
  , @ModelIds		NVARCHAR(MAX)
)
RETURNS 
@VolumeData TABLE 
(
	  Feature_Id			INT NULL
	, Pack_Id				INT NULL
	, Model_Id				INT NULL
	, Trim_Id				INT NULL
	, Volume				INT NULL
	, PercentageTakeRate	DECIMAL(5,2) NULL
)
AS
BEGIN
	DECLARE @Models AS TABLE
	(	
		Model_Id INT PRIMARY KEY
	);
	INSERT INTO @Models (Model_Id)
	SELECT Model_Id AS ModelId FROM dbo.FN_SPLIT_MODEL_IDS(@ModelIds);
	
	INSERT INTO @VolumeData
	(
		  Feature_Id
		, Pack_Id
		, Model_Id
		, Trim_Id
		, Volume
		, PercentageTakeRate
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
    JOIN @Models			AS M	ON D.ModelId		= M.Model_Id
    JOIN Fdp_OxoDoc			AS FO	ON D.FdpOxoDocId	= FO.FdpOxoDocId
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
	
	RETURN 
END
