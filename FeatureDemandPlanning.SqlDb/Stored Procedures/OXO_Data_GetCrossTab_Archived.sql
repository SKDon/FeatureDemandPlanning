CREATE PROCEDURE [dbo].[OXO_Data_GetCrossTab_Archived] 
  @p_make nvarchar(50),
  @p_doc_id int,
  @p_prog_id int,
  @p_section nvarchar(50),
  @p_mode nvarchar(50),
  @p_object_id int,
  @p_model_ids nvarchar(MAX),
  @p_export bit = 0
AS

  DECLARE @sql nvarchar(MAX) = N'';    	
  DECLARE @marketGroupId INT;
  
  IF @p_mode = 'm'
  BEGIN
	SELECT Top 1 @marketGroupId = Market_Group_Id 
	FROM OXO_Archived_Programme_MarketGroupMarket_VW
	WHERE Doc_Id = @p_doc_id
	AND Programme_Id = @p_prog_id	
	AND Market_Id = @p_object_id;
  END

  IF (@p_section = 'MBM')
  BEGIN
      -- Do Model By Market DataSet	
	  SET @sql = @sql + 'WITH SET_A AS ( ';
	  SET @sql = @sql +	'SELECT MGM.Display_Order, MGM.Market_Group_Name, MGM.PAR, MGM.Market_Name, MGM.WHD, OD.OXO_Code, OD.Model_Id, MGM.Market_Id, '; 
	  SET @sql = @sql +	'dbo.OXO_VariantCount(MGM.Market_Id, @docId, ''@cols'') AS Variant_Count, MGM.Market_Group_Id, MGM.SubRegion, MGM.SubRegionOrder ';
	  SET @sql = @sql +	'FROM OXO_Archived_Programme_MarketGroupMarket_VW MGM ';
	  SET @sql = @sql +	'LEFT OUTER JOIN OXO_Item_Data_MBM OD WITH(NOLOCK) ';
	  SET @sql = @sql +	'ON MGM.Market_Id = OD.Market_Id ';
	  SET @sql = @sql +	'AND OD.Active=1 ';
	  SET @sql = @sql + 'AND OXO_Doc_Id=@docId ';
	  SET @sql = @sql + 'WHERE MGM.Doc_Id = @docId '
	  SET @sql = @sql + 'AND MGM.Programme_Id = @progId) '
	  SET @sql = @sql +	'SELECT * FROM SET_A ';
	  SET @sql = @sql + 'PIVOT ( ';
	  SET @sql = @sql + 'MAX(OXO_Code) FOR Model_Id ';
	  SET @sql = @sql + 'IN (@cols)) AS DataSet ';	
	  SET @sql = @sql + 'ORDER BY Display_Order,  SubRegionOrder, SubRegion, Market_Name';			
	  SET @sql = REPLACE(@sql, '@cols', @p_model_ids); 	
	  SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
	  SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 
  END
  
  IF (@p_section = 'PCK')
  BEGIN	
		-- Do Feature Packs DataSet
		IF (@p_mode = 'g')
		BEGIN
			SET @sql = @sql + 'WITH SET_A AS ( ';
			SET @sql = @sql + 'SELECT DISTINCT ';
			SET @sql = @sql + 'PCK.Id AS PackId, ';
			SET @sql = @sql + 'PCK.Pack_Name AS PackName, ';
			SET @sql = @sql + 'PCK.Feature_Code AS FeatureCode, ';
			SET @sql = @sql + 'PCK.Pack_Name AS BrandDescription, ';
			SET @sql = @sql + '-1000 AS Feature_Id, ';
			SET @sql = @sql + 'PCK.Pack_Name AS SystemDescription, ';
			SET @sql = @sql + 'CASE WHEN LEN(PCK.Rule_Text) > 0 THEN 1 ELSE 0 END AS HasRule, ';
			SET @sql = @sql + 'CASE WHEN LEN(PCK.Extra_Info)> 0 THEN 1 ELSE 0 END AS HasInfo, ';
			SET @sql = @sql + 'ODPK.OXO_Code, ODPK.Model_Id ';
			SET @sql = @sql + 'FROM OXO_Archived_Programme_Pack PCK ';			 
			SET @sql = @sql + 'LEFT OUTER JOIN dbo.FN_OXO_Data_Get_PCK_Global(@docId, ''@cols'') ODPK ';			
			SET @sql = @sql + 'ON PCK.PackId = ODPK.Pack_Id '; 
			SET @sql = @sql + 'WHERE PCK.Doc_Id = @docId AND PCK.ProgrammeId = @progId) '; 
			SET @sql = @sql + 'SELECT * FROM SET_A  ';
			SET @sql = @sql + 'PIVOT ( MAX(OXO_Code) FOR Model_Id IN (@cols)) AS DataSet ';
			SET @sql = @sql + 'ORDER BY PackId, PackName, FeatureCode ';
			SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
			SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	 
			SET @sql = REPLACE(@sql, '@cols', @p_model_ids);		
		END
		 
		IF @p_mode = 'mg'
		BEGIN
			SET @sql = @sql + 'WITH SET_A AS ( ';
			SET @sql = @sql + 'SELECT DISTINCT ';
			SET @sql = @sql + 'PCK.Id AS PackId, ';
			SET @sql = @sql + 'PCK.Pack_Name AS PackName, ';
			SET @sql = @sql + 'PCK.Feature_Code AS FeatureCode, ';
			SET @sql = @sql + 'PCK.Pack_Name AS BrandDescription, ';
			SET @sql = @sql + '-1000 AS Feature_Id, ';
			SET @sql = @sql + 'PCK.Pack_Name AS SystemDescription, ';			
			SET @sql = @sql + 'CASE WHEN LEN(PCK.Rule_Text) > 0 THEN 1 ELSE 0 END AS HasRule, ';
			SET @sql = @sql + 'CASE WHEN LEN(PCK.Extra_Info)> 0 THEN 1 ELSE 0 END AS HasInfo, ';			
			SET @sql = @sql + 'ODPK.OXO_Code, ODPK.Model_Id ';
			SET @sql = @sql + 'FROM OXO_Archived_Programme_Pack PCK ';
			SET @sql = @sql + 'LEFT OUTER JOIN dbo.FN_OXO_Data_Get_PCK_MarketGroup(@docId,@marketgroupId,''@cols'') ODPK ';
			SET @sql = @sql + 'ON PCK.PackId = ODPK.Pack_Id '; 
			SET @sql = @sql + 'WHERE PCK.Doc_Id = @docId AND PCK.ProgrammeId = @progId) '; 
			SET @sql = @sql + 'SELECT * FROM SET_A  ';
			SET @sql = @sql + 'PIVOT ( MAX(OXO_Code) FOR Model_Id IN (@cols)) AS DataSet ';
			SET @sql = @sql + 'ORDER BY PackId, PackName, FeatureCode ';
			SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
			SET @sql = REPLACE(@sql, '@marketgroupId', @p_object_id); 
			SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	 
			SET @sql = REPLACE(@sql, '@cols', @p_model_ids);  
		END
		
		IF @p_mode = 'm'
		BEGIN
		
			SET @sql = @sql + 'WITH SET_A AS ( ';
			SET @sql = @sql + 'SELECT DISTINCT ';
			SET @sql = @sql + 'PCK.Id AS PackId, ';
			SET @sql = @sql + 'PCK.Pack_Name AS PackName, ';
			SET @sql = @sql + 'PCK.Feature_Code AS FeatureCode, ';
			SET @sql = @sql + 'PCK.Pack_Name AS BrandDescription, ';
			SET @sql = @sql + '-1000 AS Feature_Id, ';
			SET @sql = @sql + 'PCK.Pack_Name AS SystemDescription, ';
			SET @sql = @sql + 'CASE WHEN LEN(PCK.Rule_Text) > 0 THEN 1 ELSE 0 END AS HasRule, ';
			SET @sql = @sql + 'CASE WHEN LEN(PCK.Extra_Info)> 0 THEN 1 ELSE 0 END AS HasInfo, ';						
			SET @sql = @sql + 'ODPK.OXO_Code, ODPK.Model_Id ';;
			SET @sql = @sql + 'FROM OXO_Archived_Programme_Pack PCK ';
			SET @sql = @sql + 'LEFT OUTER JOIN dbo.FN_OXO_Data_Get_PCK_Market(@docId, @marketgroupId, @marketId, ''@cols'') ODPK ';
			SET @sql = @sql + 'ON PCK.PackId = ODPK.Pack_Id '; 
			SET @sql = @sql + 'WHERE PCK.Doc_Id = @docId AND PCK.ProgrammeId = @progId) '; 
			SET @sql = @sql + 'SELECT * FROM SET_A  ';
			SET @sql = @sql + 'PIVOT ( MAX(OXO_Code) FOR Model_Id IN (@cols)) AS DataSet ';
			SET @sql = @sql + 'ORDER BY PackId, PackName, FeatureCode ';
			SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
			SET @sql = REPLACE(@sql, '@marketgroupId', @marketGroupId); 
			SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	 
			SET @sql = REPLACE(@sql, '@cols', @p_model_ids);
			SET @sql = REPLACE(@sql, '@make', @p_make);
			SET @sql = REPLACE(@sql, '@marketId', @p_object_id);
		END
				
  END
  
  IF (@p_section = 'FPS')
  BEGIN	
		-- Do Feature Packs DataSet
		IF (@p_mode = 'g')
		BEGIN
			SET @sql = @sql + 'WITH SET_A AS ( ';
			SET @sql = @sql + 'SELECT DISTINCT ';
			SET @sql = @sql + 'PCK.PackId, ';
			SET @sql = @sql + 'PCK.PackName, ';
			SET @sql = @sql + 'PCK.FeatureCode, ';
			SET @sql = @sql + 'PCK.BrandDescription, ';
			SET @sql = @sql + 'PCK.ID AS Feature_Id, ';
			SET @sql = @sql + 'PCK.SystemDescription, ';
			SET @sql = @sql + 'PCK.FeatureComment, ';
			SET @sql = @sql + 'ISNULL(LEN(PCK.FeatureRuleText),0) AS RuleCount, ';	
			SET @sql = @sql + 'PCK.LongDescription, ';																
			SET @sql = @sql + 'ODPF.OXO_Code AS OXO_Code,';
			SET @sql = @sql + 'ODPF.Model_Id AS Model_Id ';
			SET @sql = @sql + 'FROM OXO_Archived_Pack_Feature_VW PCK '; 		
			SET @sql = @sql + 'LEFT OUTER JOIN dbo.FN_OXO_Data_Get_FPS_Global(@docId,''@cols'') ODPF ';
			SET @sql = @sql + 'ON PCK.Id = ODPF.Feature_Id ';
			SET @sql = @sql + 'AND PCK.PackId = ODPF.Pack_Id '; 
			SET @sql = @sql + 'WHERE PCK.Doc_Id = @docId AND PCK.ProgrammeId = @progId) '; 
			SET @sql = @sql + 'SELECT * FROM SET_A  ';
			SET @sql = @sql + 'PIVOT ( MAX(OXO_Code) FOR Model_Id IN (@cols)) AS DataSet ';
			SET @sql = @sql + 'ORDER BY PackId, PackName, FeatureCode ';
			SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
			SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	 
			SET @sql = REPLACE(@sql, '@cols', @p_model_ids);   
		END
		
		IF (@p_mode = 'mg')
		BEGIN
			SET @sql = @sql + 'WITH SET_A AS ( ';
			SET @sql = @sql + 'SELECT DISTINCT ';
			SET @sql = @sql + 'PCK.PackId, ';
			SET @sql = @sql + 'PCK.PackName, ';
			SET @sql = @sql + 'PCK.FeatureCode, ';
			SET @sql = @sql + 'PCK.BrandDescription, ';
			SET @sql = @sql + 'PCK.ID AS Feature_Id, ';
			SET @sql = @sql + 'PCK.SystemDescription, ';
			SET @sql = @sql + 'PCK.FeatureComment, ';
			SET @sql = @sql + 'ISNULL(LEN(PCK.FeatureRuleText),0) AS RuleCount, ';	
			SET @sql = @sql + 'PCK.LongDescription, ';														
			SET @sql = @sql + 'ODPF.OXO_Code AS OXO_Code,';
			SET @sql = @sql + 'ODPF.Model_Id AS Model_Id ';
			SET @sql = @sql + 'FROM OXO_Archived_Pack_Feature_VW PCK '; 
			SET @sql = @sql + 'LEFT OUTER JOIN dbo.FN_OXO_Data_Get_FPS_MarketGroup(@docId,@marketgroupId,''@cols'') ODPF ';
			SET @sql = @sql + 'ON PCK.Id = ODPF.Feature_Id ';
			SET @sql = @sql + 'AND PCK.PackId = ODPF.Pack_Id ';
			SET @sql = @sql + 'WHERE PCK.Doc_Id = @docId AND PCK.ProgrammeId = @progId) '; 
			SET @sql = @sql + 'SELECT * FROM SET_A  ';
			SET @sql = @sql + 'PIVOT ( MAX(OXO_Code) FOR Model_Id IN (@cols)) AS DataSet ';
			SET @sql = @sql + 'ORDER BY PackId, PackName, FeatureCode ';
			SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
			SET @sql = REPLACE(@sql, '@marketgroupId', @p_object_id); 
			SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	 
			SET @sql = REPLACE(@sql, '@cols', @p_model_ids);
		END		
		
		IF (@p_mode = 'm')
		BEGIN
			SET @sql = @sql + 'WITH SET_A AS ( ';
			SET @sql = @sql + 'SELECT DISTINCT ';
			SET @sql = @sql + 'PCK.PackId, ';
			SET @sql = @sql + 'PCK.PackName, ';
			SET @sql = @sql + 'PCK.FeatureCode, ';
			SET @sql = @sql + 'PCK.BrandDescription, ';
			SET @sql = @sql + 'PCK.ID AS Feature_Id, ';
			SET @sql = @sql + 'PCK.SystemDescription, ';
			SET @sql = @sql + 'PCK.FeatureComment, ';
			SET @sql = @sql + 'ISNULL(LEN(PCK.FeatureRuleText),0) AS RuleCount, ';	
			SET @sql = @sql + 'PCK.LongDescription, ';														
			SET @sql = @sql + 'ODPF.OXO_Code AS OXO_Code,';
			SET @sql = @sql + 'ODPF.Model_Id AS Model_Id ';
			SET @sql = @sql + 'FROM OXO_Archived_Pack_Feature_VW PCK '; 						
			SET @sql = @sql + 'LEFT OUTER JOIN dbo.FN_OXO_Data_Get_FPS_Market(@docId,@marketgroupId,@marketid,''@cols'') ODPF ';
			SET @sql = @sql + 'ON PCK.Id = ODPF.Feature_Id ';
			SET @sql = @sql + 'AND PCK.PackId = ODPF.Pack_Id ';
			SET @sql = @sql + 'WHERE PCK.Doc_Id = @docId AND PCK.ProgrammeId = @progId) '; 
			SET @sql = @sql + 'SELECT * FROM SET_A  ';
			SET @sql = @sql + 'PIVOT ( MAX(OXO_Code) FOR Model_Id IN (@cols)) AS DataSet ';
			SET @sql = @sql + 'ORDER BY PackId, PackName, FeatureCode ';
			SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
			SET @sql = REPLACE(@sql, '@marketgroupId', @marketGroupId); 
			SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	 
			SET @sql = REPLACE(@sql, '@cols', @p_model_ids);  
			SET @sql = REPLACE(@sql, '@marketId', @p_object_id);		
		END		
  END
  
  IF (@p_section = 'FBM')
  BEGIN	
     -- Do Feature By Market DataSet
     -- Do Global Generic Level  
     IF (@p_mode = 'g')
     BEGIN
		-- Get Global Generic
		SET @sql = @sql + 'WITH SET_A AS ( ';
	    SET @sql = @sql + 'SELECT Id, ProgrammeId, FeatureGroup, FeatureSubGroup, FeatureCode, '; 
		SET @sql = @sql + 'SystemDescription, BrandDescription, FeatureComment, FeatureRuleText, ';
		SET @sql = @sql + 'LongDescription, DisplayOrder, EFGName FROM OXO_Archived_Programme_Feature_VW ';
		SET @sql = @sql + 'WHERE Doc_Id = @docId AND ProgrammeId = @progId ), '; 
		SET @sql = @sql + 'SET_B AS (';	
		SET @sql = @sql + 'SELECT  -1000 AS ID, @progId AS ProgrammeId, Group_Name AS FeatureGroup,'; 
	    SET @sql = @sql + 'null AS FeatureSubGroup,null  AS FeatureCode,';
	    SET @sql = @sql + '''No Feature Selected'' AS SystemDescription,'; 
	    SET @sql = @sql + '''No Feature Selected'' AS BrandDescription,'; 
	    SET @sql = @sql + 'null AS FeatureComment, null AS FeatureRuleText,'; 
	    SET @sql = @sql + 'null AS LongDescription, MAX(Display_Order) AS DisplayOrder, null as EFGName ';
	    SET @sql = @sql + 'FROM OXO_Feature_Group G WHERE Status = 1 ';
		SET @sql = @sql + 'AND NOT EXISTS (';
		SET @sql = @sql + ' SELECT 1 FROM SET_A F WHERE F.FeatureGroup = G.Group_Name) GROUP BY Group_Name ';
	    SET @sql = @sql + ' UNION SELECT * FROM SET_A ),';
		SET @sql = @sql + 'SET_C AS ( ';
		SET @sql = @sql +	'SELECT DISTINCT FEA.DisplayOrder AS Display_Order, '; 
		SET @sql = @sql +	'FEA.FeatureGroup,FEA.FeatureSubGroup,FEA.FeatureCode,FEA.BrandDescription,FEA.ID AS Feature_Id, ';	 
		SET @sql = @sql +	'FEA.FeatureComment, FEA.SystemDescription, ISNULL(LEN(FEA.FeatureRuleText),0) AS RuleCount, FEA.LongDescription, '; 
		SET @sql = @sql +   'FEA.EFGName, ODG.OXO_Code, ODG.Model_Id ';	  
	
		-- control to include the No feature selected rows. Don't want this from export.
		IF (@p_export = 1)
			SET @sql = @sql +	'FROM SET_A FEA ';
		ELSE
			SET @sql = @sql +	'FROM SET_B FEA ';
		
		SET @sql = @sql +	'LEFT OUTER JOIN dbo.FN_OXO_Data_Get_FBM_Global(@docId, ''@cols'') ODG ';	  		
		SET @sql = @sql +	'ON FEA.Id = ODG.Feature_Id ';
		SET @sql = @sql + 'WHERE FEA.ProgrammeId = @progId) '
		SET @sql = @sql +	'SELECT * FROM SET_C ';
		SET @sql = @sql + 'PIVOT ( ';
		SET @sql = @sql + 'MAX(OXO_Code) FOR Model_Id ';
		SET @sql = @sql + 'IN (@cols)) AS DataSet ';	
		SET @sql = @sql + 'ORDER BY Display_Order, EFGName, FeatureCode';		
		SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
		SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	 
		SET @sql = REPLACE(@sql, '@cols', @p_model_ids);  		
     END
     
     -- Do Market Group Level
     IF @p_mode = 'mg'
     BEGIN
		SET @sql = @sql + 'WITH SET_A AS ( ';
		SET @sql = @sql +	'SELECT DISTINCT FEA.DisplayOrder AS Display_Order, '; 
		SET @sql = @sql +	'FEA.FeatureGroup,FEA.FeatureSubGroup,FEA.FeatureCode,FEA.BrandDescription,FEA.ID AS Feature_Id, ';	
		SET @sql = @sql +	'FEA.FeatureComment, FEA.SystemDescription, ISNULL(LEN(FEA.FeatureRuleText),0) AS RuleCount, FEA.LongDescription, ';   
		SET @sql = @sql +   'FEA.EFGName, ODG.OXO_Code, ODG.Model_Id ';	  	  
		SET @sql = @sql +	'FROM OXO_Archived_Programme_Feature_VW FEA ';
		SET @sql = @sql +	'LEFT OUTER JOIN dbo.FN_OXO_Data_Get_FBM_MarketGroup(@docId,@marketgroupId,''@cols'') ODG ';	  		
		SET @sql = @sql +	'ON FEA.Id = ODG.Feature_Id ';
		SET @sql = @sql + 'WHERE FEA.Doc_Id = @docId AND FEA.ProgrammeId = @progId) '
		SET @sql = @sql +	'SELECT * FROM SET_A ';
		SET @sql = @sql + 'PIVOT ( ';
		SET @sql = @sql + 'MAX(OXO_Code) FOR Model_Id ';
		SET @sql = @sql + 'IN (@cols)) AS DataSet ';	
		SET @sql = @sql + 'ORDER BY Display_Order, EFGName, FeatureCode';		
		SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
		SET @sql = REPLACE(@sql, '@marketgroupId', @p_object_id); 
		SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	 
		SET @sql = REPLACE(@sql, '@cols', @p_model_ids);  
     END
     
     -- Do Market Level
     IF @p_mode = 'm'
     BEGIN
				  
		SET @sql = @sql + 'WITH SET_A AS ( ';
		SET @sql = @sql +	'SELECT DISTINCT FEA.DisplayOrder AS Display_Order, '; 
		SET @sql = @sql +	'FEA.FeatureGroup,FEA.FeatureSubGroup,FEA.FeatureCode,FEA.BrandDescription,FEA.ID AS Feature_Id, ';	  				  				  
		SET @sql = @sql +	'FEA.FeatureComment,FEA.SystemDescription, ISNULL(LEN(FEA.FeatureRuleText),0) AS RuleCount, FEA.LongDescription, ';
		SET @sql = @sql +   'FEA.EFGName, ODG.OXO_Code, ODG.Model_Id ';	  				  
		SET @sql = @sql +	'FROM OXO_Archived_Programme_Feature_VW FEA ';
		SET @sql = @sql +	'LEFT OUTER JOIN dbo.FN_OXO_Data_Get_FBM_Market(@docId,@marketgroupId,@marketId,''@cols'') ODG ';	  						
		SET @sql = @sql +	'ON FEA.Id = ODG.Feature_Id ';
		SET @sql = @sql + 'WHERE FEA.Doc_Id = @docId AND FEA.ProgrammeId = @progId) '
		SET @sql = @sql +	'SELECT * FROM SET_A ';
		SET @sql = @sql + 'PIVOT ( ';
		SET @sql = @sql + 'MAX(OXO_Code) FOR Model_Id ';
		SET @sql = @sql + 'IN (@cols)) AS DataSet ';	
		SET @sql = @sql + 'ORDER BY Display_Order, EFGName, FeatureCode';		
		SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
		SET @sql = REPLACE(@sql, '@marketId', @p_object_id); 
		SET @sql = REPLACE(@sql, '@marketgroupId', @marketGroupId); 
		SET @sql = REPLACE(@sql, '@cols', @p_model_ids);
		SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	   
     END
     
  END
  
  IF (@p_section = 'GSF')
  BEGIN	
	-- Get Global Standard Features
	SET @sql = @sql + 'WITH SET_A AS ( ';
	SET @sql = @sql +	'SELECT FEA.DisplayOrder AS Display_Order, '; 
	SET @sql = @sql +	'FEA.FeatureGroup,FEA.FeatureSubGroup,FEA.FeatureCode,FEA.BrandDescription,FEA.ID AS Feature_Id, ';	 
	SET @sql = @sql +	'FEA.FeatureComment, FEA.LongDescription, 0 AS RuleCount,  '; 
	SET @sql = @sql +   'FEA.EFGName, ODG.OXO_Code, ODG.Model_Id ';	  	  
	SET @sql = @sql +	'FROM OXO_Archived_Programme_GSF_VW FEA ';
	SET @sql = @sql +	'LEFT OUTER JOIN dbo.FN_OXO_Data_Get_GSF_Global(@docId, ''@cols'') ODG ';	  		
	SET @sql = @sql +	'ON FEA.Id = ODG.Feature_Id ';	
	SET @sql = @sql + 'WHERE FEA.ProgrammeId = @progId) '
	SET @sql = @sql +	'SELECT * FROM SET_A ';
	SET @sql = @sql + 'PIVOT ( ';
	SET @sql = @sql + 'MAX(OXO_Code) FOR Model_Id ';
	SET @sql = @sql + 'IN (@cols)) AS DataSet ';	
	SET @sql = @sql + 'ORDER BY Display_Order, EFGName, FeatureCode';		
	SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
	SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	 
	SET @sql = REPLACE(@sql, '@cols', @p_model_ids);   			 
  END

 Print @sql;
 EXEC sp_executesql @sql;

