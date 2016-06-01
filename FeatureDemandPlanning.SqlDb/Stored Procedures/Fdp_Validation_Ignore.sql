CREATE PROCEDURE [dbo].[Fdp_Validation_Ignore]
	  @FdpValidationId INT,
	  @CDSId NVARCHAR(16)
AS

SET NOCOUNT ON;

DECLARE @FdpVolumeHeaderId AS INT;
DECLARE @MarketId AS INT;
DECLARE @Message AS NVARCHAR(MAX);

SELECT @FdpVolumeHeaderId = FdpVolumeHeaderId, @MarketId = MarketId, @Message = [Message]
FROM Fdp_Validation
WHERE
FdpValidationId = @FdpValidationId

IF NOT EXISTS(SELECT TOP 1 1 FROM Fdp_ValidationIgnore WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId AND MarketId = @MarketId AND [Message] = @Message)
BEGIN
	INSERT INTO Fdp_ValidationIgnore
	(
		  FdpVolumeHeaderId
		, MarketId
		, [Message]
		, IsActive
	)
	VALUES
	(
		  @FdpVolumeHeaderId
		, @MarketId
		, @Message
		, 1
	)
END