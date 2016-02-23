
CREATE PROCEDURE [dbo].[Fdp_ProgrammeByGateway_GetMany]
	  @Make					NVARCHAR(10)	= NULL
	, @VehicleId			INT				= NULL
	, @ProgrammeId			INT				= NULL
	, @ModelYear			NVARCHAR(10)	= NULL
	, @Gateway				NVARCHAR(10)	= NULL
	, @TotalRecords			INT				OUTPUT
	, @CDSId				NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @ShowAll AS BIT;
	SELECT @ShowAll = CAST(Value AS BIT) 
	FROM Fdp_Configuration
	WHERE
	ConfigurationKey = 'ShowAllOXODocuments'

	SELECT 
		  P.Id
		, P.VehicleId
		, P.VehicleName 
		, P.VehicleAKA
		, P.VehicleMake
		, P.VehicleDisplayFormat
		, P.ModelYear
		, D.Gateway
		, P.PS
		, P.J1
		, P.Notes 
		, P.ProductManager 
		, P.RSGUID
		, P.OXOEnabled
		, P.Active
		, P.UseOACode
		, P.CreatedBy  
		, P.CreatedOn  
		, P.UpdatedBy  
		, P.LastUpdated
	FROM dbo.OXO_Programme_VW		AS P
	JOIN dbo.OXO_Doc				AS D	ON	P.Id = D.Programme_Id
											AND	
											(
												@ShowAll = 1
												OR
												(@ShowAll = 0 AND D.[Status] = 'PUBLISHED')
											)
	JOIN dbo.OXO_Gateway			AS G	ON		D.Gateway	= G.Gateway
	JOIN dbo.fn_Fdp_UserProgrammes_GetMany2(@CDSId) AS P1 ON P.Id = P1.ProgrammeId
	WHERE
	(@Make IS NULL OR P.VehicleMake = @Make)
	AND
	(@VehicleId IS NULL OR P.VehicleId = @VehicleId)
	AND
	(@ProgrammeId IS NULL OR P.Id = @ProgrammeId)
	AND
	(@ModelYear IS NULL OR P.ModelYear = @ModelYear)
	AND
	(@Gateway IS NULL OR D.Gateway = @Gateway)
	ORDER BY 
		P.VehicleName
	  , P.ModelYear
	  , G.Display_Order

	SET @TotalRecords = @@ROWCOUNT;

