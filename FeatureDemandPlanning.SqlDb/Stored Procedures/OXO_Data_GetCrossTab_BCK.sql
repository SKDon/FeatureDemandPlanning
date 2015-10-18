CREATE PROCEDURE [dbo].[OXO_Data_GetCrossTab_BCK] 
  @p_make nvarchar(50),
  @p_doc_id int,
  @p_prog_id int,
  @p_section nvarchar(50),
  @p_mode nvarchar(50),
  @p_object_id int,
  @p_model_ids nvarchar(2000)
AS

  DECLARE @sql nvarchar(4000) = N'';    	
  DECLARE @stripModelIds nvarchar(2000);
  
  -- strip the square brackets
  SET @stripModelIds = REPLACE(@p_model_ids, '[', '');
  SET @stripModelIds = REPLACE(@stripModelIds, ']', '');

  IF (@p_section = 'MBM')
  BEGIN
      -- Do Model By Market DataSet	
	  SET @sql = @sql + 'WITH SET_A AS ( ';
	  SET @sql = @sql +	'SELECT MGM.Display_Order, MGM.Market_Group_Name, MGM.PAR, MGM.Market_Name, MGM.WHD, OD.OXO_Code, OD.Model_Id, MGM.Market_Id, '; 
	  SET @sql = @sql +	'dbo.OXO_VariantCount(MGM.Market_Id, @docId) AS Variant_Count, MGM.Market_Group_Id ';
	  SET @sql = @sql +	'FROM OXO_Programme_MarketGroupMarket_VW MGM ';
	  SET @sql = @sql +	'LEFT OUTER JOIN OXO_Item_Data OD ';
	  SET @sql = @sql +	'ON MGM.Market_Id = OD.Market_Id ';
	  SET @sql = @sql +	'AND OD.Active=1 ';
	  SET @sql = @sql + 'AND Section=''MBM'' AND OXO_Doc_Id=@docId ';
	  SET @sql = @sql + 'WHERE MGM.Make = ''@make'' AND MGM.Programme_Id = @progId) '
	  SET @sql = @sql +	'SELECT * FROM SET_A ';
	  SET @sql = @sql + 'PIVOT ( ';
	  SET @sql = @sql + 'MAX(OXO_Code) FOR Model_Id ';
	  SET @sql = @sql + 'IN (@cols)) AS DataSet ';	
	  SET @sql = @sql + 'ORDER BY Display_Order, Market_Name';			
	  SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
	  SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	  			
	  SET @sql = REPLACE(@sql, '@cols', @p_model_ids); 
	  SET @sql = REPLACE(@sql, '@make', @p_make); 
  END
  
  IF (@p_section = 'PCK')
  BEGIN	
		-- Do Feature Packs DataSet
		
		SET @sql = @sql + 'WITH SET_A AS ( ';
		SET @sql = @sql + 'SELECT DISTINCT ';
		SET @sql = @sql + 'PCK.Id AS PackId, ';
		SET @sql = @sql + 'PCK.Pack_Name AS PackName, ';
		SET @sql = @sql + 'PCK.PROFET, ';
		SET @sql = @sql + 'PCK.Pack_Name AS MarketingDescription, ';
		SET @sql = @sql + '0 AS Feature_Id, ';
		SET @sql = @sql + '0 AS RuleCount, ';
		SET @sql = @sql + 'ODPK.OXO_Code AS OXO_Code,';
		SET @sql = @sql + 'CAST(MDL.strVal AS INT) AS Model_Id ';
		SET @sql = @sql + 'FROM OXO_Programme_Pack PCK '; 
		SET @sql = @sql + 'CROSS JOIN dbo.FN_Split(''@stripModelIds'', '','') MDL ';
		SET @sql = @sql + 'LEFT OUTER JOIN dbo.FN_OXO_Data_Get(''PCK'',@docId, ''@mode'', @objectId) ODPK ';
		SET @sql = @sql + 'ON PCK.Id = ODPK.Pack_Id '; 
		SET @sql = @sql + 'AND ODPK.Model_Id =  MDL.strVal '; 
		SET @sql = @sql + 'WHERE PCK.Programme_Id = @progId) '; 
		SET @sql = @sql + 'SELECT * FROM SET_A  ';
		SET @sql = @sql + 'PIVOT ( MAX(OXO_Code) FOR Model_Id IN (@cols)) AS DataSet ';
		SET @sql = @sql + 'ORDER BY PackName, PROFET ';
		SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
		SET @sql = REPLACE(@sql, '@marketgroupId', @p_object_id); 
		SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	 
		SET @sql = REPLACE(@sql, '@cols', @p_model_ids);
		SET @sql = REPLACE(@sql, '@stripModelIds', @stripModelIds);	   
		SET @sql = REPLACE(@sql, '@make', @p_make);
		SET @sql = REPLACE(@sql, '@mode', @p_mode);
		SET @sql = REPLACE(@sql, '@objectId', @p_object_id);
				
  END
  
  IF (@p_section = 'FPS')
  BEGIN	
		-- Do Feature Packs DataSet
		
		SET @sql = @sql + 'WITH SET_A AS ( ';
		SET @sql = @sql + 'SELECT DISTINCT ';
		SET @sql = @sql + 'PCK.PackId, ';
		SET @sql = @sql + 'PCK.PackName, ';
		SET @sql = @sql + 'PCK.PROFET, ';
		SET @sql = @sql + 'PCK.MarketingDescription, ';
		SET @sql = @sql + 'PCK.ID AS Feature_Id, ';
		SET @sql = @sql + 'dbo.OXO_RuleCount(@progId, PCK.ID) AS RuleCount, ';
		SET @sql = @sql + 'ISNULL(ODPF.OXO_Code, REPLACE(ODF.OXO_Code, ''O'', ''P'')) AS OXO_Code,';
		SET @sql = @sql + 'CAST(MDL.strVal AS INT) AS Model_Id ';
		SET @sql = @sql + 'FROM OXO_Pack_Feature_VW PCK '; 
		SET @sql = @sql + 'CROSS JOIN dbo.FN_Split(''@stripModelIds'', '','') MDL ';
		SET @sql = @sql + 'LEFT OUTER JOIN dbo.FN_OXO_Data_Get(''FBM'',@docId, ''@mode'', @objectId) ODF ';
		SET @sql = @sql + 'ON PCK.Id = ODF.Feature_Id '; 
		SET @sql = @sql + 'AND ODF.Model_Id =  MDL.strVal '; 
		SET @sql = @sql + 'LEFT OUTER JOIN dbo.FN_OXO_Data_Get(''FPS'',@docId, ''@mode'', @objectId) ODPF ';
		SET @sql = @sql + 'ON PCK.Id = ODPF.Feature_Id ';
		SET @sql = @sql + 'AND PCK.PackId = ODPF.Pack_Id ';
		SET @sql = @sql + 'AND ODPF.Model_Id =  MDL.strVal '; 
		SET @sql = @sql + 'WHERE PCK.VehicleMake = ''@make'' '; 
		SET @sql = @sql + 'and PCK.ProgrammeId = @progId) '; 
		SET @sql = @sql + 'SELECT * FROM SET_A  ';
		SET @sql = @sql + 'PIVOT ( MAX(OXO_Code) FOR Model_Id IN (@cols)) AS DataSet ';
		SET @sql = @sql + 'ORDER BY PackName, PROFET ';
		SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
		SET @sql = REPLACE(@sql, '@marketgroupId', @p_object_id); 
		SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	 
		SET @sql = REPLACE(@sql, '@cols', @p_model_ids);
		SET @sql = REPLACE(@sql, '@stripModelIds', @stripModelIds);	   
		SET @sql = REPLACE(@sql, '@make', @p_make);
		SET @sql = REPLACE(@sql, '@mode', @p_mode);
		SET @sql = REPLACE(@sql, '@objectId', @p_object_id);
				
  END
  
  IF (@p_section = 'FBM')
  BEGIN	
     -- Do Feature By Market DataSet
     -- Do Global Generic Level  
     IF (@p_mode = 'g')
     BEGIN
		-- Get Global Generic
		SET @sql = @sql + 'WITH SET_A AS ( ';
		SET @sql = @sql +	'SELECT DISTINCT ISNULL(REF.Display_Order, 100) AS Display_Order, '; 
		SET @sql = @sql +	'FEA.FeatureGroup,FEA.FeatureSubGroup,FEA.PROFET,FEA.MarketingDescription,FEA.ID AS Feature_Id, ';	 
		SET @sql = @sql +	'dbo.OXO_RuleCount(@progId, FEA.ID) AS RuleCount, '; 
		SET @sql = @sql + 'ODG.OXO_Code AS OXO_Code, ';	  
		SET @sql = @sql +	'CAST(MDL.strVal AS INT) AS Model_Id ';	  	  
		SET @sql = @sql +	'FROM OXO_Programme_Feature_VW FEA ';
		SET @sql = @sql +	'CROSS JOIN dbo.FN_Split(''@stripModelIds'', '','') MDL ';
		SET @sql = @sql +	'LEFT OUTER JOIN OXO_Reference_List REF ';	  
		SET @sql = @sql +	'ON FEA.FeatureGroup = REF.Description ';
		SET @sql = @sql +	'AND REF.List_Name = ''Feature Group'' ';	 	  
		--SET @sql = @sql +	'LEFT OUTER JOIN dbo.FN_OXO_Data_Get(''@section'', @docId,''g'',-1) ODG ';	  		
		SET @sql = @sql +	'LEFT OUTER JOIN dbo.FN_OXO_Data_Get_FBM_Global(@docId, @progid, ''@cols'') ODG ' 
		SET @sql = @sql +	'ON FEA.Id = ODG.Feature_Id ';
		SET @sql = @sql + 'AND ODG.Model_Id =  MDL.strVal ';	
		SET @sql = @sql + 'WHERE FEA.Make = ''@make'' AND FEA.ProgrammeId = @progId AND FEA.ID > 0) '
		SET @sql = @sql +	'SELECT * FROM SET_A ';
		SET @sql = @sql + 'PIVOT ( ';
		SET @sql = @sql + 'MAX(OXO_Code) FOR Model_Id ';
		SET @sql = @sql + 'IN (@cols)) AS DataSet ';	
		SET @sql = @sql + 'ORDER BY Display_Order, PROFET';		
		SET @sql = REPLACE(@sql, '@section', @p_section); 				  
		SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
		SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	 
		SET @sql = REPLACE(@sql, '@cols', @p_model_ids);
		SET @sql = REPLACE(@sql, '@stripModelIds', @stripModelIds);	   
		SET @sql = REPLACE(@sql, '@make', @p_make); 		
     END
     
     -- Do Market Group Level
     IF @p_mode = 'mg'
     BEGIN
		SET @sql = @sql + 'WITH SET_A AS ( ';
		SET @sql = @sql +	'SELECT DISTINCT ISNULL(REF.Display_Order, 100) AS Display_Order, '; 
		SET @sql = @sql +	'FEA.FeatureGroup,FEA.FeatureSubGroup,FEA.PROFET,FEA.MarketingDescription,FEA.ID AS Feature_Id, ';	
		SET @sql = @sql +	'dbo.OXO_RuleCount(@progId, FEA.ID) AS RuleCount, ';   
		SET @sql = @sql +	'CASE WHEN dbo.OXO_VariantAvailableMarketGroup(MDL.strVal, @marketgroupId, @docId, @progId) = 0 THEN ''NA***'' ';          				  
		SET @sql = @sql + 'ELSE ODG.OXO_Code ' ;
		SET @sql = @sql + 'END AS OXO_Code, ';	  				  
		SET @sql = @sql +	'CAST(MDL.strVal AS INT) AS Model_Id ';	  	  
		SET @sql = @sql +	'FROM OXO_Programme_Feature_VW FEA ';
		SET @sql = @sql +	'CROSS JOIN dbo.FN_Split(''@stripModelIds'', '','') MDL ';
		SET @sql = @sql +	'LEFT OUTER JOIN OXO_Reference_List REF ';	  
		SET @sql = @sql +	'ON FEA.FeatureGroup = REF.Description ';
		SET @sql = @sql +	'AND REF.List_Name = ''Feature Group'' ';	 	  
		SET @sql = @sql +	'LEFT OUTER JOIN dbo.FN_OXO_Data_Get(''@section'', @docId,''mg'',@marketgroupId) ODG ';	  
		SET @sql = @sql +	'ON FEA.Id = ODG.Feature_Id ';
		SET @sql = @sql + 'AND ODG.Model_Id =  MDL.strVal ';	
		SET @sql = @sql + 'WHERE FEA.Make = ''@make'' and FEA.ProgrammeId = @progId AND FEA.ID > 0) '
		SET @sql = @sql +	'SELECT * FROM SET_A ';
		SET @sql = @sql + 'PIVOT ( ';
		SET @sql = @sql + 'MAX(OXO_Code) FOR Model_Id ';
		SET @sql = @sql + 'IN (@cols)) AS DataSet ';	
		SET @sql = @sql + 'ORDER BY Display_Order, PROFET';		
		SET @sql = REPLACE(@sql, '@section', @p_section); 			  
		SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
		SET @sql = REPLACE(@sql, '@marketgroupId', @p_object_id); 
		SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	 
		SET @sql = REPLACE(@sql, '@cols', @p_model_ids);
		SET @sql = REPLACE(@sql, '@stripModelIds', @stripModelIds);	   
		SET @sql = REPLACE(@sql, '@make', @p_make);
     END
     
     -- Do Market Level
     IF @p_mode = 'm'
     BEGIN
		-- first need to get the market_group_id 	
		DECLARE @marketGroupId INT

		SELECT Top 1 @marketGroupId = Market_Group_Id 
		FROM dbo.OXO_Programme_MarketGroup_Market_Link
		WHERE Country_Id = @p_object_id
		AND Programme_Id = @p_prog_id;	
				  
		SET @sql = @sql + 'WITH SET_A AS ( ';
		SET @sql = @sql +	'SELECT DISTINCT ISNULL(REF.Display_Order, 100) AS Display_Order, '; 
		SET @sql = @sql +	'FEA.FeatureGroup,FEA.FeatureSubGroup,FEA.PROFET,FEA.MarketingDescription,FEA.ID AS Feature_Id, ';	  				  				  
		SET @sql = @sql +	'dbo.OXO_RuleCount(@progId, FEA.ID) AS RuleCount, ';   				  
		SET @sql = @sql +	'CASE WHEN dbo.OXO_VariantAvailableMarket(MDL.strVal, @marketId, @docId) = 0 THEN ''NA***'' ';           
		SET @sql = @sql + '     ELSE ODG.OXO_Code ';
		SET @sql = @sql + 'END AS OXO_Code, ';	  				  
		SET @sql = @sql +	'CAST(MDL.strVal AS INT) AS Model_Id ';	  	  
		SET @sql = @sql +	'FROM OXO_Programme_Feature_VW FEA ';
		SET @sql = @sql +	'CROSS JOIN dbo.FN_Split(''@stripModelIds'', '','') MDL ';
		SET @sql = @sql +	'LEFT OUTER JOIN OXO_Reference_List REF ';	  
		SET @sql = @sql +	'ON FEA.FeatureGroup = REF.Description ';
		SET @sql = @sql +	'AND REF.List_Name = ''Feature Group'' ';	 	  
		SET @sql = @sql +	'LEFT OUTER JOIN dbo.FN_OXO_Data_Get(''@section'',@docId,''m'',@marketId) ODG ';	  
		SET @sql = @sql +	'ON FEA.Id = ODG.Feature_Id ';
		SET @sql = @sql + 'AND ODG.Model_Id =  MDL.strVal ';	
		SET @sql = @sql + 'WHERE FEA.Make = ''@make'' and FEA.ProgrammeId = @progId and FEA.ID > 0) '
		SET @sql = @sql +	'SELECT * FROM SET_A ';
		SET @sql = @sql + 'PIVOT ( ';
		SET @sql = @sql + 'MAX(OXO_Code) FOR Model_Id ';
		SET @sql = @sql + 'IN (@cols)) AS DataSet ';	
		SET @sql = @sql + 'ORDER BY Display_Order, PROFET';		
		SET @sql = REPLACE(@sql, '@section', @p_section); 			  
		SET @sql = REPLACE(@sql, '@docId', @p_doc_id); 
		SET @sql = REPLACE(@sql, '@marketId', @p_object_id); 
		SET @sql = REPLACE(@sql, '@marketgroupId', @marketGroupId); 
		SET @sql = REPLACE(@sql, '@cols', @p_model_ids);
		SET @sql = REPLACE(@sql, '@progId', @p_prog_id); 	 
		SET @sql = REPLACE(@sql, '@stripModelIds', @stripModelIds);	   
		SET @sql = REPLACE(@sql, '@make', @p_make); 
     END
     
  END
  
 --Print @sql;
  EXEC sp_executesql @sql;

