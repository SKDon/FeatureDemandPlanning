

CREATE PROCEDURE [dbo].[OXO_SysUser_New] 
   @p_cdsid NVARCHAR(10), 
   @p_title NVARCHAR(50),  
   @p_first_names NVARCHAR(100), 
   @p_surname NVARCHAR(100), 
   @p_department NVARCHAR(100), 
   @p_job_title NVARCHAR(100),
   @p_senior_mgr   NVARCHAR(300),        
   @p_allowed_progs  NVARCHAR(3000),    
   @p_allowed_sections  NVARCHAR(3000),    
   @p_admin BIT,    
   @p_created_by NVARCHAR(10),
   @p_Id INT OUTPUT
AS
	  
  DECLARE @_rec_count INT; 		
	
  -- Check for duplicated entry
  SELECT @_rec_count = COUNT(*) 
  FROM dbo.OXO_System_User
  WHERE CDSID = @p_cdsid;
	
  IF @_rec_count = 0 	   
	  BEGIN
		INSERT INTO dbo.OXO_System_User
			(CDSID, Title, First_Names, Surname, Department, Job_Title, 
				Senior_Manager, Is_Admin, Registered_On, Created_By)
		VALUES (@p_cdsid,  @p_title, @p_first_names, @p_surname, @p_department, @p_job_title, 
				@p_senior_mgr, @p_admin, GetDate(), @p_created_by);
	   
	    -- Clear all Programme Permission
	    DELETE FROM OXO_Permission 
	    WHERE CDSID = @p_cdsid
	    AND Object_Type = 'Programme';
	 
	    INSERT INTO OXO_Permission (CDSID, Object_Type, Object_Id, Operation, Created_By, Created_On)
	    SELECT @p_cdsid, 
			  'Programme', 
			  CAST(Replace(strval, '*', '') AS int),
			  CASE WHEN CHARINDEX('*',strval) > 0 THEN 'CanEdit'
			  ELSE 'CanView' END,
			  'System',
			  GETDATE()		   	    
	    FROM dbo.FN_SPLIT(@p_allowed_progs, ',');
	    
	    -- Clear all Adm-Section Permission
	    DELETE FROM OXO_Permission 
	    WHERE CDSID = @p_cdsid
	    AND Object_Type like 'Adm-%';
	 
	    INSERT INTO OXO_Permission (CDSID, Object_Type, Object_Id, Operation, Created_By, Created_On)
	    SELECT @p_cdsid, 
			  Replace(Code, '*', ''), 
			  0,
			  CASE WHEN CHARINDEX('*',Code) > 0 THEN 'CanEdit'
			  ELSE 'CanView' END,
			  'System',
			  GETDATE()		   	    
	    FROM dbo.FN_CsvIN(@p_allowed_sections)
	    WHERE LEN(Code) > 0;
	    
	    
	    
	  END
  ELSE 	 
	  BEGIN
		   -- tell the caller 
		   SET @p_Id = -1000;
	  END

