CREATE PROCEDURE [dbo].[OXO_Model_GetMany]
   @p_make NVARCHAR(50) = NULL,	
   @p_prog_id int = NULL,
   @p_doc_id int = NULL,
   @p_cdsid NVARCHAR(50) = NULL 
AS
	
  IF (@p_prog_id IS NULL AND @p_doc_id IS NULL) 
  BEGIN
	 SELECT DisplayOrder,
				VehicleName,
				VehicleAKA,
				ModelYear,
				DisplayFormat,
				Name,
				NameWithBR,
				Shape AS BodyShape,
				Doors,
				Wheelbase,
				Size AS EngineSize,
				Cylinder,
				Turbo,
				Fuel_Type AS FuelType,
				Power,
				Electrification,
				Type AS TransType,
				Drivetrain,
				TrimName,
				Abbreviation,
				Level AS TrimLevel,				
	           Id, 
	           Programme_Id AS ProgrammeId , 
	           Body_Id AS BodyId, 
	           Engine_Id AS EngineId, 
	           Transmission_Id AS TransmissionId, 
	           Trim_Id As TrimId, 
	           Active, 
	           Created_By AS CreatedBy, 
	           Created_On AS CreatedOn, 
	           Updated_By AS UpdatedBy, 
	           Last_Updated AS LastUpdated, 
	           BMC, CoA, DPCK, KD,
	           0 AS MarketsCount
	FROM OXO_Models_VW
	WHERE (Programme_Id = @p_prog_id OR @p_prog_id IS NULL)
	AND   (ISNULL(@p_make, '') = '' OR Make = @p_make)
	AND Active = 1
	ORDER BY COA Desc, Shape, DisplayOrder;
  
  END
  ELSE
  BEGIN
	
	DECLARE @p_archived BIT;

	SELECT @p_archived = Archived 
	FROM OXO_Doc 
	WHERE Id = @p_doc_id	
	AND Programme_Id = @p_prog_id;
  
	IF ISNULL(@p_archived, 0) = 0
	BEGIN
		SELECT 
		M.DisplayOrder,
		M.VehicleName,
		M.VehicleAKA,
		M.ModelYear,    
		M.DisplayFormat,        
		M.Name,       
		NameWithBR,
		M.Shape AS BodyShape,
		M.Doors,
		M.Wheelbase,
		M.Size AS EngineSize,
		M.Cylinder,
		M.Turbo,
		M.Fuel_Type AS FuelType,
		M.Power,
		M.Electrification,
		M.Type AS TransType,
		M.DriveTrain,
		M.TrimName,
		M.Abbreviation,
		M.Level AS TrimLevel,
		M.Body_Id as BodyId,
		M.Engine_Id as EngineId,
		M.Transmission_Id  AS TransmissionId,  
		M.Trim_Id  AS TrimId,  
		M.Active  AS Active,  
		M.Created_By  AS CreatedBy,  
		M.Created_On  AS CreatedOn,  
		M.Updated_By  AS UpdatedBy,  
		M.Last_Updated  AS LastUpdated,  
		M.BMC,
		M.CoA,
		M.DPCK,
		M.KD,
		M.Id,
		M.Programme_Id as ProgrammeId,
		dbo.OXO_MarketCountByVariant(M.Id,@p_doc_id) AS MarketsCount
		FROM OXO_Models_VW M
		WHERE (@p_prog_id IS NULL OR M.Programme_Id = @p_prog_id)   
		AND M.Active = 1
		AND EXISTS
		(
			-- Check Permission
			SELECT 1
			FROM dbo.OXO_Permission PM
			WHERE PM.Object_Type = 'Programme'
			AND PM.Operation IN ('CanEdit')
			AND PM.Object_Id = M.Programme_Id
			AND PM.CDSID = ISNULL(@p_cdsid, PM.CDSID)
			
		)
		ORDER BY M.CoA DESC, M.Shape, M.DisplayOrder;  
	END
	ELSE
	BEGIN
		SELECT 
		M.DisplayOrder,
		M.VehicleName,
		M.VehicleAKA,
		M.ModelYear,    
		M.DisplayFormat,        
		M.Name,       
		NameWithBR,
		M.Shape AS BodyShape,
		M.Doors,
		M.Wheelbase,
		M.Size AS EngineSize,
		M.Cylinder,
		M.Turbo,
		M.Fuel_Type AS FuelType,
		M.Power,
		M.Electrification,
		M.Type AS TransType,
		M.DriveTrain,
		M.TrimName,
		M.Abbreviation,
		M.Level AS TrimLevel,
		M.Body_Id as BodyId,
		M.Engine_Id as EngineId,
		M.Transmission_Id  AS TransmissionId,  
		M.Trim_Id  AS TrimId,  
		M.Active  AS Active,  
		M.Created_By  AS CreatedBy,  
		M.Created_On  AS CreatedOn,  
		M.Updated_By  AS UpdatedBy,  
		M.Last_Updated  AS LastUpdated,  
		M.BMC,
		M.CoA,
		M.DPCK,
		M.KD,
		M.Id,
		M.Programme_Id as ProgrammeId,
		dbo.OXO_MarketCountByVariant(M.Id,@p_doc_id) AS MarketsCount
		FROM OXO_Archived_Models_VW M
		WHERE (@p_prog_id IS NULL OR M.Programme_Id = @p_prog_id)
		AND (@p_doc_id IS NULL OR M.Doc_Id = @p_doc_id)   
		AND M.Active = 1
		AND EXISTS
		(
			-- Check Permission
			SELECT 1
			FROM dbo.OXO_Permission PM
			WHERE PM.Object_Type = 'Programme'
			AND PM.Operation IN ('CanEdit')
			AND PM.Object_Id = M.Programme_Id
			AND PM.CDSID = ISNULL(@p_cdsid, PM.CDSID)
			
		)
		ORDER BY M.CoA DESC, M.Shape, M.DisplayOrder;  
	END
  END

