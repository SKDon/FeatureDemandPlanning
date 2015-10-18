
CREATE PROCEDURE [dbo].[OXO_ModelTrim_Delete] 
  @p_Id int
AS

	-- Set inactive flag instand of delete	
 -- DELETE 
 -- FROM dbo.OXO_Programme_Trim 
 -- WHERE Id = @p_Id;
  
  UPDATE dbo.OXO_Programme_Trim 
  SET Active = 0
  WHERE Id = @p_Id;



