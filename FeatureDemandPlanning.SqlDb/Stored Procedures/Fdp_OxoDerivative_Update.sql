CREATE PROCEDURE [dbo].[Fdp_OxoDerivative_Update]
	@FdpVolumeHeaderId AS INT
AS
	SET NOCOUNT ON;

	INSERT INTO Fdp_OxoDerivative
	(
		  ProgrammeId
		, DocumentId
		, Gateway
		, DerivativeCode
		, BodyId
		, EngineId
		, TransmissionId
		, IsArchived
	)
	SELECT
		  H.ProgrammeId
		, H.DocumentId
		, H.Gateway
		, M.BMC
		, M.Body_Id			AS BodyId
		, M.Engine_Id		AS EngineId
		, M.Transmission_Id AS TransmissionId
		, CAST(0 AS BIT)	AS IsArchived
	FROM
	Fdp_VolumeHeader_VW				AS H 
	JOIN OXO_Programme_Model		AS M	ON	H.ProgrammeId	= M.Programme_Id
											AND H.IsArchived	= 0
	LEFT JOIN Fdp_OxoDerivative		AS CUR	ON	M.BMC			= CUR.DerivativeCode
											AND H.DocumentId	= CUR.DocumentId			
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	CUR.FdpOxoDerivativeId IS NULL
	AND
	M.BMC IS NOT NULL
	GROUP BY
	H.ProgrammeId, M.BMC, M.Body_Id, M.Engine_Id, M.Transmission_Id, H.DocumentId, H.Gateway

	UNION

	SELECT
		  H.ProgrammeId
		, H.DocumentId
		, H.Gateway
		, M.BMC
		, M.Body_Id			AS BodyId
		, M.Engine_Id		AS EngineId
		, M.Transmission_Id AS TransmissionId
		, CAST(0 AS BIT)	AS IsArchived
	FROM
	Fdp_VolumeHeader_VW				AS H
	JOIN Fdp_VolumeDataItem_VW		AS D	ON	H.FdpVolumeHeaderId	= D.FdpVolumeHeaderId
	JOIN OXO_Programme_Model		AS M	ON	D.ModelId			= M.Id
	LEFT JOIN Fdp_OxoDerivative		AS CUR	ON	M.BMC				= CUR.DerivativeCode
											AND H.DocumentId		= CUR.DocumentId			
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	CUR.FdpOxoDerivativeId IS NULL
	AND
	M.BMC IS NOT NULL
	GROUP BY
	H.ProgrammeId, M.BMC, M.Body_Id, M.Engine_Id, M.Transmission_Id, H.DocumentId, H.Gateway

	UNION

	SELECT
		  H.ProgrammeId
		, H.DocumentId
		, H.Gateway
		, M.BMC
		, M.Body_Id			AS BodyId
		, M.Engine_Id		AS EngineId
		, M.Transmission_Id AS TransmissionId
		, CAST(1 AS BIT)	AS IsArchived
	FROM
	Fdp_VolumeHeader_VW					AS H 
	JOIN OXO_Archived_Programme_Model	AS M	ON	H.DocumentId	= M.Doc_Id
												AND H.IsArchived	= 1
	LEFT JOIN Fdp_OxoDerivative			AS CUR	ON	M.BMC			= CUR.DerivativeCode
												AND H.DocumentId	= CUR.DocumentId			
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	CUR.FdpOxoDerivativeId IS NULL
	AND
	M.BMC IS NOT NULL
	GROUP BY
	H.ProgrammeId, M.BMC, M.Body_Id, M.Engine_Id, M.Transmission_Id, H.DocumentId, H.Gateway
