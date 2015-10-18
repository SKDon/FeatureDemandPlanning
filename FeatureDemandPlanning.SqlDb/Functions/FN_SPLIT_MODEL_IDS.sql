CREATE FUNCTION [dbo].[FN_SPLIT_MODEL_IDS] (@p_model_ids NVARCHAR(MAX))
RETURNS @strtable TABLE (Model_Id NVARCHAR(1000))

AS

BEGIN

DECLARE @occurrences INT;
DECLARE @counter INT;
DECLARE @tmpStr NVARCHAR(1000);
DECLARE @separator NVARCHAR(4);

SET @counter = 0;
SET @separator = ',';
SET @p_model_ids = REPLACE(@p_model_ids, '[', '');
SET @p_model_ids = REPLACE(@p_model_ids, ']', '');

IF SUBSTRING(@p_model_ids,LEN(@p_model_ids),1) <> @separator 

SET @p_model_ids = @p_model_ids + @separator

SET @occurrences = (DATALENGTH(REPLACE(@p_model_ids,@separator,@separator+'#')) - DATALENGTH(@p_model_ids))/ DATALENGTH(@separator)

SET @tmpStr = @p_model_ids

WHILE @counter <= @occurrences 

BEGIN

SET @counter = @counter + 1

INSERT INTO @strtable

VALUES ( LTRIM(SUBSTRING(@tmpStr,1,CHARINDEX(@separator,@tmpStr)-1)))

SET @tmpStr = SUBSTRING(@tmpStr,CHARINDEX(@separator,@tmpStr)+1,8000)


IF DATALENGTH(@tmpStr) = 0

BREAK


END

RETURN 

END
