
CREATE PROCEDURE [dbo].[OXO_GSF_Model_GetMany]
   @p_prog_id int = NULL,
   @p_doc_id int = NULL,
   @p_cdsid NVARCHAR(50) = NULL 
AS
  BEGIN
		SELECT
		MIN(M.Id) AS GSFId,
		ISNULL(M.Doors,'') + ' ' + ISNULL(M.Wheelbase, '') + ' ' + ISNULL(M.Shape,'') AS GSFBody,
		ISNULL(M.Size,'') + ' ' + ISNULL(M.Cylinder,'') + ' ' + ISNULL(M.Turbo,'') + ' ' + ISNULL(M.Power,'') + ' ' + ISNULL(M.Drivetrain,'') AS GSFEngine,
		ISNULL(M.Doors,'') + ' ' + ISNULL(M.Wheelbase,'') + ' #' + ISNULL(M.Shape,'') + ' #' + ISNULL(M.Size,'') + ' ' + ISNULL(M.Cylinder,'') + ' ' + ISNULL(M.Turbo,'') + ' #' + ISNULL(M.Power,'') + ' ' + ISNULL(M.Drivetrain,'') AS GSFNameWithBr,
		M.BMC
		FROM dbo.FN_Programme_Models_Get(@p_prog_id, @p_doc_id) M
		WHERE (@p_prog_id IS NULL OR M.Programme_Id = @p_prog_id)   
		AND EXISTS
		(
			-- Check Permission
			SELECT 1
			FROM dbo.OXO_Permission PM
			WHERE PM.Object_Type = 'Programme'
			AND PM.Operation IN ('CanEdit')
			AND PM.Object_Id = M.Programme_Id
			AND PM.CDSID = ISNULL(@p_cdsid, PM.CDSID)
			
		)
		GROUP BY M.Size,
				 ISNULL(M.Doors,'') + ' ' + ISNULL(M.Wheelbase,'') + ' ' + ISNULL(M.Shape,''),
				 ISNULL(M.Size, '') + ' ' + ISNULL(M.Cylinder, '') + ' ' + ISNULL(M.Turbo, '') + ' ' + ISNULL(M.Power,'') + ' ' + ISNULL(M.Drivetrain,''),
				 ISNULL(M.Doors,'') + ' ' + ISNULL(M.Wheelbase,'') + ' #' + ISNULL(M.Shape,'') + ' #' + ISNULL(M.Size,'') + ' ' + ISNULL(M.Cylinder,'') + ' ' + ISNULL(M.Turbo,'') + ' #' + ISNULL(M.Power,'') + ' ' + ISNULL(M.Drivetrain,''),
				 M.BMC
		ORDER BY M.Size
  END


