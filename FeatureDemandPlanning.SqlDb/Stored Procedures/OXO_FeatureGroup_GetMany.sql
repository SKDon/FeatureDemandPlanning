CREATE PROCEDURE [dbo].[OXO_FeatureGroup_GetMany]
( @p_all bit = 0)
AS

  SELECT Id AS GroupId,
         Group_Name AS FeatureGroupName,
         Sub_Group_Name AS FeatureSubGroup       
  FROM OXO_Feature_Group
  WHERE ((Status = 1 AND @p_all = 0) OR @p_all = 1)  
  ORDER By Display_Order

