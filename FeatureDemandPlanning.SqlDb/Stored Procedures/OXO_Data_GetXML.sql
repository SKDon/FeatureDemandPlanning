CREATE PROCEDURE [dbo].[OXO_Data_GetXML]
  @p_doc_id int,
  @p_level nvarchar(50), -- g (global generic), mg (market group) or m (market)
  @p_prog_id int, -- 0 all programmes
  @p_object_id int -- 0 all markets
AS

IF @p_level = 'mg' -- market group

	-- level 1 <prog>
	SELECT L1_VP.Id AS '@id', L1_VP.Model_Year AS '@year', V.Name AS '@name', V.Make AS '@make', 
			
			-- level 2 <level>
			(SELECT L2_MG.Id AS '@id', @p_level AS '@type', L2_MG.Group_Name AS '@name',
			
					-- level 3 <model>
					(SELECT L3_PM.Id AS '@id',
							'@name' = dbo.OXO_GetVariantName(V.Display_Format, B.Shape, B.Doors, B.Wheelbase, E.Size, E.Fuel_Type, E.Cylinder, E.Turbo, E.Power, T.DriveTrain, T.Type, TM.Name, TM.Level, L3_PM.KD, 0),
							B.Shape AS '@shape', B.Doors AS '@doors', B.Wheelbase AS '@wheelbase', E.Size AS '@size', E.Cylinder AS '@cylinders', E.Turbo AS '@turbo', T.Type AS '@transmission', T.Drivetrain AS '@drivetrain', E.Fuel_Type AS '@fuel', E.Power AS '@power', E.Electrification AS '@drive', TM.Name AS '@trim', TM.Level AS '@level',
				
								-- level 4 <feat>
								(SELECT F.Id AS '@id', F.PROFET_JAG AS '@profet_jag', F.PROFET_LR AS '@profet_lr', F.Feature_Group AS '@featGroup', F.MFD_EFG AS '@featEFG', ISNULL(OXO_Code, '') as '@oxoCode'
								 FROM OXO_Feature F
									  LEFT OUTER JOIN OXO_Item_Data D -- change to inner join to return only 'set' features
									  ON F.Id = D.Feature_Id
								 AND D.OXO_Doc_Id = @p_doc_id
								 AND D.Model_Id = L3_PM.Id
								 AND D.Section = 'FBM'  		
								 AND D.Market_Group_Id = L2_MG.Id
								 FOR XML PATH('feat'), TYPE)	 
								-- </feat>
								
					 FROM	dbo.OXO_Programme_Model L3_PM
							INNER JOIN dbo.OXO_Programme_Body B
							ON L3_PM.Body_Id = B.Id
							INNER JOIN dbo.OXO_Programme_Engine E
							ON L3_PM.Engine_Id = E.Id
							INNER JOIN dbo.OXO_Programme_Transmission T
							ON L3_PM.Transmission_Id = T.Id
							INNER JOIN dbo.OXO_Programme_Trim TM
							ON L3_PM.Trim_Id = TM.Id
							INNER JOIN dbo.OXO_Programme P
							ON P.ID = L3_PM.Programme_Id 
							INNER JOIN OXO_Vehicle V
							ON V.Id = P.Vehicle_Id
					 WHERE   L1_VP.Id = L3_PM.Programme_Id
					 FOR XML PATH('model'), TYPE)
					 -- </model>
					 
			 FROM  OXO_Programme_MarketGroup AS L2_MG
			 WHERE L2_MG.Id IN (SELECT  ID.Market_Group_Id
								FROM    OXO_Item_Data ID
										INNER JOIN OXO_Programme_Model PM
										ON ID.Model_Id = PM.Id
										INNER JOIN OXO_Programme P
										ON PM.Programme_Id = P.Id
								WHERE P.Id = L1_VP.Id)
			 AND (L2_MG.Id = @p_object_id
			 OR 0 = @p_object_id)
			 AND L2_MG.Programme_Id = @p_prog_id
			 FOR XML PATH('level'), TYPE)
			-- </level>
			
	FROM   OXO_Programme L1_VP INNER JOIN
		   OXO_Vehicle V ON V.Id = L1_VP.Vehicle_Id
	WHERE  (L1_VP.Id = @p_prog_id
			OR 0 = @p_prog_id)
	FOR XML PATH('prog'), ROOT('oxo')
	-- </prog>

