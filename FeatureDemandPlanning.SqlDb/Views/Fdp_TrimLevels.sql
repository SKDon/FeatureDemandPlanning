CREATE VIEW [dbo].[Fdp_TrimLevels] AS

	SELECT 
		  T.Programme_Id	AS ProgrammeId
		, T.Id				AS TrimId
		, T.Name			AS TrimName
		, T.Abbreviation
		, RANK() OVER (PARTITION BY T.Programme_Id ORDER BY T.[Level]) AS [Level]
		, 'TL'	+ CAST(RANK() OVER (PARTITION BY T.Programme_Id ORDER BY T.[Level]) AS NVARCHAR(2)) AS TrimLevel
		, 'TLA' + CAST(RANK() OVER (PARTITION BY T.Programme_Id ORDER BY T.[Level]) AS NVARCHAR(2)) AS TrimLevelAbbr
	
	FROM OXO_Programme_Trim AS T
	WHERE
	T.Active = 1;

