


CREATE VIEW [dbo].[Fdp_PowertrainDataItem_VW]
AS

	SELECT
		  P.FdpPowertrainDataItemId
		, P.CreatedOn
		, P.CreatedBy
		, H.FdpVolumeHeaderId
		, H.DocumentId
		, H.Gateway
		, P.MarketId
		, ISNULL(O.DerivativeCode, F.DerivativeCode) AS DerivativeCode
		, ISNULL(O.EngineId, F.EngineId) AS EngineId
		, ISNULL(E1.Size, E2.Size) AS Size
		, ISNULL(E1.Turbo, E2.Turbo) AS Turbo
		, ISNULL(E1.Cylinder, E2.Cylinder) AS Cylinder
		, ISNULL(E1.Electrification, E2.Electrification) AS Electrification
		, ISNULL(E1.Fuel_Type, E2.Fuel_Type) AS FuelType
		, ISNULL(E1.[Power], E2.[Power]) AS [Power]
		, ISNULL(O.BodyId, F.BodyId) AS BodyId
		, ISNULL(B1.Shape, B2.Shape) AS Shape
		, ISNULL(B1.Wheelbase, B2.Wheelbase) AS Wheelbase
		, ISNULL(B1.Doors, B2.Doors) AS Doors
		, ISNULL(O.TransmissionId, F.TransmissionId) AS TransmissionId
		, ISNULL(T1.Drivetrain, T2.Drivetrain) AS Drivetrain
		, ISNULL(T1.[Type], T2.[Type]) AS [Type]
		, P.Volume
		, P.PercentageTakeRate
		, P.UpdatedOn
		, P.UpdatedBy
	FROM
	Fdp_VolumeHeader_VW				AS H
	JOIN Fdp_PowertrainDataItem		AS P	ON	H.FdpVolumeHeaderId		= P.FdpVolumeHeaderId
	LEFT JOIN Fdp_OxoDerivative		AS O	ON	P.FdoOxoDerivativeId	= O.FdpOxoDerivativeId
	LEFT JOIN Fdp_Derivative		AS F	ON	P.FdpDerivativeId		= F.FdpDerivativeId
	
	-- OXO Derivatives
	LEFT JOIN OXO_Programme_Body			AS B1	ON	O.BodyId			= B1.Id
	LEFT JOIN OXO_Programme_Engine			AS E1	ON	O.EngineId			= E1.Id
	LEFT JOIN OXO_Programme_Transmission	AS T1	ON	O.TransmissionId	= T1.Id
	
	-- FDP Derivatives
	LEFT JOIN OXO_Programme_Body			AS B2	ON	F.BodyId			= B2.Id
	LEFT JOIN OXO_Programme_Engine			AS E2	ON	F.EngineId			= E2.Id
	LEFT JOIN OXO_Programme_Transmission	AS T2	ON	F.TransmissionId	= T2.Id