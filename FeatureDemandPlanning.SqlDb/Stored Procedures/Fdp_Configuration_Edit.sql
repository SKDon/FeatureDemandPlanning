
CREATE PROCEDURE [dbo].[Fdp_Configuration_Edit] 
   @p_ConfigurationKey  nvarchar(50) 
  ,@p_Value  nvarchar(max) 
  ,@p_Description  nvarchar(max) 
  ,@p_DataType  nvarchar(50) 
      
AS

	IF NOT EXISTS(SELECT TOP 1 1 FROM Fdp_Configuration WHERE ConfigurationKey = @p_ConfigurationKey)
	BEGIN
		INSERT INTO Fdp_Configuration 
		(
			  ConfigurationKey
			, DataType
			, [Description]
			, Value
		)
		VALUES
		(
			  @p_ConfigurationKey
			, @p_DataType
			, @p_Description
			, @p_Value
		);
	END
	ELSE
	BEGIN
		UPDATE dbo.Fdp_Configuration 
		SET 
		  ConfigurationKey=@p_ConfigurationKey,  
		  Value=@p_Value,  
		  [Description]=@p_Description,  
		  DataType=@p_DataType  
  		WHERE ConfigurationKey = @p_ConfigurationKey;
	END
	
  

