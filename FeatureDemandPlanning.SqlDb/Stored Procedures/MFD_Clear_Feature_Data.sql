CREATE PROCEDURE [dbo].[MFD_Clear_Feature_Data] 
AS
	
  DELETE FROM dbo.MFD_Brand_Feature;
  DELETE FROM dbo.MFD_Feature;
  DELETE FROM dbo.MFD_Legacy_Feature;

