CREATE FUNCTION dbo.fn_BankersRound(@Val DECIMAL(32, 16), @Digits INT)
	RETURNS DECIMAL(32, 16)
AS
BEGIN
	RETURN 
		CASE 
			WHEN ABS(@Val - ROUND(@Val, @Digits, 1)) * POWER(10, @Digits + 1) = 5
			THEN ROUND(@Val, @Digits, CASE WHEN CONVERT(INT, ROUND(ABS(@Val) * POWER(10, @Digits), 0, 1)) % 2 = 1 THEN 0 ELSE 1 END)
			ELSE ROUND(@Val, @Digits)
		END
END