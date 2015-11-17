CREATE FUNCTION [dbo].[Fdp_UserProgrammes_GetMany]
(
	@CDSId NVARCHAR(16)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @ProgrammeList AS NVARCHAR(MAX);

	SELECT @ProgrammeList = COALESCE(@ProgrammeList + ', ', '') + 
		P.VehicleName + ' ' + P.ModelYear +
		' (' + P.Permission + ')'
	FROM
	Fdp_UserProgramme_VW AS P
	WHERE
	CDSId = @CDSId
	ORDER BY
	P.VehicleName, P.ModelYear;
	
	RETURN @ProgrammeList
   
END