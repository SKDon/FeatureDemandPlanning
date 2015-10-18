
CREATE  PROCEDURE [dbo].[OXO_ModelEngine_New] 
   @p_Programme_Id  int, 
   @p_Size  nvarchar(50), 
   @p_Cylinder  nvarchar(50), 
   @p_Turbo  nvarchar(50), 
   @p_Fuel_Type  nvarchar(50), 
   @p_Power  nvarchar(50), 
 --  @p_Electrification nvarchar(50),
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
  FROM OXO_Programme_Engine
  WHERE Programme_Id = @p_Programme_Id
  AND Size = @p_Size
  AND Cylinder = @p_Cylinder
  AND Turbo = @p_Turbo
  AND Fuel_Type = @p_Fuel_Type
  AND Power = @p_Power;
-- AND Electrification = @p_Electrification;		 
  		
    	
  IF @_rec_count = 0 		
  BEGIN		
	  INSERT INTO dbo.OXO_Programme_Engine
	  (
		Programme_Id,  
		Size,  
		Cylinder,  
		Turbo,  
		Fuel_Type,  
		Power,  
--		Electrification,		   
		Active,  
		Created_By,  
		Created_On,
		Updated_By,  
		Last_Updated         
	  )
	  VALUES 
	  (
		@p_Programme_Id,  
		@p_Size,  
		@p_Cylinder,  
		@p_Turbo,  
		@p_Fuel_Type,  
		@p_Power,  
--		@p_Electrification,  
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

