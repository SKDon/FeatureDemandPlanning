
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
		, P.EngineId
		, E.Size
		, E.Turbo
		, E.Cylinder
		, E.Electrification
		, E.Fuel_Type
		, P.BodyId
		, B.Shape
		, B.Wheelbase
		, B.Doors
		, P.TransmissionId
		, T.Drivetrain
		, T.[Type]
		, P.Volume
		, P.PercentageTakeRate
		, P.UpdatedOn
		, P.UpdatedBy
	FROM
	Fdp_VolumeHeader_VW				AS H
	JOIN Fdp_PowertrainDataItem		AS P	ON	H.FdpVolumeHeaderId = P.FdpVolumeHeaderId
	JOIN OXO_Programme_Body			AS B	ON	P.BodyId			= B.Id
											AND H.ProgrammeId		= B.Programme_Id
	JOIN OXO_Programme_Engine		AS E	ON	P.EngineId			= E.Id
											AND H.ProgrammeId		= E.Programme_Id
	JOIN OXO_Programme_Transmission	AS T	ON	P.TransmissionId	= T.Id
											AND	H.ProgrammeId		= T.Programme_Id