CREATE PROCEDURE [OXO_Doc_Clone_Forward_Packs] 
   @p_doc_id  int, 
   @p_prog_id  int, 
   @p_new_prog_id  int,    
   @p_clone_by nvarchar(50)
AS
BEGIN

	DECLARE @p_archived BIT;
	
	SELECT @p_archived = Archived 
	FROM OXO_Doc 
	WHERE Id = @p_doc_id	
	AND Programme_Id = @p_prog_id;
		
	IF (ISNULL(@p_archived,0) = 0) 
	  BEGIN
		-- Get Pack
		INSERT INTO OXO_Programme_Pack (Programme_Id, Pack_Name, Extra_Info, Feature_Code, OA_Code,
		                                Clone_Id, Created_By, Created_On, Updated_By, Last_Updated)
		SELECT Distinct @p_new_prog_id, Pack_Name, Extra_Info, Feature_Code, OA_Code,
						Id, @p_clone_by, GetDate(), @p_clone_by, GetDate()   
		FROM  OXO_Programme_Pack
        WHERE Programme_Id = @p_prog_id;     
		
		-- Get the Pack_Feature_Link
		INSERT INTO OXO_Pack_Feature_Link (Programme_Id, Pack_Id, Feature_Id)	                                       
		SELECT Distinct @p_new_prog_id, P.Id, M.Feature_Id   
		FROM OXO_Pack_Feature_Link M
		INNER JOIN OXO_Programme_Pack P
		ON P.Programme_Id = @p_new_prog_id
		AND P.Clone_Id = M.Pack_Id
		WHERE M.Programme_Id = @p_prog_id
	
	  END
	ELSE
	  BEGIN
		-- Get Pack
		INSERT INTO OXO_Programme_Pack (Programme_Id, Pack_Name, Extra_Info, Feature_Code, OA_Code,
		                                Clone_Id, Created_By, Created_On, Updated_By, Last_Updated)
		SELECT Distinct @p_new_prog_id, Pack_Name, Extra_Info, Feature_Code, OA_Code,
						Id, @p_clone_by, GetDate(), @p_clone_by, GetDate()   
		FROM  OXO_Archived_Programme_Pack
        WHERE Programme_Id = @p_prog_id
        AND Doc_Id =  @p_doc_id; 
				
		-- Get the Pack_Feature_Link
		INSERT INTO OXO_Pack_Feature_Link (Programme_Id, Pack_Id, Feature_Id)	                                       
		SELECT Distinct @p_new_prog_id, M.Pack_Id, M.Feature_Id   
		FROM OXO_Archived_Pack_Feature_Link M
		INNER JOIN OXO_Programme_Pack P
		ON P.Programme_Id = @p_new_prog_id
		AND P.Clone_Id = M.Pack_Id
		WHERE M.Programme_Id = @p_prog_id
		AND M.Doc_Id = @p_doc_id;
		
	  END	
END

