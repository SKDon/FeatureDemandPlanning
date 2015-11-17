CREATE PROCEDURE [dbo].[Fdp_UserProgramme_GetMany]
	@CDSId NVARCHAR(16) = NULL
AS
	SET NOCOUNT ON;
	
	SELECT
		  P.CDSId
		, P.FullName
		, P.IsActive
		, P.IsAdmin
		, P.ProgrammeId
		, P.VehicleName
		, P.VehicleAKA
		, P.FdpPermissionTypeId AS PermissionTypeId
		, P.Permission			AS PermissionType
	FROM
	Fdp_UserProgramme_VW AS P
	WHERE
	(@CDSId IS NULL OR P.CDSId = @CDSId)
	ORDER BY
	P.FullName, P.VehicleName, P.Permission