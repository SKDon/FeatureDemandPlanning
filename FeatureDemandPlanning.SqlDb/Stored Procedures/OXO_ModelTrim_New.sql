


CREATE PROCEDURE [OXO_ModelTrim_New] 
   @p_Programme_Id  int, 
   @p_Name  nvarchar(500), 
   @p_Abbreviation nvarchar(50),  
   @p_Level  nvarchar(50), 
   @p_DPCK nvarchar(50),
   @p_Active  bit, 
   @p_Created_By  nvarchar(8), 
   @p_Created_On  datetime,
   @p_Updated_By  varchar(8), 
   @p_Last_Updated  datetime, 
   @p_Id INT OUTPUT
AS
  
  SET NOCOUNT ON	
	
  DECLARE @_rec_count INT;
   	
  -- Check for duplicated entry
  SELECT @_rec_count = COUNT(*) 
  FROM OXO_Programme_Trim
  WHERE Programme_Id = @p_Programme_Id
  AND ISNULL(Active, 0) = 1
  AND (Name = @p_Name);	
	
  IF @_rec_count = 0 		
  BEGIN	
	  INSERT INTO dbo.OXO_Programme_Trim
	  (
		Programme_Id,  
		Name,  
		Abbreviation,
		Level,  
		DPCK,
		Active,  
		Created_By,  
		Created_On,
		Updated_By,  
		Last_Updated            
	  )
	  VALUES 
	  (
		@p_Programme_Id,  
		@p_Name,  
		@p_Abbreviation,
		@p_Level,  
		@p_DPCK,
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
       -- tell the caller 
	   SET @p_Id = -1000;
  END

