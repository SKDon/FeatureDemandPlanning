CREATE PROCEDURE [dbo].[OXO_ModelTrim_Edit] 
   @p_Id INT OUTPUT
  ,@p_Programme_Id  int 
  ,@p_Name  nvarchar(500) 
  ,@p_Abbreviation nvarchar(50)
  ,@p_Level  nvarchar(500) 
  ,@p_DPCK  nvarchar(100) 
  ,@p_Active  bit 
  ,@p_Updated_By  varchar(8) 
  ,@p_Last_Updated  datetime 
      
AS

  DECLARE @_rec_count INT 
  
  -- Check for duplicated entry
  SELECT @_rec_count = COUNT(*) 
  FROM OXO_Programme_Trim
  WHERE Programme_Id = @p_Programme_Id
  AND (Name = @p_Name)
  AND ISNULL(Active, 0) = 1
  AND Id != @p_Id;
	
  IF @_rec_count = 0
  BEGIN 	
	  UPDATE dbo.OXO_Programme_Trim 
		SET 
		  Programme_Id=@p_Programme_Id,  
		  Name=@p_Name,  
		  Abbreviation = @p_Abbreviation,
		  Level=@p_Level,  
		  DPCK=@p_DPCK,
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

