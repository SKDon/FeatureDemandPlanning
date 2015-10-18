CREATE PROCEDURE [dbo].[OXO_PackFeature_GetMany]
   @p_programme_id INT
AS
	
  SELECT  
    ProgrammeId AS ProgrammeId,
	PackId,
	PackName,
	ExtraInfo AS PackExtraInfo,
	PackFeatureCode,
	Id,
	SystemDescription,
	ISNULL(BrandDescription,SystemDescription) AS BrandDescription,
	FeatureCode,
	OACode,
	CreatedBy,
	CreatedOn,
	UpdatedBy,
	LastUpdated
FROM OXO_Pack_Feature_VW
WHERE ProgrammeId = @p_programme_id

