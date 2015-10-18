CREATE PROCEDURE [OXO_Doc_Clone_Gateway_Doc] 
   @p_doc_id  int, 
   @p_prog_id  int, 
   @p_gateway  NVARCHAR(50),
   @p_next_gateway  NVARCHAR(50),          
   @p_version_id numeric(10,1),   
   @p_clone_by nvarchar(50),
   @p_new_doc_id int output      
AS
BEGIN
	
	DECLARE @p_next_ver_id INT;
	
	SET @p_next_ver_id =  FLOOR(@p_version_id) + 1;
	
	-- First create a new OXO_Doc and this is the "ARCHIVED" doc
	INSERT INTO OXO_Doc (Programme_Id, Version_Id, Owner, Created_By, Created_On, Updated_By, Last_Updated, Gateway, Status, Archived)
	             VALUES (@p_prog_id, @p_next_ver_id, null, @p_clone_by, GetDate(), @p_clone_by, GetDate(), @p_gateway, 'Published', 1);   

	SET @p_new_doc_id = SCOPE_IDENTITY();

	-- Second Move the current doc onto the next gateway stage, resetting the version and status.
	UPDATE OXO_Doc SET Gateway = @p_next_gateway, Version_Id = 1.0, Status = 'WIP' 
	WHERE Programme_Id = @p_prog_id AND Id = @p_doc_id;

	EXEC OXO_Doc_Clone_Gateway_Models @p_doc_id, @p_prog_id, @p_new_doc_id, @p_clone_by;
	EXEC OXO_Doc_Clone_Gateway_Markets @p_doc_id, @p_prog_id, @p_new_doc_id, @p_clone_by;
	EXEC OXO_Doc_Clone_Gateway_Packs @p_doc_id, @p_prog_id, @p_new_doc_id, @p_clone_by;
	EXEC OXO_Doc_Clone_Gateway_Features @p_doc_id, @p_prog_id, @p_new_doc_id, @p_clone_by;
	EXEC OXO_Doc_Clone_Gateway_GSFs @p_doc_id, @p_prog_id, @p_new_doc_id, @p_clone_by;
	EXEC OXO_Doc_Clone_Gateway_Rules @p_doc_id, @p_prog_id, @p_new_doc_id, @p_clone_by;
	EXEC OXO_Doc_Clone_Gateway_Change_Diary @p_doc_id, @p_prog_id, @p_new_doc_id; 
	
	-- Do MBM
	INSERT INTO OXO_Item_Data_MBM (Section, OXO_Doc_Id, Model_Id, Market_Id,
								   OXO_Code, Active, Reminder,
								   Created_By, Created_On, Updated_By, Last_Updated)
	SELECT DISTINCT 'MBM', @p_new_doc_id, M.Id, O.Market_Id, 
	                         OXO_Code, O.Active, 'Gateway Published',
							 @p_clone_by, GetDate(), @p_clone_by, GetDate()     
	FROM OXO_Item_Data_MBM O
	LEFT OUTER JOIN OXO_Archived_Programme_Model M 
	ON M.Clone_Id = O.Model_Id
	AND M.Programme_Id = @p_prog_id
	AND M.Doc_Id = @p_new_doc_id
	WHERE O.OXO_Doc_Id = @p_doc_id;							   
	
	-- Do FBM	
	INSERT INTO OXO_Item_Data_FBM (Section, OXO_Doc_Id, Model_Id, Feature_Id, Market_Group_Id, Market_Id,
								   OXO_Code, Active, Reminder, Created_By, Created_On, Updated_By, Last_Updated)
	SELECT DISTINCT 'FBM', @p_new_doc_id, M.Id, O.Feature_Id, MG.ID, O.Market_Id, 
	                               OXO_Code, O.Active, 'Gateway Published',
							      @p_clone_by, GetDate(), @p_clone_by, GetDate()     
	FROM OXO_Item_Data_FBM O
	LEFT OUTER JOIN OXO_Archived_Programme_Model M 
	ON M.Clone_Id = O.Model_Id
	AND M.Programme_Id = @p_prog_id
	AND M.Doc_Id = @p_new_doc_id
	LEFT OUTER JOIN OXO_Archived_Programme_MarketGroup MG
	ON MG.Clone_Id = O.Market_Group_Id
	AND MG.Programme_Id = @p_prog_id
	AND MG.Doc_Id = @p_new_doc_id
	WHERE O.OXO_Doc_Id = @p_doc_id;
	
	-- Do PCK	
	INSERT INTO OXO_Item_Data_PCK (Section, OXO_Doc_Id, Model_Id, Pack_Id, Market_Group_Id, Market_Id,
								   OXO_Code, Active, Reminder, Created_By, Created_On, Updated_By, Last_Updated)
	SELECT DISTINCT 'PCK', @p_new_doc_id, M.Id, PK.Id, MG.ID, O.Market_Id, 
	                               OXO_Code, O.Active, 'Gateway Published',
							      @p_clone_by, GetDate(), @p_clone_by, GetDate()     
	FROM OXO_Item_Data_PCK O
	LEFT OUTER JOIN OXO_Archived_Programme_Model M 
	ON M.Clone_Id = O.Model_Id
	AND M.Programme_Id = @p_prog_id
	AND M.Doc_Id = @p_new_doc_id
	LEFT OUTER JOIN OXO_Archived_Programme_MarketGroup MG
	ON MG.Clone_Id = O.Market_Group_Id
	AND MG.Programme_Id = @p_prog_id
	AND MG.Doc_Id = @p_new_doc_id
	LEFT OUTER JOIN OXO_Archived_Programme_Pack PK
	ON PK.Clone_Id = O.Pack_Id
	AND PK.Programme_Id = @p_prog_id
	AND PK.Doc_Id = @p_new_doc_id
	WHERE O.OXO_Doc_Id = @p_doc_id;
	
	
	-- Do FPS
	INSERT INTO OXO_Item_Data_FPS (Section, OXO_Doc_Id, Model_Id, Pack_Id, Feature_Id, Market_Group_Id, Market_Id,
								   OXO_Code, Active, Reminder, Created_By, Created_On, Updated_By, Last_Updated)
	SELECT DISTINCT 'FPS', @p_new_doc_id, M.Id, PK.Id, O.Feature_Id, MG.ID, O.Market_Id, 
	                               OXO_Code, O.Active, 'Gateway Published',
							      @p_clone_by, GetDate(), @p_clone_by, GetDate()     
	FROM OXO_Item_Data_FPS O
	LEFT OUTER JOIN OXO_Archived_Programme_Model M 
	ON M.Clone_Id = O.Model_Id
	AND M.Programme_Id = @p_prog_id
	AND M.Doc_Id = @p_new_doc_id
	LEFT OUTER JOIN OXO_Archived_Programme_MarketGroup MG
	ON MG.Clone_Id = O.Market_Group_Id
	AND MG.Programme_Id = @p_prog_id
	AND MG.Doc_Id = @p_new_doc_id
	LEFT OUTER JOIN OXO_Archived_Programme_Pack PK
	ON PK.Clone_Id = O.Pack_Id
	AND PK.Programme_Id = @p_prog_id
	AND PK.Doc_Id = @p_new_doc_id
	WHERE O.OXO_Doc_Id = @p_doc_id;
	
		
	

END