ELSE -- global generic and market

	-- level 1 <prog>
	SELECT L1_VP.Id AS '@id', L1_VP.Model_Year AS '@year', V.Name AS '@name', V.Make AS '@make', 
			
			-- level 2 <level>
			(SELECT L2_MM.Id AS '@id', @p_level AS '@type', L2_MM.Name AS '@name', L2_MM.WHD AS '@whd', L2_MM.PAR_X AS '@par_x', L2_MM.Brand AS '@brand', L2_MM.Territory AS '@territory', L2_MM.WERSCode AS '@wers',
			
					-- level 3 <model>
					(SELECT L3_PM.Id AS '@id',
							'@name' = dbo.OXO_GetVariantName(V.Display_Format, B.Shape, B.Doors, B.Wheelbase, E.Size, E.Fuel_Type, E.Cylinder, E.Turbo, E.Power, T.DriveTrain, T.Type, TM.Name, TM.Level, L3_PM.KD, 0),
							B.Shape AS '@shape', B.Doors AS '@doors', B.Wheelbase AS '@wheelbase', E.Size AS '@size', E.Cylinder AS '@cylinders', E.Turbo AS '@turbo', T.Type AS '@transmission', T.Drivetrain AS '@drivetrain', E.Fuel_Type AS '@fuel', E.Power AS '@power', E.Electrification AS '@drive', TM.Name AS '@trim', TM.Level AS '@level',
				
								-- level 4 <feat>
								(SELECT F.Id AS '@id', F.PROFET_JAG AS '@profet_jag', F.PROFET_LR AS '@profet_lr', F.Feature_Group AS '@featGroup', F.MFD_EFG AS '@featEFG', ISNULL(OXO_Code, '') as '@oxoCode'
								 FROM OXO_Feature F
									  LEFT OUTER JOIN OXO_Item_Data D -- change to inner join to return only 'set' features
									  ON F.Id = D.Feature_Id
								 AND D.OXO_Doc_Id = @p_doc_id
								 AND D.Model_Id = L3_PM.Id
								 AND D.Section = 'FBM'  		
								 AND D.Market_Id = L2_MM.Id
								 FOR XML PATH('feat'), TYPE)	 
								-- </feat>
								
					 FROM	dbo.OXO_Programme_Model L3_PM
							INNER JOIN dbo.OXO_Programme_Body B
							ON L3_PM.Body_Id = B.Id
							INNER JOIN dbo.OXO_Programme_Engine E
							ON L3_PM.Engine_Id = E.Id
							INNER JOIN dbo.OXO_Programme_Transmission T
							ON L3_PM.Transmission_Id = T.Id
							INNER JOIN dbo.OXO_Programme_Trim TM
							ON L3_PM.Trim_Id = TM.Id
							INNER JOIN dbo.OXO_Programme P
							ON P.ID = L3_PM.Programme_Id 
							INNER JOIN OXO_Vehicle V
							ON V.Id = P.Vehicle_Id
					 WHERE   L1_VP.Id = L3_PM.Programme_Id
					 FOR XML PATH('model'), TYPE)
					 -- </model>
					 
			 FROM  OXO_Master_Market AS L2_MM
			 WHERE L2_MM.Id IN (SELECT  ID.Market_Id
								FROM    OXO_Item_Data ID
										INNER JOIN OXO_Programme_Model PM
										ON ID.Model_Id = PM.Id
										INNER JOIN OXO_Programme P
										ON PM.Programme_Id = P.Id
								WHERE P.Id = L1_VP.Id)
			 AND (L2_MM.Id = @p_object_id
			 OR 0 = @p_object_id)
			 FOR XML PATH('level'), TYPE)
			-- </level>
			
	FROM   OXO_Programme L1_VP INNER JOIN
		   OXO_Vehicle V ON V.Id = L1_VP.Vehicle_Id
	WHERE  (L1_VP.Id = @p_prog_id
			OR 0 = @p_prog_id)
	FOR XML PATH('prog'), ROOT('oxo')
	-- </prog>

