CREATE PROCEDURE [dbo].[OXO_ChangeSet_GetMany]
	@p_OXODocId int 
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
    WHERE OXO_Doc_Id = @p_OXODocId
    ORDER By Set_Id DESC, Last_Updated DESC;

