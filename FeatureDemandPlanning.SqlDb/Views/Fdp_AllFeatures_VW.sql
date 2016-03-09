CREATE VIEW [dbo].[Fdp_AllFeatures_VW]
AS

	-- Features where we have data
			
	SELECT 
		  FeatureId
		, FdpFeatureId
		, FeaturePackId
		, FdpVolumeHeaderId
	FROM
	Fdp_VolumeDataItem_VW 
	WHERE
	(
		FeatureId IS NOT NULL
		OR
		FdpFeatureId IS NOT NULL
	)
	GROUP BY
	FdpVolumeHeaderId, FeatureId, FdpFeatureId, FeaturePackId
	
	UNION
	
	-- Feature packs where we have data
	
	SELECT
		  CAST(NULL AS INT) AS FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, FeaturePackId
		, FdpVolumeHeaderId
	FROM
	Fdp_VolumeDataItem_VW
	WHERE
	FeaturePackId IS NOT NULL
	GROUP BY 
	FdpVolumeHeaderId, FeaturePackId
	
	UNION
	
	-- Features where we might have data (coded features but no data)
	
	SELECT 
		  F.ID AS FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, MAX(P.Id) AS FeaturePackId -- We just need an indicator that a feature is in a pack, not the actual pack
		, H.FdpVolumeHeaderId
	FROM
	Fdp_VolumeHeader_VW				AS H
	JOIN OXO_Programme_Feature_VW	AS F	ON	H.ProgrammeId		= F.ProgrammeId
	LEFT JOIN OXO_Pack_Feature_Link AS P	ON	F.Id				= P.Feature_Id
											AND H.ProgrammeId		= P.Programme_Id
	-- Cross reference with the actual take rate data. This ensures there is not a mismatch in the feature packs
	LEFT JOIN Fdp_VolumeDataItem_VW AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
											AND F.ID				= D.FeatureId
	WHERE
	D.FdpVolumeDataItemId IS NULL
	GROUP BY
	H.FdpVolumeHeaderId, F.ID
											
	UNION
	
	-- Fdp features where we might have data (FDP features but no data)
	
	SELECT 
		  CAST(NULL AS INT) AS FeatureId
		, F.FdpFeatureId
		, CAST(NULL AS INT) AS FeaturePackId
		, H.FdpVolumeHeaderId
	FROM
	Fdp_VolumeHeader_VW AS H
	JOIN Fdp_Feature	AS F	ON	H.ProgrammeId	= F.ProgrammeId
								AND H.Gateway		= F.Gateway
	
	UNION
	
	-- Feature packs where we might have data (coded packs but no data)
	
	SELECT 
		  CAST(NULL AS INT) AS FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, P.Id AS FeaturePackId
		, H.FdpVolumeHeaderId
	FROM
	Fdp_VolumeHeader_VW AS H
	JOIN OXO_Programme_Pack AS P ON H.ProgrammeId = P.Programme_Id