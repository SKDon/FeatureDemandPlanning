CREATE PROCEDURE [dbo].[Fdp_TakeRateHeader_Get]
	@FdpVolumeHeaderId	INT
AS
	SET NOCOUNT ON;
	
	;WITH Errors AS
	(
		SELECT 
			H.FdpVolumeHeaderId,
			COUNT(E.FdpImportErrorId) AS NumberOfErrors
		FROM
		Fdp_VolumeHeader_VW		AS H
		JOIN Fdp_Import			AS I	ON H.DocumentId			= I.DocumentId
										AND H.ProgrammeId		= I.ProgrammeId
										AND H.Gateway			= I.Gateway
		JOIN Fdp_ImportQueue	AS Q	ON I.FdpImportQueueId	= Q.FdpImportQueueId
		JOIN Fdp_ImportError	AS E	ON Q.FdpImportQueueId	= E.FdpImportQueueId
										AND E.IsExcluded		= 0
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		GROUP BY
		H.FdpVolumeHeaderId
	)
	SELECT DISTINCT
		  H.FdpVolumeHeaderId	AS TakeRateId
		, H.CreatedOn
		, H.CreatedBy
		, H.UpdatedOn
		, H.UpdatedBy
		, H.DocumentId AS OxoDocId
		, P.VehicleName + 
			' '  + P.VehicleAKA +
			' '  + P.ModelYear +
			' '  + D.Gateway +
			' v' + CAST(D.Version_Id AS NVARCHAR(10)) +
			' '  + D.[Status]
			AS OxoDocument
		, S.FdpTakeRateStatusId
		, S.[Status]
		, S.[Description] AS StatusDescription
		, V.VersionString AS [Version]
		, CAST(CASE WHEN E.NumberOfErrors = 0 THEN 1 ELSE 0 END AS BIT) AS IsComplete
		
	FROM Fdp_VolumeHeader_VW	AS H
	JOIN Fdp_TakeRateStatus		AS S	ON	H.FdpTakeRateStatusId	= S.FdpTakeRateStatusId
	JOIN OXO_Doc				AS D	ON	H.DocumentId			= D.Id
	JOIN OXO_Programme_VW		AS P	ON	H.ProgrammeId			= P.Id
	JOIN Fdp_Version_VW			AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
	LEFT JOIN Errors			AS E	ON	H.FdpVolumeHeaderId		= E.FdpVolumeHeaderId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId;