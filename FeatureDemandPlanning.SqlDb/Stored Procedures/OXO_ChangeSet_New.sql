CREATE  PROCEDURE [OXO_ChangeSet_New] 
   @p_doc_id INT,
   @p_section NVARCHAR(8), 
   @p_reminder NVARCHAR(500),
   @p_Updated_By NVARCHAR(8), 
   @p_Id INT OUTPUT
AS

  INSERT INTO OXO_Change_Set (OXO_Doc_Id, Section, Reminder, Version_Id, Version_Label, Updated_By, Last_Updated)
  SELECT Id, @p_section, @p_reminder, version_id, 
         dbo.OXO_Version_Label_Get(version_id, status),
         @p_Updated_By, GetDATE()
  FROM OXO_DOC WHERE Id =  @p_doc_id 
  
  SET @p_Id = SCOPE_IDENTITY();
 
