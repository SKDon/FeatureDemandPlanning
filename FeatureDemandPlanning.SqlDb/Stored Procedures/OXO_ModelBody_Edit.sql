
CREATE PROCEDURE [dbo].[OXO_ModelBody_Edit] 
   @p_Id INT OUTPUT
  ,@p_Programme_Id  int 
  ,@p_Shape  nvarchar(50) 
  ,@p_Doors  nvarchar(50) 
  ,@p_Wheelbase  nvarchar(50) 
  ,@p_Active  bit 
  ,@p_Updated_By  nvarchar(8) 
  ,@p_Last_Updated  datetime 
      
AS
	
  DECLARE @_rec_count INT; 		
	
  -- Check for duplicated entry
  SELECT @_rec_count = COUNT(*) 
  FROM OXO_Programme_Body
  WHERE Programme_Id = @p_Programme_Id
  AND Shape = @p_Shape
  AND Doors = @p_Doors
  AND Wheelbase = @p_Wheelbase
  AND Id != @p_Id;		
	
  IF @_rec_count = 0 		
  BEGIN	
	
	  UPDATE dbo.OXO_Programme_Body 
		SET 
		  Programme_Id=@p_Programme_Id,  
		  Shape=@p_Shape,  
		  Doors=@p_Doors,  
		  Wheelbase=@p_Wheelbase,  
		  Active=@p_Active,  
		  Updated_By=@p_Updated_By,  
		  Last_Updated=@p_Last_Updated    	     
	  WHERE Id = @p_Id;
  END
  ELSE	
  BEGIN
       -- tell the caller 
	   SET @p_Id = -1000;
  END
