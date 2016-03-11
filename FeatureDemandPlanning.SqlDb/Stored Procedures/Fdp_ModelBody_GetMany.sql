
CREATE PROCEDURE [dbo].[Fdp_ModelBody_GetMany]
   @DocumentId INT = NULL
AS
	
   SELECT 
      B.Id					AS Id
    , D.Id					AS DocumentId
    , B.Programme_Id		AS ProgrammeId
    , B.Shape				AS Shape 
    , B.Doors				AS Doors
    , B.Wheelbase			AS Wheelbase  
    , ISNULL(B.Active, 1)	AS Active
    , B.Created_By			AS Created_By  
    , B.Created_On			AS Created_On  
    , B.Updated_By			AS Updated_By  
    , B.Last_Updated		AS LastUpdated 
    , CAST(0 AS BIT)		AS IsArchived
    FROM 
    dbo.OXO_Doc					AS D
    JOIN dbo.OXO_Programme_Body	AS B ON D.Programme_Id = B.Programme_Id
    WHERE 
    (@DocumentId IS NULL OR D.Id = @DocumentId)
    AND
    ISNULL(D.Archived, 0) = 0 
    
    UNION
    
    SELECT 
      B.Id					AS Id
    , D.Id					AS DocumentId
    , B.Programme_Id		AS ProgrammeId
    , B.Shape				AS Shape 
    , B.Doors				AS Doors
    , B.Wheelbase			AS Wheelbase  
    , ISNULL(B.Active, 1)	AS Active
    , B.Created_By			AS Created_By  
    , B.Created_On			AS Created_On  
    , B.Updated_By			AS Updated_By  
    , B.Last_Updated		AS LastUpdated 
    , CAST(1 AS BIT)		AS IsArchived
    FROM 
    dbo.OXO_Doc					AS D
    JOIN dbo.OXO_Archived_Programme_Body	AS B ON D.Id = B.Doc_Id
    WHERE 
    (@DocumentId IS NULL OR D.Id = @DocumentId)
    AND
    ISNULL(D.Archived, 0) = 1