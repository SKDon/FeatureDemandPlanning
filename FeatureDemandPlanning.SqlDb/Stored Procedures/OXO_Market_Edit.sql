CREATE PROCEDURE [dbo].[OXO_Market_Edit] 
   @p_Name  varchar(500) 
  ,@p_WHD  varchar(500) 
  ,@p_PAR_X  varchar(500) 
  ,@p_PAR_L  varchar(500) 
  ,@p_Territory  varchar(500) 
  ,@p_Active  bit 
  ,@p_Created_By  varchar(8) 
  ,@p_Created_On  datetime 
  ,@p_Updated_By  varchar(8) 
  ,@p_Last_Updated  datetime 
  ,@p_Id INT OUTPUT     
AS

  DECLARE @_rec_count INT;
  		
  -- need to check unique	
  SELECT @_rec_count = COUNT(*) 
  FROM dbo.OXO_Master_Market
  WHERE Name = @p_Name
  AND Id != @p_Id;
	
  IF @_rec_count = 0 
  BEGIN	
	  UPDATE dbo.OXO_Master_Market
		SET 
	  Name=@p_Name,  
	  WHD = @p_WHD,
	  PAR_X=@p_PAR_X,  
	  PAR_L=@p_PAR_L,  
	  Territory=@p_Territory,  
	  Active=@p_Active,   
	  Updated_By=@p_Updated_By,  
	  Last_Updated=@p_Last_Updated  	  	     
	   WHERE Id = @p_Id;
   END
   ELSE
   BEGIN
	  SET @p_Id = -1000;
   END

