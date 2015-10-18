CREATE FUNCTION [FN_OXO_FEAT_APPLICABILITY]
(
	@p_featId int
)
RETURNS NVARCHAR(4000)
AS
BEGIN
   DECLARE @_vehicles    NVARCHAR (4000)

    SELECT @_vehicles = COALESCE(@_vehicles,'') + COALESCE(V.Name,'') + ', ' 
    FROM OXO_Vehicle_Feature_Applicability A
	INNER JOIN OXO_Vehicle V
	ON A.Vehicle_Id = V.ID
	WHERE Feature_Id = @p_featId
	ORDER BY V.Name;

   IF LEN(@_vehicles) > 0
      SET @_vehicles = LEFT(@_vehicles, LEN(@_vehicles) - 1)	
	
   RETURN ISNULL(@_vehicles, ''); 
END
