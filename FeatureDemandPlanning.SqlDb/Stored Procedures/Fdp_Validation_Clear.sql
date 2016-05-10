CREATE PROCEDURE [dbo].[Fdp_Validation_Clear]
	    @FdpVolumeHeaderId INT
	  , @MarketId INT = NULL
	  , @CDSId NVARCHAR(16)
AS

SET NOCOUNT ON;

DELETE FROM Fdp_Validation 
WHERE 
FdpVolumeHeaderId = @FdpVolumeHeaderId 
AND 
(
	ISNULL(ValidationBy, '') = '' 
	OR ValidationBy = @CDSId
)
AND
(@MarketId IS NULL OR MarketId = @MarketId);