CREATE FUNCTION [dbo].[Fdp_UserProgrammes] 
(
	@CDSId NVARCHAR(16)
)
RETURNS @UserProgrammes TABLE 
(
	  FdpUserId INT
	, CDSId NVARCHAR(16)
	, Programmes NVARCHAR(MAX)
)  
AS
BEGIN

	INSERT INTO @UserProgrammes
	(
		  FdpUserId
		, CDSId
		, Programmes
	)
	SELECT
		  U.FdpUserId
		, U.CDSId
		, dbo.Fdp_UserProgrammes_GetMany(CDSId) AS Programmes
	FROM
	Fdp_User AS U
	WHERE
	(@CDSId IS NULL OR U.CDSId = @CDSId);
    
	RETURN;
	
END