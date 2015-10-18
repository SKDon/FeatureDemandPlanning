CREATE FUNCTION [FN_Programme_Packs_Get]( 
	@p_prog_id INT,
    @p_doc_id INT
) 
RETURNS @result TABLE (
	VehicleMake NVARCHAR(500),
	VehicleName NVARCHAR(500),
	VehicleAKA NVARCHAR(500),
	ProgrammeId INT,
	ModelYear NVARCHAR(50),
	PackId INT,
	PackName NVARCHAR(500),
	PackFeatureCode NVARCHAR(10),
	ExtraInfo NVARCHAR(500),
	Id INT,
	CreatedBy NVARCHAR(8),
	CreatedOn DATETIME,
	UpdatedBy NVARCHAR(8),
	LastUpdated DATETIME
)  
AS
BEGIN

  DECLARE @p_archived BIT;
  DECLARE @p_recCount INT;	
  	
  SELECT @p_archived = Archived 
  FROM OXO_Doc 
  WHERE Id = @p_doc_id	
  AND Programme_Id = @p_prog_id;

  IF (ISNULL(@p_archived,0) = 0) 
  
  	INSERT INTO @result
    SELECT VehicleMake, VehicleName, VehicleAKA,
	       ProgrammeId, ModelYear, PackId, PackName, PackFeatureCode,
	       ExtraInfo, Id,
	       CreatedBy, CreatedOn, UpdatedBy, LastUpdated
	FROM OXO_Pack_Feature_VW
	WHERE ProgrammeId = @p_prog_id;
	
	--SELECT @p_recCount = COUNT(*) FROM @result;
	--IF @p_recCount = 0
	--	INSERT INTO @result
	--		SELECT VehicleMake, VehicleName, VehicleAKA,
	--			    Id, ModelYear, 1000, 'No Pack', NULL,
	--			   null, -1000,
	--			   'system', GetDate(), 'system', GetDate()
	--		FROM OXO_Programme_VW
	--		WHERE Id = @p_prog_id;
  
  ELSE
  
	INSERT INTO @result
    SELECT VehicleMake, VehicleName, VehicleAKA,
	       ProgrammeId, ModelYear, PackId, PackName, PackFeatureCode,
	       ExtraInfo, Id,
	       CreatedBy, CreatedOn, UpdatedBy, LastUpdated
	FROM OXO_Archived_Packs_VW
	WHERE ProgrammeId = @p_prog_id
	AND   Doc_Id = @p_doc_id;
		
   RETURN;
	
END
