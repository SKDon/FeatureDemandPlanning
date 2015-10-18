
CREATE FUNCTION [TryConvertInt](@Value varchar(18))
RETURNS int
AS
BEGIN
    SET @Value = REPLACE(@Value, ',', '')
    IF ISNUMERIC(@Value + 'e0') = 0 RETURN NULL
    IF ( CHARINDEX('.', @Value) > 0 AND CONVERT(bigint, PARSENAME(@Value, 1)) <> 0 ) RETURN NULL
    DECLARE @I bigint =
        CASE
        WHEN CHARINDEX('.', @Value) > 0 THEN CONVERT(bigint, PARSENAME(@Value, 2))
        ELSE CONVERT(bigint, @Value)
        END
    IF ABS(@I) > 2147483647 RETURN NULL
    RETURN @I
END
