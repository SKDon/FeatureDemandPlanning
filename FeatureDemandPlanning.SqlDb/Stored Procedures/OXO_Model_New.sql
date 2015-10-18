

CREATE  PROCEDURE [dbo].[OXO_Model_New] 
   @p_Programme_Id  int, 
   @p_Body_Id  int, 
   @p_Engine_Id  int, 
   @p_Transmission_Id  int, 
   @p_Trim_Id  int, 
   @p_BMC varchar(10),
   @p_CoA varchar(10),
   @p_KD bit,
   @p_Active  bit, 
   @p_Created_By  varchar(8), 
   @p_Created_On  datetime, 
   @p_Updated_By  varchar(8), 
   @p_Last_Updated  datetime, 
   @p_ChangeSet_Id int,
  @p_Id INT OUTPUT
AS
	
  DECLARE @_rec_count INT;
  		
  -- need to check unique		
  SELECT @_rec_count = COUNT(*) 
  FROM dbo.OXO_Programme_Model
  WHERE Programme_Id = @p_Programme_Id
  AND Body_Id = @p_Body_Id
  AND Engine_Id = @p_Engine_Id
  AND Transmission_Id = @p_Transmission_Id
  AND CoA = @p_CoA
  AND ISNULL(KD,0) = ISNULL(@p_KD,0)
  AND Trim_Id = @p_Trim_Id
  AND Active = 1;
	
	
  IF @_rec_count = 0
  BEGIN	
	  INSERT INTO dbo.OXO_Programme_Model
	  (
		Programme_Id,  
		Body_Id,  
		Engine_Id,  
		Transmission_Id,  
		Trim_Id,  
		BMC,
		CoA,
		ChangeSet_Id,
		KD,
		Active,  
		Created_By,  
		Created_On,  
		Updated_By,  
		Last_Updated  
	          
	  )
	  VALUES 
	  (
		@p_Programme_Id,  
		@p_Body_Id,  
		@p_Engine_Id,  
		@p_Transmission_Id,  
		@p_Trim_Id,  
		UPPER(@p_BMC),
		@p_CoA,
		@p_ChangeSet_Id,
		@p_KD,
		1,  
		@p_Created_By,  
		@p_Created_On,  
		@p_Updated_By,  
		@p_Last_Updated  
		  );

	  SET @p_Id = SCOPE_IDENTITY();
  END
  ELSE
  BEGIN      
      SET @p_Id = -1000;
  END

