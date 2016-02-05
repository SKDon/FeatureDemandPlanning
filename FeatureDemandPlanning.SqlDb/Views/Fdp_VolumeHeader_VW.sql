CREATE VIEW Fdp_VolumeHeader_VW AS

	SELECT
		  H.FdpVolumeHeaderId
		, H.CreatedOn
		, H.CreatedBy
		, H.FdpTakeRateStatusId
		, H.IsManuallyEntered
		, H.TotalVolume
		, H.UpdatedOn
		, H.UpdatedBy
		, H.DocumentId
		, D.Programme_Id AS ProgrammeId
		, D.Gateway AS Gateway
	FROM
	Fdp_VolumeHeader	AS H
	JOIN OXO_Doc		AS D	ON	H.DocumentId = D.Id