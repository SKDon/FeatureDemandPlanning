CREATE PROCEDURE [dbo].[Fdp_UserMarkets_Save]
	  @CDSId		NVARCHAR(16)
	, @MarketIds	NVARCHAR(MAX)
	, @CreatorCDSID NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpUserId AS INT;
	SELECT TOP 1 @FdpUserId = FdpUserId FROM Fdp_User WHERE CDSId = @CDSId;
	
	DECLARE @Market AS TABLE
	(
		  FdpUserId			INT
		, MarketId			INT
		, FdpUserActionId	INT
	)
	INSERT INTO @Market
	(
		  FdpUserId
		, MarketId
		, FdpUserActionId
	)
	SELECT
		  @FdpUserId AS FdpUserId
		, CAST(SUBSTRING(strval, 2, 5) AS INT) AS MarketId
		, CASE LEFT(strval, 1)
			WHEN 'V' THEN 1
			WHEN 'E' THEN 2
			ELSE 0
		  END
		AS FdpUserActionId
	FROM dbo.FN_SPLIT(@MarketIds, N',')
	
	SELECT FdpUserId, MarketId, MAX(FdpUserActionId) AS FdpUserActionId
	FROM @Market
	GROUP BY
	FdpUserId, MarketId
	
	MERGE INTO Fdp_UserMarketMapping AS TARGET
	USING (
		SELECT FdpUserId, MarketId, MAX(FdpUserActionId) AS FdpUserActionId
		FROM @Market
		GROUP BY
		FdpUserId, MarketId
	) 
	AS SOURCE	ON	TARGET.FdpUserId		= SOURCE.FdpUserId
				AND TARGET.MarketId		= SOURCE.MarketId
				AND TARGET.FdpUserActionId	= SOURCE.FdpUserActionId
				AND TARGET.IsActive			= 1
				
	WHEN MATCHED THEN
		
		UPDATE SET MarketId = SOURCE.MarketId, FdpUserActionId = SOURCE.FdpUserActionId
		
	WHEN NOT MATCHED BY TARGET THEN
	
		INSERT (FdpUserId, MarketId, FdpUserActionId, IsActive) 
		VALUES (FdpUserId, MarketId, FdpUserActionId, 1)
		
	WHEN NOT MATCHED BY SOURCE AND TARGET.FdpUserId = @FdpUserId THEN
	
		DELETE;
	
	EXEC Fdp_UserMarket_GetMany @CDSId = @CDSId;