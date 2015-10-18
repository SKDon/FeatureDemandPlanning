




CREATE VIEW [dbo].[Fdp_Import_VW] AS

	SELECT 
		  IH.FdpImportId
		, Q.ImportQueueId
		, Q.CreatedBy
		, Q.CreatedOn
		, I.LineNumber										AS ImportLineNumber  
		, I.[NSC or Importer Description (Vista Market)]	AS ImportMarket
		, I.[Country Description]							AS ImportCountry
		, I.[Derivative Code]								AS ImportDerivativeCode
		, I.[Trim Pack Description]							AS ImportTrim
		, I.[Bff Feature Code]								AS ImportFeatureCode
		, I.[Feature Description]							AS ImportFeature
		, I.[Count of Specific Order No]					AS ImportVolume
		, SFT.FdpSpecialFeatureTypeId						AS SpecialFeatureCodeTypeId
		, UPPER(SFT.SpecialFeatureType)						AS SpecialFeatureCodeType
		, SFT.[Description]									AS SpecialFeatureCodeDescription
		, P.Id												AS ProgrammeId
		, P.VehicleMake
		, P.VehicleName
		, P.VehicleAKA
		, P.ModelYear										AS ModelYear
		, IH.Gateway										AS Gateway
		, MARKET.Market_Id									AS MarketId
		, MARKET.Market_Name								AS Market
		, MARKET.Market_Group_Id							AS MarketGroupId
		, MARKET.Market_Group_Name							AS MarketGroup
		, M.Id												AS ModelId
		, M.BMC												AS BMC
		, B.Id												AS BodyId
		, B.Shape											AS BodyShape
		, B.Doors											AS BodyDoors
		, B.Wheelbase										AS BodyWheelbase
		, T.Id												AS TrimId
		, T.Name											AS TrimName
		, T.[Level]											AS TrimLevel
		, T.DPCK											AS DPCK
		, E.Id												AS EngineId
		, E.Size											AS EngineSize
		, E.Fuel_Type										AS EngineFuelType
		, E.Cylinder										AS EngineCylinder
		, ISNULL(E.Turbo, '')								AS EngineTurbo
		, E.[Power]											AS EnginePower
		, ISNULL(E.Electrification, '')						AS EngineElectrification
		, TM.Id												AS TransmissionId
		, TM.[Type]											AS TransmissionType
		, TM.Drivetrain										AS TransmissionDrivetrain
		, F.ID												AS FeatureId
		, F.FeatureCode										AS FeatureCode
		, F.SystemDescription								AS FeatureDescription
		, F.BrandDescription								AS MarketingFeatureDescription
		, FG.Id												AS FeatureGroupId
		, FG.Group_Name										AS FeatureGroup
		, ISNULL(FG.Sub_Group_Name, '')						AS FeatureSubGroup
		, FP.Id												AS FeaturePackId
		, ISNULL(FP.Pack_Name, '')							AS FeaturePack
		, CAST(	CASE 
					WHEN MARKET.Market_Id IS NULL 
					THEN 1 
					ELSE 0
				END AS BIT)									AS IsMarketMissing
		, CAST( CASE 
					WHEN 
						MAP.ProgrammeId IS NULL 
						OR MAP.TrimId IS NULL
						OR MAP.EngineId IS NULL
					THEN 1 
					ELSE 0
				END AS BIT)									AS IsDerivativeMissing
		, CAST( CASE
					WHEN F.ID IS NULL AND SF.FdpImportSpecialFeatureId IS NULL
					THEN 1
					ELSE 0
				END AS BIT)									AS IsFeatureMissing
		, CAST( CASE
					WHEN CUR.FdpVolumeDataItemId IS NULL
					THEN 0
					ELSE 1
				END AS BIT)									AS IsExistingData
		, CAST( CASE
					WHEN SF.FdpImportSpecialFeatureId IS NOT NULL
					THEN 1
					ELSE 0
				END AS BIT)									AS IsSpecialFeatureCode
		
	FROM Fdp_Import							AS IH
	JOIN Fdp_ImportData						AS I		ON	I.FdpImportId				= I.FdpImportId
	JOIN ImportQueue						AS Q		ON	IH.ImportQueueId			= Q.ImportQueueId
	JOIN OXO_Programme_VW					AS P		ON	IH.ProgrammeId				= P.Id
	LEFT JOIN Fdp_TrimMapping				AS MAP		ON	I.[Derivative Code]			= MAP.DerivativeCode
														AND I.[Trim Pack Description]	= MAP.Trim
														AND	IH.ProgrammeId				= MAP.ProgrammeId
	LEFT JOIN Fdp_ImportSpecialFeature		AS SF		ON	IH.FdpImportId				= IH.FdpImportId
														AND I.[Bff Feature Code]		= SF.FeatureCode
	LEFT JOIN Fdp_SpecialFeatureType		AS SFT		ON	SF.FdpSpecialFeatureTypeId	= SFT.FdpSpecialFeatureTypeId
	LEFT JOIN OXO_Programme_Trim			AS T		ON	MAP.TrimId					= T.Id
														AND T.Active					= 1
	LEFT JOIN OXO_Programme_Body			AS B		ON	MAP.ProgrammeId				= B.Programme_Id
														AND B.Active					= 1
	LEFT JOIN OXO_Programme_Engine			AS E		ON	MAP.EngineId				= E.Id
														AND E.Active					= 1
	LEFT JOIN OXO_Programme_Transmission	AS TM		ON	MAP.ProgrammeId				= TM.Programme_Id
														AND TM.Active					= 1
	LEFT JOIN OXO_Programme_Model			AS M		ON	P.Id						= M.Programme_Id
														AND T.Id						= M.Trim_Id
														AND E.Id						= M.Engine_Id
														AND TM.Id						= M.Transmission_Id
														AND M.Active					= 1
	LEFT JOIN Fdp_Market_VW					 AS MARKET	ON	
														(
															I.[Country Description]     = MARKET.Market_Name
															OR
															I.[NSC or Importer Description (Vista Market)] = MARKET.Market_Name
														)
														AND P.Id						= MARKET.Programme_Id
	LEFT JOIN OXO_Programme_Feature_VW		AS F		ON	I.[Bff Feature Code]		= F.FeatureCode
														AND F.ProgrammeId				= P.Id
	LEFT JOIN OXO_Feature_Group				AS FG		ON	F.FeatureGroup				= FG.Group_Name
														AND	ISNULL(F.FeatureSubGroup, '') = ISNULL(FG.Sub_Group_Name, '')
	
	LEFT JOIN OXO_Pack_Feature_Link			AS FL		ON	F.ProgrammeId				= FL.Programme_Id
														AND F.ID						= FL.Feature_Id
	LEFT JOIN OXO_Programme_Pack			AS FP		ON	FL.Pack_Id					= FP.Id
	LEFT JOIN Fdp_VolumeHeader				AS CUR1		ON	P.Id						= CUR1.ProgrammeId
														AND IH.Gateway					= CUR1.Gateway
	LEFT JOIN Fdp_VolumeDataItem			AS CUR		ON	CUR1.FdpVolumeHeaderId		= CUR.FdpVolumeHeaderId
														AND MARKET.Market_Id			= CUR.MarketId
														AND T.Id						= CUR.TrimId
														AND E.Id						= CUR.EngineId
														AND	F.ID						= CUR.FeatureId
														AND CAST(I.[Count of Specific Order No] AS INT)
																					= CUR.Volume




