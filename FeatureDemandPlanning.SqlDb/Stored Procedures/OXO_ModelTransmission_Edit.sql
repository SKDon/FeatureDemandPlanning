
CREATE PROCEDURE [dbo].[OXO_ModelTransmission_Edit] 
   @p_Id INT OUTPUT
  ,@p_Programme_Id  int 
  ,@p_Type  nvarchar(50) 
  ,@p_Drivetrain  nvarchar(50) 
  ,@p_Active  bit 
  ,@p_Updated_By  nvarchar(8) 
  ,@p_Last_Updated  datetime 
      
AS
	
  DECLARE @_rec_count INT;	
	
  -- Check for duplicated entry
  SELECT @_rec_count = COUNT(*) 
  FROM OXO_Programme_Transmission
  WHERE Programme_Id = @p_Programme_Id
  AND Type = @p_Type
  AND Drivetrain = @p_Drivetrain
  AND ID != @p_Id;
	
  IF @_rec_count = 0 	
  BEGIN
	  UPDATE dbo.OXO_Programme_Transmission 
		SET 
	  Programme_Id=@p_Programme_Id,  
	  Type=@p_Type,  
	  Drivetrain=@p_Drivetrain,  
	  Active=@p_Active,   
	  Updated_By=@p_Updated_By,  
	  Last_Updated=@p_Last_Updated    	     
	  WHERE Id = @p_Id;
 
      SET @p_Id = @p_Id;
    
  END 
  ELSE
  BEGIN  
	 SET @p_Id = -1000;
  END 
