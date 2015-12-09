CREATE VIEW [dbo].[Fdp_Import_VW] AS

	SELECT 
		  Q.FdpImportQueueId
		, IH.FdpImportId
		, Q.CreatedBy
		, Q.CreatedOn
		, Q.FdpImportStatusId
		, S.[Status]
		, I.LineNumber										AS ImportLineNumber  
		, I.[NSC or Importer Description (Vista Market)]	AS ImportMarket
		, I.[Country Description]							AS ImportCountry
		, I.[Derivative Code]								AS ImportDerivativeCode
		, I.[Trim Pack Description]							AS ImportTrim
		, I.[Bff Feature Code]								AS ImportFeatureCode
		, I.[Feature Description]							AS ImportFeature
		, I.[Count of Specific Order No]					AS ImportVolume
		, IH.ProgrammeId
		, IH.Gateway
		, IH.DocumentId
		, P.VehicleMake
		, P.VehicleName
		, P.VehicleAKA
		, P.ModelYear										AS ModelYear
		, SMAP.FdpSpecialFeatureMappingId
		, SMAP.FdpSpecialFeatureTypeId						AS SpecialFeatureTypeId
		, UPPER(SMAP.SpecialFeatureType)					AS SpecialFeatureType
		, SMAP.[Description]								AS SpecialFeatureCodeDescription
		, MMAP.Market_Id									AS MarketId
		, MMAP.Market_Name									AS Market
		, MMAP.Market_Group_Id								AS MarketGroupId
		, MMAP.Market_Group_Name							AS MarketGroup
		, M1.Id												AS ModelId
		, M2.FdpModelId
		, CASE
			WHEN M1.Id			IS NOT NULL THEN M1.BMC
			WHEN M2.FdpModelId	IS NOT NULL THEN M2.BMC
			ELSE DMAP.MappedDerivativeCode
		  END												AS BMC
		, B.Id												AS BodyId
		, B.Shape											AS BodyShape
		, B.Doors											AS BodyDoors
		, B.Wheelbase										AS BodyWheelbase
		, TMAP.TrimId
		, TMAP.FdpTrimId
		, TMAP.MappedTrim									AS TrimName
		, TMAP.[Level]										AS TrimLevel
		, TMAP.DPCK
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
		, FMAP.FeatureId
		, FMAP.FdpFeatureId
		, FMAP.MappedFeatureCode							AS FeatureCode
		, FMAP.[Description]								AS FeatureDescription
		, FMAP.BrandDescription								AS FeatureBrandDescription
		, FMAP.FeatureGroupId
		, FMAP.FeatureGroup
		, FMAP.FeatureSubGroup
		, FMAP.FeaturePackId
		, FMAP.FeaturePackCode
		, FMAP.FeaturePackName
		, CAST(	CASE 
					WHEN MMAP.Market_Id IS NULL AND SMAP.FdpSpecialFeatureMappingId IS NULL
					THEN 1 
					ELSE 0
				END AS BIT)									AS IsMarketMissing
		, CAST( CASE 
					WHEN DMAP.ProgrammeId IS NULL AND SMAP.FdpSpecialFeatureMappingId IS NULL
					THEN 1 
					ELSE 0
				END AS BIT)									AS IsDerivativeMissing
		, CAST( CASE 
					WHEN TMAP.ProgrammeId IS NULL AND SMAP.FdpSpecialFeatureMappingId IS NULL
					THEN 1 
					ELSE 0
				END AS BIT)									AS IsTrimMissing
		, CAST( CASE
					WHEN FMAP.ProgrammeId IS NULL AND SMAP.FdpSpecialFeatureMappingId IS NULL
					THEN 1
					ELSE 0
				END AS BIT)									AS IsFeatureMissing
		, CAST( CASE
					WHEN CUR.FdpVolumeDataItemId IS NULL
					THEN 0
					ELSE 1
				END AS BIT)									AS IsExistingData
		, CAST( CASE
					WHEN SMAP.FdpSpecialFeatureMappingId IS NOT NULL
					THEN 1
					ELSE 0
				END AS BIT)									AS IsSpecialFeatureCode
		
	FROM Fdp_Import							AS IH
	JOIN Fdp_ImportData						AS I		ON	IH.FdpImportId				= I.FdpImportId
	JOIN Fdp_ImportQueue					AS Q		ON	IH.FdpImportQueueId			= Q.FdpImportQueueId
	JOIN Fdp_ImportStatus					AS S		ON	Q.FdpImportStatusId			= S.FdpImportStatusId
	JOIN OXO_Programme_VW					AS P		ON	IH.ProgrammeId				= P.Id
	
	-- Mapping of market details
	
	LEFT JOIN Fdp_MarketMapping_VW			AS MMAP		ON	I.[Country Description]     = MMAP.Market_Name
														AND IH.ProgrammeId				= MMAP.ProgrammeId
														AND IH.Gateway					= MMAP.Gateway
	
	-- Mapping of derivative details
	
	LEFT JOIN Fdp_DerivativeMapping_VW		AS DMAP		ON	LTRIM(RTRIM(I.[Derivative Code])) = DMAP.ImportDerivativeCode
														AND IH.ProgrammeId				= DMAP.ProgrammeId
														AND IH.Gateway					= DMAP.Gateway
	LEFT JOIN OXO_Programme_Body			AS B		ON	DMAP.BodyId					= B.Id												
	LEFT JOIN OXO_Programme_Engine			AS E		ON	DMAP.EngineId				= E.Id												
	LEFT JOIN OXO_Programme_Transmission	AS TM		ON	DMAP.TransmissionId			= TM.Id
														
	-- Mapping of trim details	
																										
	LEFT JOIN Fdp_TrimMapping_VW			AS TMAP		ON	I.[Trim Pack Description]	= TMAP.ImportTrim
														AND IH.ProgrammeId				= TMAP.ProgrammeId
														AND IH.Gateway					= TMAP.Gateway															
	-- Mapping of features		
													
	LEFT JOIN Fdp_FeatureMapping_VW			AS FMAP		ON	I.[Bff Feature Code]		= FMAP.ImportFeatureCode
														AND IH.ProgrammeId				= FMAP.ProgrammeId
														AND IH.Gateway					= FMAP.Gateway
	LEFT JOIN Fdp_SpecialFeatureMapping_VW	AS SMAP		ON	I.[Bff Feature Code]		= SMAP.ImportFeatureCode
														AND IH.ProgrammeId				= SMAP.ProgrammeId
														AND IH.Gateway					= SMAP.Gateway
														AND SMAP.IsActive				= 1
														
	-- The combination of body, engine, transmission and trim gives us the model
	-- This will either be an existing OXO model, or an FDP model (FDP derivative, trim or both)
	
	LEFT JOIN OXO_Programme_Model			AS M1		ON	IH.ProgrammeId				= M1.Programme_Id
														AND DMAP.BodyId					= M1.Body_Id
														AND DMAP.EngineId				= M1.Engine_Id
														AND DMAP.TransmissionId			= M1.Transmission_Id
														AND TMAP.TrimId					= M1.Trim_Id
														AND M1.Active					= 1
														
	LEFT JOIN Fdp_Model_VW					AS M2		ON	IH.ProgrammeId				= M2.ProgrammeId
														AND DMAP.BodyId					= M2.BodyId
														AND DMAP.EngineId				= M2.EngineId
														AND DMAP.TransmissionId			= M2.TransmissionId
														AND 
														(
															(
																TMAP.TrimId	= M2.TrimId
																AND
																TMAP.FdpTrimId IS NULL
															)
															OR
															(
																TMAP.FdpTrimId = M2.FdpTrimId
																AND
																TMAP.TrimId	IS NULL
															)
														)
														AND M2.IsActive					= 1
													
	-- Get extended details for the features
	
	LEFT JOIN Fdp_VolumeHeader				AS CUR1		ON	IH.DocumentId				= CUR1.DocumentId
	LEFT JOIN Fdp_VolumeDataItem			AS CUR		ON	CUR1.FdpVolumeHeaderId		= CUR.FdpVolumeHeaderId
														AND MMAP.Market_Id				= CUR.MarketId
														AND 
														(
															M1.Id						= CUR.ModelId
															OR
															M2.FdpModelId				= CUR.FdpModelId
														)
														AND	
														(
															FMAP.FeatureId				= CUR.FeatureId
															OR
															FMAP.FdpFeatureId			= CUR.FdpFeatureId
														)
														AND CAST(I.[Count of Specific Order No] AS INT)
																						= CUR.Volume




