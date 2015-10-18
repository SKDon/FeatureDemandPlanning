CREATE PROCEDURE [dbo].[OXO_Model_GetManyBlank] 
@p_make nvarchar(50),
@p_CDSID nvarchar(50) = null
AS
	
   SELECT 
    0 AS Id,
    V.Name AS VehicleName,
    V.AKA AS VehicleAKA,
    P.Model_Year AS ModelYear,
    P.Id AS ProgrammeId,  
    V.Display_Format AS DisplayFormat,    
    Name = 'Missing Derivatives Information'    
    FROM  dbo.OXO_Programme P
    INNER JOIN OXO_Vehicle V
    ON V.Id = P.Vehicle_Id
    WHERE V.make = @p_make
    AND P.OXO_Enabled = 1
    AND NOT EXISTS 
    (
       SELECT 1 
       FROM dbo.OXO_Programme_Model M 
       WHERE M.Programme_ID = P.Id
       AND M.Active = 1
    )
    AND EXISTS
    (
		-- Check Permission
		SELECT 1
		FROM dbo.OXO_Permission PM
		WHERE PM.Object_Type = 'Programme'
		AND PM.Operation IN ('CanEdit')
		AND PM.Object_Id = P.Id
		AND PM.CDSID = ISNULL(@p_cdsid, PM.CDSID)
    );

