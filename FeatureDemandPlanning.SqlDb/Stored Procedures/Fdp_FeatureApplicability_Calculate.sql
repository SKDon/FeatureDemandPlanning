CREATE PROCEDURE [dbo].[Fdp_FeatureApplicability_Calculate]
	@FdpVolumeHeaderId AS INT
AS
	SET NOCOUNT ON;
	
	DECLARE @DocumentId AS INT;
	DECLARE @Models AS NVARCHAR(MAX) = N'';
	DECLARE @MarketId AS INT;
	DECLARE @MarketGroupId AS INT;
	
	SELECT @DocumentId = DocumentId FROM Fdp_VolumeHeader_VW WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;

	-- Remove all the current applicability information for all markets
	
	DELETE FROM Fdp_FeatureApplicability WHERE DocumentId = @DocumentId;

	DECLARE db_cursor CURSOR FOR  
	SELECT M.Market_Id
	FROM 
	OXO_Doc AS D
	JOIN OXO_Programme_MarketGroupMarket_VW AS M ON D.Programme_Id = M.Programme_Id
	WHERE
	D.Id = @DocumentId

	UNION

	SELECT NULL AS Market_Id

	OPEN db_cursor  
	FETCH NEXT FROM db_cursor INTO @MarketId  

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		SET @Models = NULL;
		
		SELECT TOP 1 @MarketGroupId = Market_Group_Id
		FROM
		OXO_Doc AS D
		JOIN OXO_Programme_MarketGroupMarket_VW AS M ON D.Programme_Id = M.Programme_Id
		WHERE
		D.Id = @DocumentId
		AND
		M.Market_Id = @MarketId

		SELECT @Models = COALESCE(@Models + ',' ,'') + '[' + CAST(MODEL.Id AS NVARCHAR(10)) + ']'
		FROM 
		dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(@FdpVolumeHeaderId, @MarketId, NULL, NULL) AS MODEL

		PRINT CAST(ISNULL(@MarketId, 0) AS NVARCHAR(10)) + ': ' + ISNULL(@Models, 'None')

		IF @Models IS NOT NULL
		BEGIN
			
			IF @MarketId IS NOT NULL
			BEGIN
				INSERT INTO Fdp_FeatureApplicability
				(
					  DocumentId
					, MarketId
					, ModelId
					, FeatureId
					, Applicability
					, ModelIdentifier
				)
				SELECT
					  @DocumentId AS DocumentId
					, @MarketId AS MarketId
					, Model_Id AS ModelId
					, Feature_Id AS FeatureId
					, MAX(OXO_Code) AS Applicability
					, 'O' + CAST(Model_Id AS NVARCHAR(10)) AS ModelIdentifier
				FROM 
				dbo.FN_OXO_Data_Get_FBM_Market(@DocumentId, @MarketGroupId, @MarketId, @Models)
				GROUP BY
				Feature_Id, Model_Id	
			END
			ELSE
			BEGIN
				INSERT INTO Fdp_FeatureApplicability
				(
					  DocumentId
					, MarketId
					, ModelId
					, FeatureId
					, Applicability
					, ModelIdentifier
				)
				SELECT
					  @DocumentId AS DocumentId
					, @MarketId AS MarketId
					, Model_Id AS ModelId
					, Feature_Id AS FeatureId
					, MAX(OXO_Code) AS Applicability
					, 'O' + CAST(Model_Id AS NVARCHAR(10)) AS ModelIdentifier
				FROM 
				dbo.FN_OXO_Data_Get_FBM_MarketGroup(@DocumentId, NULL, @Models)
				GROUP BY
				Feature_Id, Model_Id
			END
			
		END

		FETCH NEXT FROM db_cursor INTO @MarketId;
	END  

	CLOSE db_cursor;
	DEALLOCATE db_cursor;