

CREATE VIEW [dbo].[OXO_Archived_Models_VW]
AS
SELECT     DisplayOrder = dbo.OXO_GetVariantDisplayOrder(B.Doors, B.Wheelbase, E.Size, E.Fuel_Type, E.Power, T.DriveTrain, T.Type, CAST(RIGHT(TM. LEVEL, 1) 
                      AS INT)), V.Name AS VehicleName, V.AKA AS VehicleAKA, P.Model_Year AS ModelYear, V.Display_Format AS DisplayFormat, 
                      Name = dbo.OXO_GetVariantName(V.Display_Format, B.Shape, B.Doors, B.Wheelbase, E.Size, E.Fuel_Type, E.Cylinder, E.Turbo, E.Power, 
                      T.DriveTrain, T.Type, TM.Name, TM.LEVEL, 0, 0), NameWithBR = dbo.OXO_GetVariantName(V.Display_Format, B.Shape, B.Doors, B.Wheelbase, 
                      E.Size, E.Fuel_Type, E.Cylinder, E.Turbo, E.Power, T.DriveTrain, T.Type, TM.Abbreviation, TM.LEVEL, 0, 1), M.Id AS Id, M.Programme_Id, M.Body_Id, 
                      M.Engine_Id, M.Transmission_Id, M.Trim_Id, M.Active, M.Created_By, M.Created_On, M.Updated_By, M.Last_Updated, M.CoA, B.Shape, B.Doors, 
                      B.Wheelbase, E.Size, E.Cylinder, E.Turbo, E.Fuel_Type, E.Power, E.Electrification, T .Type, T .Drivetrain, TM.Name AS TrimName, TM.Abbreviation, 
                      TM. LEVEL, M.BMC AS BMC, TM.DPCK, M.Doc_Id AS Doc_Id, V.Make, M.KD, TM.Display_Order
FROM         dbo.OXO_Archived_Programme_Model M INNER JOIN
                      dbo.OXO_Archived_Programme_Body B ON M.Body_Id = B.Id INNER JOIN
                      dbo.OXO_Archived_Programme_Engine E ON M.Engine_Id = E.Id INNER JOIN
                      dbo.OXO_Archived_Programme_Transmission T ON M.Transmission_Id = T .Id INNER JOIN
                      dbo.OXO_Archived_Programme_Trim TM ON M.Trim_Id = TM.Id INNER JOIN
                      dbo.OXO_Programme P ON P.ID = M.Programme_Id INNER JOIN
                      OXO_Vehicle V ON V.Id = P.Vehicle_Id


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
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'OXO_Archived_Models_VW';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'OXO_Archived_Models_VW';

