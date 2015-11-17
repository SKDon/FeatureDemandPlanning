CREATE PROCEDURE [dbo].[Fdp_News_GetMany]
AS
	SELECT 
		  N.FdpNewsId
		, N.CreatedOn
		, N.CreatedBy
		, N.Headline
		, N.Body
	FROM
	Fdp_News AS N
	WHERE
	N.IsActive = 1
	ORDER BY
	N.CreatedOn DESC