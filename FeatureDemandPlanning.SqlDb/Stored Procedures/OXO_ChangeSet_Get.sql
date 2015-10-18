CREATE PROCEDURE [dbo].[OXO_ChangeSet_Get] 
  @p_set_id bigint
AS
	
	SELECT 
      Set_Id  AS SetId,
      OXO_Doc_Id  AS OXODocId,  
      Reminder  AS Reminder,  
      Version_Id AS VersionId,
      Is_Important AS IsImportant,
	  Is_Starred AS IsStarred,
      Updated_By  AS UpdatedBy,  
      Last_Updated  AS LastUpdated        	     
    FROM dbo.OXO_Change_Set
	WHERE Set_Id = @p_set_id;

