CREATE PROCEDURE [dbo].[MFD_Clear_Family_Data] 
AS
	
  DELETE FROM dbo.MFD_Feature_Family;
  DELETE FROM dbo.MFD_Feature_Family_Group;
  DELETE FROM dbo.MFD_Legacy_Feature_Family;

