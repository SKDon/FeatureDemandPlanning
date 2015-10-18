CREATE PROCEDURE [OXO_Doc_Clone_Forward_Rules] 
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
	    -- Get Market_Group
		INSERT INTO OXO_Programme_Rule (Programme_Id, Rule_Category, Rule_Group, Rule_Assert,
										Rule_Report, Rule_response, Owner, Approved, Rule_Reason, Active, Clone_Id, 
										Created_By, Created_On, Updated_By, Last_Updated)
		SELECT @p_new_prog_id, Rule_Category, Rule_Group, Rule_Assert, Rule_Report, 
		       Rule_Response, Owner, Approved, Rule_Reason, Active, Id, 
							       @p_clone_by, GetDate(), @p_clone_by, GetDate()       
        FROM OXO_Programme_Rule
		WHERE Programme_Id = @p_prog_id;
		
	  END
	ELSE
	  BEGIN
	    -- Get Market_Group
		INSERT INTO OXO_Programme_Rule (Programme_Id, Rule_Category, Rule_Group, Rule_Assert,
										Rule_Report, Rule_response, Owner, Approved, Rule_Reason, Active, Clone_Id, 
										Created_By, Created_On, Updated_By, Last_Updated)
		SELECT Distinct @p_new_prog_id, Rule_Category, Rule_Group, Rule_Assert, Rule_Report, 
										Rule_response, Owner, Approved, Rule_Reason, Active, Id,
										@p_clone_by, GetDate(), @p_clone_by, GetDate()   
		FROM OXO_Archived_Programme_Rule
		WHERE Programme_Id = @p_prog_id
		AND Doc_Id = @p_doc_id;								
			
	  END		
END

