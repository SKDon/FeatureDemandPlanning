
CREATE PROCEDURE [dbo].[OXO_Permission_GetMany]
@p_CDSID nvarchar(50) = NULL,  
@p_Object_Type nvarchar(500) = NULL  
 
AS
	
   SELECT 
    Id  AS Id,
    CDSID  AS CDSID,  
    Object_Type  AS ObjectType,  
    [Object_Id]  AS ObjectId,  
    Object_Val  AS ObjectVal,  
    Operation  AS Operation,  
    Created_By  AS CreatedBy,  
    Created_On  AS CreatedOn,  
    Updated_By  AS UpdatedBy,  
    Last_Updated  AS LastUpdated  
    FROM dbo.OXO_Permission
    WHERE 
     (CDSID = @p_CDSID OR @p_CDSID IS NULL)  AND  
     (Object_Type = @p_Object_Type OR @p_Object_Type IS NULL)   
    

