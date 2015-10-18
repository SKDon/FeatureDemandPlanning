CREATE PROCEDURE [dbo].[OXO_IMP_Features]
AS

	/* Empty the temp feature table */

	TRUNCATE TABLE TMP_Feature_Import

	/* Import tab delimited file into temp table */
	BULK INSERT TMP_Feature_Import
	FROM 'C:\MN_TEMP\Dump\Features.txt'
	WITH
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = '\t',
		ROWTERMINATOR = '\n',
		CODEPAGE = 'ACP',
		ERRORFILE = 'C:\MN_TEMP\Dump\import_errors\TMP_Feature_Import_Errors.txt'
	)

	/* Cleanup temp table */	
		
	DELETE FROM TMP_Feature_Import
	WHERE Feat_Code IS NULL
	
	UPDATE TMP_Feature_Import
	SET Feat_Desc = SUBSTRING(Feat_Desc, 2, LEN(Feat_Desc))
	WHERE LEFT(Feat_Desc, 1) = '"'
	
	UPDATE TMP_Feature_Import
	SET Feat_Desc = SUBSTRING(Feat_Desc, 1, LEN(Feat_Desc) -1)
	WHERE RIGHT(Feat_Desc, 1) = '"'
	
	UPDATE TMP_Feature_Import
	SET Feat_Desc = REPLACE(Feat_Desc, '""', '"')
	
	UPDATE TMP_Feature_Import
	SET Long_Desc = SUBSTRING(Long_Desc, 2, LEN(Long_Desc))
	WHERE LEFT(Long_Desc, 1) = '"'
	
	UPDATE TMP_Feature_Import
	SET Long_Desc = SUBSTRING(Long_Desc, 1, LEN(Long_Desc) -1)
	WHERE RIGHT(Long_Desc, 1) = '"'
	
	UPDATE TMP_Feature_Import
	SET Long_Desc = REPLACE(Long_Desc, '""', '"')
	
	UPDATE TMP_Feature_Import
	SET Legal_Comments = SUBSTRING(Legal_Comments, 2, LEN(Legal_Comments))
	WHERE LEFT(Legal_Comments, 1) = '"'
	
	UPDATE TMP_Feature_Import
	SET Legal_Comments = SUBSTRING(Legal_Comments, 1, LEN(Legal_Comments) -1)
	WHERE RIGHT(Legal_Comments, 1) = '"'
	
	UPDATE TMP_Feature_Import
	SET Legal_Comments = REPLACE(Legal_Comments, '""', '"')
	
	UPDATE TMP_Feature_Import
	SET Brand_Desc_LR = SUBSTRING(Brand_Desc_LR, 2, LEN(Brand_Desc_LR))
	WHERE LEFT(Brand_Desc_LR, 1) = '"'	
	
	UPDATE TMP_Feature_Import
	SET Brand_Desc_LR = SUBSTRING(Brand_Desc_LR, 1, LEN(Brand_Desc_LR) -1)
	WHERE RIGHT(Brand_Desc_LR, 1) = '"'
	
	UPDATE TMP_Feature_Import
	SET Brand_Desc_LR = REPLACE(Brand_Desc_LR, '""', '"')
	
	UPDATE TMP_Feature_Import
	SET Brand_Desc_Jag = SUBSTRING(Brand_Desc_Jag, 2, LEN(Brand_Desc_Jag))
	WHERE LEFT(Brand_Desc_Jag, 1) = '"'	
	
	UPDATE TMP_Feature_Import
	SET Brand_Desc_LR = SUBSTRING(Brand_Desc_Jag, 1, LEN(Brand_Desc_Jag) -1)
	WHERE RIGHT(Brand_Desc_Jag, 1) = '"'
	
	UPDATE TMP_Feature_Import
	SET Brand_Desc_Jag = REPLACE(Brand_Desc_Jag, '""', '"')
	
	UPDATE TMP_Feature_Import
	SET JLR_OXO_Grp = SUBSTRING(JLR_OXO_Grp, 2, LEN(JLR_OXO_Grp))
	WHERE LEFT(JLR_OXO_Grp, 1) = '"'

	UPDATE TMP_Feature_Import
	SET JLR_OXO_Grp = SUBSTRING(JLR_OXO_Grp, 1, LEN(JLR_OXO_Grp) -1)
	WHERE RIGHT(JLR_OXO_Grp, 1) = '"'
	
	UPDATE TMP_Feature_Import
	SET L316 = NULL
	WHERE LEFT(L316, 1) = '	'
	
	UPDATE TMP_Feature_Import
	SET L316 = REPLACE(L316, '	', '')

	/* Populate feature table with new records */
	
	INSERT INTO OXO_IMP_Feature (Feat_Code, EFG_Code, OA_Code, Description, Long_Desc, Legal_Comment, Priorty_X351_L462, 
								 In_LR_Coding, In_Jag_Coding, WERS_Code, On_Relevant_Map,
								 LR_Verified_By, Jag_Verified_By, Grp_Verified_By, Status, Created_By, Created_On)
	SELECT	DISTINCT Feat_Code, EFG_Code, OA_Code, Feat_Desc, Long_Desc, Legal_Comments, Priorty_X351_L462,
			In_LR_Coding, In_Jag_Coding, WERS_Code, On_Relevant_Map,
			LR_Verified_By, Jag_Verified_By, Grp_Verified_By, 0, 'SYSTEM', GetDate()
	FROM TMP_Feature_Import
	WHERE Feat_Code NOT IN (SELECT Feat_Code
							FROM OXO_IMP_Feature)
	
	/* Update feature table with changed records */
	
	UPDATE OXO_IMP_Feature
	SET OA_Code = TMP.OA_Code,
		EFG_Code = TMP.EFG_Code,
		Description = TMP.Feat_Desc,
		Long_Desc = TMP.Long_Desc,
		Legal_Comment = TMP.Legal_Comments,
		Priorty_X351_L462 = TMP.Priorty_X351_L462,
		In_LR_Coding = TMP.In_LR_Coding,
		In_Jag_Coding = TMP.In_Jag_Coding,
		WERS_Code = TMP.WERS_Code,
		On_Relevant_Map = TMP.On_Relevant_Map,
		LR_Verified_By = TMP.LR_Verified_By,
		Jag_Verified_By = TMP.Jag_Verified_By,
		Grp_Verified_By = TMP.Grp_Verified_By,
		Status = 1,
		Updated_By = 'SYSTEM',
		Last_Updated = GetDate()
	FROM OXO_IMP_Feature IMP
	INNER JOIN TMP_Feature_Import TMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE IMP.OA_Code <> TMP.OA_Code
	OR IMP.EFG_Code <> TMP.EFG_Code
	OR IMP.Description <> TMP.Feat_Desc
	OR IMP.Long_Desc <> TMP.Long_Desc
	OR IMP.Legal_Comment <> TMP.Legal_Comments
	OR IMP.Priorty_X351_L462 <> TMP.Priorty_X351_L462
	OR IMP.In_LR_Coding <> TMP.In_LR_Coding
	OR IMP.In_Jag_Coding <> TMP.In_Jag_Coding
	OR IMP.WERS_Code <> TMP.WERS_Code
	OR IMP.On_Relevant_Map <> TMP.On_Relevant_Map
	OR IMP.LR_Verified_By <> TMP.LR_Verified_By
	OR IMP.Jag_Verified_By <> TMP.Jag_Verified_By
	OR IMP.Grp_Verified_By <> TMP.Grp_Verified_By
	
	/* Populate brand description table with new records */

	INSERT INTO OXO_IMP_Brand_Desc (Feat_Code, Brand, Brand_Desc, Status, Created_By, Created_On)
	SELECT Feat_Code, 'J', Brand_Desc_Jag, 0, 'SYSTEM', GetDate()
	FROM TMP_Feature_Import
	WHERE Feat_Code NOT IN (SELECT Feat_Code
							FROM OXO_IMP_Brand_Desc
							WHERE Brand = 'J')
	AND Brand_Desc_Jag IS NOT NULL
	
	INSERT INTO OXO_IMP_Brand_Desc (Feat_Code, Brand, Brand_Desc, Status, Created_By, Created_On)
	SELECT Feat_Code, 'LR', Brand_Desc_LR, 0, 'SYSTEM', GetDate()
	FROM TMP_Feature_Import
	WHERE Feat_Code NOT IN (SELECT Feat_Code
							FROM OXO_IMP_Brand_Desc
							WHERE Brand = 'LR')
	AND Brand_Desc_LR IS NOT NULL
	
	/* Update brand description table with changed records */

	UPDATE OXO_IMP_Brand_Desc
	SET Brand_Desc = TMP.Brand_Desc_Jag,
		Status = 1,
		Updated_By = 'SYSTEM',
		Last_Updated = GetDate()
	FROM OXO_IMP_Brand_Desc IMP
	INNER JOIN TMP_Feature_Import TMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE IMP.Brand = 'J'
	AND IMP.Brand_Desc <> TMP.Brand_Desc_Jag
	
	UPDATE OXO_IMP_Brand_Desc
	SET Brand_Desc = TMP.Brand_Desc_LR,
		Status = 1,
		Updated_By = 'SYSTEM',
		Last_Updated = GetDate()
	FROM OXO_IMP_Brand_Desc IMP
	INNER JOIN TMP_Feature_Import TMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE IMP.Brand = 'LR'
	AND IMP.Brand_Desc <> TMP.Brand_Desc_LR
	
	/* Populate EFG table with new records */
	
	INSERT INTO OXO_IMP_Efg (EFG_Code, EFG_Desc, EFG_Type, Status, Created_By, Created_On)
	SELECT DISTINCT  EFG_Code, EFG_Desc, EFG_Type, 0, 'SYSTEM', GetDate()
	FROM TMP_Feature_Import
	WHERE EFG_Code NOT IN (SELECT EFG_Code
								  FROM OXO_IMP_Efg)
	AND EFG_Code IS NOT NULL
	
	/* Update EFG table with changed records */
	
	UPDATE OXO_IMP_Efg
	SET EFG_Desc = TMP.EFG_Desc,
		EFG_Type = TMP.EFG_Type,
		Status = 1,
		Updated_By = 'SYSTEM',
		Last_Updated = GetDate()
	FROM OXO_IMP_Efg IMP
	INNER JOIN TMP_Feature_Import TMP
	ON IMP.EFG_Code = TMP.EFG_Code
	WHERE IMP.EFG_Desc <> TMP.EFG_Desc
	OR	  IMP.EFG_Type <> TMP.EFG_Type
	
	/* Populate the OXO Group table with new records */
	
	BEGIN
	WITH SET_A AS (
		SELECT DISTINCT CASE 
							WHEN JLR_OXO_Grp LIKE '% -%' THEN LEFT(JLR_OXO_Grp, CHARINDEX(' -', JLR_OXO_Grp) - 1)
							ELSE JLR_OXO_Grp
						END AS Group_Name,
						CASE 
							WHEN JLR_OXO_Grp LIKE '% - %' THEN RIGHT(JLR_OXO_Grp, LEN(JLR_OXO_Grp) - CHARINDEX('-', JLR_OXO_Grp) - 1)
							ELSE NULL
						END AS Sub_Group_Name
		FROM TMP_Feature_Import
		WHERE JLR_OXO_Grp IS NOT NULL
	)
	
	INSERT INTO OXO_IMP_OXO_Group (Group_Name, Sub_Group_Name, Status, Created_By, Created_On)
	SELECT Group_Name, Sub_Group_Name, 0, 'SYSTEM', GetDate()
	FROM SET_A
	WHERE Group_Name + ':' + Sub_Group_Name NOT IN (SELECT Group_Name + ':' + ISNULL(Sub_Group_Name,'')
													FROM OXO_IMP_OXO_Group)
	END
	
	/* Update the Feature table with the OXO Group Code */
	
	UPDATE OXO_IMP_Feature
	SET OXO_Grp = OG.Id
	FROM OXO_IMP_Feature IMP
	INNER JOIN TMP_Feature_Import TMP
	ON IMP.Feat_Code = TMP.Feat_Code
	INNER JOIN OXO_IMP_OXO_Group OG
	ON OG.Group_Name = LEFT(TMP.JLR_OXO_Grp, CHARINDEX(' -', TMP.JLR_OXO_Grp) - 1)
	AND
	OG.Sub_Group_Name = RIGHT(TMP.JLR_OXO_Grp, LEN(TMP.JLR_OXO_Grp) - CHARINDEX('-', TMP.JLR_OXO_Grp) - 1)
	WHERE TMP.JLR_OXO_Grp LIKE '% - %'
	
	UPDATE OXO_IMP_Feature
	SET OXO_Grp = OG.Id
	FROM OXO_IMP_Feature IMP
	INNER JOIN TMP_Feature_Import TMP
	ON IMP.Feat_Code = TMP.Feat_Code
	INNER JOIN OXO_IMP_OXO_Group OG
	ON OG.Group_Name = LEFT(TMP.JLR_OXO_Grp, CHARINDEX(' -', TMP.JLR_OXO_Grp) - 1)
	AND
	OG.Sub_Group_Name IS NULL
	WHERE TMP.JLR_OXO_Grp LIKE '% -%'
	
	UPDATE OXO_IMP_Feature
	SET OXO_Grp = OG.Id
	FROM OXO_IMP_Feature IMP
	INNER JOIN TMP_Feature_Import TMP
	ON IMP.Feat_Code = TMP.Feat_Code
	INNER JOIN OXO_IMP_OXO_Group OG
	ON OG.Group_Name = TMP.JLR_OXO_Grp
	AND
	OG.Sub_Group_Name IS NULL
	WHERE TMP.JLR_OXO_Grp NOT LIKE '% -%'	
	
	/* Populate the Config Group table with new records */
	
	BEGIN
	WITH SET_A AS (
		SELECT DISTINCT CASE 
							WHEN Config_Grp LIKE '%>%' THEN LEFT(Config_Grp, CHARINDEX('>', Config_Grp) - 1)
							ELSE Config_Grp
						END AS Group_Name,
						CASE 
							WHEN Config_Grp LIKE '%>%' THEN RIGHT(Config_Grp, LEN(Config_Grp) - CHARINDEX('>', Config_Grp))
							ELSE NULL
						END AS Sub_Group_Name
		FROM TMP_Feature_Import
		WHERE Config_Grp IS NOT NULL
	)
	
	INSERT INTO OXO_IMP_Config_Group (Group_Name, Sub_Group_Name, Status, Created_By, Created_On)
	SELECT Group_Name, Sub_Group_Name, 0, 'SYSTEM', GetDate()
	FROM SET_A
	WHERE Group_Name + ':' + Sub_Group_Name NOT IN (SELECT Group_Name + ':' + ISNULL(Sub_Group_Name,'')
													FROM OXO_IMP_Config_Group)
	END
	
	/* Update the Feature table with the Config Group Code */
	
	UPDATE OXO_IMP_Feature
	SET Config_Grp = CG.Id
	FROM OXO_IMP_Feature IMP
	INNER JOIN TMP_Feature_Import TMP
	ON IMP.Feat_Code = TMP.Feat_Code
	INNER JOIN OXO_IMP_Config_Group CG
	ON CG.Group_Name = LEFT(TMP.Config_Grp, CHARINDEX('>', TMP.Config_Grp) - 1)
	AND
	CG.Sub_Group_Name = RIGHT(TMP.Config_Grp, LEN(TMP.Config_Grp) - CHARINDEX('>', TMP.Config_Grp))
	WHERE TMP.Config_Grp LIKE '%>%'
	
	UPDATE OXO_IMP_Feature
	SET Config_Grp = CG.Id
	FROM OXO_IMP_Feature IMP
	INNER JOIN TMP_Feature_Import TMP
	ON IMP.Feat_Code = TMP.Feat_Code
	INNER JOIN OXO_IMP_Config_Group CG
	ON CG.Group_Name = TMP.Config_Grp
	AND CG.Sub_Group_Name IS NULL
	WHERE TMP.Config_Grp NOT LIKE '%>%'
	
	/* Populate Vehicles with any new models */
	
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM OXO_Vehicle WHERE Name = 'X761')
			BEGIN
				INSERT INTO OXO_Vehicle (Name, AKA, Display_Format, Make, Active, Created_By, Created_On)
				VALUES ('X761', 'F-Pace', '[sh][dr][wb][sz][cy][tb][pw][dv][gr][tr]', 'Jaguar', 1, 'pbriscoe', GetDate())
			END
	END
   
	/* Populate vehicle feature applicability */
	
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'X761'
	AND TMP.X761 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)
	
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'X760'
	AND TMP.X760 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)
	
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'X152'
	AND TMP.X152 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)
	
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'X351'
	AND TMP.X351 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)
					   
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'X260'
	AND TMP.X260 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)
	
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'X360'
	AND TMP.X360 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)
					   
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'X540'
	AND TMP.X540 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)
	
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'L405'
	AND TMP.L405 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)
	
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'L494'
	AND TMP.L494 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)
	
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'L538'
	AND TMP.L538 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)
	
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'L319'
	AND TMP.L319 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)
	
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'L550'
	AND TMP.L550 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)
	
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'L462'
	AND TMP.L462 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)
	
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'L316'
	AND TMP.L316 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)

