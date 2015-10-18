CREATE PROCEDURE [dbo].[OXO_Doc_Clone_Forward_Doc] 
   @p_doc_id  int, 
   @p_prog_id  int, 
   @p_new_prog_id  int,   
   @p_gateway  NVARCHAR(50),          
   @p_donor NVARCHAR(500),
   @p_version_id numeric(10,1),   
   @p_clone_by nvarchar(50)       
AS
BEGIN
	
	DECLARE @_new_doc_id INT
	
	INSERT INTO OXO_Doc (Programme_Id, Version_Id, Owner, Created_By, Created_On, Updated_By, Last_Updated, Gateway, Status, Archived)
	             VALUES (@p_new_prog_id, 1.0, null, @p_clone_by, GetDate(), @p_clone_by, GetDate(), @p_gateway, 'WIP', 0);   

	SET @_new_doc_id = SCOPE_IDENTITY();

	EXEC OXO_Doc_Clone_Forward_Models @p_doc_id, @p_prog_id, @p_new_prog_id, @p_clone_by;
	EXEC OXO_Doc_Clone_Forward_Markets @p_doc_id, @p_prog_id, @p_new_prog_id, @p_clone_by;
	EXEC OXO_Doc_Clone_Forward_Packs @p_doc_id, @p_prog_id, @p_new_prog_id, @p_clone_by;
	EXEC OXO_Doc_Clone_Forward_Features @p_doc_id, @p_prog_id, @p_new_prog_id, @p_clone_by;
	EXEC OXO_Doc_Clone_Forward_GSFs @p_doc_id, @p_prog_id, @p_new_prog_id, @p_clone_by;
	EXEC OXO_Doc_Clone_Forward_Rules @p_doc_id, @p_prog_id, @p_new_prog_id, @p_clone_by;
	EXEC OXO_Doc_Clone_Forward_Change_Diary @p_doc_id, @p_prog_id, @_new_doc_id, @p_new_prog_id;
		
	INSERT INTO OXO_Item_Data_MBM (Section, OXO_Doc_Id, Model_Id, Market_Id, OXO_Code, 
	                               Active, Reminder, Created_By, Created_On, Updated_By, Last_Updated)	
	SELECT DISTINCT 'MBM', @_new_doc_id, M.Id, O.Market_Id, OXO_Code, O.Active, 'Cloned From ' + @p_donor,
		                   @p_clone_by, GetDate(), @p_clone_by, GetDate()     
	FROM OXO_Item_Data_MBM O
	LEFT OUTER JOIN OXO_Programme_Model M 
	ON M.Clone_Id = O.Model_Id
	AND M.Programme_Id = @p_new_prog_id
	WHERE O.OXO_Doc_Id = @p_doc_id;
	
	INSERT INTO OXO_Item_Data_FBM (Section, OXO_Doc_Id, Model_Id, Feature_Id, Market_Group_Id,
	                               Market_Id, OXO_Code, Active, Reminder, Created_By, 
	                               Created_On, Updated_By, Last_Updated)	
	SELECT DISTINCT 'FBM', @_new_doc_id, M.Id, O.Feature_Id, MG.Id, O.Market_Id, 
	                OXO_Code, O.Active, 'Cloned From ' + @p_donor,
		            @p_clone_by, GetDate(), @p_clone_by, GetDate()     
	FROM OXO_Item_Data_FBM O
	LEFT OUTER JOIN OXO_Programme_Model M 
	ON M.Clone_Id = O.Model_Id
	AND M.Programme_Id = @p_new_prog_id
	LEFT OUTER JOIN OXO_Programme_MarketGroup MG
	ON MG.Clone_Id = O.Market_Group_Id
	AND M.Programme_Id = @p_new_prog_id
	WHERE O.OXO_Doc_Id = @p_doc_id;
	
	INSERT INTO OXO_Item_Data_PCK (Section, OXO_Doc_Id, Model_Id, Pack_Id, Market_Group_Id,
	                               Market_Id, OXO_Code, Active, Reminder, Created_By, 
	                               Created_On, Updated_By, Last_Updated)	
	SELECT DISTINCT 'PCK', @_new_doc_id, M.Id, PK.ID, MG.Id, O.Market_Id, 
	                OXO_Code, O.Active, 'Cloned From ' + @p_donor,
		            @p_clone_by, GetDate(), @p_clone_by, GetDate()     
	FROM OXO_Item_Data_PCK O
	LEFT OUTER JOIN OXO_Programme_Model M 
	ON M.Clone_Id = O.Model_Id
	AND M.Programme_Id = @p_new_prog_id
	LEFT OUTER JOIN OXO_Programme_MarketGroup MG
	ON MG.Clone_Id = O.Market_Group_Id
	AND M.Programme_Id = @p_new_prog_id
	LEFT OUTER JOIN OXO_Programme_Pack PK
	ON PK.Clone_Id = O.Pack_Id
	AND M.Programme_Id = @p_new_prog_id
	WHERE O.OXO_Doc_Id = @p_doc_id;
	
	INSERT INTO OXO_Item_Data_FPS (Section, OXO_Doc_Id, Model_Id, Pack_Id, Feature_Id, Market_Group_Id,
	                               Market_Id, OXO_Code, Active, Reminder, Created_By, 
	                               Created_On, Updated_By, Last_Updated)	
	SELECT DISTINCT 'FPS', @_new_doc_id, M.Id, PK.ID, O.Feature_Id, MG.Id, O.Market_Id, 
	                OXO_Code, O.Active, 'Cloned From ' + @p_donor,
		            @p_clone_by, GetDate(), @p_clone_by, GetDate()     
	FROM OXO_Item_Data_FPS O
	LEFT OUTER JOIN OXO_Programme_Model M 
	ON M.Clone_Id = O.Model_Id
	AND M.Programme_Id = @p_new_prog_id
	LEFT OUTER JOIN OXO_Programme_MarketGroup MG
	ON MG.Clone_Id = O.Market_Group_Id
	AND M.Programme_Id = @p_new_prog_id
	LEFT OUTER JOIN OXO_Programme_Pack PK
	ON PK.Clone_Id = O.Pack_Id
	AND M.Programme_Id = @p_new_prog_id
	WHERE O.OXO_Doc_Id = @p_doc_id;

END

