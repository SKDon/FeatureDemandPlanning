CREATE PROCEDURE [OXO_Rule_GetManyByFeature]
   @p_prog_id int,
   @p_feature_id int
   
AS 
   
   SELECT RuleId, 
	      RuleResponse,
	      RuleReason,
	      RuleApproved,
	      RuleCategory,
	      RuleActive   
   FROM OXO_Rule_Feature_VW 
   Where Id = @p_feature_id
   AND  Programme_Id = @p_prog_id;

