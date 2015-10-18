

CREATE PROCEDURE [dbo].[OXO_Pack_New] 
   @p_doc_id INT
  ,@p_programme_id INT
  ,@p_name nvarchar(500) 
  ,@p_extra_info nvarchar(500) 
  ,@p_feature_Code nvarchar(50) 
  ,@p_Created_By  nvarchar(10) 
  ,@p_Created_On  datetime 
  ,@p_Updated_By  nvarchar(10) 
  ,@p_Last_Updated  datetime 
  ,@p_Id INT OUTPUT
AS
	
  DECLARE @_rec_count INT; 			
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
			  INSERT INTO dbo.OXO_Programme_Pack
			  (
				Programme_Id,
				Pack_Name,  
				Extra_Info,
				Feature_Code,
				Created_By,  
				Created_On,  
				Updated_By,  
				Last_Updated  
			          
			  )
			  VALUES 
			  (
				@p_programme_id,
				@p_name,
				@p_extra_info,
				@p_feature_Code,  
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
			  INSERT INTO dbo.OXO_Archived_Programme_Pack
			  (
			    Doc_Id,
				Programme_Id,
				Pack_Name,  
				Extra_Info,
				Feature_Code,
				Created_By,  
				Created_On,  
				Updated_By,  
				Last_Updated  
			          
			  )
			  VALUES 
			  (
			    @p_doc_id,
				@p_programme_id,
				@p_name,
				@p_extra_info,
				@p_feature_Code,  
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
  END

