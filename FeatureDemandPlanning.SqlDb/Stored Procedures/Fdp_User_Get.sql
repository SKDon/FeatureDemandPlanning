CREATE PROCEDURE [dbo].[Fdp_User_Get]
	  @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	SELECT 
		  U.FdpUserId
		, U.CDSId
		, U.FullName
		, U.IsActive
		, U.IsAdmin
		, dbo.Fdp_UserProgrammes_GetMany(U.CDSId) AS Programmes
		, U.CreatedOn
		, U.CreatedBy
		, U.UpdatedOn
		, U.UpdatedBy
		
	FROM Fdp_User AS U
	WHERE
	U.CDSId = @CDSId;