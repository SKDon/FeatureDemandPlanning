CREATE PROCEDURE [dbo].[Fdp_OxoDerivative_Update]
	@FdpVolumeHeaderId AS INT
AS
	SET NOCOUNT ON;

	INSERT INTO Fdp_OxoDervivative
	(
		  ProgrammeId
		, DerivativeCode
		, BodyId
		, EngineId
		, TransmissionId
	)
	SELECT
		  H.ProgrammeId 
		, M.BMC
		, M.Body_Id			AS BodyId
		, M.Engine_Id		AS EngineId
		, M.Transmission_Id AS TransmissionId
	FROM
	Fdp_VolumeHeader_VW				AS H 
	JOIN OXO_Programme_Model		AS M	ON H.ProgrammeId	= M.Programme_Id
	LEFT JOIN Fdp_OxoDervivative	AS CUR	ON M.BMC			= CUR.DerivativeCode			
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	CUR.FdpOxoDervivativeId IS NULL
	AND
	M.BMC IS NOT NULL
	GROUP BY
	H.ProgrammeId, M.BMC, M.Body_Id, M.Engine_Id, M.Transmission_Id

	UNION

	SELECT
		  H.ProgrammeId 
		, M.BMC
		, M.Body_Id			AS BodyId
		, M.Engine_Id		AS EngineId
		, M.Transmission_Id AS TransmissionId
	FROM
	Fdp_VolumeHeader_VW				AS H
	JOIN Fdp_VolumeDataItem_VW		AS D	ON H.FdpVolumeHeaderId	= D.FdpVolumeHeaderId
	JOIN OXO_Programme_Model		AS M	ON D.ModelId			= M.Id
	LEFT JOIN Fdp_OxoDervivative	AS CUR	ON M.BMC				= CUR.DerivativeCode			
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	CUR.FdpOxoDervivativeId IS NULL
	AND
	M.BMC IS NOT NULL
	GROUP BY
	H.ProgrammeId, M.BMC, M.Body_Id, M.Engine_Id, M.Transmission_Id