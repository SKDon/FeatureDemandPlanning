
CREATE  PROCEDURE [dbo].[OXO_ModelBody_New] 
   @p_Programme_Id  int, 
   @p_Shape  nvarchar(50), 
   @p_Doors  nvarchar(50), 
   @p_Wheelbase  nvarchar(50), 
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
  FROM OXO_Programme_Body
  WHERE Programme_Id = @p_Programme_Id
  AND Shape = @p_Shape
  AND Doors = @p_Doors
  AND Wheelbase = @p_Wheelbase;	
	    	
  IF @_rec_count = 0 		
  BEGIN		
	  INSERT INTO dbo.OXO_Programme_Body
	  (
		Programme_Id,  
		Shape,  
		Doors,  
		Wheelbase,  
		Active,  
		Created_By,  
		Created_On,
	    Updated_By,  
		Last_Updated        
	  )
	  VALUES 
	  (
		@p_Programme_Id,  
		@p_Shape,  
		@p_Doors,  
		@p_Wheelbase,  
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

