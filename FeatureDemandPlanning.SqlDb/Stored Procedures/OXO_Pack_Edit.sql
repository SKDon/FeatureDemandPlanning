

CREATE PROCEDURE [dbo].[OXO_Pack_Edit] 
   @p_doc_id INT
  ,@p_programme_id INT
  ,@p_name nvarchar(500) 
  ,@p_extra_info nvarchar(500) 
  ,@p_feature_code nvarchar(50) 
  ,@p_Updated_By  nvarchar(10) 
  ,@p_Last_Updated  datetime
  ,@p_Id INT OUTPUT 
      
AS
	
  DECLARE @_rec_count INT 
  DECLARE @p_archived BIT;
  	
  SELECT @p_archived = Archived 
  FROM OXO_Doc 
  WHERE Id = @p_doc_id	
  AND Programme_Id = @p_programme_id;	
  
  IF ISNULL(@p_archived, 0) = 0
  BEGIN
	  -- Check for duplicated entry
	  SELECT @_rec_count = COUNT(*) 
	  FROM OXO_Programme_Pack 
	  WHERE Programme_Id = @p_Programme_Id
	  AND Pack_Name = @p_Name
	  AND Id != @p_Id;
	  	
	  IF @_rec_count = 0
		  BEGIN 		
			  UPDATE dbo.OXO_Programme_Pack 
				SET 
				  Programme_Id = @p_programme_id,    
				  Pack_Name = @p_name,  
				  Extra_Info = @p_extra_info,  
				  Feature_Code = @p_feature_code,
				  Updated_By=@p_Updated_By,  
				  Last_Updated=@p_Last_Updated  	  	     
			  WHERE ID = @p_Id;
		  END
	  ELSE
		  BEGIN
			   -- tell the caller 
			   SET @p_Id = -1000;
		  END
  END
  ELSE
  BEGIN
	  -- Check for duplicated entry
	  SELECT @_rec_count = COUNT(*) 
	  FROM OXO_Archived_Programme_Pack 
	  WHERE Programme_Id = @p_Programme_Id
	  AND Pack_Name = @p_Name
	  AND Doc_Id = @p_doc_id
	  AND Id != @p_Id;
	  	
	  IF @_rec_count = 0
		  BEGIN 		
			  UPDATE dbo.OXO_Archived_Programme_Pack 
				SET 
				  Doc_Id = @p_doc_id,
				  Programme_Id = @p_programme_id,    
				  Pack_Name = @p_name,  
				  Extra_Info = @p_extra_info,  
				  Feature_Code = @p_feature_code,
				  Updated_By=@p_Updated_By,  
				  Last_Updated=@p_Last_Updated  	  	     
			  WHERE ID = @p_Id;
		  END
	  ELSE
		  BEGIN
			   -- tell the caller 
			   SET @p_Id = -1000;
		  END
  END

