CREATE PROCEDURE [dbo].[OXO_OXODoc_GetManyByUser]
   @p_cdsid nvarchar(8)
AS
	
	WITH SET_A AS
	(
		SELECT Object_Id, Operation 
		FROM OXO_Permission 
		WHERE CDSID = @p_cdsid
		AND Object_Type = 'Programme'
		AND Operation IN ('CanView','CanEdit')
	)
	SELECT 
		Distinct
		ISNULL(O.Id, -1000)  AS Id,
		V.ID AS ProgrammeId,
		ISNULL(O.Version_Id, 0) AS VersionId,
		ISNULL(O.Gateway, '') AS Gateway,  
		dbo.OXO_GetNextGateway(O.Gateway) AS NextGateway, 
		ISNULL(O.Status, '') AS Status,  
		ISNULL(O.Owner, '') AS Owner,  
		V.VehicleName,
		V.VehicleAKA,
		V.ModelYear,
		V.VehicleMake,
		O.Created_By  AS CreatedBy,  
		O.Created_On  AS CreatedOn,  
		O.Updated_By  AS UpdatedBy,  
		O.Last_Updated  AS LastUpdated,
		[dbo].[OXO_GetChangeTimeStamp] (O.Id, 'MBM', 0) AS MBMCreated,
		[dbo].[OXO_GetChangeTimeStamp] (O.Id, 'MBM', 1) AS MBMUpdated,
		[dbo].[OXO_GetChangeTimeStamp] (O.Id, 'FBM', 0) AS FBMCreated,
		[dbo].[OXO_GetChangeTimeStamp] (O.Id, 'FBM', 1) AS FBMUpdated,
		[dbo].[OXO_GetChangeTimeStamp] (O.Id, 'GSF', 0) AS GSFCreated,
		[dbo].[OXO_GetChangeTimeStamp] (O.Id, 'GSF', 1) AS GSFUpdated,
		ISNULL(G.Display_Order, 1000) AS DisplayOrder,
		O.Archived,
		Editable = CASE WHEN A.Operation = 'CanEdit' THEN 1
		           ELSE 0 END 	 
	FROM SET_A A
	INNER JOIN dbo.OXO_Programme_VW V
	ON A.Object_Id = V.ID
	LEFT OUTER JOIN OXO_DOC O
	ON A.Object_Id = O.Programme_Id
	LEFT OUTER JOIN OXO_Gateway G
    ON O.Gateway = G.Gateway
	WHERE V.OXOEnabled = 1
	ORDER BY VehicleName, V.ModelYear ASC, ISNULL(G.Display_Order, 1000);

