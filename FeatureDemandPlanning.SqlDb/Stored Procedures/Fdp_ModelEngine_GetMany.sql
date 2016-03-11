CREATE PROCEDURE [dbo].[Fdp_ModelEngine_GetMany]
    @DocumentId INT = NULL
AS
	SET NOCOUNT ON;
	
	SELECT 
		  DocumentId
		, Id
		, ProgrammeId 
		, Size
		, Cylinder  
		, Turbo  
		, FuelType  
		, [Power]  
		, Electrification
		, Active
		, CreatedBy  
		, CreatedOn 
		, UpdatedBy  
		, LastUpdated 
		, IsArchived
	FROM
	(
		SELECT 
			  D.Id					AS DocumentId
			, E.Id					AS Id
			, E.Programme_Id		AS ProgrammeId 
			, E.Size				AS Size
			, Cylinder				AS Cylinder  
			, Turbo					AS Turbo  
			, Fuel_Type				AS FuelType  
			, [Power]				AS [Power]  
			, Electrification		AS Electrification
			, ISNULL(Active, 1)		AS Active
			, E.Created_By			AS CreatedBy  
			, E.Created_On			AS CreatedOn 
			, E.Updated_By			AS UpdatedBy  
			, E.Last_Updated		AS LastUpdated 
			, ISNULL(D.Archived, 0)	AS IsArchived
		FROM 
		dbo.OXO_Doc						AS D
		JOIN dbo.OXO_Programme_Engine	AS E	ON	D.Programme_Id = E.Programme_Id
		WHERE 
		(@DocumentId IS NULL OR D.Id = @DocumentId)
		AND
		ISNULL(D.Archived, 0) = 0
		
		UNION
		
		SELECT 
			  D.Id					AS DocumentId
			, E.Id					AS Id
			, E.Programme_Id		AS ProgrammeId 
			, E.Size				AS Size
			, Cylinder				AS Cylinder  
			, Turbo					AS Turbo  
			, Fuel_Type				AS FuelType  
			, [Power]				AS [Power]  
			, Electrification		AS Electrification
			, ISNULL(Active, 1)		AS Active
			, E.Created_By			AS CreatedBy  
			, E.Created_On			AS CreatedOn 
			, E.Updated_By			AS UpdatedBy  
			, E.Last_Updated		AS LastUpdated 
			, ISNULL(D.Archived, 0)	AS IsArchived
		FROM 
		dbo.OXO_Doc								AS D
		JOIN dbo.OXO_Archived_Programme_Engine	AS E	ON	D.Id = E.Doc_Id
		WHERE 
		(@DocumentId IS NULL OR D.Id = @DocumentId)
		AND
		ISNULL(D.Archived, 0) = 1
	)
	AS E
	ORDER BY 
	DocumentId, ProgrammeId, Size, Cylinder, FuelType DESC, [Power]