CREATE PROCEDURE [dbo].[OXO_OXODoc_Get] 
  @p_Id int,
  @p_Programme_Id int = 0
AS
	
	 SELECT 
    O.Id  AS Id,
    O.Programme_Id AS ProgrammeId,
    O.Gateway AS Gateway,
	dbo.OXO_GetNextGateway(O.Gateway) AS NextGateway, 
	O.Version_Id AS VersionId,
	O.Status AS Status,
	O.Owner AS Owner,  
	V.VehicleName,
	V.VehicleAKA,
	V.ModelYear,
	V.VehicleMake,
    O.Created_By  AS Created_By,  
    O.Created_On  AS Created_On,  
    O.Updated_By  AS Updated_By,  
    O.Last_Updated  AS Last_Updated,
    O.Archived,
	[dbo].[OXO_GetChangeTimeStamp] (O.Id, 'MBM', 0) AS MBMCreated,
	[dbo].[OXO_GetChangeTimeStamp] (O.Id, 'MBM', 1) AS MBMUpdated,
	[dbo].[OXO_GetChangeTimeStamp] (O.Id, 'FBM', 0) AS FBMCreated,
	[dbo].[OXO_GetChangeTimeStamp] (O.Id, 'FBM', 1) AS FBMUpdated	 
		  
    FROM dbo.OXO_Doc O   
    INNER JOIN dbo.OXO_Programme_VW V
    ON O.Programme_Id = V.Id
	WHERE (@p_Id = 0 OR O.Id = @p_Id)
	AND (@p_Programme_Id = 0 OR O.Programme_Id = @p_Programme_Id);

