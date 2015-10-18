CREATE PROCEDURE [dbo].[OXO_ProgrammeFeature_GetMany]
   @p_prog_id INT,
   @p_doc_id INT,
   @p_lookup NVARCHAR(50) = NULL,
   @p_group  NVARCHAR(500) = NULL,
   @p_exclude_packid INT = 0
AS

  DECLARE @p_archived BIT;
   	
  SELECT @p_archived = Archived 
  FROM OXO_Doc 
  WHERE Id = @p_doc_id	
  AND Programme_Id = @p_prog_id;
 
  IF @p_lookup = '@@@'
     SET @p_lookup = NULL; 
		
  IF @p_group = 'All'
     SET @p_group = NULL;  		

 
  IF ISNULL(@p_archived,0) = 0
  BEGIN   						
	   WITH SET_A 
	   AS 
	   (
		  SELECT Id,
				 SystemDescription,
				 BrandDescription,
				 FeatureCode,
				 FeatureGroup,
				 DisplayOrder  AS GroupOrder,
				 FeatureSubGroup,
				 FeatureComment AS Comment,
				 FeatureRuleText AS RuleText
		  FROM 	 OXO_Programme_Feature_VW         
		  WHERE  ProgrammeId  = @p_prog_id
   		  AND (
			(@p_lookup IS NULL OR FeatureCode LIKE '%' + @p_lookup + '%')
			OR                             
			(@p_lookup IS NULL OR BrandDescription LIKE '%' + @p_lookup + '%')
		  )
		  AND (
			@p_group IS NULL OR FeatureGroup = @p_group
		  )     
		), 
		SET_B AS
		(
			SELECT Id
			FROM  OXO_Pack_Feature_VW
			WHERE PackId = @p_exclude_packid
		)
	   SELECT * FROM SET_A A 
		WHERE NOT EXISTS
		(SELECT 1 FROM SET_B WHERE ID = A.ID)	
  		ORDER BY A.GroupOrder, A.FeatureSubGroup, A.FeatureCode;
  END
  ELSE
    BEGIN   						
	   WITH SET_A 
	   AS 
	   (
		  SELECT Id,
				 SystemDescription,
				 BrandDescription,
				 FeatureCode,
				 FeatureGroup,
				 DisplayOrder  AS GroupOrder,
				 FeatureSubGroup,
				 FeatureComment AS Comment,
				 FeatureRuleText AS RuleText
		  FROM 	 OXO_Archived_Programme_Feature_VW
		  WHERE  ProgrammeId  = @p_prog_id
		  AND Doc_Id = @p_doc_id 
   		  AND (
			(@p_lookup IS NULL OR FeatureCode LIKE '%' + @p_lookup + '%')
			OR                             
			(@p_lookup IS NULL OR BrandDescription LIKE '%' + @p_lookup + '%')
		  )
		  AND (
			@p_group IS NULL OR FeatureGroup = @p_group
		  )     
		), 
		SET_B AS
		(
			SELECT Id
			FROM OXO_Archived_Pack_Feature_VW
			WHERE ProgrammeId = @p_prog_id
			AND Doc_Id = @p_doc_id
			AND PackId = @p_exclude_packid
		)
	   SELECT * FROM SET_A A 
		WHERE NOT EXISTS
		(SELECT 1 FROM SET_B WHERE ID = A.ID)	
  		ORDER BY A.GroupOrder, A.FeatureSubGroup, A.FeatureCode;
  END
