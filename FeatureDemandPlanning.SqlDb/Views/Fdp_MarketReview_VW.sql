﻿CREATE VIEW dbo.Fdp_MarketReview_VW 
AS

SELECT
	  H.FdpVolumeHeaderId
	, M.FdpMarketReviewId
	, M.CreatedBy
	, M.CreatedOn
	, H.DocumentId
	, H.ProgrammeId
	, P.VehicleName
	, P.VehicleAKA
	, P.ModelYear
	, M.MarketId
	, MK.Market_Name AS MarketName
	, S.FdpMarketReviewStatusId
	, S.[Status]
	FROM
	Fdp_MarketReview					AS M
	JOIN Fdp_MarketReviewStatus			AS S	ON M.FdpMarketReviewStatusId = S.FdpMarketReviewStatusId				
	JOIN Fdp_VolumeHeader_VW			AS H	ON M.FdpVolumeHeaderId	= H.FdpVolumeHeaderId
	JOIN OXO_Market_Group_Market_VW		AS MK	ON M.MarketId			= MK.Market_Id
	JOIN OXO_Programme_VW				AS P	ON H.ProgrammeId		= P.Id;