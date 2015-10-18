


CREATE  PROCEDURE [dbo].[OXO_Model_Edit] 
  @p_Id INT OUTPUT
  ,@p_Programme_Id  int 
  ,@p_Body_Id  int 
  ,@p_Engine_Id  int 
  ,@p_Transmission_Id  int 
  ,@p_Trim_Id  int 
  ,@p_BMC varchar(10)
  ,@p_CoA varchar(10)
  ,@p_KD bit
  ,@p_Active  bit 
  ,@p_ChangeSet_Id int
  ,@p_Updated_By  varchar(8) 
  ,@p_Last_Updated  datetime 
      
AS
	
  DECLARE @_rec_count INT;
  		
  -- need to check unique	 
  SELECT @_rec_count = COUNT(*) 
  FROM dbo.OXO_Programme_Model
  WHERE Programme_Id = @p_Programme_Id
  AND Body_Id = @p_Body_Id
  AND Engine_Id = @p_Engine_Id
  AND Transmission_Id = @p_Transmission_Id
  AND Trim_Id = @p_Trim_Id
  AND CoA = @p_CoA
  AND ISNULL(KD, 0) = ISNULL(@p_KD,0)
  AND Active = @p_Active
  AND Id != @p_Id
  
 	
  IF @_rec_count = 0 
  BEGIN	
	  UPDATE dbo.OXO_Programme_Model 
		SET 
		  Programme_Id=@p_Programme_Id,  
		  Body_Id=@p_Body_Id,  
		  Engine_Id=@p_Engine_Id,  
		  Transmission_Id=@p_Transmission_Id,  
		  Trim_Id=@p_Trim_Id, 
		  BMC=UPPER(@p_BMC),
		  CoA=@p_CoA,
		  KD=@p_KD,
		  Active=@p_Active,  
		  ChangeSet_Id = @p_ChangeSet_Id,
		  Updated_By=@p_Updated_By,  
		  Last_Updated=@p_Last_Updated  	  	     
	   WHERE Id = @p_Id;
   END 
   ELSE
   BEGIN	
       SET @p_Id = -1000;
   END

