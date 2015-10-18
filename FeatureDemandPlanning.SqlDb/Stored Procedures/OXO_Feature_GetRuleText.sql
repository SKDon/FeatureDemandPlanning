

CREATE PROCEDURE [OXO_Feature_GetRuleText]
   @p_prog_id int,
   @p_doc_id int,
   @p_feature_id int
AS 
   
   DECLARE @p_archived BIT
   
   SELECT @p_archived = Archived 
   FROM OXO_Doc 
   WHERE Id = @p_doc_id	
   AND Programme_Id = @p_prog_id;
  
   IF @p_archived = 0
   BEGIN
     SELECT Rule_Text AS FeatureRuleText 
	 FROM OXO_Programme_Feature_Link 
	 WHERE Programme_Id = @p_prog_id
	 AND Feature_Id = @p_feature_id;
   END
   ELSE
   BEGIN
        SELECT Rule_Text AS FeatureRuleText  
		 FROM OXO_Archived_Programme_Feature_Link 
		 WHERE Programme_Id = @p_prog_id
		 AND doc_id = @p_doc_id
		 AND Feature_Id = @p_feature_id;
   END

