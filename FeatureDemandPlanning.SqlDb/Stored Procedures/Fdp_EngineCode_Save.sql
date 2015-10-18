
CREATE PROCEDURE [dbo].[Fdp_EngineCode_Save]
	  @ProgrammeId			INT
	, @EngineId				INT
	, @ExternalEngineCode	NVARCHAR(10) = NULL
	, @MappingId			INT OUTPUT
AS
	SET NOCOUNT ON;
	
	SELECT @MappingId = Id
	FROM Fdp_TrimMapping
	WHERE 
	ProgrammeId = @ProgrammeId
	AND 
	EngineId = @EngineId;
	
	IF @MappingId IS NULL
	BEGIN
		INSERT INTO Fdp_TrimMapping
		(
			  ProgrammeId
			, EngineId
			, DerivativeCode
		)
		VALUES
		(
			  @ProgrammeId
			, @EngineId
			, @ExternalEngineCode
		);
		
		SET @MappingId = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		UPDATE Fdp_TrimMapping SET DerivativeCode = UPPER(@ExternalEngineCode)
		WHERE 
		Id = @MappingId
	END
	
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
		, M.Id					AS MappingId
		, M.DerivativeCode		AS ExternalEngineCode
	FROM
	OXO_Programme_VW			AS P
	JOIN OXO_Programme_Engine	AS E ON		P.Id		= E.Programme_Id
									 AND	E.Active	= 1
	LEFT JOIN Fdp_TrimMapping	AS M ON		E.Id		= M.EngineId
									 AND	P.Id		= M.ProgrammeId
	WHERE
	M.Id = @MappingId
	ORDER BY
	  VehicleMake
	, VehicleName
	, ModelYear
	, ExternalEngineCode
	, Fuel_Type
	, Cylinder
	, Size
	, [Power];
	



