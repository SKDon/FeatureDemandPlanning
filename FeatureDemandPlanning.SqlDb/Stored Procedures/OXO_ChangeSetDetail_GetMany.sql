CREATE PROCEDURE [dbo].[OXO_ChangeSetDetail_GetMany]
  @p_set_id INT,
  @p_prog_id INT, 
  @p_doc_id INT
AS
	
	DECLARE @_Use_OA_Code BIT = 0;
	DECLARE @_make NVARCHAR(500);
	
	SELECT @_Use_OA_Code = ISNULL(UseOACode,0),
	       @_make = VehicleMake
	FROM OXO_Programme_VW 
	WHERE Id = @p_prog_id;
	
	SELECT DISTINCT @p_set_id AS SetId, 
		   CASE WHEN D.Market_Id = -1 THEN 'Global Generic'
	            ELSE ISNULL(MG2.Market_Name, MG.Market_Group_Name) 
	             END AS MarketName,
	       M.Name AS ModelName,  
		   CASE WHEN D.SECTION = 'MBM' THEN 'Availability'
		        WHEN D.SECTION = 'PCK' THEN 
		        ISNULL(F.Description, PP.Pack_Name)
		        ELSE 		        
				   '[' + CASE WHEN @_Use_OA_Code = 0 THEN F.Feat_Code
						 ELSE F.OA_Code END				   
				   + '] ' + ISNULL(FBD.Brand_Desc, F.Description)
		     END AS FeatureName, 
	       ISNULL(H.Prev_Code, '') AS PrevFitment,
	       ISNULL(H.Item_Code, '') AS CurrFitment
	FROM OXO_ITEM_DATA_Hist H WITH(NOLOCK)
	INNER JOIN OXO_ITEM_DATA_VW D WITH(NOLOCK)
	ON H.Item_Id = D.ID
	AND H.Section = D.Section
	INNER JOIN FN_Programme_Models_Get(@p_prog_id, @p_doc_id) M
	ON D.Model_Id = M.Id
	INNER JOIN OXO_DOC OD
	ON D.OXO_Doc_Id = OD.ID
	LEFT OUTER JOIN dbo.FN_Programme_Markets_Get(@p_prog_id, @p_doc_id) MG
	ON D.Market_Group_Id = MG.Market_Group_ID
	AND OD.Programme_Id = MG.Programme_Id
	LEFT OUTER JOIN dbo.FN_Programme_Markets_Get(@p_prog_id, @p_doc_id) MG2
	ON D.Market_Id = MG2.Market_ID
	AND OD.Programme_Id = MG2.Programme_Id	
	LEFT OUTER JOIN OXO_Feature_Ext F WITH(NOLOCK)
	ON D.Feature_Id = F.ID
	LEFT JOIN OXO_Feature_Brand_Desc FBD WITH(NOLOCK)
	ON F.Feat_Code = FBD.Feat_Code
	AND FBD.Brand = @_make
	LEFT OUTER JOIN OXO_Programme_Pack PP WITH(NOLOCK)
	ON D.Pack_Id = PP.ID
	AND OD.Programme_Id = PP.Programme_Id
	WHERE H.Set_Id = @p_set_id
	AND ISNULL(H.Prev_Code, '') != ISNULL(H.Item_Code, '')
	UNION 
	SELECT DISTINCT @p_set_id AS SetId, 
		   'Global Generic' AS MarketName,
	       Event_Type AS ModelName,  
		   '[' + CASE WHEN @_Use_OA_Code = 0 THEN F.Feat_Code
		         ELSE F.OA_Code END				   
		   + '] ' + ISNULL(FBD.Brand_Desc, F.Description)  FeatureName, 
	       CASE WHEN Event_Type IN ('Remove Programme Feature', 'Remove Global Standard Feature') THEN 'Misc'	       
	       ELSE '' END AS PrevFitment,
	       CASE WHEN Event_Type IN ('Remove Programme Feature', 'Remove Global Standard Feature') THEN 'Nil'	       
	       ELSE '' END AS CurrFitment
	FROM OXO_EVENT_LOG E WITH(NOLOCK)
	INNER JOIN OXO_Feature_Ext F WITH(NOLOCK)
	ON E.Event_Parent2_Id = F.Id
	AND E.Event_Parent2_Object = 'Feature'
	LEFT JOIN OXO_Feature_Brand_Desc FBD WITH(NOLOCK)
	ON F.Feat_Code = FBD.Feat_Code
	AND FBD.Brand = @_make
	WHERE changeset_id = @p_set_id
	UNION
	SELECT DISTINCT @p_set_id AS SetId, 
		   'Global Generic' AS MarketName,
	       Event_Type AS ModelName,  
		   F.Name   FeatureName, 
	       '' AS PrevFitment,
	       '' AS CurrFitment
	FROM OXO_EVENT_LOG E
	INNER JOIN OXO_Models_VW F
	ON E.Event_Parent2_Id = F.Id
	AND E.Event_Parent2_Object = 'Model'
	WHERE changeset_id = @p_set_id
	UNION
	SELECT DISTINCT @p_set_id AS SetId, 
		   'Global Generic' AS MarketName,
	       Event_Type AS ModelName,  
	       PK.Pack_Name + 	      	       
		   ' - [' + CASE WHEN @_Use_OA_Code = 0 THEN PF.Feat_Code
		         ELSE PF.OA_Code END				   
		   + '] ' + ISNULL(FBD.Brand_Desc, PF.Description) FeatureName, 
	       '' AS PrevFitment,
	       '' AS CurrFitment
	FROM OXO_EVENT_LOG E WITH(NOLOCK)
	INNER JOIN OXO_Programme_Pack PK WITH(NOLOCK)
	ON E.Event_Parent_Id = PK.Programme_Id
	AND E.Event_Parent_Object = 'Programme'
	AND E.Event_Parent2_Id = PK.Id
	AND E.Event_Parent2_Object = 'Pack'
	INNER JOIN OXO_Feature_Ext PF	
	ON E.Event_Parent3_Id = PF.Id
	AND E.Event_Parent3_Object = 'Feature'
	LEFT JOIN OXO_Feature_Brand_Desc FBD WITH(NOLOCK)
	ON PF.Feat_Code = FBD.Feat_Code
	AND FBD.Brand = @_make
	WHERE E.changeset_id = @p_set_id
	UNION
	SELECT DISTINCT @p_set_id AS SetId, 
		   'Global Generic' AS MarketName,
	       Event_Type AS ModelName,  
	       PK.Pack_Name + 	      	       
		   ' - [' + CASE WHEN @_Use_OA_Code = 0 THEN PF.Feat_Code
		         ELSE PF.OA_Code END				   
		   + '] ' + ISNULL(FBD.Brand_Desc, PF.Description)  FeatureName, 
	       '' AS PrevFitment,
	       '' AS CurrFitment
	FROM OXO_EVENT_LOG E WITH(NOLOCK)
	INNER JOIN OXO_Archived_Programme_Pack PK WITH(NOLOCK)
	ON E.Event_Parent_Id = PK.Doc_Id
	AND E.Event_Parent_Object = 'Document'
	AND E.Event_Parent2_Id = PK.Id
	AND E.Event_Parent2_Object = 'Pack'
	INNER JOIN OXO_Feature_Ext PF	
	ON E.Event_Parent3_Id = PF.Id
	AND E.Event_Parent3_Object = 'Feature'	
	LEFT JOIN OXO_Feature_Brand_Desc FBD WITH(NOLOCK)
	ON PF.Feat_Code = FBD.Feat_Code
	AND FBD.Brand = @_make
	WHERE E.changeset_id = @p_set_id

