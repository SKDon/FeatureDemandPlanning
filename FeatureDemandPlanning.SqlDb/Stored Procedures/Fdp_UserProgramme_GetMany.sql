CREATE PROCEDURE [dbo].[Fdp_UserProgramme_GetMany]
	  @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;

	SELECT
		  U.FdpUserId 
		, P.ProgrammeId
		, O.VehicleName
		, O.VehicleAKA
		, O.ModelYear
		, A.FdpUserActionId
		, A.[Action]
	FROM
	Fdp_User						AS U
	JOIN Fdp_UserProgrammeMapping	AS P	ON	U.FdpUserId		= P.FdpUserId
											AND P.IsActive		= 1
	JOIN OXO_Programme_VW			AS O	ON	P.ProgrammeId	= O.Id
	JOIN Fdp_UserAction				AS A	ON	P.FdpUserActionId = A.FdpUserActionId
	WHERE
	U.CDSId = @CDSId