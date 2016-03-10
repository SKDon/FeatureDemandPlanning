CREATE PROCEDURE [dbo].[Fdp_OxoDerivative_Insert]
	@FdpVolumeHeaderId AS INT
AS
	SET NOCOUNT ON;

	INSERT INTO Fdp_OxoDerivative
	(
		  DocumentId
		, Gateway
		, ProgrammeId
		, DerivativeCode
		, BodyId
		, EngineId
		, TransmissionId
		, IsArchived
	)
	SELECT
		  H.DocumentId
		, H.Gateway
		, H.ProgrammeId 
		, M.BMC
		, M.Body_Id			AS BodyId
		, M.Engine_Id		AS EngineId
		, M.Transmission_Id AS TransmissionId
		, 0
	FROM
	Fdp_VolumeHeader_VW				AS H 
	JOIN OXO_Programme_Model		AS M	ON	H.DocumentId		= M.Programme_Id
	LEFT JOIN Fdp_OxoDerivative		AS CUR	ON	M.Body_Id			= CUR.BodyId
											AND M.Engine_Id			= CUR.EngineId
											AND M.Transmission_Id	= CUR.TransmissionId
											AND H.DocumentId		= CUR.DocumentId			
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	CUR.FdpOxoDerivativeId IS NULL
	GROUP BY
	H.DocumentId, H.Gateway, H.ProgrammeId, M.BMC, M.Body_Id, M.Engine_Id, M.Transmission_Id

	UNION

	SELECT
		  H.DocumentId
		, H.Gateway
		, H.ProgrammeId 
		, M.BMC
		, M.Body_Id			AS BodyId
		, M.Engine_Id		AS EngineId
		, M.Transmission_Id AS TransmissionId
		, 1
	FROM
	Fdp_VolumeHeader_VW					AS H 
	JOIN OXO_Archived_Programme_Model	AS M	ON	H.DocumentId		= M.Doc_Id
	LEFT JOIN Fdp_OxoDerivative			AS CUR	ON	M.Body_Id			= CUR.BodyId
												AND M.Engine_Id			= CUR.EngineId
												AND M.Transmission_Id	= CUR.TransmissionId
												AND H.DocumentId		= CUR.DocumentId			
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	CUR.FdpOxoDerivativeId IS NULL
	GROUP BY
	H.DocumentId, H.Gateway, H.ProgrammeId, M.BMC, M.Body_Id, M.Engine_Id, M.Transmission_Id