
CREATE PROCEDURE [dbo].[Fdp_ModelTransmission_Get]
	  @TransmissionId INT
	, @DocumentId INT = NULL
AS
	SET NOCOUNT ON;
	
	SELECT TOP 1
		  DocumentId
		, Id
		, ProgrammeId
		, [Type]
		, Drivetrain 
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
			, T.Id
			, T.Programme_Id		AS ProgrammeId  
			, T.[Type]  
			, T.Drivetrain			AS Drivetrain  
			, ISNULL(T.Active, 1)	AS Active  
			, T.Created_By			AS CreatedBy  
			, T.Created_On			AS CreatedOn  
			, T.Updated_By			AS UpdatedBy  
			, T.Last_Updated		AS LastUpdated 
			, CAST(0 AS BIT)		AS IsArchived
		FROM 
		dbo.OXO_Doc								AS D
		JOIN dbo.OXO_Programme_Transmission		AS T	ON D.Programme_Id = T.Programme_Id
		WHERE 
		(@DocumentId IS NULL OR D.Id = @DocumentId)
		AND
		T.Id = @TransmissionId
		AND
		ISNULL(D.Archived, 0) = 0
	    
		UNION
	    
		SELECT 
			  D.Id					AS DocumentId
			, T.Id
			, T.Programme_Id		AS ProgrammeId  
			, T.[Type]  
			, T.Drivetrain			AS Drivetrain  
			, ISNULL(T.Active, 1)	AS Active  
			, T.Created_By			AS CreatedBy  
			, T.Created_On			AS CreatedOn  
			, T.Updated_By			AS UpdatedBy  
			, T.Last_Updated		AS LastUpdated 
			, CAST(1 AS BIT)		AS IsArchived
		FROM 
		dbo.OXO_Doc										AS D
		JOIN dbo.OXO_Archived_Programme_Transmission	AS T	ON D.Id = T.Doc_Id
		WHERE 
		(@DocumentId IS NULL OR D.Id = @DocumentId)
		AND
		T.Id = @TransmissionId
		AND
		ISNULL(D.Archived, 0) = 1
    )
    AS T
    ORDER BY DocumentId, ProgrammeId, Drivetrain, [Type];