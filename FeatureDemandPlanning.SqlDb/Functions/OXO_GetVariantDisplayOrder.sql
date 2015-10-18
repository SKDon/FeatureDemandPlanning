

CREATE FUNCTION [OXO_GetVariantDisplayOrder] 
(
  @p_door nvarchar(50),
  @p_wheelbase nvarchar(50),
  @p_size decimal(5,2),
  @p_fueltype nvarchar(50),
  @p_power int,
  @p_drive nvarchar(50),
  @p_trim_level int
)  
RETURNS INTEGER
AS
BEGIN

	-- Declare the return variable here
	DECLARE @retVal int; 
	
	DECLARE @door_order int;
	DECLARE @wheelbase_order int;
	DECLARE @engine_order int;
	DECLARE @fuel_order int;
	DECLARE @power_order int;
    DECLARE @tran_order int;    
    DECLARE @trim_order int;
    
    SET @door_order = ISNULL(dbo.TryConvertInt(LEFT(@p_door, 1)), 1) * 100000;
    SET @wheelbase_order = CASE WHEN ISNULL(@p_wheelbase, 'SWB') = 'SWB' THEN 90000
						   ELSE 99000 END;      
    SET @engine_order = @p_size * 1000; 
	SET @fuel_order = CASE WHEN ISNULL(@p_fueltype, 'Petrol') = 'Petrol' THEN 1000
						   WHEN ISNULL(@p_fueltype, 'Petrol') = 'Diesel' THEN 2000	
	                       ELSE 0 END;
			
	SET @power_order = @p_power;
	                                    
	SET @tran_order = CASE WHEN ISNULL(@p_drive,'2WD') IN ('FWD', 'RWD', '2WD') THEN 100
					       WHEN ISNULL(@p_drive, '2WD') IN ('4WD', 'AWD') THEN 500
	                  ELSE 0 END;
	                   	
	SET @trim_order = @p_trim_level;
		    
	SET @retVal = @door_order + @wheelbase_order + @engine_order + @fuel_order + @power_order + @tran_order + @trim_order;
	
	RETURN @retVal;

END
