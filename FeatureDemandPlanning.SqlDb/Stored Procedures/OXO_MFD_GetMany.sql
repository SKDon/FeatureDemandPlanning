CREATE PROCEDURE [dbo].[OXO_MFD_GetMany]	
	@p_section INT = 0	
AS
	
	IF (@p_section = 0)
	BEGIN
		  SELECT 
			  ISNULL(FF.Code, '') AS JLRFamilyCode, 
			  ISNULL(FF.Description, '') AS JLRFamilyName, 
			  ISNULL(LFF.LegacyFamilyCode, '') AS LegacyFamilyCode, 
			  ISNULL(LFF.LegacyFamilyDescription, '') AS LegacyFamilyName, 
			  ISNULL(F.Code, '') AS JLRFeatureCode, 
			  ISNULL(F.Description, '') AS JLRFeatureName,
			  ISNULL(LF.LegacyCode, '') AS LegacyOACode,
			  ISNULL(LF.LegacyDescription, '') AS LegacyOAName,
			  ISNULL(LF2.LegacyCode, '') AS LegacyWERSCode,
			  ISNULL(LF2.LegacyDescription, '') AS LegacyWERSName,
			  CASE WHEN FF.LessFeature = F.Code THEN 1
				   ELSE 0 END AS IsLessFeature  
			FROM MFD_Feature F
			LEFT OUTER JOIN MFD_Feature_Family FF
			ON F.FamilyCode = FF.Code
			LEFT OUTER JOIN MFD_Legacy_Feature_Family LFF
			ON FF.Code = LFF.JLRFamilyCode
			AND LFF.LegacySystemCode = 'OA'
			LEFT OUTER JOIN MFD_Legacy_Feature LF
			ON F.Code = LF.JLRCode
			AND LF.LegacyCodeName = 'OA'
			LEFT OUTER JOIN MFD_Legacy_Feature LF2
			ON F.Code = LF2.JLRCode
			AND LF2.LegacyCodeName = 'WERS'
			WHERE (FF.Code like 'A%'
			OR FF.Code like 'B%' OR FF.Code like 'C%'
			OR FF.Code like 'D%' OR FF.Code like 'E%')	
			ORDER BY  FF.Code, FF.Description, F.Code, F.Description; 
	END;	    

	IF (@p_section = 1)
	BEGIN
		SELECT 
		  ISNULL(FF.Code, '') AS JLRFamilyCode, 
		  ISNULL(FF.Description, '') AS JLRFamilyName, 
		  ISNULL(LFF.LegacyFamilyCode, '') AS LegacyFamilyCode, 
		  ISNULL(LFF.LegacyFamilyDescription, '') AS LegacyFamilyName, 
		  ISNULL(F.Code, '') AS JLRFeatureCode, 
		  ISNULL(F.Description, '') AS JLRFeatureName,
		  ISNULL(LF.LegacyCode, '') AS LegacyOACode,
		  ISNULL(LF.LegacyDescription, '') AS LegacyOAName,
		  ISNULL(LF2.LegacyCode, '') AS LegacyWERSCode,
		  ISNULL(LF2.LegacyDescription, '') AS LegacyWERSName,
		  CASE WHEN FF.LessFeature = F.Code THEN 1
			   ELSE 0 END AS IsLessFeature  
		FROM MFD_Feature F
		LEFT OUTER JOIN MFD_Feature_Family FF
		ON F.FamilyCode = FF.Code
		LEFT OUTER JOIN MFD_Legacy_Feature_Family LFF
		ON FF.Code = LFF.JLRFamilyCode
		AND LFF.LegacySystemCode = 'OA'
		LEFT OUTER JOIN MFD_Legacy_Feature LF
		ON F.Code = LF.JLRCode
		AND LF.LegacyCodeName = 'OA'
		LEFT OUTER JOIN MFD_Legacy_Feature LF2
		ON F.Code = LF2.JLRCode
		AND LF2.LegacyCodeName = 'WERS'
		WHERE (FF.Code like 'F%'
		OR FF.Code like 'G%' OR FF.Code like 'H%'
		OR FF.Code like 'I%' OR FF.Code like 'J%')	
		ORDER BY  FF.Code, FF.Description, F.Code, F.Description; 
	END;
	
	IF (@p_section = 2)
	BEGIN
			SELECT 
		  ISNULL(FF.Code, '') AS JLRFamilyCode, 
		  ISNULL(FF.Description, '') AS JLRFamilyName, 
		  ISNULL(LFF.LegacyFamilyCode, '') AS LegacyFamilyCode, 
		  ISNULL(LFF.LegacyFamilyDescription, '') AS LegacyFamilyName, 
		  ISNULL(F.Code, '') AS JLRFeatureCode, 
		  ISNULL(F.Description, '') AS JLRFeatureName,
		  ISNULL(LF.LegacyCode, '') AS LegacyOACode,
		  ISNULL(LF.LegacyDescription, '') AS LegacyOAName,
		  ISNULL(LF2.LegacyCode, '') AS LegacyWERSCode,
		  ISNULL(LF2.LegacyDescription, '') AS LegacyWERSName,
		  CASE WHEN FF.LessFeature = F.Code THEN 1
			   ELSE 0 END AS IsLessFeature  
		FROM MFD_Feature F
		LEFT OUTER JOIN MFD_Feature_Family FF
		ON F.FamilyCode = FF.Code
		LEFT OUTER JOIN MFD_Legacy_Feature_Family LFF
		ON FF.Code = LFF.JLRFamilyCode
		AND LFF.LegacySystemCode = 'OA'
		LEFT OUTER JOIN MFD_Legacy_Feature LF
		ON F.Code = LF.JLRCode
		AND LF.LegacyCodeName = 'OA'
		LEFT OUTER JOIN MFD_Legacy_Feature LF2
		ON F.Code = LF2.JLRCode
		AND LF2.LegacyCodeName = 'WERS'
		WHERE (FF.Code like 'K%'
		OR FF.Code like 'L%' OR FF.Code like 'M%'
		OR FF.Code like 'N%' OR FF.Code like 'O%')	
		ORDER BY  FF.Code, FF.Description, F.Code, F.Description; 
		
	END;
	
	IF (@p_section = 3)
	BEGIN
	
				SELECT 
		  ISNULL(FF.Code, '') AS JLRFamilyCode, 
		  ISNULL(FF.Description, '') AS JLRFamilyName, 
		  ISNULL(LFF.LegacyFamilyCode, '') AS LegacyFamilyCode, 
		  ISNULL(LFF.LegacyFamilyDescription, '') AS LegacyFamilyName, 
		  ISNULL(F.Code, '') AS JLRFeatureCode, 
		  ISNULL(F.Description, '') AS JLRFeatureName,
		  ISNULL(LF.LegacyCode, '') AS LegacyOACode,
		  ISNULL(LF.LegacyDescription, '') AS LegacyOAName,
		  ISNULL(LF2.LegacyCode, '') AS LegacyWERSCode,
		  ISNULL(LF2.LegacyDescription, '') AS LegacyWERSName,
		  CASE WHEN FF.LessFeature = F.Code THEN 1
			   ELSE 0 END AS IsLessFeature  
		FROM MFD_Feature F
		LEFT OUTER JOIN MFD_Feature_Family FF
		ON F.FamilyCode = FF.Code
		LEFT OUTER JOIN MFD_Legacy_Feature_Family LFF
		ON FF.Code = LFF.JLRFamilyCode
		AND LFF.LegacySystemCode = 'OA'
		LEFT OUTER JOIN MFD_Legacy_Feature LF
		ON F.Code = LF.JLRCode
		AND LF.LegacyCodeName = 'OA'
		LEFT OUTER JOIN MFD_Legacy_Feature LF2
		ON F.Code = LF2.JLRCode
		AND LF2.LegacyCodeName = 'WERS'
		WHERE (FF.Code like 'P%'
		OR FF.Code like 'Q%' OR FF.Code like 'R%'
		OR FF.Code like 'S%' OR FF.Code like 'T%')	
		ORDER BY  FF.Code, FF.Description, F.Code, F.Description;
	END;
	
	
	IF (@p_section = 4)
	BEGIN	
		SELECT 
		  ISNULL(FF.Code, '') AS JLRFamilyCode, 
		  ISNULL(FF.Description, '') AS JLRFamilyName, 
		  ISNULL(LFF.LegacyFamilyCode, '') AS LegacyFamilyCode, 
		  ISNULL(LFF.LegacyFamilyDescription, '') AS LegacyFamilyName, 
		  ISNULL(F.Code, '') AS JLRFeatureCode, 
		  ISNULL(F.Description, '') AS JLRFeatureName,
		  ISNULL(LF.LegacyCode, '') AS LegacyOACode,
		  ISNULL(LF.LegacyDescription, '') AS LegacyOAName,
		  ISNULL(LF2.LegacyCode, '') AS LegacyWERSCode,
		  ISNULL(LF2.LegacyDescription, '') AS LegacyWERSName,
		  CASE WHEN FF.LessFeature = F.Code THEN 1
			   ELSE 0 END AS IsLessFeature  
		FROM MFD_Feature F
		LEFT OUTER JOIN MFD_Feature_Family FF
		ON F.FamilyCode = FF.Code
		LEFT OUTER JOIN MFD_Legacy_Feature_Family LFF
		ON FF.Code = LFF.JLRFamilyCode
		AND LFF.LegacySystemCode = 'OA'
		LEFT OUTER JOIN MFD_Legacy_Feature LF
		ON F.Code = LF.JLRCode
		AND LF.LegacyCodeName = 'OA'
		LEFT OUTER JOIN MFD_Legacy_Feature LF2
		ON F.Code = LF2.JLRCode
		AND LF2.LegacyCodeName = 'WERS'
		WHERE (FF.Code like 'U%'
		OR FF.Code like 'V%' OR FF.Code like 'W%'
		OR FF.Code like 'X%' OR FF.Code like 'Y%'
		OR FF.Code like 'Z%')	
		ORDER BY  FF.Code, FF.Description, F.Code, F.Description;
	END;

