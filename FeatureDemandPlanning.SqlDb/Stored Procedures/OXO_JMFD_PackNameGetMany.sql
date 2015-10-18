CREATE PROCEDURE [OXO_JMFD_PackNameGetMany]	
	@p_vehicle NVARCHAR(50) = NULL,
	@p_ex_prog_id INT,
	@p_ex_doc_id INT,
	@p_use_OACode BIT = 0
AS
	
	DECLARE @_make NVARCHAR(50);	
	SELECT @_make = Make FROM OXO_Vehicle WHERE Name = @p_vehicle;
			
	DECLARE @p_archived BIT;
   	
	SELECT @p_archived = Archived 
	FROM OXO_Doc 
	WHERE Id = @p_ex_doc_id	
	AND Programme_Id = @p_ex_prog_id;		
			
	IF ISNULL(@p_archived, 0) = 0
	BEGIN		
		SELECT CASE WHEN @p_use_OACode = 1 THEN OA_Code
				ELSE Feat_Code END AS FeatureCode,
			   CASE	WHEN @_make = 'Jaguar' THEN ISNULL(Jaguar_Desc, Description)
					ELSE ISNULL(LR_Desc, Description) END AS Name
		FROM JMFD_Feature_VW 	 
		WHERE Group_Name = 'Option Packs' 
		AND dbo.FN_OXO_FEAT_APPLICABILITY(Id) like '%' + @p_vehicle + '%'
		AND CASE WHEN @_make = 'Jaguar' THEN ISNULL(Jaguar_Desc, Description)
					ELSE ISNULL(LR_Desc, Description) END 
		NOT IN (
			SELECT Pack_Name FROM OXO_Programme_Pack WHERE Programme_Id = @p_ex_prog_id
		)	        
		ORDER BY Name;
	END
	ELSE
	BEGIN		
		SELECT CASE WHEN @p_use_OACode = 1 THEN OA_Code
				ELSE Feat_Code END AS FeatureCode,
			   CASE	WHEN @_make = 'Jaguar' THEN ISNULL(Jaguar_Desc, Description)
					ELSE ISNULL(LR_Desc, Description) END AS Name
		FROM JMFD_Feature_VW 	 
		WHERE Group_Name = 'Option Packs' 
		AND dbo.FN_OXO_FEAT_APPLICABILITY(Id) like '%' + @p_vehicle + '%'
		AND CASE WHEN @_make = 'Jaguar' THEN ISNULL(Jaguar_Desc, Description)
					ELSE ISNULL(LR_Desc, Description) END 
		NOT IN (
			SELECT Pack_Name FROM OXO_Archived_Programme_Pack 
			WHERE Programme_Id = @p_ex_prog_id
			AND Doc_Id = @p_ex_doc_id
		)	        
		ORDER BY Name;
	END