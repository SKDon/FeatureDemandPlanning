CREATE PROCEDURE [dbo].[Fdp_VolumeHeader_GetManyByOxoDocId]
	  @OxoDocId INT
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
		, D.Id AS OXODocId
		, V.CreatedOn
		, V.CreatedBy
		, V.IsManuallyEntered
		, NULL			AS ImportFilePath
		, P.Id					AS ProgrammeId
		, P.VehicleMake
		, P.VehicleName + ' - ' + P.VehicleAKA AS CarLine
		, P.VehicleName
		, P.VehicleAKA
		, P.ModelYear
		, P.VehicleDisplayFormat
		, G.Gateway
		, G.Display_Order
		
	FROM Fdp_VolumeHeader		AS V
	JOIN OXO_Doc				AS D	ON V.DocumentId		= D.Id
	JOIN ProgrammePermissions	AS PP	ON D.Programme_Id	= PP.ProgrammeId
	JOIN OXO_Programme_VW		AS P	ON D.Programme_Id	= P.Id
	JOIN OXO_Gateway			AS G	ON D.Gateway		= G.Gateway
	WHERE
	V.DocumentId = @OxoDocId
	ORDER BY
	G.Display_Order, V.CreatedOn DESC;