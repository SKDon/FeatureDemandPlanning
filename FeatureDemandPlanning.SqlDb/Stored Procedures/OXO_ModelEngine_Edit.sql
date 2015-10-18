
CREATE PROCEDURE [dbo].[OXO_ModelEngine_Edit] 
   @p_Id INT OUTPUT
  ,@p_Programme_Id  int 
  ,@p_Size  nvarchar(50) 
  ,@p_Cylinder  nvarchar(50) 
  ,@p_Turbo  nvarchar(50) 
  ,@p_Fuel_Type  nvarchar(50) 
  ,@p_Power  nvarchar(50) 
--  ,@p_Electrification nvarchar(50) 
  ,@p_Active  bit 
  ,@p_Updated_By  nvarchar(8) 
  ,@p_Last_Updated  datetime 
      
AS
	
  DECLARE @_rec_count INT; 	
   	
  SELECT @_rec_count = COUNT(*) 
  FROM OXO_Programme_Engine
  WHERE Programme_Id = @p_Programme_Id
  AND Size = @p_Size
  AND Cylinder = @p_Cylinder
  AND Turbo = @p_Turbo
  AND Fuel_Type = @p_Fuel_Type
  AND Power = @p_Power
 -- AND Electrification = @p_Electrification
  AND Id != @p_Id;
  			
  IF @_rec_count = 0 		
  BEGIN		
	  UPDATE dbo.OXO_Programme_Engine 
		SET 
		  Programme_Id=@p_Programme_Id,  
		  Size=@p_Size,  
		  Cylinder=@p_Cylinder,  
		  Turbo=@p_Turbo,  
		  Fuel_Type=@p_Fuel_Type,  
		  Power=@p_Power,  
--		  Electrification = @p_Electrification,
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
