
CREATE PROCEDURE [dbo].[OXO_SysUser_GetProgrammes] 
  @p_CDSID nvarchar(100),
  @p_allowed  BIT
AS	

	
  IF @p_allowed = 1   
	  SELECT 
			V.Id  AS Id,
			V.VehicleMake,
			V.VehicleName,  
			V.VehicleAKA,
			V.ModelYear,		
			CASE WHEN P.Operation = 'CanEdit' THEN 1
			ELSE 0 END CanEdit  
	 FROM OXO_Permission P
	 INNER JOIN OXO_Programme_VW V
	 ON P.Object_Id = V.Id
	 WHERE CDSID = @p_CDSID
	 AND Object_Type = 'Programme'
	 AND V.OXOEnabled = 1
	 ORDER BY V.VehicleName, V.ModelYear;  
 ELSE
	 SELECT 
			V.Id  AS Id,
			V.VehicleMake,
			V.VehicleName,  
			V.VehicleAKA,
			V.ModelYear,		
			CASE WHEN P.Operation = 'CanEdit' THEN 1
			ELSE 0 END CanEdit  
	 FROM OXO_Programme_VW V 
	 LEFT OUTER JOIN OXO_Permission P
	 ON V.Id = P.Object_Id 
	 AND Object_Type = 'Programme' 
	 AND P.CDSID = @p_CDSID
	 WHERE P.Object_Id  IS NULL
	 AND V.OXOEnabled = 1
	 ORDER BY V.VehicleName, V.ModelYear;  





