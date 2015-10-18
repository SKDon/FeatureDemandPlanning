CREATE PROCEDURE [dbo].[OXO_Doc_Clone_Gateway_Rules] 
   @p_doc_id  int, 
   @p_prog_id  int, 
   @p_new_doc_id  int,    
   @p_clone_by nvarchar(50)
AS
BEGIN

	-- Get Market_Group
	INSERT INTO OXO_Archived_Programme_Rule (Doc_id, Programme_Id, Rule_Category, Rule_Group, Rule_Assert,
	                                Rule_Report, Rule_response, Owner, Approved, Rule_Reason, Active, Clone_Id, 
	                                Created_By, Created_On, Updated_By, Last_Updated)
	SELECT Distinct @p_new_doc_id, @p_prog_id, Rule_Category, Rule_Group, Rule_Assert, Rule_Report, 
	                                Rule_response, Owner, Approved, Rule_Reason, Active, Id,
	                                @p_clone_by, GetDate(), @p_clone_by, GetDate()   
	FROM dbo.FN_Programme_Rules_Get (@p_prog_id, @p_doc_id);

END

