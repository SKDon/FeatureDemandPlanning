
CREATE PROCEDURE [dbo].[OXO_ProgrammeGSF_Get]
   @p_prog_id INT,
   @p_doc_id INT,
   @p_feature_id INT
AS  						
   
   SELECT Id, 
		  BrandDescription AS SystemDescription,
		  BrandDescription,
		  FeatureCode,
		  FeatureGroup,
		  FeatureSubGroup,
		  DisplayOrder AS GroupOrder,
		  FeatureComment AS Comment,
		  FeatureRuleText AS RuleText  
		  
   
   FROM dbo.FN_Programme_GSF_Get(@p_prog_id, @p_doc_id)
   WHERE Id = @p_feature_id;
   
   


