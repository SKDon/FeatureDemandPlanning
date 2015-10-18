
CREATE PROCEDURE [dbo].[OXO_Vehicle_GetMany]
@p_Make nvarchar(500) = NULL  
 
AS


   		
   SELECT 
    Id  AS Id,
    Name  AS Name,  
    AKA  AS AKA,  
    Make  AS Make,  
    Active  AS Active,  
    Created_By  AS Created_By,  
    Created_On  AS Created_On,  
    Updated_By  AS Updated_By,  
    Last_Updated  AS Last_Updated  
    FROM dbo.OXO_Vehicle
    WHERE 
     (Make = @p_Make OR @p_Make IS NULL)   
    
