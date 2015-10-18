

CREATE PROCEDURE [dbo].[OXO_ProgrammeFeature_Get]
   @p_prog_id INT,
   @p_doc_id INT,
   @p_feature_id INT
AS

  						
   SELECT ID,
          SystemDescription AS SystemDescription,
          BrandDescription AS BrandDescription,
          FeatureCode ,
          FeatureGroup, 
          DisplayOrder AS GroupOrder,
          FeatureSubGroup,
          FeatureComment AS Comment,
          FeatureRuleText AS RuleText              
   FROM FN_Programme_Features_Get(@p_prog_id, @p_doc_id)
   WHERE Id = @p_feature_id;
   
   
   

