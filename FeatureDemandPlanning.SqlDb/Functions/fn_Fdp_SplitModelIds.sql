CREATE FUNCTION [dbo].[fn_Fdp_SplitModelIds] (@ModelIds NVARCHAR(MAX))
RETURNS @strtable TABLE 
(
	  ModelId INT
	, StringIdentifier NVARCHAR(10)
	, IsFdpModel BIT NOT NULL DEFAULT(0)
)
AS

BEGIN

DECLARE @occurrences INT;
DECLARE @counter INT;
DECLARE @tmpStr NVARCHAR(1000);
DECLARE @separator NVARCHAR(4);

SET @counter = 0;
SET @separator = ',';
SET @ModelIds = REPLACE(@ModelIds, '[', '');
SET @ModelIds = REPLACE(@ModelIds, ']', '');

IF SUBSTRING(@ModelIds,LEN(@ModelIds),1) <> @separator 

SET @ModelIds = @ModelIds + @separator

SET @occurrences = (DATALENGTH(REPLACE(@ModelIds,@separator,@separator+'#')) - DATALENGTH(@ModelIds))/ DATALENGTH(@separator)

SET @tmpStr = @ModelIds

WHILE @counter <= @occurrences 

BEGIN

SET @counter = @counter + 1

INSERT INTO @strtable 
(
	  ModelId
	, StringIdentifier
	, IsFdpModel
)
VALUES 
( 
	  CAST(SUBSTRING(LTRIM(SUBSTRING(@tmpStr,1,CHARINDEX(@separator,@tmpStr)-1)), 2, 10) AS INT)
	, LTRIM(SUBSTRING(@tmpStr,1,CHARINDEX(@separator,@tmpStr)-1))
	, CASE 
		WHEN LEFT(LTRIM(SUBSTRING(@tmpStr,1,CHARINDEX(@separator,@tmpStr)-1)), 1) = 'F'
		THEN 1
		ELSE 0
	  END
)

SET @tmpStr = SUBSTRING(@tmpStr,CHARINDEX(@separator,@tmpStr)+1,8000)


IF DATALENGTH(@tmpStr) = 0

BREAK


END

RETURN 

END