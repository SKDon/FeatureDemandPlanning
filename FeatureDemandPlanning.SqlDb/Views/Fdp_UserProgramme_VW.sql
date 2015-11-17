
CREATE VIEW [dbo].[Fdp_UserProgramme_VW] AS

	WITH PermissionsByUser AS
	(
		SELECT
			  U.FdpUserId
			, P.ProgrammeId
			, CASE
				WHEN U.IsAdmin = 1						
				THEN 2 -- Edit if admin (regardless as to what the permissions on programme say)
				WHEN P1.FdpUserProgrammeId IS NOT NULL 
				THEN 2
				ELSE 
				P.FdpPermissionTypeId
			  END
			  AS FdpPermissionTypeId
		FROM
		Fdp_User AS U
		JOIN Fdp_UserProgramme		AS	P	ON	U.FdpUserId				= P.FdpUserId
											AND P.FdpPermissionTypeId	= 1
		LEFT JOIN Fdp_UserProgramme AS	P1	ON	U.FdpUserId				= P1.FdpUserId
											AND P1.FdpPermissionTypeId	= 2
	)
	SELECT
		  U.CDSId
		, U.FullName
		, U.IsActive
		, U.IsAdmin
		, V.Id	AS ProgrammeId
		, V.VehicleName
		, V.VehicleAKA
		, V.ModelYear
		, T.FdpPermissionTypeId
		, T.Permission
	FROM
	PermissionsByUser		AS P
	JOIN Fdp_User			AS U ON P.FdpUserId				= U.FdpUserId
	JOIN OXO_Programme_VW	AS V ON P.ProgrammeId			= V.Id
	JOIN Fdp_PermissionType AS T ON P.FdpPermissionTypeId	= T.FdpPermissionTypeId