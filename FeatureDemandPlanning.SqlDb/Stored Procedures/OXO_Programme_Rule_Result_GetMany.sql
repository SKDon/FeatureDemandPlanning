CREATE PROCEDURE [dbo].[OXO_Programme_Rule_Result_GetMany]
	@p_oxo_doc_id int,
	@p_prog_id int = NULL,
	@p_Level  nvarchar(3) = null, 
	@p_ObjectId  int = null,
	@p_show_what bit = null
AS
	
   SELECT
    V.OXO_Doc_Id  AS OXODocId,  
    V.Programme_Id  AS ProgrammeId,  
    V.Rule_Id  AS RuleId,
    V.Model_Id  AS ModelId,   
    V.Model  AS Model,
    V.CoA,
    V.Feature_Group AS FeatureGroup,
    V.Rule_Category AS RuleCategory,  
    V.Owner AS Owner,
    V.Rule_Response AS RuleResponse,
    V.Rule_Result  AS RuleResult,
    V.Created_By  AS CreatedBy,  
    V.Created_On  AS CreatedOn,
    CASE WHEN V.Object_Level = 'g' THEN 'Global Generic'
		 WHEN V.Object_Level = 'mg' THEN M.Market_Group_Name
		 ELSE M.Market_Name
	END AS ObjectName	 
    FROM dbo.OXO_Programme_Rule_Result_VW V
    LEFT OUTER JOIN OXO_Programme_MarketGroupMarket_VW M
    ON V.Programme_Id = M.Programme_Id 
    AND V.Object_Id = CASE WHEN V.Object_Level = 'mg' THEN M.Market_Group_Id
                           WHEN V.Object_Level = 'm' THEN M.Market_Id
                           ELSE NULL END
    WHERE V.OXO_Doc_Id = @p_oxo_doc_id
    AND V.Programme_Id = @p_prog_id
    AND (@p_Level IS NULL OR  V.Object_Level = @p_Level)
    AND (@p_ObjectId IS NULL OR V.Object_Id = @p_ObjectId)
    AND (@p_show_what IS NULL or V.Rule_Result = @p_show_what)
    ;

