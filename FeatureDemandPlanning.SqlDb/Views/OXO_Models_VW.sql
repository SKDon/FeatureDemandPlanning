CREATE VIEW [dbo].[OXO_Models_VW]
AS
      
   SELECT 
   	DisplayOrder = dbo.OXO_GetVariantDisplayOrder(B.Doors, B.Wheelbase, E.Size,
												  E.Fuel_Type, E.Power, T.DriveTrain,
												  TM.Display_Order),	
    V.Name AS VehicleName,
    V.AKA AS VehicleAKA,
    P.Model_Year AS ModelYear,    
    V.Display_Format AS DisplayFormat,        
    Name = dbo.OXO_GetVariantName(V.Display_Format,
                                      B.Shape,
                                      B.Doors,
                                      B.Wheelbase,
                                      E.Size,
                                      E.Fuel_Type,
                                      E.Cylinder,
                                      E.Turbo,
                                      E.Power,
                                      T.DriveTrain,
                                      T.Type,
								      TM.Name,
								      TM.Level,
								      M.KD,
								      0),       
	NameWithBR = dbo.OXO_GetVariantName(V.Display_Format,
                                      B.Shape,
                                      B.Doors,
                                      B.Wheelbase,
                                      E.Size,
                                      E.Fuel_Type,
                                      E.Cylinder,
                                      E.Turbo,
                                      E.Power,
                                      T.DriveTrain,
                                      T.Type,
								      TM.Abbreviation,
								      TM.Level,
								      M.KD,
								      1),        								      												  								      
    M.Id  AS Id,
    M.Programme_Id,  
    M.Body_Id,  
    M.Engine_Id,
    M.Transmission_Id,  
    M.Trim_Id,  
    M.Active,  
    M.Created_By,  
    M.Created_On,  
    M.Updated_By,  
    M.Last_Updated,
    M.CoA AS CoA,
    B.Shape AS Shape,
    B.Doors,
    B.Wheelbase,
	E.Size,
	E.Cylinder,
	E.Turbo,
	E.Fuel_Type,
	E.Power,
	E.Electrification,
	T.Type,
	T.Drivetrain,
	TM.Name As TrimName,
	TM.Abbreviation,
	TM.Level,
    M.BMC AS BMC,    
    TM.DPCK AS DPCK,
    V.Make,
    M.KD  
    FROM dbo.OXO_Programme_Model M
    INNER JOIN dbo.OXO_Programme_Body B
    ON M.Body_Id = B.Id
    INNER JOIN dbo.OXO_Programme_Engine E
    ON M.Engine_Id = E.Id
    INNER JOIN dbo.OXO_Programme_Transmission T
    ON M.Transmission_Id = T.Id
    INNER JOIN dbo.OXO_Programme_Trim TM
    ON M.Trim_Id = TM.Id
    INNER JOIN dbo.OXO_Programme P
    ON P.ID = M.Programme_Id 
    INNER JOIN OXO_Vehicle V
    ON V.Id = P.Vehicle_Id

