CREATE PROCEDURE [dbo].[Fdp_SpecialFeature_GetMany] 
	  @ProgrammeId	INT				= NULL
	, @Gateway		NVARCHAR(100)	= NULL
	, @CDSId		NVARCHAR(16)	= NULL
AS
	SET NOCOUNT ON;

	SELECT 
		  SF.FdpSpecialFeatureId
		, SF.ProgrammeId
		, SF.Gateway
		, SF.FeatureCode
		, SFT.FdpSpecialFeatureTypeId
		, SFT.SpecialFeatureType
		, SFT.[Description] AS FeatureDescription
		, SF.CreatedOn
		, SF.CreatedBy
		, SF.UpdatedOn
		, SF.UpdatedBy
		, SF.IsActive

	FROM Fdp_SpecialFeature		AS SF
	JOIN Fdp_SpecialFeatureType AS SFT ON SF.FdpSpecialFeatureTypeId = SFT.FdpSpecialFeatureTypeId
	WHERE 
	(@ProgrammeId IS NULL OR SF.ProgrammeId = @ProgrammeId)
	AND
	(@Gateway IS NULL OR SF.Gateway = @Gateway)
	AND
	SF.IsActive = 1
	ORDER BY
	SF.FeatureCode;