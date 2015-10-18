CREATE PROCEDURE [dbo].[OXO_Doc_Clone_Gateway_Packs] 
   @p_doc_id  int, 
   @p_prog_id  int, 
   @p_new_doc_id  int,    
   @p_clone_by nvarchar(50)
AS
BEGIN

	-- Get Market_Group
	INSERT INTO OXO_Archived_Programme_Pack (Doc_Id, Programme_Id, Pack_Name, Extra_Info, Clone_Id,
	                                       Created_By, Created_On, Updated_By, Last_Updated)
	SELECT Distinct @p_new_doc_id, @p_prog_id, PackName, ExtraInfo, PackId,
	       @p_clone_by, GetDate(), @p_clone_by, GetDate()   
	FROM dbo.FN_Programme_Packs_Get (@p_prog_id, @p_doc_id);
	
	-- Get the Market_Link
	INSERT INTO OXO_Archived_Pack_Feature_Link (Doc_Id, Programme_Id, Pack_Id, Feature_Id)	                                       
	SELECT Distinct @p_new_doc_id, @p_prog_id, P.Id, M.Id   
	FROM dbo.FN_Programme_Packs_Get (@p_prog_id, @p_doc_id) M
	INNER JOIN OXO_Archived_Programme_Pack P
	ON P.Programme_Id = @p_prog_id
	AND P.Doc_Id = @p_new_doc_id
	AND P.Clone_Id = M.PackId;
	
END

