
CREATE PROCEDURE [dbo].[Configuration_Get] 
  @p_ConfigurationKey nvarchar(100)
AS
	
	SELECT 
      ConfigurationKey  AS ConfigurationKey,  
      Value  AS Value,  
      Description  AS Description,  
      DataType  AS DataType  
      	     
    FROM dbo.Fdp_Configuration
	WHERE ConfigurationKey = @p_ConfigurationKey;



