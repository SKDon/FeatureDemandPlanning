
CREATE PROCEDURE [dbo].[OXO_JMFD_GetMany]	
	@p_vehicle NVARCHAR(50) = NULL,
	@p_group NVARCHAR(100) = NULL
AS
	
	IF @p_group = 'ALL'
		SET @p_group = null;
	
	SELECT 
		Id,
		Feat_Code AS FeatureCode,
		OA_Code AS OACode,
		Description AS DEscription,
		Long_Desc AS LongDescription,
		VISTA_Visibility AS VistaVisibility,	
		EFG_Code AS EFG,
		EFG_Desc AS EFGDescription,
		Feature_Group AS FeatureGroup,
		Feature_Sub_Group AS FeatureSubGroup,
		Config_Group AS ConfiguratorGroup,
		Config_Sub_Group AS ConfiguratorSubGroup,
		Jaguar_Desc AS JaguarDescription,
		LandRover_Desc AS LandroverDescription,	
		Applicability AS Applicability
	FROM JMFD
	WHERE (CHARINDEX(@p_vehicle, Applicability) != 0 OR @p_vehicle IS NULL)
	AND (Feature_Group = @p_group OR @p_group IS NULL)

