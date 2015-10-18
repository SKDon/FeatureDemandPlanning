
CREATE PROCEDURE [dbo].[OXO_Rule_Feature_GetMany]
   @p_rule_id int
AS
	
   SELECT 
    Rule_Id AS RuleId,
    Programme_Id AS ProgrammeId,
    Feature_Id  AS FeatureId,
    Created_By  AS CreatedBy,  
    Created_On  AS CreatedOn,  
    Updated_By  AS UpdatedBy,  
    Last_Updated  AS LastUpdated  
    FROM dbo.OXO_Rule_Feature_Link
    WHERE dbo.OXO_Rule_Feature_Link.Rule_Id = @p_rule_id
    ; 
    

