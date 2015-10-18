CREATE FUNCTION [dbo].[OXO_GetPermission]
(
	@p_cdsid nvarchar(50)
)
RETURNS NVARCHAR(4000)
AS
BEGIN
   DECLARE @_programmes    NVARCHAR (4000);

   WITH SET_A 	
   AS (
	 
	 SELECT 
			V.VehicleName + ' ' + V.ModelYear +		
			CASE WHEN P.Operation = 'CanEdit' THEN ' (Edit)'
			ELSE '' END AS Prog_Label
	 FROM OXO_Permission P
	 INNER JOIN OXO_Programme_VW V
	 ON P.Object_Id = V.Id
	 WHERE CDSID = @p_cdsid
	 AND Object_Type = 'Programme'
	 AND V.OXOEnabled = 1	 
   )
   SELECT @_programmes = COALESCE(@_programmes,'') + COALESCE(A.Prog_Label,'') + ', ' 
   FROM SET_A A
   
   IF LEN(@_programmes) > 0
      SET @_programmes = LEFT(@_programmes, LEN(@_programmes) - 1)	
	
   RETURN ISNULL(@_programmes, ''); 
   
END

