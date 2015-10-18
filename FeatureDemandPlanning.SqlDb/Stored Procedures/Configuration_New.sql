
CREATE  PROCEDURE [dbo].[Configuration_New] 
   @p_ConfigurationKey  nvarchar(50) OUTPUT, 
   @p_Value  nvarchar(max), 
   @p_Description  nvarchar(max), 
   @p_DataType  nvarchar(50)
AS
	
  INSERT INTO dbo.Fdp_Configuration
  (
    ConfigurationKey,  
    Value,  
    Description,  
    DataType  
          
  )
  VALUES 
  (
    @p_ConfigurationKey,  
    @p_Value,  
    @p_Description,  
    @p_DataType  
      );

