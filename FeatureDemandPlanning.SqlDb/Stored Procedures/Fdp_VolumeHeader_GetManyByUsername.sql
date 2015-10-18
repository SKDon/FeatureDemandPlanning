CREATE PROCEDURE [dbo].[Fdp_VolumeHeader_GetManyByUsername]
	  @VehicleName NVARCHAR(1000) = NULL
	, @ModelYear NVARCHAR(100) = NULL
	, @Gateway NVARCHAR(50) = NULL
	, @CDSID NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	WITH ProgrammePermissions AS
	(
		SELECT 
			[Object_Id] AS ProgrammeId
			, CAST(MAX(
				CASE 
					WHEN Operation = 'CanEdit' 
					THEN 1
					ELSE 0
				END) AS BIT) AS IsEditable
		FROM OXO_Permission 
		WHERE 
		CDSID = @CDSID
		AND 
		Object_Type = 'Programme'
		AND 
		Operation IN ('CanView', 'CanEdit')
		GROUP BY
		[Object_Id]
	)
	SELECT DISTINCT
		  V.FdpVolumeHeaderId
		, V.CreatedOn
		, V.CreatedBy
		, V.IsManuallyEntered
		, I.FilePath			AS ImportFilePath
		, P.Id					AS ProgrammeId
		, P.VehicleMake
		, P.VehicleName
		, P.VehicleAKA
		, P.ModelYear
		, P.VehicleDisplayFormat
		, G.Gateway
		, G.Display_Order
		
	FROM Fdp_VolumeHeader		AS V
	JOIN ProgrammePermissions	AS PP	ON V.ProgrammeId	= PP.ProgrammeId
	JOIN OXO_Programme_VW		AS P	ON V.ProgrammeId	= P.Id
	JOIN OXO_Gateway			AS G	ON V.Gateway		= G.Gateway
	LEFT JOIN Fdp_Import		AS I1	ON V.FdpImportId	= I1.FdpImportId
	LEFT JOIN ImportQueue_VW	AS I	ON I1.ImportQueueId	= I.ImportQueueId
	WHERE
	(@VehicleName IS NULL OR P.VehicleName = @VehicleName)
	AND
	(@ModelYear IS NULL OR P.ModelYear = @ModelYear)
	AND
	(@Gateway IS NULL OR G.Gateway = @Gateway)
	ORDER BY
	G.Display_Order, V.CreatedOn DESC