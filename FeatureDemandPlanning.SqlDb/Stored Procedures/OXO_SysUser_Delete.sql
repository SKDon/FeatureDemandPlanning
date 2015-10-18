CREATE  PROCEDURE [dbo].[OXO_SysUser_Delete] 
  @p_id INT
AS

  DECLARE @_cdsid NVARCHAR(50)	
 
  SELECT Top 1 @_cdsid = CDSID 
  FROM dbo.OXO_System_User
  WHERE Id = @p_id;

  DELETE 
  FROM OXO_Permission
  WHERE CDSID = @_cdsid;
  	  	
  DELETE
  FROM dbo.OXO_System_User
  WHERE ID = @p_id;

	

