CREATE VIEW [OXO_Programme_Rule_Result_VW]
AS
SELECT     RE.OXO_Doc_Id, RE.Programme_Id, RE.Object_Level, RE.Object_Id, RE.Rule_Id, RE.Model_Id, M.Name AS Model, M.CoA, ISNULL(L.Description, 
                      N'Unspecified') AS Feature_Group, 
                      CASE WHEN RU.Rule_Category = 'E' THEN 'Engineering' 
                           WHEN RU.Rule_Category = 'M' THEN 'Marketing' 
                           WHEN RU.Rule_Category = 'T' THEN 'Territorial'
                           ELSE 'Other' END AS Rule_Category, 
                      RU.Owner, 
						   CASE WHEN RU.Rule_Group = 'EFG' AND RE.Rule_Result = 0
						        THEN REPLACE(RU.Rule_Response, '<efg>', '<' + RE.Result_Info + '>') 
						        WHEN RU.Rule_Group = 'GEN' AND RE.Rule_Result = 0
						        THEN REPLACE(RU.Rule_Response, '<gen>', RE.Result_Info) 
						        WHEN RU.Rule_Group = 'EFG' AND RE.Rule_Result = 1
						        THEN RE.Result_Info 
						        WHEN RU.Rule_Group = 'GEN' AND RE.Rule_Result = 1
						        THEN RE.Result_Info 
                                ELSE RU.Rule_Response END AS Rule_Response, 
                      RE.Rule_Result, RE.Created_By, RE.Created_On,
                      M.DisplayOrder
FROM       dbo.OXO_Programme_Rule_Result AS RE INNER JOIN
          dbo.OXO_Programme_Rule AS RU ON RE.Rule_Id = RU.Id INNER JOIN
          dbo.OXO_Models_VW AS M ON RE.Model_Id = M.Id LEFT OUTER JOIN
          dbo.OXO_Reference_List AS L ON RU.Rule_Group = L.Code AND L.List_Name = 'Feature Group'


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[24] 4[20] 2[31] 3) )"
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
         Begin Table = "RE"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RU"
            Begin Extent = 
               Top = 6
               Left = 228
               Bottom = 121
               Right = 383
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "M"
            Begin Extent = 
               Top = 126
               Left = 38
               Bottom = 241
               Right = 196
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "L"
            Begin Extent = 
               Top = 126
               Left = 234
               Bottom = 241
               Right = 386
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
      Begin ColumnWidths = 15
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1410
         Width = 2865
         Width = 1500
         Width = 885
         Width = 4380
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
      ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'OXO_Programme_Rule_Result_VW';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'   GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'OXO_Programme_Rule_Result_VW';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'OXO_Programme_Rule_Result_VW';

