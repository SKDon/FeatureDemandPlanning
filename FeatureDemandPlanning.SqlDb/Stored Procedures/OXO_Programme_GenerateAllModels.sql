CREATE PROCEDURE [dbo].[OXO_Programme_GenerateAllModels]
   @p_veh_prog_id INT
AS

DECLARE @count INT
DECLARE @body_id INT
DECLARE @engine_id INT
DECLARE @trans_id INT
DECLARE @trim_id INT

DECLARE c_all_model CURSOR FOR  
SELECT  DISTINCT
		B.Id AS Body_Id, 
		E.Id AS Engine_Id,
		T.Id AS Trans_Id,
		Tr.Id AS Trim_Id
FROM OXO_Programme_Body B
CROSS JOIN OXO_Programme_Engine E
CROSS JOIN OXO_Programme_Transmission T
CROSS JOIN OXO_Programme_Trim Tr
WHERE B.Programme_Id = @p_veh_prog_id
AND E.Programme_Id = @p_veh_prog_id
AND T.Programme_Id = @p_veh_prog_id
AND Tr.Programme_Id = @p_veh_prog_id;

OPEN c_all_model;
FETCH NEXT FROM c_all_model INTO @body_id, @engine_id, @trans_id, @trim_id;        
WHILE @@FETCH_STATUS = 0   
BEGIN   
	
	SELECT @count = COUNT(*) 
	FROM OXO_Programme_Model  	
	WHERE Programme_Id = @p_veh_prog_id
	AND Body_Id = @body_id
	AND Engine_Id = @engine_id
	AND Transmission_Id = @trans_id
	AND Trim_Id = @trim_id;
	IF @count = 0 	
    BEGIN
		INSERT INTO OXO_Programme_Model
			(Programme_Id, Body_Id, Engine_Id, Transmission_Id, Trim_Id)
		VALUES 
			(@p_veh_prog_id, @body_id, @engine_id, @trans_id, @trim_id);
		
    END
              
    FETCH NEXT FROM c_all_model INTO @body_id, @engine_id, @trans_id, @trim_id;        
    
END   
CLOSE c_all_model;   
DEALLOCATE c_all_model;
