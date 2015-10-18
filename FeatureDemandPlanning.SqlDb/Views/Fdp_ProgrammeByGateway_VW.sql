CREATE VIEW [dbo].[Fdp_ProgrammeByGateway_VW] AS

	SELECT 
		  P.Id						AS ProgrammeId
		, V.Id						AS VehicleId
		, G.Id						AS GatewayId
		, V.Make
		, V.Name					AS Code
		, V.Name + ' - ' + V.AKA	AS [Description]
		, P.Model_Year
		, G.Gateway
	FROM
	OXO_Programme AS P
	JOIN OXO_Vehicle AS V ON P.Vehicle_Id	= V.Id
	JOIN OXO_Doc	 AS D ON P.Id			= D.Programme_Id
	JOIN OXO_Gateway AS G ON D.Gateway		= G.Gateway
