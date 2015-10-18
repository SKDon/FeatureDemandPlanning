CREATE PROCEDURE [OXO_ProgrammeGSF_Get]
   @p_prog_id INT,
   @p_doc_id INT,
   @p_feature_id INT
AS  						
   
	DECLARE @p_archived BIT;

	SELECT @p_archived = Archived 
	FROM OXO_Doc 
	WHERE Id = @p_doc_id	
	AND Programme_Id = @p_prog_id;
   
	IF (ISNULL(@p_archived,0) = 0) 
      BEGIN   	  
	   SELECT Id, 
	          BrandDescription AS SystemDescription,
	          BrandDescription,
	          FeatureCode,
			  FeatureGroup,
			  FeatureSubGroup,
			  DisplayOrder AS GroupOrder,
			  FeatureComment AS Comment,
			  FeatureRuleText AS RuleText,  
			  LongDescription
		FROM OXO_Programme_GSF_VW
		WHERE ProgrammeId = @p_prog_id
		AND Id = @p_feature_id;	  	   	   
     END 
   ELSE
     BEGIN   	  
	   SELECT Id, 
	          BrandDescription AS SystemDescription,
	          BrandDescription,
	          FeatureCode,
			  FeatureGroup,
			  FeatureSubGroup,
			  DisplayOrder AS GroupOrder,
			  FeatureComment AS Comment,
			  FeatureRuleText AS RuleText,  
			  LongDescription
		FROM OXO_Archived_Programme_GSF_VW
		WHERE ProgrammeId = @p_prog_id
		AND doc_Id = @p_doc_id
		AND Id = @p_feature_id;	  	   	   
     END
   
   


