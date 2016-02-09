CREATE FUNCTION dbo.fn_Fdp_UserProgrammes_GetMany2
(
	@CDSId NVARCHAR(16)
)
RETURNS 
@Programme TABLE 
(
	  ProgrammeId		INT
	, Name				NVARCHAR(1000)
	, ModelYear			NVARCHAR(100)
	, FdpUserActionId	INT
)
AS
BEGIN
	INSERT INTO @Programme
	(
		  ProgrammeId
		, Name
		, ModelYear
		, FdpUserActionId
	)
	-- Permissions that have been defined individually
	SELECT
		  P1.ProgrammeId
		, P2.VehicleName
		, P2.ModelYear
		, P1.FdpUserActionId
	FROM
	Fdp_User						AS U
	JOIN 
	(
		-- Ensure if we have both view and edit permission, the edit permission takes precedence
		SELECT P.FdpUserId, P.ProgrammeId, MAX(P.FdpUserActionId) AS FdpUserActionId
		FROM
		Fdp_UserProgrammeMapping	AS p
		GROUP BY
		P.FdpUserId, P.ProgrammeId
	)
	AS P								ON	U.FdpUserId			= P.FdpUserId
	JOIN Fdp_UserProgrammeMapping AS P1	ON	P.FdpUserId			= P1.FdpUserId
										AND P.ProgrammeId		= P1.ProgrammeId
										AND P.FdpUserActionId	= P1.FdpUserActionId 
	JOIN OXO_Programme_VW		 AS P2	ON	P1.ProgrammeId		= P2.Id
	WHERE
	U.CDSId = @CDSId;

	INSERT INTO @Programme
	(
		  ProgrammeId
		, Name
		, ModelYear
		, FdpUserActionId
	)
	-- Permissions that have been defined with an "All Programmes" role and haven't been individually expressed
	SELECT
		  P.Id
		, P.VehicleName
		, P.ModelYear
		, CASE
			WHEN R1.FdpUserRoleMappingId IS NOT NULL THEN 2 -- Edit
			ELSE 1 -- View
		  END
	FROM
	Fdp_User AS U
	CROSS APPLY OXO_Programme_VW	AS P
	JOIN Fdp_UserRoleMapping		AS R	ON	U.FdpUserId			= R.FdpUserId
											AND R.IsActive			= 1
											AND R.FdpUserRoleId		= 8 -- All Programmes
	LEFT JOIN Fdp_UserRoleMapping	AS R1	ON	U.FdpUserId			= R1.FdpUserId
											AND R1.IsActive			= 1
											AND R1.FdpUserRoleId	= 3 -- Editor
	LEFT JOIN @Programme			AS P1	ON	P.Id				= P1.ProgrammeId
	WHERE
	U.CDSId = @CDSId
	AND
	P1.ProgrammeId IS NULL -- We haven't already defined the programme manually
	
	RETURN 
END