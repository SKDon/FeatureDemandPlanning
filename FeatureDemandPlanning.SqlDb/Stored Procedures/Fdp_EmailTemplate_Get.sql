CREATE PROCEDURE dbo.Fdp_EmailTemplate_Get
	@FdpEmailTemplateId INT
AS
	SET NOCOUNT ON;

	SELECT
		  T.FdpEmailTemplateId
		, T.[Subject]
		, T.Body
		, T.IsActive
	FROM
	Fdp_EmailTemplate AS T
	WHERE
	T.FdpEmailTemplateId = @FdpEmailTemplateId