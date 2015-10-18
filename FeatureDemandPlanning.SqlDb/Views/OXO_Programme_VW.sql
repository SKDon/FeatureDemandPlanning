CREATE VIEW [OXO_Programme_VW]
AS

    SELECT 
		O.Id  AS Id,
		V.ID AS VehicleId,
		V.Name AS VehicleName,  
		V.AKA AS VehicleAKA,
		V.Display_Format AS VehicleDisplayFormat,
		O.Model_Year AS ModelYear,
		ISNULL(R.PS, '') AS PS,
		ISNULL(R.J1, '') AS J1,
		ISNULL(Notes, '')  AS Notes,  
		ISNULL(Product_Manager, '')  AS ProductManager,  
		ISNULL(RSG_UID, '')  AS RSGUID,  
		V.Make AS VehicleMake,
		ISNULL(O.OXO_Enabled, 0) AS OXOEnabled,
		ISNULL(O.Use_OA_Code,0) AS UseOACode,
		O.Active  AS Active,  
		O.Created_By  AS CreatedBy,  
		O.Created_On  AS CreatedOn,  
		O.Updated_By  AS UpdatedBy,  
		O.Last_Updated  AS LastUpdated  
    FROM dbo.OXO_Vehicle V
    INNER JOIN dbo.OXO_Programme O
    ON V.Id = O.Vehicle_Id
    LEFT OUTER JOIN dbo.RSG R
    ON O.RSG_UID = R.UID;

