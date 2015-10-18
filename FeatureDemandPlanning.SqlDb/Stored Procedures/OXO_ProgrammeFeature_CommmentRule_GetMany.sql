
CREATE PROCEDURE [dbo].[OXO_ProgrammeFeature_CommmentRule_GetMany]
    @p_prog_id INT
AS
	
	DECLARE @_use_OA_Code BIT;
	DECLARE @_make NVARCHAR(500);
	
	SELECT @_use_OA_Code = UseOACode,
	       @_make = VehicleMake
	FROM OXO_Programme_VW 
	WHERE Id = @p_prog_id;
	
		SELECT FL.Feature_Id AS FeatureId, 
			   CASE WHEN ISNULL(@_use_OA_Code, 0) = 0 THEN F.OA_Code
			   ELSE F.Feat_Code END AS FeatCode,			       
			   ISNULL(FD.Brand_Desc, F.Description) AS FeatDescription,
			   FL.Comment AS Comment, 
			   FL.Rule_Text AS RuleText,
			   FL.CDSID AS CDSID,
			   0 AS Source
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Feature_Ext F
		ON F.Id = FL.Feature_Id
		LEFT JOIN OXO_Feature_Brand_Desc FD
		ON F.Feat_Code = FD.Feat_Code
		AND FD.Brand = @_make		
		WHERE Programme_Id = @p_prog_id
		AND (LEN(Rule_Text) > 0)
		UNION
		SELECT Id, 
		       Feature_Code,
			   Pack_Name,	
	           Extra_Info, 
			   Rule_Text,
			   Updated_By,
			   1 AS Source
		FROM OXO_Programme_Pack
		WHERE Programme_Id = @p_prog_id
		AND (LEN(Rule_Text) > 0)		
		ORDER BY Source, FeatCode