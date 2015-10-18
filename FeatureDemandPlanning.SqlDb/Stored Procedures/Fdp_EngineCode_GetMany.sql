
CREATE PROCEDURE [dbo].[Fdp_EngineCode_GetMany]
	  @Make					NVARCHAR(10)	= NULL
	, @VehicleId			INT				= NULL
	, @ProgrammeId			INT				= NULL
	, @ModelYear			NVARCHAR(10)	= NULL
	, @EngineId				INT				= NULL
	, @ExternalEngineCode	NVARCHAR(10)	= NULL
	, @TotalRecords			INT				OUTPUT
AS
	SET NOCOUNT ON;
	
	SELECT
		  P.VehicleMake
		, P.Id
		, P.VehicleId
		, P.VehicleName
		, P.VehicleAKA
		, P.VehicleName + ' ' + 
		  P.VehicleAKA			AS VehicleDescription
		, P.ModelYear
		, E.Id					AS EngineId
		, E.Size				AS EngineSize
		, E.Cylinder
		, E.Fuel_Type			AS Fuel
		, E.[Power]
		, E.Electrification
		, M.DerivativeCode		AS ExternalEngineCode
	FROM
	OXO_Programme_VW			AS P
	JOIN OXO_Programme_Engine	AS E ON		P.Id		= E.Programme_Id
									 AND	E.Active	= 1
	LEFT JOIN Fdp_TrimMapping	AS M ON		E.Id		= M.EngineId
									 AND	P.Id		= M.ProgrammeId
	WHERE
	(@Make IS NULL OR P.VehicleMake = @Make)
	AND
	(@VehicleId IS NULL OR P.VehicleId = @VehicleId)
	AND
	(@ProgrammeId IS NULL OR P.Id = @ProgrammeId)
	AND
	(@ModelYear IS NULL OR P.ModelYear = @ModelYear)
	AND
	(@EngineId IS NULL OR E.Id = @EngineId)
	AND
	(@ExternalEngineCode IS NULL OR M.DerivativeCode = @ExternalEngineCode)
	ORDER BY
	  VehicleMake
	, VehicleName
	, ModelYear
	, ExternalEngineCode
	, Fuel_Type
	, Cylinder
	, Size
	, [Power];
	
	SET @TotalRecords = @@ROWCOUNT;
	



