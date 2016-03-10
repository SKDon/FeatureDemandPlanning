
CREATE VIEW [dbo].[Fdp_VolumeHeader_VW] AS

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
		, ISNULL(D.Archived, 0) AS IsArchived
	FROM
	Fdp_VolumeHeader	AS H
	JOIN OXO_Doc		AS D	ON	H.DocumentId = D.Id