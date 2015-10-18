
CREATE  PROCEDURE [dbo].[OXO_ModelTransmission_New] 
   @p_Programme_Id  int, 
   @p_Type  nvarchar(50), 
   @p_Drivetrain  nvarchar(50), 
   @p_Active  bit, 
   @p_Created_By  nvarchar(8), 
   @p_Created_On  datetime, 
   @p_Updated_By  varchar(8), 
   @p_Last_Updated  datetime, 
  @p_Id INT OUTPUT
AS
	
  DECLARE @_rec_count INT;	
	
  -- Check for duplicated entry
  SELECT @_rec_count = COUNT(*) 
  FROM OXO_Programme_Transmission
  WHERE Programme_Id = @p_Programme_Id
  AND Type = @p_Type
  AND Drivetrain = @p_Drivetrain;
  	
  IF @_rec_count = 0 		
  BEGIN
	  
	  INSERT INTO dbo.OXO_Programme_Transmission
	  (
		Programme_Id,  
		Type,  
		Drivetrain,  
		Active,  
		Created_By,  
		Created_On,
		Updated_By,  
		Last_Updated  
	          
	  )
	  VALUES 
	  (
		@p_Programme_Id,  
		@p_Type,  
		@p_Drivetrain,  
		@p_Active,  
		@p_Created_By,  
		@p_Created_On,
		@p_Updated_By,  
		@p_Last_Updated  
		  );

		SET @p_Id = SCOPE_IDENTITY();
	
  END
  ELSE
  BEGIN
       -- tell the caller 
	   SET @p_Id = -1000;
  END

