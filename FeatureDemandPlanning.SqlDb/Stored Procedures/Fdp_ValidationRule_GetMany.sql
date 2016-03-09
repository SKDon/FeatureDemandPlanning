CREATE PROCEDURE [dbo].[Fdp_ValidationRule_GetMany]
AS
BEGIN

	SET NOCOUNT ON;

    SELECT
		  FdpValidationRuleId
		, [Rule]
		, [Description]
		, IsActive
    FROM
    Fdp_ValidationRule AS R
    ORDER BY
    [Rule]
END