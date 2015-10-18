
CREATE   PROCEDURE [dbo].[OXO_SysUser_GetByCDSID] 
  @p_cdsid nvarchar(10)
AS

	SELECT  
		OU.Id AS Id,
		OU.CDSID AS CDSID,	          
		OU.Title AS Title,
		OU.First_names AS FirstNames,
		OU.Surname AS Surname,
		OU.Department AS Department,
		RE.Description AS DepartmentText,
		OU.Job_Title AS JobTitle,
		OU.Senior_Manager AS SeniorManager,
		OU.Registered_On AS RegisteredOn,
		OU.Is_Admin AS IsAdmin,	
		OU.Created_By AS CreatedBy,
		OU.Created_On AS CreatedOn,
		OU.Updated_By AS UpdatedBy,
		OU.Last_Updated AS LastUpdated,
		dbo.OXO_GetPermission(OU.CDSID) AS AllowedProgrammeString   
	FROM  OXO_System_User OU
	LEFT OUTER JOIN OXO_Reference_List RE
	ON OU.Department = RE.Code
	AND RE.List_Name = 'Department'
	WHERE OU.CDSID = @p_cdsid;



