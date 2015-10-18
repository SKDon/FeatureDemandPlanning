CREATE PROCEDURE [OXO_Doc_Clone_Gateway_Features] 
   @p_doc_id  int, 
   @p_prog_id  int, 
   @p_new_doc_id  int,    
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
		-- Get Feature Link
		INSERT INTO OXO_Archived_Programme_Feature_Link (
			  Doc_Id, Programme_Id, Feature_Id, CDSID, Comment, Rule_Text)
		SELECT Distinct @p_new_doc_id, @p_prog_id, Feature_Id, @p_clone_by, 
			   Comment, Rule_Text 
		FROM OXO_Programme_Feature_Link 
		WHERE Programme_Id = @p_prog_id;
	  END
	ELSE
	  BEGIN
		-- Get Feature Link
		INSERT INTO OXO_Archived_Programme_Feature_Link (
			  Doc_Id, Programme_Id, Feature_Id, CDSID, Comment, Rule_Text)
		SELECT Distinct @p_new_doc_id, @p_prog_id, Feature_Id, @p_clone_by, 
			   Comment, Rule_Text 
		FROM OXO_Archived_Programme_Feature_Link 
		WHERE programme_Id = @p_prog_id
		AND Doc_Id = @p_doc_id;
	  END
	
	

END

