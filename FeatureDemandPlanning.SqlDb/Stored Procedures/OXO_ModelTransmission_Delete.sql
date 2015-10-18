
CREATE PROCEDURE [dbo].[OXO_ModelTransmission_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Programme_Transmission 
  WHERE Id = @p_Id;



