﻿
CREATE PROCEDURE [dbo].[Fdp_Configuration_Delete] 
  @p_ConfigurationKey nvarchar(100)
AS
	
  DELETE 
  FROM dbo.Fdp_Configuration 
  WHERE ConfigurationKey = @p_ConfigurationKey;



