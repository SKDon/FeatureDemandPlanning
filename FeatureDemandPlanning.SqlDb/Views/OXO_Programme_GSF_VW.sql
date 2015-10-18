CREATE VIEW [dbo].[OXO_Programme_GSF_VW]
AS

SELECT     
   F.Id AS Id, 
   V.Name AS Name, 
   V.AKA AS AKA, 
   P.Model_Year AS ModelYear, 
   P.Id AS ProgrammeId, 
   V.Make, 
   CASE 
	WHEN ISNULL(P.Use_OA_Code, 0) = 0 THEN F.Feat_Code 
	ELSE F.OA_Code END AS FeatureCode,        
   F.OA_Code AS OACode, 
   F.Description AS SystemDescription, 
   ISNULL(M.Brand_Desc, F.Description) AS BrandDescription, 
   G.Group_Name AS FeatureGroup, 
   G.Sub_Group_Name AS FeatureSubGroup, 
   G.Display_Order AS DisplayOrder, 
   L.Comment AS FeatureComment,
   L.Rule_Text AS FeatureRuleText,
   F.Long_Desc AS LongDescription
   FROM dbo.OXO_Vehicle AS V 
   INNER JOIN dbo.OXO_Programme AS P 
   ON V.Id = P.Vehicle_Id 
   INNER JOIN dbo.OXO_Programme_GSF_Link AS L 
   ON P.Id = L.Programme_Id 
   INNER JOIN dbo.OXO_Feature_Ext AS F 
   ON L.Feature_Id = F.Id 
   INNER JOIN dbo.OXO_Feature_Group AS G 
   ON F.OXO_Grp = G.Id 
   LEFT OUTER JOIN dbo.OXO_Feature_Brand_Desc AS M 
   ON F.Feat_Code = M.Feat_Code 
   AND M.Brand = V.Make






GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "SET_A_1"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 207
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'OXO_Programme_GSF_VW';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'OXO_Programme_GSF_VW';

