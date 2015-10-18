

CREATE PROCEDURE [dbo].[OXO_Programme_File_GetMany]
	@p_prog_id int = NULL,
	@p_category nvarchar(100) = NULL
AS
	
    SELECT 
    F.Id  AS Id,
    F.Programme_Id  AS ProgrammeId,
    F.File_Category AS FileCategory,
    F.File_Comment AS FileComment,      
    F.File_Name  AS FileName,  
    F.File_Ext AS FileExt,
    F.File_Desc AS FileDesc,
    F.File_Type  AS FileType,  
    F.File_Size  AS FileSize,  
    F.Gateway AS Gateway,
    ISNULL(F.PACN, 'N/A') AS PACN,
    F.Created_By  AS UploadedBy,  
    CONVERT(NVARCHAR(20), F.Created_On, 120)  AS DateUploaded,  
    F.Updated_By  AS UpdatedBy,  
    F.Last_Updated  AS LastUpdated,
    P.VehicleName, 
    P.ModelYear,  
    ISNULL(G.Display_Order, 1000) AS DisplayOrder
    FROM dbo.OXO_Programme_File_VW   F
    LEFT OUTER JOIN dbo.OXO_Programme_VW  P
    ON F.Programme_Id = P.Id
    LEFT JOIN OXO_Gateway G
    ON G.Gateway = F.Gateway
    WHERE (F.Programme_Id = @p_prog_id OR @p_prog_id IS NULL)
    AND (File_Category = @p_category OR @p_category IS NULL)
    ORDER BY ModelYear, DisplayOrder, F.Created_By

