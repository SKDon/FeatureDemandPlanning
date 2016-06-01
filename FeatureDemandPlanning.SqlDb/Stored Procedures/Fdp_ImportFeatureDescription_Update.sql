CREATE PROCEDURE dbo.Fdp_ImportFeatureDescription_Update
	@FdpVolumeHeaderId AS INT
AS
	SET NOCOUNT ON;

	DELETE FROM Fdp_ImportFeatureDescription
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId;

	;WITH ImportFeatureDescription AS
	(
		SELECT LATEST.FdpVolumeHeaderId, D.[Bff Feature Code], MAX(D.[Feature Description]) AS [Description]
		FROM Fdp_ImportData AS D
		JOIN 
		(
			SELECT FdpVolumeHeaderId, MAX(FdpImportId) AS FdpImportId, MAX(FdpImportQueueId) AS FdpImportQueueId
			FROM 
			Fdp_VolumeHeader AS H
			JOIN Fdp_Import AS I ON H.DocumentId = I.DocumentId
			WHERE
			I.Uploaded = 1
			GROUP BY
			H.FdpVolumeHeaderId
		)
		AS LATEST ON D.FdpImportId = LATEST.FdpImportId
		GROUP BY
		LATEST.[FdpVolumeHeaderId], [Bff Feature Code]
	)
	INSERT INTO Fdp_ImportFeatureDescription
	(
		  FdpVolumeHeaderId
		, MappedFeatureCode
		, ImportFeatureCode
		, FeatureDescription
	)
	SELECT
		  H.FdpVolumeHeaderId 
		, F.MappedFeatureCode
		, F.ImportFeatureCode
		, CASE 
			WHEN F.MappedFeatureCode <> F.ImportFeatureCode THEN I.[Description]
			ELSE ISNULL(F.BrandDescription, F.[Description])
		  END AS [Description]
	FROM 
	Fdp_VolumeHeader_VW			AS H
	JOIN Fdp_FeatureMapping_VW	AS F		ON H.DocumentId = F.DocumentId
	JOIN 
	(
		SELECT DocumentId, MappedFeatureCode
		FROM
		Fdp_FeatureMapping_VW
		GROUP BY DocumentId, MappedFeatureCode
		HAVING COUNT(DISTINCT ImportFeatureCode) > 1
	) 
								AS MULTI	ON F.DocumentId			= MULTI.DocumentId
											AND F.MappedFeatureCode = MULTI.MappedFeatureCode
	LEFT JOIN ImportFeatureDescription AS I		ON	H.FdpVolumeHeaderId	= I.FdpVolumeHeaderId
											AND	F.ImportFeatureCode = I.[Bff Feature Code]
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId;