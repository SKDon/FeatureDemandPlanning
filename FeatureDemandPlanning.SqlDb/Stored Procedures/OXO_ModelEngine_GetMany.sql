
CREATE PROCEDURE [dbo].[OXO_ModelEngine_GetMany]
    @p_prog_id INT
AS
	
   SELECT 
    Id  AS Id,
    Programme_Id  AS ProgrammeId,  
    Size  AS Size,  
    Cylinder  AS Cylinder,  
    Turbo  AS Turbo,  
    Fuel_Type  AS FuelType,  
    [Power]  AS [Power],  
	Electrification AS Electrification,
    Active  AS Active,  
    Created_By  AS CreatedBy,  
    Created_On  AS CreatedOn,  
    Updated_By  AS UpdatedBy,  
    Last_Updated  AS LastUpdated  
    FROM dbo.OXO_Programme_Engine
    WHERE (@p_prog_id = 0 OR Programme_Id = @p_prog_id)
    ORDER BY Size, Cylinder, Fuel_Type Desc, [Power] ; 
    

