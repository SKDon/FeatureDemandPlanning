
CREATE PROCEDURE [dbo].[OXO_Model_Delete] 
  @p_Id int,
  @p_changeSet_Id int,
  @p_Updated_By NVARCHAR(8)
AS
	
  -- no hard delete going forward
  -- do a soft delete by changing the active flag		
  UPDATE dbo.OXO_Programme_Model 
  SET Active = 0,
      ChangeSet_Id = @p_changeSet_Id,
      Updated_By = @p_Updated_By
  WHERE Id = @p_Id;


