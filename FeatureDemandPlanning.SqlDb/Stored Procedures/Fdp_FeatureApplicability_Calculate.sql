CREATE PROCEDURE [dbo].[Fdp_FeatureApplicability_Calculate]
	@FdpVolumeHeaderId AS INT
AS
	SET NOCOUNT ON;
	
	DECLARE @DocumentId AS INT;
	DECLARE @Models AS NVARCHAR(MAX) = N'';
	DECLARE @MarketId AS INT;
	DECLARE @MarketGroupId AS INT;
	DECLARE @Message AS NVARCHAR(MAX);
	
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

		SET @Message = CAST(ISNULL(@MarketId, 0) AS NVARCHAR(10)) + ': ' + ISNULL(@Models, 'None')
		RAISERROR(@Message, 0, 1) WITH NOWAIT;

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
				
				INSERT INTO Fdp_FeatureApplicability
				(
					  DocumentId
					, MarketId
					, ModelId
					, FeaturePackId
					, Applicability
					, ModelIdentifier
				)
				SELECT 
					  H.DocumentId
					, MK.Market_Id
					, M.Id												AS ModelId
					, F.FeaturePackId
					, CASE 
						WHEN P1.Id IS NOT NULL AND P1.OXO_Code IS NOT NULL THEN P1.OXO_Code
						WHEN P2.Id IS NOT NULL AND P2.OXO_Code IS NOT NULL THEN P2.OXO_Code
						WHEN P3.Id IS NOT NULL AND P3.OXO_Code IS NOT NULL THEN P3.OXO_Code
						ELSE 'NA'
					  END AS Applicability
					, 'O' + CAST(M.Id AS NVARCHAR(10))					AS ModelIdentifier
				FROM 
				Fdp_VolumeHeader_VW						AS H
				JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON H.ProgrammeId = MK.Programme_Id
				CROSS APPLY dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(H.FdpVolumeHeaderId, MK.Market_Id, NULL, NULL) 
														AS M
				JOIN Fdp_Feature_VW						AS F	ON H.DocumentId = F.DocumentId
																AND F.FeatureId		IS NULL
																AND F.FeaturePackId IS NOT NULL
				-- Market level
				LEFT JOIN OXO_Item_Data_PCK				AS P1	ON	H.DocumentId		= P1.OXO_Doc_Id
																AND MK.Market_Id		= P1.Market_Id
																AND P1.Market_Group_Id	IS NULL
																AND M.Id				= P1.Model_Id
																AND F.FeaturePackId		= P1.Pack_Id
																AND P1.Active			= 1
				-- Market group level
				LEFT JOIN OXO_Item_Data_PCK				AS P2	ON	H.DocumentId		= P2.OXO_Doc_Id
																AND MK.Market_Group_Id	= P2.Market_Group_Id
																AND P2.Market_Id		IS NULL
																AND M.Id				= P2.Model_Id
																AND F.FeaturePackId		= P2.Pack_Id
																AND P2.Active			= 1
				-- Global level
				LEFT JOIN OXO_Item_Data_PCK				AS P3	ON	H.DocumentId		= P3.OXO_Doc_Id
																AND P3.Market_Id		= -1
																AND M.Id				= P3.Model_Id
																AND F.FeaturePackId		= P3.Pack_Id
																AND P3.Active			= 1

				WHERE
				H.FdpVolumeHeaderId = @FdpVolumeHeaderId
				AND
				MK.Market_Id = @MarketId
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