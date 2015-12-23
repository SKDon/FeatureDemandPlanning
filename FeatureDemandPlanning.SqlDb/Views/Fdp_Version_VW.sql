
CREATE VIEW [dbo].[Fdp_Version_VW] AS

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
		, ISNULL(V.MajorVersion, 0)			AS MajorVersion
		, ISNULL(V.MinorVersion, 0)			AS MinorVersion
		, ISNULL(V.Revision, 0)				AS Revision
		,	CAST(ISNULL(V.MajorVersion, 0) AS NVARCHAR)	+ '.' +
			CAST(ISNULL(V.MinorVersion, 0) AS NVARCHAR)	+ '.' +
			CAST(ISNULL(V.Revision, 0) AS NVARCHAR)	AS VersionString
		, S.[Status]
			
	FROM Fdp_VolumeHeader			AS H
	JOIN OXO_Doc					AS D	ON	H.DocumentId			= D.Id
	JOIN OXO_Programme_VW			AS P	ON	D.Programme_Id			= P.Id
	JOIN Fdp_TakeRateStatus			AS S	ON	H.FdpTakeRateStatusId	= S.FdpTakeRateStatusId
	LEFT JOIN LatestVersion			AS L	ON	H.FdpVolumeHeaderId		= L.FdpTakeRateHeaderId
	LEFT JOIN Fdp_TakeRateVersion	AS V	ON	L.FdpTakeRateVersionId	= V.FdpTakeRateVersionId