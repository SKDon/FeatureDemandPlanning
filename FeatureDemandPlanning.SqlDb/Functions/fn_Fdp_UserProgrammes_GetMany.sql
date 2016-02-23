CREATE FUNCTION [dbo].[fn_Fdp_UserProgrammes_GetMany]
(
	@CDSId NVARCHAR(16)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	
	DECLARE @Programmes AS NVARCHAR(MAX)
	
	SELECT @Programmes = COALESCE(@Programmes + ',', '') + O.VehicleName + ' ' + O.ModelYear + ' (' + A.[Action] + ')'
	FROM
	Fdp_User				AS U
	JOIN
	(
		SELECT FdpUserId, ProgrammeId, MAX(FdpUserActionId) AS FdpUserActionId
		FROM
		Fdp_UserProgrammeMapping AS M
		GROUP BY
		M.FdpUserId, M.ProgrammeId
	)
							AS P ON U.FdpUserId			= P.FdpUserId
	JOIN OXO_Programme_VW	AS O ON P.ProgrammeId		= O.Id
	JOIN Fdp_UserAction		AS A ON P.FdpUserActionId	= A.FdpUserActionId
	WHERE
	U.CDSId = @CDSId
	ORDER BY
	O.VehicleName, O.ModelYear
	
	RETURN @Programmes
   
END