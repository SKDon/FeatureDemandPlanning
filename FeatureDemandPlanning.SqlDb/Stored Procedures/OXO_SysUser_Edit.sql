
CREATE PROCEDURE [dbo].[OXO_SysUser_Edit] 
   @p_cdsid NVARCHAR(10), 
   @p_title NVARCHAR(50),  
   @p_first_names NVARCHAR(100), 
   @p_surname NVARCHAR(100), 
   @p_department NVARCHAR(100), 
   @p_job_title NVARCHAR(100),
   @p_senior_mgr NVARCHAR(300),
   @p_admin BIT,
   @p_registered_on DATETIME,
   @p_allowed_progs  NVARCHAR(3000),  
   @p_allowed_sections  NVARCHAR(3000),   
   @p_updated_by NVARCHAR(10),
   @p_Id INT OUTPUT
AS
	
	DECLARE @_rec_count INT; 		
	
	-- Check for duplicated entry
	SELECT @_rec_count = COUNT(*) 
	FROM dbo.OXO_System_User
	WHERE CDSID = @p_cdsid
	AND Id != @p_Id;		

	IF @_rec_count = 0 		
		BEGIN	
			
		   UPDATE dbo.OXO_SYSTEM_USER
		   SET Title=@p_title, 
			   First_Names=@p_first_names, 
			   Surname=@p_surname, 
			   Department=@p_department, 
			   Job_Title=@p_job_title,
			   Senior_Manager = @p_senior_mgr,    
			   Is_Admin = @p_admin, 
			   Registered_On=@p_registered_on, 
			   Updated_By=@p_updated_by,
			   Last_Updated = GETDATE()
		   WHERE Id = @p_Id;

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
		   FROM dbo.FN_SPLIT(@p_allowed_progs, ',')
		   
		   
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
	
	
	
	
 




