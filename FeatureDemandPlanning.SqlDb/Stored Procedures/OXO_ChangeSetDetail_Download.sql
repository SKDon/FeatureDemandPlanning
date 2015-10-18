CREATE PROCEDURE [OXO_ChangeSetDetail_Download]
  @p_oxo_doc_id INT,
  @p_prog_id INT = 0
AS

	DECLARE @_Use_OA_Code BIT = 0;
	
	SELECT @_Use_OA_Code = Use_OA_Code 
	FROM OXO_Programme WHERE Id = @p_prog_id;
	

	SELECT S.Set_ID AS SetId, 
	       S.Version_Id AS VersionId, 
	       S.Version_Label AS VersionLabel,
	       S.Reminder, 
	       S.Updated_By AS UpdatedBy,
	       S.Last_Updated AS LastUpdated,
		   ISNULL(C.Name, MG.Market_Group_Name) AS MarketName,
		   M.Name AS ModelName,  
		   CASE WHEN D.SECTION = 'MBM' THEN 'Availability'
		   ELSE ISNULL(F.Description, PP.Pack_Name) END AS FeatureName, 
		   ISNULL(H.Prev_Code, '') AS PrevFitment,
		   ISNULL(H.Item_Code, '') AS CurrFitment
	FROM OXO_ITEM_DATA_Hist H WITH(NOLOCK)
	INNER JOIN OXO_ITEM_DATA_VW D WITH(NOLOCK)
	ON H.Item_Id = D.ID
	AND H.Section = D.Section
	INNER JOIN OXO_Models_VW M
	ON D.Model_Id = M.Id
	INNER JOIN OXO_DOC OD	
	ON D.OXO_Doc_Id = OD.ID
	INNER JOIN OXO_Change_Set S
	ON S.Set_Id = H.Set_Id
	LEFT OUTER JOIN OXO_Master_Market C
	ON D.Market_Id = C.Id
	LEFT OUTER JOIN dbo.FN_Programme_Markets_Get(@p_prog_id, @p_oxo_doc_id) MG
	ON D.Market_Group_Id = MG.Market_Group_ID	
	AND OD.Programme_Id = MG.Programme_Id
	LEFT OUTER JOIN OXO_Feature_Ext F
	ON D.Feature_Id = F.ID
	LEFT OUTER JOIN OXO_Programme_Pack PP
	ON D.Pack_Id = PP.ID
	AND OD.Programme_Id = PP.Programme_Id
	WHERE S.OXO_Doc_Id = @p_oxo_doc_id
	AND   ISNULL(H.Prev_Code, '') != ISNULL(H.Item_Code, '')
	UNION 
	SELECT DISTINCT S.Set_ID AS SetId, 
		   s.Version_Id AS VersionId,
		   S.Version_Label AS VersionLabel,
		   s.Reminder,
		   S.Updated_By AS UpdatedBy,
	       S.Last_Updated AS LastUpdated,	
		   'Global Generic' AS MarketName,
	       Event_Type AS ModelName,  
		   '[' + CASE WHEN @_Use_OA_Code = 0 THEN F.Feat_Code
		         ELSE F.OA_Code END + '] ' + F.Description   FeatureName, 
	       '' AS PrevFitment,
	       '' AS CurrFitment
	FROM OXO_EVENT_LOG E WITH(NOLOCK)
	INNER JOIN OXO_Feature_Ext F WITH(NOLOCK)
	ON E.Event_Parent2_Id = F.Id
	AND E.Event_Parent2_Object = 'Feature'
	INNER JOIN OXO_Change_Set s
	ON E.ChangeSet_Id = S.Set_Id  
	AND S.OXO_Doc_Id = @p_oxo_doc_id
	WHERE (E.Event_Parent_Id = @p_prog_id OR E.Event_Parent_Id = @p_oxo_doc_id)
	AND E.Event_Parent_Object IN ('Programme', 'Document')
	UNION
	SELECT DISTINCT S.Set_ID AS SetId, 
		   s.Version_Id AS VersionId,
		   S.Version_Label AS VersionLabel,
		   s.Reminder,
		   S.Updated_By AS UpdatedBy,
	       S.Last_Updated AS LastUpdated,		
		   'Global Generic' AS MarketName,
	       Event_Type AS ModelName,  
		   F.Name   FeatureName, 
	       '' AS PrevFitment,
	       '' AS CurrFitment
	FROM OXO_EVENT_LOG E WITH(NOLOCK)
	INNER JOIN OXO_Models_VW F WITH(NOLOCK)
	ON E.Event_Parent2_Id = F.Id
	AND E.Event_Parent2_Object = 'Model'
	INNER JOIN OXO_Change_Set s
	ON E.ChangeSet_Id = S.Set_Id  	
	AND S.OXO_Doc_Id = @p_oxo_doc_id
	WHERE E.Event_Parent_Id = @p_prog_id
	AND E.Event_Parent_Object = 'Programme'
    UNION
    SELECT DISTINCT S.Set_Id AS SetId, 
		   S.Version_Id AS VersionId,
		   S.Version_Label AS VersionLabel,
		   s.Reminder,
		   S.Updated_By AS UpdatedBy,
	       S.Last_Updated AS LastUpdated,			
		   'Global Generic' AS MarketName,
	       Event_Type AS ModelName,  
		   '[' + CASE WHEN @_Use_OA_Code = 0 THEN F.Feat_Code
		         ELSE F.OA_Code END				   
		   + '] ' + F.Description   FeatureName, 
	       '' AS PrevFitment,
	       '' AS CurrFitment
	FROM OXO_Change_Set S WITH(NOLOCK)
	INNER JOIN OXO_EVENT_LOG E WITH(NOLOCK)
	ON S.Set_Id = E.ChangeSet_Id
	INNER JOIN OXO_Feature_Ext F
	ON E.Event_Parent2_Id = F.Id
	AND E.Event_Parent2_Object = 'Feature'
	WHERE S.OXO_Doc_Id = @p_oxo_doc_id
	UNION
	SELECT DISTINCT S.Set_Id AS SetId, 
		   S.Version_Id AS VersionId,
		   S.Version_Label AS VersionLabel,  
		   s.Reminder,
		   S.Updated_By AS UpdatedBy,
	       S.Last_Updated AS LastUpdated,		
		   'Global Generic' AS MarketName,
	       Event_Type AS ModelName,  
		   F.Name   FeatureName, 
	       '' AS PrevFitment,
	       '' AS CurrFitment
	FROM OXO_Change_Set S WITH(NOLOCK)
	INNER JOIN OXO_EVENT_LOG E WITH(NOLOCK)
	ON S.Set_ID = E.ChangeSet_Id
	INNER JOIN OXO_Models_VW F
	ON E.Event_Parent2_Id = F.Id
	AND E.Event_Parent2_Object = 'Model'
	WHERE S.OXO_Doc_Id = @p_oxo_doc_id
	UNION
	SELECT DISTINCT S.Set_Id AS SetId, 
		   S.Version_Id AS VersionId,
		   S.Version_Label AS VersionLabel,
		   s.Reminder,
		   S.Updated_By AS UpdatedBy,
	       S.Last_Updated AS LastUpdated,	
		   'Global Generic' AS MarketName,
	       Event_Type AS ModelName,  
	       PK.Pack_Name + 	      	       
		   ' - [' + CASE WHEN @_Use_OA_Code = 0 THEN PF.Feat_Code
		         ELSE PF.OA_Code END				   
		   + '] ' + PF.Description  FeatureName, 
	       '' AS PrevFitment,
	       '' AS CurrFitment
	FROM OXO_Change_Set S WITH(NOLOCK)
	INNER JOIN OXO_EVENT_LOG E WITH(NOLOCK)
	ON S.SET_Id = E.ChangeSet_Id	
	INNER JOIN OXO_Programme_Pack PK
	ON E.Event_Parent_Id = PK.Programme_Id
	AND E.Event_Parent_Object = 'Programme'
	AND E.Event_Parent2_Id = PK.Id
	AND E.Event_Parent2_Object = 'Pack'
	INNER JOIN OXO_Feature_Ext PF	
	ON E.Event_Parent3_Id = PF.Id
	AND E.Event_Parent3_Object = 'Feature'
	WHERE S.OXO_Doc_Id = @p_oxo_doc_id
	UNION
	SELECT DISTINCT S.Set_Id AS SetId, 
		   S.Version_Id AS VersionId,
		   S.Version_Label AS VersionLabel, 
		   s.Reminder,
		   S.Updated_By AS UpdatedBy,
	       S.Last_Updated AS LastUpdated,	
		   'Global Generic' AS MarketName,
	       Event_Type AS ModelName,  
	       PK.Pack_Name + 	      	       
		   ' - [' + CASE WHEN @_Use_OA_Code = 0 THEN PF.Feat_Code
		         ELSE PF.OA_Code END				   
		   + '] ' + PF.Description  FeatureName, 
	       '' AS PrevFitment,
	       '' AS CurrFitment
	FROM OXO_Change_Set S WITH(NOLOCK)
	INNER JOIN OXO_EVENT_LOG E WITH(NOLOCK)
	ON S.SET_Id = E.ChangeSet_Id	
	INNER JOIN OXO_Archived_Programme_Pack PK
	ON E.Event_Parent_Id = PK.Doc_Id
	AND E.Event_Parent_Object = 'Document'
	AND E.Event_Parent2_Id = PK.Id
	AND E.Event_Parent2_Object = 'Pack'
	INNER JOIN OXO_Feature_Ext PF	
	ON E.Event_Parent3_Id = PF.Id
	AND E.Event_Parent3_Object = 'Feature'
	WHERE S.OXO_Doc_Id = @p_oxo_doc_id

