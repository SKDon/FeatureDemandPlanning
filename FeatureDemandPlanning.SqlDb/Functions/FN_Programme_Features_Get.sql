CREATE FUNCTION [dbo].[FN_Programme_Features_Get]( 
	@p_prog_id INT,
    @p_doc_id INT
) 
RETURNS @result TABLE (
	Id int,
	Programme_Id int,
	Make NVARCHAR(100),
	FeatureGroup NVARCHAR(1000),
	FeatureSubGroup NVARCHAR(1000),
	FeatureCode NVARCHAR(50),
	SystemDescription NVARCHAR(4000),
	BrandDescription NVARCHAR(4000),
	FeatureComment nvarchar(4000),
	FeatureRuleText nvarchar(4000),
	LongDescription NVARCHAR(4000),
	DisplayOrder int
)  
AS
BEGIN

  DECLARE @p_archived BIT;
  DECLARE @p_make NVARCHAR(50);
  	
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
    SELECT DISTINCT Id, ProgrammeId, Make, FeatureGroup, FeatureSubGroup, FeatureCode, 
                    SystemDescription, BrandDescription, FeatureComment, FeatureRuleText, 
                    LongDescription, DisplayOrder
	FROM OXO_Programme_Feature_VW
	WHERE ProgrammeId = @p_prog_id;
	
	INSERT INTO @result
	SELECT  -1000, @p_prog_id, @p_make, Group_Name, null AS Sub_Group_Name, '','No Feature Selected', 'No Feature Selected', '', '', '', MAX(Display_Order) AS Display_Order
	FROM OXO_Feature_Group G
	WHERE Status = 1
	AND NOT EXISTS 
	(
		SELECT 1 
		FROM OXO_Programme_Feature_VW F
		WHERE F.ProgrammeId =  @p_prog_id
		AND F.FeatureGroup = G.Group_Name
	)
	GROUP BY Group_Name
				
  END	  
  ELSE
  
	INSERT INTO @result
	SELECT DISTINCT Id, ProgrammeId, Make, FeatureGroup, FeatureSubGroup, FeatureCode, 
					SystemDescription, BrandDescription, FeatureComment, FeatureRuleText, 
					LongDescription, DisplayOrder
	FROM dbo.OXO_Archived_Programme_Feature_VW
	WHERE ProgrammeId = @p_prog_id
	AND doc_id = @p_doc_id;
		
   RETURN;
	
END

