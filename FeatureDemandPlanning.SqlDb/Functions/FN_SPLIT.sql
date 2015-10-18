CREATE FUNCTION [dbo].[FN_SPLIT] (

@str_in VARCHAR(8000),

@separator VARCHAR(4) )

RETURNS @strtable TABLE (strval VARCHAR(8000))

AS

BEGIN

DECLARE

@Occurrences INT,

@Counter INT,

@tmpStr VARCHAR(8000)

SET @Counter = 0

IF SUBSTRING(@str_in,LEN(@str_in),1) <> @separator 

SET @str_in = @str_in + @separator

SET @Occurrences = (DATALENGTH(REPLACE(@str_in,@separator,@separator+'#')) - DATALENGTH(@str_in))/ DATALENGTH(@separator)

SET @tmpStr = @str_in

WHILE @Counter <= @Occurrences 

BEGIN

SET @Counter = @Counter + 1

INSERT INTO @strtable

VALUES ( SUBSTRING(@tmpStr,1,CHARINDEX(@separator,@tmpStr)-1))

SET @tmpStr = SUBSTRING(@tmpStr,CHARINDEX(@separator,@tmpStr)+1,8000)


IF DATALENGTH(@tmpStr) = 0

BREAK


END

RETURN 

END