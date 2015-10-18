CREATE FUNCTION [FN_Pack_Features_Get]( 
	@p_prog_id INT,
    @p_doc_id INT
) 
RETURNS @result TABLE (
	VehicleMake  NVARCHAR(500),
	VehicleName  NVARCHAR(500),
	VehicleAKA   NVARCHAR(500),
	ProgrammeId  INT,
	ModelYear  NVARCHAR(50),
	PackId  INT,
	PackName NVARCHAR(500),    
	ExtraInfo NVARCHAR(500),
	PackFeatureCode NVARCHAR(50),
	Id   INT,
	SystemDescription NVARCHAR(1000),  
	BrandDescription NVARCHAR(1000),
	FeatureCode NVARCHAR(10),
	OACode NVARCHAR(10),
	CreatedBy  NVARCHAR(8),  
	CreatedOn DATETIME,  
	UpdatedBy NVARCHAR(8),  
	LastUpdated DATETIME
)  

AS
BEGIN

  DECLARE @p_archived BIT;
  DECLARE @p_make NVARCHAR(50);
  DECLARE @p_rec_count 	INT;
  
  	
  SELECT @p_archived = Archived 
  FROM OXO_Doc 
  WHERE Id = @p_doc_id	
  AND Programme_Id = @p_prog_id;
  
  SELECT @p_make = VehicleMake 
  FROM OXO_Programme_VW
  WHERE Id = @p_prog_id;

  IF (ISNULL(@p_archived,0) = 0) 
  BEGIN
  	
  	INSERT INTO @result
    SELECT DISTINCT VehicleMake, VehicleName, VehicleAKA, ProgrammeId, ModelYear,
		   PackId, PackName, ExtraInfo, PackFeatureCode, Id,
		   SystemDescription, BrandDescription, FeatureCode, OACode,
		   CreatedBy, CreatedOn, UpdatedBy, LastUpdated
	FROM OXO_PACK_FEATURE_VW 
	WHERE ProgrammeId = @p_prog_id;	   

	--SELECT @p_rec_count = COUNT(*) FROM @result;    
 --   IF @p_rec_count = 0
    
	--INSERT INTO @result
	--SELECT VehicleMake, VehicleName, VehicleAKA, Id, ModelYear,
	--	   1000, 'No Pack', null, null, -1000, 'No Feature Selected', 'No Feature Selected',
	--	   null, null, 'system', GETDATE(), 'system', GETDATE()	 
	--FROM OXO_Programme_VW
	--WHERE Id = @p_prog_id;
				
  END	  
  ELSE
  
	INSERT INTO @result
	SELECT DISTINCT VehicleMake, VehicleName, VehicleAKA, ProgrammeId, ModelYear,
		   PackId, PackName, ExtraInfo, PackFeatureCode, Id,
		   SystemDescription, BrandDescription, FeatureCode, OACode,
		   CreatedBy, CreatedOn, UpdatedBy, LastUpdated
	FROM dbo.OXO_Archived_PACK_FEATURE_VW 
	WHERE ProgrammeId = @p_prog_id
	AND doc_id = @p_doc_id;
		
   RETURN;
	
END
