
CREATE VIEW [dbo].[Fdp_AllDerivativesByMarket_VW] 
AS
	SELECT
		  D.FdpVolumeHeaderId
		, D.MarketId
		, D.DerivativeCode
		, D.FdpOxoDerivativeId
		, D.FdpDerivativeId
		, D.BodyId
		, D.EngineId
		, D.TransmissionId
		, B.Shape
		, B.Doors
		, B.Wheelbase
		, E.Size
		, E.Cylinder
		, E.Turbo
		, E.Fuel_Type AS FuelType
		, E.[Power]
		, E.Electrification
		, T.[Type]
		, T.Drivetrain
	FROM
	(
	-- OXO Coded Derivatives
	SELECT 
		  H.FdpVolumeHeaderId
		, O.Market_Id			AS MarketId
		, D.DerivativeCode
		, D.FdpOxoDerivativeId
		, CAST(NULL AS INT) AS FdpDerivativeId
		, D.BodyId
		, D.EngineId
		, D.TransmissionId
	FROM
	Fdp_VolumeHeader_VW				AS H
	JOIN OXO_Item_Data_MBM			AS O	ON H.DocumentId			= O.OXO_Doc_Id
	JOIN OXO_Programme_Model		AS M	ON O.Model_Id			= M.Id
	JOIN Fdp_OxoDerivative			AS D	ON M.BMC				= D.DerivativeCode

	GROUP BY
	  H.FdpVolumeHeaderId
	, O.Market_Id
	, D.DerivativeCode
	, D.FdpOxoDerivativeId
	, D.BodyId
	, D.EngineId
	, D.TransmissionId

	UNION

	-- Other derivatives where we may have take rate information
	SELECT
	      H.FdpVolumeHeaderId
		, S.MarketId
		, D.DerivativeCode
		, D.FdpOxoDerivativeId
		, CAST(NULL AS INT) AS FdpDerivativeId
		, D.BodyId
		, D.EngineId
		, D.TransmissionId
	FROM
	Fdp_VolumeHeader_VW							AS H
	JOIN Fdp_TakeRateSummaryByModelAndMarket_VW AS S ON H.FdpVolumeHeaderId = S.FdpVolumeHeaderId
	JOIN Fdp_OxoDerivative						AS D ON S.BMC				= D.DerivativeCode
	GROUP BY
	  H.FdpVolumeHeaderId
	, S.MarketId
	, D.DerivativeCode
	, D.FdpOxoDerivativeId
	, D.BodyId
	, D.EngineId
	, D.TransmissionId

	UNION

	-- Fdp derivatives where we may have take rate information
	SELECT
	      H.FdpVolumeHeaderId
		, S.MarketId
		, D.DerivativeCode
		, CAST(NULL AS INT) AS FdpOxoDerivativeId
		, D.FdpDerivativeId
		, D.BodyId
		, D.EngineId
		, D.TransmissionId
	FROM
	Fdp_VolumeHeader_VW							AS H
	JOIN Fdp_TakeRateSummaryByModelAndMarket_VW AS S ON H.FdpVolumeHeaderId = S.FdpVolumeHeaderId
	JOIN Fdp_Derivative							AS D ON S.BMC				= D.DerivativeCode
	GROUP BY
	  H.FdpVolumeHeaderId
	, S.MarketId
	, D.DerivativeCode
	, D.FdpDerivativeId
	, D.BodyId
	, D.EngineId
	, D.TransmissionId
	)
	AS D
	JOIN OXO_Programme_Body AS B ON D.BodyId = B.Id
	JOIN OXO_Programme_Engine AS E ON D.EngineId = E.Id
	JOIN OXO_Programme_Transmission AS T ON D.TransmissionId = T.Id