CREATE FUNCTION [dbo].[FN_OXO_Data_Get] 
(
  @p_section NVARCHAR(50),
  @p_doc_id INT,
  @p_mode NVARCHAR(50),
  @p_object_id INT
)
RETURNS @result TABLE (Feature_Id INT, Pack_Id INT, Model_Id INT, OXO_Code NVARCHAR(50))  
AS
BEGIN

	-- First let's work out which programme this oxo_doc is for?
	-- then use this to find out the list of features that go onto the OXO
	DECLARE @prog_id INT	
	SELECT @prog_id = Programme_Id FROM OXO_Doc WHERE Id = @p_doc_id; 

    IF (@p_mode = 'g')
    BEGIN
		
		IF(@p_section = 'FBM')
		BEGIN
			INSERT INTO @result
			SELECT DISTINCT PF.Id, 0, PM.Id, OD.OXO_Code AS OXO_Code 
			FROM OXO_Programme_Feature_VW PF
			CROSS JOIN OXO_Programme_Model PM
			LEFT OUTER JOIN OXO_Item_Data OD
			ON PF.Id = OD.Feature_Id
			AND OD.Section = 'FBM'
			AND OD.OXO_Doc_Id = @p_doc_id
			AND OD.Market_Id = -1
			AND OD.Active = 1
			AND OD.Model_Id = PM.ID
			WHERE PF.ProgrammeId = @prog_id
			AND PM.Programme_Id = @prog_id
			AND PM.Active = 1;				
		END;
		
		IF(@p_section = 'PCK')
		BEGIN		
		    INSERT INTO @result
			SELECT DISTINCT 0, PK.Id, PM.Id, OD.OXO_Code AS OXO_Code 
			FROM OXO_Programme_Pack PK
			CROSS JOIN OXO_Programme_Model PM
			LEFT OUTER JOIN OXO_Item_Data OD
			ON PK.Id = OD.Pack_Id
			AND OD.Section = 'PCK'
			AND OD.OXO_Doc_Id = @p_doc_id
			AND OD.Market_Id = -1
			AND OD.Active = 1
			AND OD.Model_Id = PM.ID
			WHERE PK.Programme_Id = @prog_id
			AND PM.Programme_Id = @prog_id
			AND PM.Active = 1; 
		END;
		
		IF(@p_section = 'FPS')
		BEGIN
			INSERT INTO @result
			SELECT DISTINCT PKF.Id, PKF.PackId, PM.Id, OD.OXO_Code AS OXO_Code 
			FROM OXO_Pack_Feature_VW PKF
			CROSS JOIN OXO_Programme_Model PM
			LEFT OUTER JOIN OXO_Item_Data OD
			ON PKF.Id = OD.Feature_Id
			AND PKF.PackId = OD.Pack_Id   
			AND OD.Section = 'FPS'
			AND OD.OXO_Doc_Id = @p_doc_id
			AND OD.Market_Id = -1
			AND OD.Active = 1
			AND OD.Model_Id = PM.ID
			WHERE PKF.ProgrammeId = @prog_id
			AND PM.Programme_Id = @prog_id
			AND PM.Active = 1;					
		END;
		
    END;

    IF (@p_mode = 'mg')
    BEGIN
		IF(@p_section = 'FBM')
		BEGIN
			INSERT INTO @result
			SELECT DISTINCT PF.Id, 0, PM.Id, coalesce(ODG.OXO_Code, OD.OXO_Code + '*') AS OXO_Code 
			FROM OXO_Programme_Feature_VW PF
			CROSS JOIN OXO_Programme_Model PM
			LEFT OUTER JOIN OXO_Item_Data OD
			ON PF.Id = OD.Feature_Id
			AND OD.Section = 'FBM' 
			AND OD.OXO_Doc_Id = @p_doc_id
			AND OD.Market_Id = -1
			AND OD.Active = 1
			AND OD.Model_Id = PM.ID
			LEFT OUTER JOIN OXO_Item_Data ODG
			ON PF.Id = ODG.Feature_Id
			AND ODG.Section = 'FBM'
			AND ODG.OXO_Doc_Id = @p_doc_id
			AND ODG.Market_group_Id = @p_object_id
			AND ODG.Active = 1
			AND ODG.Model_Id = PM.ID
			WHERE PF.ProgrammeId = @prog_id
			AND PM.Programme_Id = @prog_id
			AND PM.Active = 1;
					
		END;
		
		IF(@p_section = 'PCK')
		BEGIN
			INSERT INTO @result
			SELECT DISTINCT 0, PK.Id, PM.Id, coalesce(ODG.OXO_Code, OD.OXO_Code + '*') AS OXO_Code 
			FROM OXO_Programme_Pack PK
			CROSS JOIN OXO_Programme_Model PM
			LEFT OUTER JOIN OXO_Item_Data OD
			ON PK.Id = OD.Pack_Id
			AND OD.Section = 'PCK'
			AND OD.OXO_Doc_Id = @p_doc_id
			AND OD.Market_Id = -1
			AND OD.Active = 1
			AND OD.Model_Id = PM.ID
			LEFT OUTER JOIN OXO_Item_Data ODG
			ON PK.Id = OD.Pack_Id
			AND ODG.Section = 'PCK'
			AND ODG.OXO_Doc_Id = @p_doc_id
			AND ODG.Market_group_Id = @p_object_id
			AND ODG.Active = 1
			AND ODG.Model_Id = PM.ID
			WHERE PK.Programme_Id = @prog_id
			AND PM.Programme_Id = @prog_id
			AND PM.Active = 1;
		END; 
		
		IF(@p_section = 'FPS')
		BEGIN
			INSERT INTO @result
			SELECT DISTINCT PKF.Id, PKF.PackId, PM.Id, coalesce(ODG.OXO_Code, OD.OXO_Code + '*') AS OXO_Code 
			FROM OXO_Pack_Feature_VW PKF
			CROSS JOIN OXO_Programme_Model PM
			LEFT OUTER JOIN OXO_Item_Data OD
			ON PKF.Id = OD.Feature_Id
			AND PKF.PackId = OD.Pack_Id
			AND OD.Section = 'FPS' 
			AND OD.OXO_Doc_Id = @p_doc_id
			AND OD.Market_Id = -1
			AND OD.Active = 1
			AND OD.Model_Id = PM.ID
			LEFT OUTER JOIN OXO_Item_Data ODG
			ON PKF.Id = ODG.Feature_Id
			AND PKF.PackId = ODG.Pack_Id
			AND ODG.Section = 'FPS'
			AND ODG.OXO_Doc_Id = @p_doc_id
			AND ODG.Market_group_Id = @p_object_id
			AND ODG.Active = 1
			AND ODG.Model_Id = PM.ID
			WHERE PKF.ProgrammeId = @prog_id
			AND PM.Programme_Id = @prog_id
			AND PM.Active = 1;
		END;
    END;
    
    IF (@p_mode = 'm')
    BEGIN
    
		DECLARE @marketGroupId INT

		SELECT Top 1 @marketGroupId = Market_Group_Id 
		FROM dbo.OXO_Programme_MarketGroup_Market_Link
		WHERE Country_Id = @p_object_id
		AND Programme_Id = @prog_id;
    
    	IF(@p_section = 'FBM')
		BEGIN
			INSERT INTO @result
			SELECT DISTINCT PF.Id, 0, PM.Id, coalesce(ODM.OXO_Code, ODG.OXO_Code + '**', OD.OXO_Code + '*') AS OXO_Code 
			FROM OXO_Programme_Feature_VW PF
			CROSS JOIN OXO_Programme_Model PM
			LEFT OUTER JOIN OXO_Item_Data OD
			ON PF.Id = OD.Feature_Id
			AND OD.Section = 'FBM'
			AND OD.OXO_Doc_Id = @p_doc_id
			AND OD.Market_Id = -1
			AND OD.Active = 1
			AND OD.Model_Id = PM.ID
			LEFT OUTER JOIN OXO_Item_Data ODG
			ON PF.Id = ODG.Feature_Id
			AND ODG.Section = 'FBM'
			AND ODG.OXO_Doc_Id = @p_doc_id
			AND ODG.Market_group_Id = @marketGroupId
			AND ODG.Active = 1
			AND ODG.Model_Id = PM.ID
			LEFT OUTER JOIN OXO_Item_Data ODM
			ON PF.Id = ODM.Feature_Id
			AND ODM.Section = 'FBM'
			AND ODM.OXO_Doc_Id = @p_doc_id
			AND ODM.Market_Id = @p_object_id
			AND ODM.Active = 1
			AND ODM.Model_Id = PM.ID
			WHERE PF.ProgrammeId = @prog_id
			AND PM.Programme_Id = @prog_id
			AND PM.Active = 1;
				
		END;
		
		IF(@p_section = 'PCK')
		BEGIN 		
			INSERT INTO @result
			SELECT DISTINCT 0, PK.Id, PM.Id, coalesce(ODM.OXO_Code, ODG.OXO_Code + '**', OD.OXO_Code + '*') AS OXO_Code 
			FROM OXO_Programme_Pack PK
			CROSS JOIN OXO_Programme_Model PM
			LEFT OUTER JOIN OXO_Item_Data OD
			ON PK.Id = OD.Pack_Id
			AND OD.Section = 'PCK'
			AND OD.OXO_Doc_Id = @p_doc_id
			AND OD.Market_Id = -1
			AND OD.Active = 1
			AND OD.Model_Id = PM.ID
			LEFT OUTER JOIN OXO_Item_Data ODG
			ON PK.Id = ODG.Pack_Id
			AND ODG.Section = 'PCK'
			AND ODG.OXO_Doc_Id = @p_doc_id
			AND ODG.Market_group_Id = @marketGroupId
			AND ODG.Active = 1
			AND ODG.Model_Id = PM.ID
			LEFT OUTER JOIN OXO_Item_Data ODM
			ON PK.Id = ODM.Pack_Id
			AND ODM.Section = 'PCK'
			AND ODM.OXO_Doc_Id = @p_doc_id
			AND ODM.Market_Id = @p_object_id
			AND ODM.Active = 1
			AND ODM.Model_Id = PM.ID
			WHERE PK.Programme_Id = @prog_id
			AND PM.Programme_Id = @prog_id
			AND PM.Active = 1; 
		END; 
		 
		IF(@p_section = 'FPS')
		BEGIN
			INSERT INTO @result
			SELECT DISTINCT PKF.Id, PKF.PackId,  PM.Id, coalesce(ODM.OXO_Code, ODG.OXO_Code + '**', OD.OXO_Code + '*') AS OXO_Code 
			FROM OXO_Pack_Feature_VW PKF
			CROSS JOIN OXO_Programme_Model PM
			LEFT OUTER JOIN OXO_Item_Data OD
			ON PKF.Id = OD.Feature_Id
			AND PKF.PackId = OD.Pack_Id
			AND OD.Section = 'FPS'
			AND OD.OXO_Doc_Id = @p_doc_id
			AND OD.Market_Id = -1
			AND OD.Active = 1
			AND OD.Model_Id = PM.ID
			LEFT OUTER JOIN OXO_Item_Data ODG
			ON PKF.Id = ODG.Feature_Id
			AND PKF.PackId = ODG.Pack_Id
			AND ODG.Section = 'FPS'
			AND ODG.OXO_Doc_Id = @p_doc_id
			AND ODG.Market_group_Id = @marketGroupId
			AND ODG.Active = 1
			AND ODG.Model_Id = PM.ID
			LEFT OUTER JOIN OXO_Item_Data ODM
			ON PKF.Id = ODM.Feature_Id
			AND PKF.PackId = ODM.Pack_Id
			AND ODM.Section = 'FPS'
			AND ODM.OXO_Doc_Id = @p_doc_id
			AND ODM.Market_Id = @p_object_id
			AND ODM.Active = 1
			AND ODM.Model_Id = PM.ID
			WHERE PKF.ProgrammeId = @prog_id
			AND PM.Programme_Id = @prog_id
			AND PM.Active = 1;
		END;
    END;
    
	RETURN
	
END
