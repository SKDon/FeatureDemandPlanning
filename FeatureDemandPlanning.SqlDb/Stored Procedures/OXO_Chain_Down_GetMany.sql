CREATE PROCEDURE [OXO_Chain_Down_GetMany]
@p_section nvarchar(10),
@p_doc_id int,
@p_prog_id int,
@p_model_id int,
@p_feature_id int,
@p_pack_id int,
@p_level nvarchar(10),
@p_object_id int=0
AS
BEGIN
	
	IF (@p_section = 'FBM')
	BEGIN
		EXEC OXO_Chain_Down_FBM_GetMany @p_doc_id, @p_prog_id, @p_model_id,
                                        @p_feature_id, @p_level, @p_object_id;
	END 	

	IF (@p_section = 'PCK')
	BEGIN
		EXEC OXO_Chain_Down_PCK_GetMany @p_doc_id, @p_prog_id, @p_model_id,
                                        @p_pack_id, @p_level, @p_object_id;
	END 	
	
	IF (@p_section = 'FPS')
	BEGIN
		EXEC OXO_Chain_Down_FPS_GetMany @p_doc_id, @p_prog_id, @p_model_id, @p_feature_id,
                                        @p_pack_id, @p_level, @p_object_id;
	END 	
END

