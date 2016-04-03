CREATE VIEW [dbo].[Fdp_Import_VW] AS

	WITH TakeRateFiles AS
	(
		SELECT DocumentId, MAX(FdpVolumeHeaderId) AS FdpVolumeHeaderId
		FROM
		Fdp_VolumeHeader
		WHERE
		FdpTakeRateStatusId <> 3
		GROUP BY
		DocumentId
	)
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
		, I.[Derivative Description]						AS ImportDerivative
		, I.[Trim Pack Description]							AS ImportTrim
		, I.[Bff Feature Code]								AS ImportFeatureCode
		, I.[Feature Description]							AS ImportFeature
		, dbo.fn_Fdp_ParsedVolume_Get(I.[Count of Specific Order No]) AS ImportVolume
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
		, CASE 
			WHEN DMAP.IsArchived = 0 THEN M1.Id
			ELSE M3.Id
		  END												AS ModelId
		, M2.FdpModelId
		, CASE
			WHEN M1.Id			IS NOT NULL THEN M1.BMC
			WHEN M2.FdpModelId	IS NOT NULL THEN M2.BMC
			WHEN M3.Id			IS NOT NULL THEN M3.BMC
			ELSE DMAP.MappedDerivativeCode
		  END												AS BMC
		, DMAP.BodyId
		, CASE 
			WHEN DMAP.IsArchived = 0 THEN B1.Shape
			ELSE B2.Shape
		  END												AS BodyShape
		, CASE 
			WHEN DMAP.IsArchived = 0 THEN B1.Doors
			ELSE B2.Doors
		  END												AS BodyDoors
		, CASE 
			WHEN DMAP.IsArchived = 0 THEN B1.Wheelbase
			ELSE B2.Wheelbase
		  END												AS BodyWheelbase
		, TMAP.TrimId
		, TMAP.FdpTrimId
		, TMAP.MappedTrim									AS TrimName
		, TMAP.[Level]										AS TrimLevel
		, TMAP.DPCK
		, DMAP.EngineId
		, CASE 
			WHEN DMAP.IsArchived = 0 THEN E1.Size
			ELSE E2.Size
		  END												AS EngineSize
		, CASE 
			WHEN DMAP.IsArchived = 0 THEN E1.Fuel_Type
			ELSE E2.Fuel_Type
		  END												AS EngineFuelType
		, CASE 
			WHEN DMAP.IsArchived = 0 THEN E1.Cylinder
			ELSE E2.Cylinder
		  END												AS EngineCylinder
		, ISNULL(CASE 
			WHEN DMAP.IsArchived = 0 THEN E1.Turbo
			ELSE E2.Turbo
		  END, '')											AS EngineTurbo
		, CASE 
			WHEN DMAP.IsArchived = 0 THEN E1.[Power]
			ELSE E2.[Power]
		  END												AS EnginePower
		, ISNULL(CASE 
			WHEN DMAP.IsArchived = 0 THEN E1.Electrification
			ELSE E2.Electrification
		  END, '')											AS EngineElectrification
		, DMAP.TransmissionId
		, CASE 
			WHEN DMAP.IsArchived = 0 THEN TM1.[Type]
			ELSE TM2.[Type]
		  END												AS TransmissionType
		, CASE 
			WHEN DMAP.IsArchived = 0 THEN TM1.Drivetrain
			ELSE TM2.Drivetrain
		  END												AS TransmissionDrivetrain
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
					WHEN DMAP.DocumentId IS NULL AND SMAP.FdpSpecialFeatureMappingId IS NULL
					THEN 1 
					ELSE 0
				END AS BIT)									AS IsDerivativeMissing
		, CAST( CASE 
					WHEN TMAP.DocumentId IS NULL AND SMAP.FdpSpecialFeatureMappingId IS NULL
					THEN 1 
					ELSE 0
				END AS BIT)									AS IsTrimMissing
		, CAST( CASE
					WHEN FMAP.DocumentId IS NULL AND SMAP.FdpSpecialFeatureMappingId IS NULL
					THEN 1
					ELSE 0
				END AS BIT)									AS IsFeatureMissing
		, CAST( CASE
					WHEN CUR.FdpVolumeHeaderId IS NULL
					THEN 0
					ELSE 1
				END AS BIT)									AS IsExistingData
		, CAST( CASE
					WHEN SMAP.FdpSpecialFeatureMappingId IS NOT NULL
					THEN 1
					ELSE 0
				END AS BIT)									AS IsSpecialFeatureCode
		, CUR1.FdpVolumeHeaderId
		
	FROM Fdp_Import							AS IH
	JOIN Fdp_ImportData						AS I		ON	IH.FdpImportId				= I.FdpImportId
														AND I.[Count of Specific Order No] IS NOT NULL
	JOIN OXO_Doc							AS D		ON	IH.DocumentId				= D.Id
	JOIN Fdp_ImportQueue					AS Q		ON	IH.FdpImportQueueId			= Q.FdpImportQueueId
	JOIN Fdp_ImportStatus					AS S		ON	Q.FdpImportStatusId			= S.FdpImportStatusId
	
	JOIN OXO_Programme_VW					AS P		ON	IH.ProgrammeId				= P.Id
	
	-- Mapping of market details
	
	LEFT JOIN Fdp_MarketMapping_VW			AS MMAP		ON	I.[Country Description]     = MMAP.Market_Name
														AND IH.ProgrammeId				= MMAP.ProgrammeId
														AND IH.Gateway					= MMAP.Gateway
	
	-- Mapping of derivative details (non-archived)
	
	LEFT JOIN Fdp_DerivativeMapping_VW		AS DMAP		ON	IH.DocumentId				= DMAP.DocumentId
														AND I.[Derivative Code]			= DMAP.ImportDerivativeCode 
	LEFT JOIN OXO_Programme_Body			AS B1		ON	DMAP.BodyId					= B1.Id
														AND DMAP.IsArchived				= 0												
	LEFT JOIN OXO_Programme_Engine			AS E1		ON	DMAP.EngineId				= E1.Id
														AND DMAP.IsArchived				= 0													
	LEFT JOIN OXO_Programme_Transmission	AS TM1		ON	DMAP.TransmissionId			= TM1.Id
														AND DMAP.IsArchived				= 0	

	-- Mapping of derivative details (archived)

	LEFT JOIN OXO_Archived_Programme_Body	AS B2		ON	DMAP.BodyId					= B2.Id
														AND DMAP.IsArchived				= 1												
	LEFT JOIN OXO_Archived_Programme_Engine	AS E2		ON	DMAP.EngineId				= E2.Id
														AND DMAP.IsArchived				= 1													
	LEFT JOIN OXO_Archived_Programme_Transmission	AS TM2		ON	DMAP.TransmissionId			= TM2.Id
														AND DMAP.IsArchived				= 1
														
	-- Mapping of trim details	
																										
	LEFT JOIN Fdp_TrimMapping_VW			AS TMAP		ON IH.DocumentId				= TMAP.DocumentId
														AND I.[Trim Pack Description]	= TMAP.ImportTrim	
														AND DMAP.MappedDerivativeCode	= TMAP.BMC														
	-- Mapping of features		
													
	LEFT JOIN Fdp_FeatureMapping_VW			AS FMAP		ON	IH.DocumentId				= FMAP.DocumentId
														AND I.[Bff Feature Code]		= FMAP.ImportFeatureCode
	LEFT JOIN Fdp_SpecialFeatureMapping_VW	AS SMAP		ON	IH.DocumentId				= SMAP.DocumentId
														AND I.[Bff Feature Code]		= SMAP.ImportFeatureCode
														AND SMAP.IsActive				= 1
														
	-- The combination of body, engine, transmission and trim gives us the model
	-- This will either be an existing OXO model, or an FDP model (FDP derivative, trim or both)
	
	LEFT JOIN OXO_Programme_Model			AS M1		WITH (INDEX(Ix_NC_OXO_Programme_Model_Cover))
														ON	IH.ProgrammeId				= M1.Programme_Id
														AND DMAP.BodyId					= M1.Body_Id
														AND DMAP.EngineId				= M1.Engine_Id
														AND DMAP.TransmissionId			= M1.Transmission_Id
														AND TMAP.TrimId					= M1.Trim_Id
														AND M1.Active					= 1
														AND DMAP.IsArchived				= 0
														
	LEFT JOIN Fdp_Model_VW					AS M2		ON	IH.ProgrammeId				= M2.ProgrammeId
														AND IH.Gateway					= M2.Gateway
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

	LEFT JOIN OXO_Archived_Programme_Model	AS M3		ON	IH.DocumentId				= M3.Doc_Id
														AND DMAP.BodyId					= M3.Body_Id
														AND DMAP.EngineId				= M3.Engine_Id
														AND DMAP.TransmissionId			= M3.Transmission_Id
														AND TMAP.TrimId					= M3.Trim_Id
														AND M3.Active					= 1
														AND DMAP.IsArchived				= 1
													
	-- Get extended details for the features
	
	LEFT JOIN TakeRateFiles					AS CUR1		ON	IH.DocumentId				= CUR1.DocumentId
	LEFT JOIN
	(
		SELECT 
			  FdpVolumeHeaderId
			, MarketId
			, ModelId
			, FdpModelId
			, FeatureId
			, FdpFeatureId
			, FeaturePackId
			, SUM(Volume) AS Volume
		FROM Fdp_VolumeDataItem
		GROUP BY
		  FdpVolumeHeaderId
		, MarketId
		, ModelId
		, FdpModelId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
	)										
	AS CUR		ON	CUR1.FdpVolumeHeaderId		= CUR.FdpVolumeHeaderId
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
					OR
					(FMAP.FeatureId IS NULL AND CUR.FeatureId IS NULL AND FMAP.FeaturePackId = CUR.FeaturePackId)
				)
				AND dbo.fn_Fdp_ParsedVolume_Get(I.[Count of Specific Order No]) = CUR.Volume




