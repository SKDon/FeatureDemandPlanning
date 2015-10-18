
CREATE PROCEDURE [dbo].[OXO_Data_GetXSL]
	@p_prog_id INT
AS

BEGIN

	SET NOCOUNT ON;

	DECLARE @head NVARCHAR(MAX)		= '<?xml version="1.0" encoding="utf-8" ?>',
			@schema_o NVARCHAR(MAX) = '<schema xmlns="http://www.ascc.net/xml/schematron">',
			@title NVARCHAR(MAX)	= '  <title>OXO Schematron</title>',
			@pat_o NVARCHAR(MAX)	= '  <pattern name="RuleSet">',
			@rule_o NVARCHAR(MAX)	= '    <rule context="oxo/prog/level/model">',
			@rule_c NVARCHAR(MAX)	= '    </rule>',
			@pat_c NVARCHAR(MAX)	= '  </pattern>',
			@schema_c NVARCHAR(MAX) = '</schema>'
	

	SELECT @head AS [XML]
	UNION ALL
	SELECT @schema_o
	UNION ALL
	SELECT @title
	UNION ALL
	SELECT @pat_o
	UNION ALL
	SELECT @rule_o
	UNION ALL
	SELECT '      <assert test="' + Rule_Assert
		 + '" id="' + CAST(Id AS NVARCHAR) + '"'
		 + ' area="' + Rule_Group + '"'
		 + ' source="' + Rule_Category + '"'
		 + ' owner="' + Owner + '">'
		 + Rule_Response
		 + '</assert>'
	FROM OXO_Programme_Rule
	WHERE Programme_Id = @p_prog_id
	AND Active = 1
	AND Approved = 1
	UNION ALL
	SELECT '      <report test="' + Rule_Report
		 + '" id="' + CAST(Id AS NVARCHAR) + '"'
		 + ' area="' + Rule_Group + '"'
		 + ' source="' + Rule_Category + '"'
		 + ' owner="' + Owner + '">'
		 + Rule_Response
		 + '</report>'
	FROM OXO_Programme_Rule
	WHERE Programme_Id = @p_prog_id
	AND Active = 1
	AND Approved = 1
	UNION ALL
	SELECT @rule_c
	UNION ALL
	SELECT @pat_c
	UNION ALL
	SELECT @schema_c
	 
END
