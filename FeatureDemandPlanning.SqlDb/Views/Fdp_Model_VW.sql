
CREATE VIEW [dbo].[Fdp_Model_VW]
AS
	-- Direct representation of FDP models in the same way as OXO_Models_VW
	
	-- OXO Derivative + FDP trim

	SELECT 
		  M.FdpModelId
		, M.CreatedOn
		, M.CreatedBy
		, M.ProgrammeId
		, M.Gateway
		, P.VehicleMake		AS Make
		, P.VehicleName
		, P.VehicleAKA
		, P.ModelYear
		, V.Display_Format	AS DisplayFormat
		, M.IsActive
		, M.UpdatedOn
		, M.UpdatedBy
		, dbo.OXO_GetVariantName(  V.Display_Format
                                 , B.Shape
                                 , B.Doors
                                 , B.Wheelbase
                                 , E.Size
                                 , E.Fuel_Type
                                 , E.Cylinder
                                 , E.Turbo
                                 , E.[Power]
                                 , T.DriveTrain
                                 , T.[Type]
							     , TR.TrimName
							     , TR.TrimLevel
							     , 0 
							     , 0) AS Name
		, dbo.OXO_GetVariantName(  V.Display_Format
                                 , B.Shape
                                 , B.Doors
                                 , B.Wheelbase
                                 , E.Size
                                 , E.Fuel_Type
                                 , E.Cylinder
                                 , E.Turbo
                                 , E.[Power]
                                 , T.DriveTrain
                                 , T.[Type]
							     , TR.TrimName
							     , TR.TrimLevel
							     , 0 
							     , 1) AS NameWithBR
		, OXO.BMC
		, OXO.BodyId
		, OXO.EngineId
		, OXO.TransmissionId
		, OXO.CoA
		, B.Shape
		, B.Doors
		, B.Wheelbase
		, E.Size
		, E.Cylinder
		, E.Turbo
		, E.Fuel_Type
		, E.[Power]
		, E.Electrification
		, T.[Type]
		, T.Drivetrain
		, NULL					AS TrimId
		, TR.FdpTrimId
		, TR.TrimName
		, TR.TrimAbbreviation	AS Abbreviation
		, TR.TrimLevel			AS [Level]
		, TR.DPCK
		, dbo.OXO_GetVariantDisplayOrder( B.Doors
										, B.Wheelbase
										, E.Size
										, E.Fuel_Type
										, E.[Power]
										, T.DriveTrain
										, T.[Type]
										, TL.[Level]) 
								AS DisplayOrder
		, CAST(NULL AS BIT)		AS KD
		, CAST(0 AS BIT)		AS IsFdpDerivative
		, CAST(1 AS BIT)		AS IsFdpTrim
		
	FROM 
	Fdp_Model AS M
	JOIN
	(
		SELECT 
			  Programme_Id
			, BMC
			, Body_Id			AS BodyId
			, Engine_Id			AS EngineId
			, Transmission_Id	AS TransmissionId
			, MAX(CoA)			AS CoA
		FROM 
		OXO_Programme_Model
		WHERE
		Active = 1
		GROUP BY
		  Programme_Id
		, BMC
		, Body_Id
		, Engine_Id
		, Transmission_Id
	)								AS OXO	ON M.DerivativeCode		= OXO.BMC
											AND M.ProgrammeId		= OXO.Programme_Id
	JOIN OXO_Programme_Body			AS B	ON OXO.BodyId			= B.Id
	JOIN OXO_Programme_Engine		AS E	ON OXO.EngineId			= E.Id
	JOIN OXO_Programme_Transmission AS T	ON OXO.TransmissionId	= T.Id
	JOIN Fdp_Trim					AS TR	ON M.FdpTrimId			= TR.FdpTrimId
	JOIN OXO_Programme_VW			AS P	ON M.ProgrammeId		= P.Id
	JOIN OXO_Vehicle				AS V	ON P.VehicleId			= V.Id
	JOIN Fdp_TrimLevels				AS TL	ON TR.FdpTrimId			= TL.FdpTrimId
	
	-- FDP Derivative + OXO trim
	
	UNION
	
	SELECT 
		  M.FdpModelId
		, M.CreatedOn
		, M.CreatedBy
		, M.ProgrammeId
		, M.Gateway
		, P.VehicleMake		AS Make
		, P.VehicleName
		, P.VehicleAKA
		, P.ModelYear
		, V.Display_Format	AS DisplayFormat
		, M.IsActive
		, M.UpdatedOn
		, M.UpdatedBy
		, dbo.OXO_GetVariantName(  V.Display_Format
                                 , B.Shape
                                 , B.Doors
                                 , B.Wheelbase
                                 , E.Size
                                 , E.Fuel_Type
                                 , E.Cylinder
                                 , E.Turbo
                                 , E.[Power]
                                 , T.DriveTrain
                                 , T.[Type]
							     , TR.Name
							     , TR.[Level]
							     , 0 
							     , 0) AS Name
		, dbo.OXO_GetVariantName(  V.Display_Format
                                 , B.Shape
                                 , B.Doors
                                 , B.Wheelbase
                                 , E.Size
                                 , E.Fuel_Type
                                 , E.Cylinder
                                 , E.Turbo
                                 , E.[Power]
                                 , T.DriveTrain
                                 , T.[Type]
							     , TR.Name
							     , TR.[Level]
							     , 0 
							     , 1) AS NameWithBR
		, D.DerivativeCode		AS BMC
		, D.BodyId
		, D.EngineId
		, D.TransmissionId
		, NULL					AS CoA
		, B.Shape
		, B.Doors
		, B.Wheelbase
		, E.Size
		, E.Cylinder
		, E.Turbo
		, E.Fuel_Type
		, E.[Power]
		, E.Electrification
		, T.[Type]
		, T.Drivetrain
		, TR.Id					AS TrimId
		, NULL					AS FdpTrimId
		, TR.Name				AS TrimName
		, TR.Abbreviation
		, TR.[Level]
		, TR.DPCK
		, dbo.OXO_GetVariantDisplayOrder( B.Doors
										, B.Wheelbase
										, E.Size
										, E.Fuel_Type
										, E.[Power]
										, T.DriveTrain
										, T.[Type]
										, TL.[Level])
								AS DisplayOrder 
		, CAST(NULL AS BIT)		AS KD
		, CAST(1 AS BIT)		AS IsFdpDerivative
		, CAST(0 AS BIT)		AS IsFdpTrim
		
	FROM Fdp_Model					AS M
	JOIN Fdp_Derivative				AS D	ON M.FdpDerivativeId	= D.FdpDerivativeId
	JOIN OXO_Programme_Body			AS B	ON D.BodyId				= B.Id
	JOIN OXO_Programme_Engine		AS E	ON D.EngineId			= E.Id
	JOIN OXO_Programme_Transmission AS T	ON D.TransmissionId		= T.Id
	JOIN OXO_Programme_Trim			AS TR	ON M.TrimId				= TR.Id
	JOIN OXO_Programme_VW			AS P	ON M.ProgrammeId		= P.Id
	JOIN OXO_Vehicle				AS V	ON P.VehicleId			= V.Id
	JOIN Fdp_TrimLevels				AS TL	ON M.TrimId				= TL.TrimId
	
	-- FDP Derivative + FDP Trim
	
	UNION
	
	SELECT
		  M.FdpModelId
		, M.CreatedOn
		, M.CreatedBy
		, M.ProgrammeId
		, M.Gateway
		, P.VehicleMake		AS Make
		, P.VehicleName
		, P.VehicleAKA
		, P.ModelYear
		, V.Display_Format	AS DisplayFormat
		, M.IsActive
		, M.UpdatedOn
		, M.UpdatedBy
		, dbo.OXO_GetVariantName(  V.Display_Format
                                 , B.Shape
                                 , B.Doors
                                 , B.Wheelbase
                                 , E.Size
                                 , E.Fuel_Type
                                 , E.Cylinder
                                 , E.Turbo
                                 , E.[Power]
                                 , T.DriveTrain
                                 , T.[Type]
							     , TR.TrimName
							     , TR.TrimLevel
							     , 0 
							     , 0) AS Name
		, dbo.OXO_GetVariantName(  V.Display_Format
                                 , B.Shape
                                 , B.Doors
                                 , B.Wheelbase
                                 , E.Size
                                 , E.Fuel_Type
                                 , E.Cylinder
                                 , E.Turbo
                                 , E.[Power]
                                 , T.DriveTrain
                                 , T.[Type]
							     , TR.TrimName
							     , TR.TrimLevel
							     , 0 
							     , 1) AS NameWithBR
		, D.DerivativeCode		AS BMC
		, D.BodyId
		, D.EngineId
		, D.TransmissionId
		, NULL					AS CoA
		, B.Shape
		, B.Doors
		, B.Wheelbase
		, E.Size
		, E.Cylinder
		, E.Turbo
		, E.Fuel_Type
		, E.[Power]
		, E.Electrification
		, T.[Type]
		, T.Drivetrain
		, NULL					AS TrimId
		, TR.FdpTrimId			AS FdpTrimId
		, TR.TrimName
		, TR.TrimAbbreviation	AS Abbreviation
		, TR.TrimLevel			AS [Level]
		, TR.DPCK
		, dbo.OXO_GetVariantDisplayOrder( B.Doors
										, B.Wheelbase
										, E.Size
										, E.Fuel_Type
										, E.[Power]
										, T.DriveTrain
										, T.[Type]
										, TL.[Level])
								AS DisplayOrder 
		, CAST(NULL AS BIT)		AS KD
		, CAST(1 AS BIT)		AS IsFdpDerivative
		, CAST(1 AS BIT)		AS IsFdpTrim
		
	FROM Fdp_Model					AS M
	JOIN Fdp_Derivative				AS D	ON M.FdpDerivativeId	= D.FdpDerivativeId
	JOIN OXO_Programme_Body			AS B	ON D.BodyId				= B.Id
	JOIN OXO_Programme_Engine		AS E	ON D.EngineId			= E.Id
	JOIN OXO_Programme_Transmission AS T	ON D.TransmissionId		= T.Id
	JOIN Fdp_Trim					AS TR	ON M.FdpTrimId			= TR.FdpTrimId
	JOIN OXO_Programme_VW			AS P	ON M.ProgrammeId		= P.Id
	JOIN OXO_Vehicle				AS V	ON P.VehicleId			= V.Id
	JOIN Fdp_TrimLevels				AS TL	ON M.FdpTrimId			= TL.FdpTrimId