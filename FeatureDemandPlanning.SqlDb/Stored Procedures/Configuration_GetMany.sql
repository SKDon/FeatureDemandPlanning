
CREATE PROCEDURE [dbo].[Configuration_GetMany]
 
AS
	
   SELECT 
    ConfigurationKey  AS ConfigurationKey,  
    Value  AS Value,  
    Description  AS Description,  
    DataType  AS DataType  
    FROM dbo.Fdp_Configuration
    ; 
    

