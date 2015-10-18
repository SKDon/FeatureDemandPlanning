CREATE PROCEDURE [dbo].[OXO_IMP_Features]
AS
BEGIN

	/* Empty the temp feature table */

	TRUNCATE TABLE TMP_Feature_Import

	/* Import tab delimited file into temp table */
	
	BULK INSERT TMP_Feature_Import
	FROM 'C:\Users\$sbant.JLRIEU1\Documents\JMFD\Features.txt'
	WITH
	(
		FIRSTROW = 2,
		FIELDTERMINATOR = '\t',
		ROWTERMINATOR = '\n',
		CODEPAGE = 'ACP',
		ERRORFILE = 'C:\Users\$sbant.JLRIEU1\Documents\JMFD\Error\TMP_Feature_Import_Errors.txt'
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
	AND Status = 'NEW'
	
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
	WHERE ISNULL(IMP.OA_Code, '') <> ISNULL(TMP.OA_Code, '')
	OR ISNULL(IMP.EFG_Code, '') <> ISNULL(TMP.EFG_Code, '')
	OR ISNULL(IMP.Description, '') <> ISNULL(TMP.Feat_Desc, '')
	OR ISNULL(IMP.Long_Desc, '') <> ISNULL(TMP.Long_Desc, '')
	OR ISNULL(IMP.Legal_Comment, '') <> ISNULL(TMP.Legal_Comments, '')
	OR ISNULL(IMP.Priorty_X351_L462, '') <> ISNULL(TMP.Priorty_X351_L462, '')
	OR ISNULL(IMP.In_LR_Coding, '') <> ISNULL(TMP.In_LR_Coding, '')
	OR ISNULL(IMP.In_Jag_Coding, '') <> ISNULL(TMP.In_Jag_Coding, '')
	OR ISNULL(IMP.WERS_Code, '') <> ISNULL(TMP.WERS_Code, '')
	OR ISNULL(IMP.On_Relevant_Map, '') <> ISNULL(TMP.On_Relevant_Map, '')
	OR ISNULL(IMP.LR_Verified_By, '') <> ISNULL(TMP.LR_Verified_By, '')
	OR ISNULL(IMP.Jag_Verified_By, '') <> ISNULL(TMP.Jag_Verified_By, '')
	OR ISNULL(IMP.Grp_Verified_By, '') <> ISNULL(TMP.Grp_Verified_By, '')
	AND TMP.Status = 'Amended'
	
	/* Update feature table with 'mapped' feature codes */
	
	UPDATE OXO_IMP_Feature
	SET Feat_Code = TMP.Feat_Code,
		Status = 1,
		Updated_By = 'SYSTEM',
		Last_Updated = GetDate()
	FROM OXO_IMP_Feature IMP
	INNER JOIN TMP_Feature_Import TMP
	ON IMP.Id = TMP.RADS_Id
	WHERE TMP.Status = 'Mapped'
	
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
	AND TMP.Brand_Desc_Jag IS NOT NULL
	AND ISNULL(IMP.Brand_Desc, '') <> ISNULL(TMP.Brand_Desc_Jag, '')
	
	UPDATE OXO_IMP_Brand_Desc
	SET Brand_Desc = TMP.Brand_Desc_LR,
		Status = 1,
		Updated_By = 'SYSTEM',
		Last_Updated = GetDate()
	FROM OXO_IMP_Brand_Desc IMP
	INNER JOIN TMP_Feature_Import TMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE IMP.Brand = 'LR'
	AND TMP.Brand_Desc_LR IS NOT NULL
	AND ISNULL(IMP.Brand_Desc, '') <> ISNULL(TMP.Brand_Desc_LR, '')
	
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
	WHERE ISNULL(IMP.EFG_Desc, '') <> ISNULL(TMP.EFG_Desc, '')
	OR	  ISNULL(IMP.EFG_Type, '') <> ISNULL(TMP.EFG_Type, '')
	
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
	WHERE Group_Name + ':' + ISNULL(Sub_Group_Name, '') NOT IN (SELECT Group_Name + ':' + ISNULL(Sub_Group_Name,'')
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
		IF NOT EXISTS (SELECT 1 FROM OXO_Vehicle WHERE Name = 'L560')
			BEGIN
				INSERT INTO OXO_Vehicle (Name, AKA, Display_Format, Make, Active, Created_By, Created_On)
				VALUES ('L560', 'TBC', '[sh][dr][wb][sz][cy][tb][pw][dv][gr][tr]', 'Land Rover', 1, 'pbriscoe', GetDate())
			END
	END
	
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM OXO_Vehicle WHERE Name = 'X590')
			BEGIN
				INSERT INTO OXO_Vehicle (Name, AKA, Display_Format, Make, Active, Created_By, Created_On)
				VALUES ('X590', 'TBC', '[sh][dr][wb][sz][cy][tb][pw][dv][gr][tr]', 'Jaguar', 1, 'pbriscoe', GetDate())
			END
	END
	
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM OXO_Vehicle WHERE Name = 'X261')
			BEGIN
				INSERT INTO OXO_Vehicle (Name, AKA, Display_Format, Make, Active, Created_By, Created_On)
				VALUES ('X261', 'TBC', '[sh][dr][wb][sz][cy][tb][pw][dv][gr][tr]', 'Jaguar', 1, 'pbriscoe', GetDate())
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
					   
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'L663'
	AND TMP.L663 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)
	
	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'L560'
	AND TMP.L560 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)

	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'X590'
	AND TMP.X590 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)

	INSERT INTO OXO_Vehicle_Feature_Applicability (Vehicle_Id, Feature_Id, Created_By, Created_On)
	SELECT DISTINCT V.Id, IMP.Id, 'SYSTEM', GetDate()
	FROM OXO_Vehicle V
	CROSS JOIN TMP_Feature_Import TMP
	INNER JOIN OXO_IMP_Feature IMP
	ON IMP.Feat_Code = TMP.Feat_Code
	WHERE V.Name = 'X261'
	AND TMP.X261 IS NOT NULL
	AND IMP.Id NOT IN (SELECT Feature_Id
					   FROM OXO_Vehicle_Feature_Applicability
					   WHERE OXO_Vehicle_Feature_Applicability.Vehicle_Id = V.Id)

	/* Remove any retired features */
	
	UPDATE OXO_IMP_Feature
	SET Status = NULL
	WHERE Feat_Code IN ('300SA',
						'030NV',
						'064DB',
						'064HJ',
						'080FJ',
						'080JF',
						'080JG',
						'100',
						'101',
						'967',
						'968',
						'969',
						'974',
						'975',
						'976',
						'977',
						'978',
						'980',
						'982',
						'988',
						'989',
						'990',
						'991',
						'993',
						'025WW',
						'022EA',
						'088MZ',
						'048BQ',
						'032CW',
						'032JC',
						'021BQ',
						'021BR',
						'045AV',
						'109AC',
						'033GT',
						'033NH',
						'033NJ',
						'033NK',
						'031FH',
						'031FI',
						'031FJ',
						'031HS',
						'031HT',
						'031HU',
						'031HV',
						'031HW',
						'031HX',
						'031HY',
						'031JA',
						'031JB',
						'031JC',
						'031JD',
						'031JE',
						'031JF',
						'031JG',
						'031JH',
						'031JJ')
	AND Status IS NOT NULL
						
	/* Delete any redundant OXO groups */
	
	DELETE
	FROM OXO_Imp_OXO_Group
	WHERE Id NOT IN (SELECT DISTINCT ISNULL(OXO_Grp, 0)
					 FROM OXO_Imp_Feature
					 WHERE Status IS NOT NULL)
					 
	
	/* Delete / retire unwanted features by carline */
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X761 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X761'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'X761'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X761 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X761'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'X761'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X760 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X760'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'X760'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X760 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X760'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'X760'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X152 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X152'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'X152'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X152 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X152'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'X152'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X351 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X351'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'X351'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X351 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X351'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'X351'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X260 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X260'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'X260'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X260 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X260'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'X260'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X360 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X360'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'X360'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X360 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X360'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'X360'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X540 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X540'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'X540'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X540 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X540'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'X540'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L405 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L405'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'L405'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L405 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L405'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'L405'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L494 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L494'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'L494'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L494 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L494'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'L494'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L538 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L538'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'L538'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L538 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L538'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'L538'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L319 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L319'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'L319'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L319 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L319'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'L319'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L550 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L550'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'L550'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L550 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L550'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'L550'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L462 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L462'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'L462'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L462 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L462'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'L462'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L316 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L316'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'L316'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L316 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L316'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'L316'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L663 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L663'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'L663'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L663 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L663'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'L663'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L560 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L560'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'L560'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.L560 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'L560'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'L560'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X590 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X590'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'X590'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X590 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X590'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'X590'
		AND B.Feature_Id IS NULL;
	END
	
	BEGIN
		WITH SET_A AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X261 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X261'
		)	
		UPDATE OXO_Programme_Feature_Link
		SET Status = 'Removed'
		FROM OXO_Programme_Feature_Link FL
		INNER JOIN OXO_Programme P
		ON P.Id = FL.Programme_Id
		INNER JOIN OXO_Vehicle V
		ON P.Vehicle_Id = V.Id
		LEFT OUTER JOIN SET_A AS A
		ON FL.Feature_Id = A.Feature_Id
		WHERE V.Name = 'X261'
		AND A.Feature_Id IS NULL;
		
		WITH SET_B AS (
			SELECT VFA.Feature_Id
			FROM OXO_Vehicle_Feature_Applicability VFA
			INNER JOIN OXO_IMP_Feature IMP
			ON IMP.Id = VFA.Feature_Id
			INNER JOIN OXO_Vehicle V
			ON VFA.Vehicle_Id = V.Id
			INNER JOIN TMP_Feature_Import TMP
			ON IMP.Feat_Code = CASE WHEN TMP.X261 IS NOT NULL THEN TMP.Feat_Code ELSE NULL END
			WHERE V.Name = 'X261'
		)
		DELETE VFA
		FROM OXO_Vehicle_Feature_Applicability VFA
		INNER JOIN OXO_Vehicle V
		ON V.Id = VFA.Vehicle_Id
		LEFT OUTER JOIN SET_B AS B
		ON VFA.Feature_Id = B.Feature_Id
		WHERE V.Name = 'X261'
		AND B.Feature_Id IS NULL;
	END

END

