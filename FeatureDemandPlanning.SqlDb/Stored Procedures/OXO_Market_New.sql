
CREATE  PROCEDURE [dbo].[OXO_Market_New] 
   @p_Name  varchar(500), 
   @p_WHD varchar(500),
   @p_PAR_X  varchar(500), 
   @p_PAR_L  varchar(500), 
   @p_Territory  varchar(500), 
   @p_Active  bit, 
   @p_Created_By  varchar(8), 
   @p_Created_On  datetime, 
   @p_Updated_By  varchar(8), 
   @p_Last_Updated  datetime, 
  @p_Id INT OUTPUT
AS

  DECLARE @_rec_count INT;
  		
  -- need to check unique	
  SELECT @_rec_count = COUNT(*) 
  FROM dbo.OXO_Master_Market
  WHERE Name = @p_Name;
  
 IF @_rec_count = 0
 BEGIN 	   	
	  INSERT INTO dbo.OXO_Master_Market
	  (
		Name,  
		WHD,
		PAR_X,  
		PAR_L,  
		Territory,  
		Active,  
		Created_By,  
		Created_On,  
		Updated_By,  
		Last_Updated  
	          
	  )
	  VALUES 
	  (
		@p_Name,  
		@p_WHD,
		@p_PAR_X,  
		@p_PAR_L,  
		@p_Territory,  
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
	   SET @p_Id = -1000;
   END

