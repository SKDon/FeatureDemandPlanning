CREATE VIEW dbo.Fdp_Version_VW AS

	WITH LatestVersion AS
	(
		SELECT 
			  FdpTakeRateHeaderId
			, MAX(FdpTakeRateVersionId) AS FdpTakeRateVersionId 
		FROM Fdp_TakeRateVersion
		GROUP BY 
		FdpTakeRateHeaderId
	)
	SELECT 
		  H.DocumentId
		, H.FdpVolumeHeaderId
		, P.Id								AS ProgrammeId
		, P.VehicleMake
		, P.VehicleName
		, P.VehicleAKA
		, P.ModelYear
		, D.Gateway
		, D.Version_Id						AS DocumentVersion
		, V.MajorVersion
		, V.MinorVersion
		, V.Revision
		,	CAST(V.MajorVersion AS NVARCHAR)	+ '.' +
			CAST(V.MinorVersion AS NVARCHAR)	+ '.' +
			CAST(V.Revision AS NVARCHAR)	AS VersionString
		, S.[Status]
			
	FROM Fdp_VolumeHeader		AS H
	JOIN OXO_Doc				AS D	ON	H.DocumentId			= D.Id
	JOIN OXO_Programme_VW		AS P	ON	D.Programme_Id			= P.Id
	JOIN LatestVersion			AS L	ON	H.FdpVolumeHeaderId		= L.FdpTakeRateHeaderId
	JOIN Fdp_TakeRateVersion	AS V	ON	L.FdpTakeRateVersionId	= V.FdpTakeRateVersionId
	JOIN Fdp_TakeRateStatus		AS S	ON	H.FdpTakeRateStatusId	= S.FdpTakeRateStatusId