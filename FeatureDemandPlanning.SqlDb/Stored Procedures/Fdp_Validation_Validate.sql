CREATE PROCEDURE [dbo].[Fdp_Validation_Validate] 
	  @FdpVolumeHeaderId	AS INT
	, @MarketId				AS INT = NULL
	, @CDSId				AS NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;

	-- Lower any validation errors for that document / market
	-- This stops any validation errors that are no longer relevant from surfacing
	
	-- Lower any changeset validation specifically for the user
	
	UPDATE V SET IsActive = 0
	FROM
	Fdp_ChangesetDataItem_VW	AS C
	JOIN Fdp_Validation			AS V ON C.FdpChangesetDataItemId = V.FdpChangesetDataItemId
	WHERE
	C.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR V.MarketId = @MarketId)
	AND
	C.CDSId = @CDSId
	
	-- Lower any global validation not associated with a changeset
	
	UPDATE V SET IsActive = 0
	FROM
	Fdp_Validation AS V
	WHERE
	V.FdpChangesetDataItemId IS NULL
	AND
	V.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR V.MarketId = @MarketId)
	
	-- We have number of validation rules - Validate against each in turn, adding validation entries as necessary

	-- 1. Take rate above 100% and below 0% is not allowed
	-- 2. Volume for a feature cannot exceed the volume for a model
	-- 3. Total volumes for models at a market level cannot exceed the total volume for the market
	-- 4. Total % take for models at a market level cannot exceed 100%
	-- 5. Take rate for standard features should be 100%
	-- 6. Take rate for all features as part of packs should be equivalent
	-- 7. EFG (Exclusive feature group). All features in a group must add up to 100% (or less if information is incomplete)
	-- 8. Non-applicable features should be 0%
	
	DECLARE @CurrentStoredProcedureName AS NVARCHAR(100);
	DECLARE @Sql AS NVARCHAR(MAX);
	DECLARE @ParmDefinition NVARCHAR(500);
	DECLARE @ValidationRoutines AS TABLE
	(
		  StoredProcedureName NVARCHAR(100)
		, Processed BIT
	)
	INSERT INTO @ValidationRoutines (StoredProcedureName, Processed)
	SELECT StoredProcedureName, 0
	FROM Fdp_ValidationRule
	WHERE
	IsActive = 1
	ORDER BY
	ValidationOrder;

	SELECT TOP 1 @CurrentStoredProcedureName = StoredProcedureName FROM @ValidationRoutines WHERE Processed = 0

	WHILE @CurrentStoredProcedureName IS NOT NULL
	BEGIN
		SET @ParmDefinition = N'@p1 INT, @p2 INT = NULL, @p3 NVARCHAR(16)'
		SET @Sql = @CurrentStoredProcedureName + N' @p1, @p2, @p3'
		EXEC sp_executesql 
		  @Sql
		, @ParmDefinition
		, @p1 = @FdpVolumeHeaderId
		, @p2 = @MarketId
		, @p3 = @CDSId 
		
		UPDATE @ValidationRoutines SET Processed = 1 WHERE StoredProcedureName = @CurrentStoredProcedureName;
		SET @CurrentStoredProcedureName = NULL
		SELECT TOP 1 @CurrentStoredProcedureName = StoredProcedureName FROM @ValidationRoutines WHERE Processed = 0
	END

END