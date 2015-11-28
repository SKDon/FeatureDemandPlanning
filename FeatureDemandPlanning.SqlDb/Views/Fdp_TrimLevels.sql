
CREATE VIEW [dbo].[Fdp_TrimLevels] AS

	SELECT 
		  T.Programme_Id	AS ProgrammeId
		, T.Id				AS TrimId
		, NULL				AS FdpTrimId
		, T.Name			AS TrimName
		, T.Abbreviation
		, RANK() OVER (PARTITION BY T.Programme_Id ORDER BY T.[Level]) AS [Level]
		, 'TL'	+ CAST(RANK() OVER (PARTITION BY T.Programme_Id ORDER BY T.[Level]) AS NVARCHAR(2)) AS TrimLevel
		, 'TLA' + CAST(RANK() OVER (PARTITION BY T.Programme_Id ORDER BY T.[Level]) AS NVARCHAR(2)) AS TrimLevelAbbr
	
	FROM OXO_Programme_Trim AS T
	WHERE
	T.Active = 1
	
	UNION
	
	SELECT 
		  T.ProgrammeId
		, NULL				AS TrimId
		, T.FdpTrimId
		, T.TrimName
		, T.TrimAbbreviation AS Abbreviation
		, RANK() OVER (PARTITION BY T.ProgrammeId ORDER BY T.TrimLevel) AS [Level]
		, 'TL'	+ CAST(RANK() OVER (PARTITION BY T.ProgrammeId ORDER BY T.TrimLevel) AS NVARCHAR(2)) AS TrimLevel
		, 'TLA' + CAST(RANK() OVER (PARTITION BY T.ProgrammeId ORDER BY T.TrimLevel) AS NVARCHAR(2)) AS TrimLevelAbbr
	
	FROM Fdp_Trim AS T
	WHERE
	T.IsActive = 1;

