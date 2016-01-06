using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using ClosedXML.Excel;
using FeatureDemandPlanning.DataStore;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using System.Data;
using System.Threading.Tasks;
using FeatureDemandPlanning.Model.Filters;

namespace FeatureDemandPlanning.Model.Helpers
{
    public class ExcelResult : ActionResult
    {
        private readonly XLWorkbook _workbook;
        private readonly string _fileName;

        public ExcelResult(XLWorkbook workbook, string fileName)
        {
            _workbook = workbook;
            _fileName = fileName;
        }

        public override void ExecuteResult(ControllerContext context)
        {
            var response = context.HttpContext.Response;
            response.Clear();
            response.ContentType = "application/vnd.openxmlformats-officedocument."
                                 + "spreadsheetml.sheet";
            response.AddHeader("content-disposition",
                               "attachment;filename=\"" + _fileName + ".xlsx\"");

            using (var memoryStream = new MemoryStream())
            {
                _workbook.SaveAs(memoryStream);
                memoryStream.WriteTo(response.OutputStream);
            }
            response.End();
        }
    }

    public class ExcelReader
    {
        public static DataTable ReadExcelAsDataTable(string filePath)
        {
            var result = new DataTable();
            using (var workBook = new XLWorkbook(filePath))
            {
                var firstRow = true;

                foreach (var row in workBook.Worksheets.SelectMany(workSheet => workSheet.Rows()))
                {
                    // Use the first row to add columns to DataTable.
                    if (firstRow)
                    {
                        foreach (var cell in row.Cells())
                        {
                            result.Columns.Add(cell.Value.ToString());
                        }
                        firstRow = false;
                    }
                    else
                    {
                        result.Rows.Add();
                        var i = 0;
                        foreach (var cell in row.Cells())
                        {
                            result.Rows[result.Rows.Count - 1][i] = cell.Value.ToString();
                            i++;
                        }
                    }
                }
            }
            return result;
        }
    }

    public class ClosedXmlExcelGenerator
    {
        public static XLWorkbook GenerateExcelCoverSheet(XLWorkbook workbook, int progid, int docid, string cdsid, OXODoc OXODoc, bool popDoc)
        {
            Stopwatch stopWatch = new Stopwatch();
            
            try
            {
                stopWatch.Reset();
                stopWatch.Start();
                
                IXLWorksheet worksheet = workbook.Worksheets.Add("Cover Sheet");
                workbook.Worksheet("Cover Sheet").Cell("K1").Value = "Creating Cover Sheet: " + DateTime.Now;
                worksheet.Protect("Password123")
                    .SetFormatColumns()
                    .SetFormatRows();
                worksheet.Style
                    .Fill.SetBackgroundColor(XLColor.White)
                    .Font.SetFontSize(11)
                    .Font.SetFontName("Arial");
                worksheet.TabColor = XLColor.Yellow;

                string blank = (popDoc == false) ? " (BLANK)" : "";
                

                worksheet.Cell("A1").Value = "STANDARD SPECIFICATION FORMAT";
                worksheet.Cell("B1").Value = OXODoc.VehicleAKA.ToUpper() + " OXO CHART" + blank;
                worksheet.Cell("B1").Style.Fill.SetBackgroundColor(XLColor.Yellow);
                worksheet.Cell("A3").Value = "MODEL YEAR";
                worksheet.Cell("B3").Value = OXODoc.ModelYear;
                worksheet.Cell("B3").Style.Fill.SetBackgroundColor(XLColor.Yellow);
                worksheet.Cell("A4").Value = "VERSION";
                worksheet.Cell("B4").Value = (OXODoc.VehicleName + " (" + OXODoc.VehicleAKA + ") " + OXODoc.Gateway + " V" + OXODoc.VersionId + " " + OXODoc.Status).ToUpper();
                worksheet.Cell("B4").Style.Fill.SetBackgroundColor(XLColor.Yellow);
                worksheet.Cell("A5").Value = "AUTHOR";
                worksheet.Cell("B5").Value = cdsid.ToUpper();
                worksheet.Cell("B5").Style.Fill.SetBackgroundColor(XLColor.Yellow);
                worksheet.Cell("A6").Value = "DATE ISSUED";
                worksheet.Cell("B6").Value = DateTime.Now;
                worksheet.Cell("B6").Style.Fill.SetBackgroundColor(XLColor.Yellow);
                worksheet.Cell("B6").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left);
                worksheet.Range("A1:B6").Style.Font.SetBold(true);
                worksheet.Cell("A9").Value = "OXO KEY";
                worksheet.Cell("A10").Value = "S";
                worksheet.Cell("B10").Value = "Standard - the feature is standard to a particular derivative";
                worksheet.Cell("A11").Value = "O";
                worksheet.Cell("B11").Value = "Optional - the feature is optional to a particular derivative and must correspond to a priced feature";
                worksheet.Cell("A12").Value = "NA";
                worksheet.Cell("B12").Value = "Not Available";
                worksheet.Cell("A13").Value = "P";
                worksheet.Cell("B13").Value = "Pack - the feature is only available as part of a pack";
                worksheet.Cell("A14").Value = "(O)";
                worksheet.Cell("B14").Value = "Linked Option - the option has a relationship with another option that means they must be ordered together";
                worksheet.Range("A10:A15").Style.Alignment.SetIndent(5);
                worksheet.Cell("A17").Value = "The worksheets included in this document are as follows";
                worksheet.Cell("A19").Value = "Change Log";
                worksheet.Cell("A19").Hyperlink = new XLHyperlink("'Change Log'!A1");
                worksheet.Cell("B19").Value = "Highlights changes which have occurred since the last OxO version was issued";
                worksheet.Cell("A20").Value = "Model Market Matrix";
                worksheet.Cell("A20").Hyperlink = new XLHyperlink("'Model Market Matrix'!A1");
                worksheet.Cell("B20").Value = "Provides summary information on specification groups & derivative line up for each market";
                worksheet.Cell("A21").Value = "Reasons for Rules";
                worksheet.Cell("A21").Hyperlink = new XLHyperlink("'Reasons for Rules'!A1");
                worksheet.Cell("B21").Value = "Provides further information explaining rules within the main OxO";
                worksheet.Cell("A22").Value = "Global Standard Features";
                worksheet.Cell("A22").Hyperlink = new XLHyperlink("'Global Standard Features'!A1");
                worksheet.Cell("B22").Value = "Indicates features that are standard on all derivatives for all markets";
                worksheet.Cell("A23").Value = "World At A Glance";
                worksheet.Cell("A23").Hyperlink = new XLHyperlink("'World At A Glance'!A1");
                worksheet.Cell("B23").Value = "Details the full specifications for the global and regional generic specifications";
                worksheet.Cell("A25").Value = "Regions vs Global Generic";
                worksheet.Cell("B25").Value = "Details the specification variance at regional level versus the global generic specification";
                worksheet.Range("A9:A25").Style.Font.SetBold(true);
                worksheet.Range("A19:A25").Style.Alignment.SetIndent(3);
                worksheet.Columns("A").Width = 48;
                worksheet.Columns("B").Width = 40;

                stopWatch.Stop();
                var executionTime = stopWatch.ElapsedMilliseconds;
            }
            catch (Exception ex)
            {
                AppHelper.LogError("ExcelHelper.GenerateExcelCoverSheet", ex.Message, "SYSTEM");
            }

            return workbook;
        }

        public static XLWorkbook GenerateExcelChangeLog(XLWorkbook workbook, int docid, string cdsid, OXODoc OXODoc)
        {
            Stopwatch stopWatch = new Stopwatch();
            
            try
            {
                stopWatch.Reset();
                stopWatch.Start();
                
                IXLWorksheet worksheet = workbook.Worksheets.Add("Change Log");
                worksheet.Protect("Password123")
                    .SetFormatColumns()
                    .SetFormatRows();
                worksheet.Style
                    .Fill.SetBackgroundColor(XLColor.White)
                    .Font.SetFontSize(11)
                    .Font.SetFontName("Arial");
                worksheet.TabColor = XLColor.Orange;

                // data
                ChangeDiaryDataStore cds = new ChangeDiaryDataStore(cdsid);
                var changeDiary = cds.ChangeDiaryGetMany(docid);

                // page title
                worksheet.Cell("A1").Value = "CHANGE LOG";
                worksheet.Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A19");
                worksheet.Cell("A2").Value = (OXODoc.VehicleName + " (" + OXODoc.VehicleAKA + ") " + OXODoc.ModelYear + " " + OXODoc.Gateway + " V" + OXODoc.VersionId + " " + OXODoc.Status).ToUpper();
                worksheet.Cell("A3").Value = DateTime.Now;
                worksheet.Cell("A4").Value = cdsid.ToUpper();
                worksheet.Range("A1:A4").Style.Font.SetBold()
                    .Font.SetFontSize(14);

                // heading row
                worksheet.Cell("A6").Value = "Date of OXO Change";
                worksheet.Column("A").Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Left;
                worksheet.Cell("B6").Value = "Market";
                worksheet.Cell("C6").Value = "Engine & Trim Level";
                worksheet.Cell("D6").Value = "Feature & Detail of Change (Since Previous OXO Version)";
                worksheet.Cell("E6").Value = "Current" + Environment.NewLine + "Fitment";
                worksheet.Column("E").Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
                worksheet.Cell("F6").Value = "Proposed" + Environment.NewLine + "Fitment";
                worksheet.Column("F").Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
                worksheet.Cell("G6").Value = "Pricing Status";
                worksheet.Cell("H6").Value = "PACN / PDL";
                worksheet.Column("H").Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
                worksheet.Cell("I6").Value = "FCIM E-Tracker";
                worksheet.Column("I").Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
                worksheet.Cell("J6").Value = "Reason for Change";
                worksheet.Cell("K6").Value = "Order Call";
                worksheet.Column("K").Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
                worksheet.Cell("L6").Value = "Build Effectivity Date";
                worksheet.Range("A6:L6")
                         .Style.Font.SetBold(true)
                         .Font.SetFontColor(XLColor.White)
                         .Fill.SetBackgroundColor(XLColor.Black)
                         .Alignment.Vertical = XLAlignmentVerticalValues.Center;

                // output data
                int row = 7;
                string header = "";

                foreach (var item in changeDiary)
                {
                    // row grouping
                    if (header != item.VersionInfo)
                    {
                        worksheet.Cell("A" + row).SetValue(item.VersionInfo)
                            .Style.Font.SetFontColor(XLColor.White)
                            .Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left)
                            .Font.SetBold(true)
                            .Font.SetUnderline(XLFontUnderlineValues.Single);
                        worksheet.Range(row, 1, row, 12).Style.Fill.SetBackgroundColor(XLColor.Black);
                        row = row + 1;
                    }
                    header = item.VersionInfo;

                    worksheet.Cell(row, 1).Value = item.EntryDate;
                    worksheet.Cell(row, 2).Value = item.Markets;
                    worksheet.Cell(row, 3).Value = item.Models;
                    worksheet.Cell(row, 4).Value = item.Features;
                    worksheet.Cell(row, 5).Value = item.CurrentFitment;
                    worksheet.Cell(row, 6).Value = item.ProposedFitment;
                    worksheet.Cell(row, 7).Value = item.PricingStatus;
                    worksheet.Cell(row, 8).Value = item.PACN;
                    worksheet.Cell(row, 9).Value = item.ETracker;
                    worksheet.Cell(row, 10).Value = item.Comment;
                    worksheet.Cell(row, 11).Value = item.OrderCall;
                    worksheet.Cell(row, 12).Value = item.BuildEffectiveDate;

                    row = row + 1;
                }

                // adjust column widths
                worksheet.Columns().AdjustToContents();
                worksheet.Column(1).Width = 27;
                worksheet.Column(2).Width = 50;
                worksheet.Column(2).Style.Alignment.SetWrapText();
                worksheet.Column(3).Width = 26;
                worksheet.Column(4).Width = 100;
                worksheet.Column(4).Style.Alignment.SetWrapText();
                worksheet.Column(5).Width = 14;
                worksheet.Column(6).Width = 14;
                worksheet.Column(7).Width = 20;
                worksheet.Column(8).Width = 17;
                worksheet.Column(9).Width = 22;
                worksheet.Column(10).Width = 50;
                worksheet.Column(10).Style.Alignment.SetWrapText();
                worksheet.Column(11).Width = 14;
                worksheet.Column(12).Width = 28;

                // set border styles
                worksheet.Range(7, 1, worksheet.LastRowUsed().RowNumber(), 12).Style
                    .Border.SetTopBorder(XLBorderStyleValues.Thin)
                    .Border.SetRightBorder(XLBorderStyleValues.Thin)
                    .Border.SetOutsideBorder(XLBorderStyleValues.Thin);

                // split the screen
                worksheet.SheetView.Freeze(6, 0);

                stopWatch.Stop();
                var executionTime = stopWatch.ElapsedMilliseconds;
            }
            catch (Exception ex)
            {
                AppHelper.LogError("ExcelHelper.GenerateExcelChangeLog", ex.Message, "SYSTEM");
            }

            return workbook;
        }

        public static XLWorkbook GenerateExcelRFR(XLWorkbook workbook, int progid, string cdsid, OXODoc OXODoc)
        {
            Stopwatch stopWatch = new Stopwatch();

            try
            {
                stopWatch.Reset();
                stopWatch.Start();
                
                IXLWorksheet worksheet = workbook.Worksheets.Add("Reasons for Rules");
                worksheet.Protect("Password123")
                    .SetFormatColumns()
                    .SetFormatRows();
                worksheet.Style
                    .Fill.SetBackgroundColor(XLColor.White)
                    .Font.SetFontSize(11)
                    .Font.SetFontName("Arial");
                worksheet.TabColor = XLColor.Green;

                // data
                OXORuleDataStore rds = new OXORuleDataStore(cdsid);
                var ruleReasons = rds.OXORuleGetMany(progid);

                // page title
                worksheet.Cell("A1").Value = "REASONS FOR RULES";
                worksheet.Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A21");
                worksheet.Cell("A2").Value = (OXODoc.VehicleName + " (" + OXODoc.VehicleAKA + ") " + OXODoc.ModelYear + " " + OXODoc.Gateway + " V" + OXODoc.VersionId + " " + OXODoc.Status).ToUpper();
                worksheet.Cell("A3").Value = DateTime.Now;
                worksheet.Cell("A4").Value = cdsid.ToUpper();
                worksheet.Range("A1:A4").Style.Font.SetBold()
                    .Font.SetFontSize(14)
                    .Alignment.Horizontal = XLAlignmentHorizontalValues.Left;

                // heading row
                worksheet.Cell("A6").Value = "Rule ID";
                worksheet.Column("A").Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Left;
                worksheet.Cell("B6").Value = "Rule Ref";
                worksheet.Cell("C6").Value = "Rule";
                worksheet.Column("C").Style.Alignment.SetWrapText();
                worksheet.Cell("D6").Value = "Reason";
                worksheet.Column("D").Style.Alignment.SetWrapText();
                worksheet.Cell("E6").Value = "Contact";
                worksheet.Range("A6:E6")
                         .Style.Font.SetBold(true)
                         .Font.SetFontColor(XLColor.White)
                         .Fill.SetBackgroundColor(XLColor.Black)
                         .Alignment.Vertical = XLAlignmentVerticalValues.Center;

                // output data
                int row = 7;

                foreach (var rule in ruleReasons)
                {
                    worksheet.Cell(row, 1).Value = "'" + rule.Id.ToString("000000");
                    worksheet.Cell(row, 2).Value = rule.RuleCategory;
                    worksheet.Cell(row, 3).Value = rule.RuleResponse;
                    worksheet.Cell(row, 4).Value = rule.RuleReason;
                    worksheet.Cell(row, 5).Value = rule.Owner;

                    row = row + 1;
                }

                // adjust column widths
                worksheet.Columns().AdjustToContents();
                worksheet.Column(1).Width = 12;
                worksheet.Column(3).Width = 100;
                worksheet.Column(4).Width = 100;

                // set border styles
                worksheet.Range(7, 1, worksheet.LastRowUsed().RowNumber(), 5).Style
                    .Border.SetTopBorder(XLBorderStyleValues.Thin)
                    .Border.SetRightBorder(XLBorderStyleValues.Thin)
                    .Border.SetOutsideBorder(XLBorderStyleValues.Thin);

                // split the screen
                worksheet.SheetView.Freeze(7, 0);

                stopWatch.Stop();
                var executionTime = stopWatch.ElapsedMilliseconds;
            }
            catch (Exception ex)
            {
                AppHelper.LogError("ExcelHelper.GenerateExcelRFR", ex.Message, "SYSTEM");
            }

            return workbook;
        }

        public static XLWorkbook GenerateExcelMBM(XLWorkbook workbook, int progid, int docid, string cdsid, OXODoc OXODoc, OXODocDataStore ods, IEnumerable<Model> carModels, bool popDoc)
        {
            Stopwatch stopWatch = new Stopwatch();

            try
            {
                stopWatch.Reset();
                stopWatch.Start();
                
                IXLWorksheet worksheet = workbook.Worksheets.Add("Model Market Matrix");
                worksheet.Protect("Password123")
                    .SetFormatColumns()
                    .SetFormatRows();
                worksheet.Style
                    .Fill.SetBackgroundColor(XLColor.White)
                    .Font.SetFontSize(11)
                    .Font.SetFontName("Arial");
                worksheet.TabColor = XLColor.Orange;

                // car models
                string modelIds = string.Join(",", carModels.Select(p => string.Format("[{0}]", p.Id.ToString())));
                int modelCount = carModels.Count();
            
                // data
                string make = OXODoc.VehicleMake;
                var OXOData = ods.OXODocGetItemData(make, docid, progid, "MBM", "mbm", -1, modelIds);
                int rowCount = OXOData.Count();

                // white page title
                worksheet.Cell("A1").Value = "DERIVATIVE AVAILABILITY";
                worksheet.Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A20");
                worksheet.Cell("A1").Style.Font.SetUnderline(XLFontUnderlineValues.Single);
                worksheet.Cell("A2").Value = (OXODoc.VehicleName + " (" + OXODoc.VehicleAKA + ") " + OXODoc.ModelYear + " " + OXODoc.Gateway + " V" + OXODoc.VersionId + " " + OXODoc.Status).ToUpper();
                worksheet.Cell("A3").Value = DateTime.Now;
                worksheet.Cell("A4").Value = cdsid.ToUpper();
                worksheet.Range("A1:A4").Style
                    .Font.SetBold()
                    .Font.SetFontSize(14)
                    .Alignment.Horizontal = XLAlignmentHorizontalValues.Left;

                // grey derivative title
                worksheet.Cell("B1").Value = "BODY STYLE";
                worksheet.Cell("B2").Value = "ENGINE";
                worksheet.Cell("B3").Value = "DERIVATIVE";
                worksheet.Cell("B4").Value = "MODEL CODE";
                worksheet.Cell("B5").Value = "TRIM LEVEL";
                worksheet.Cell("B6").Value = "DERIVATIVE PACK CODE";
                worksheet.Range("B1:B6").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right)
                    .Alignment.SetVertical(XLAlignmentVerticalValues.Center);
                worksheet.Range(1, 2, 6, modelCount + 3).Style.Font.SetBold(true)
                    .Fill.SetBackgroundColor(XLColor.LightGray);

                // heading row - 7
                worksheet.Cell("A7").Value = "MARKET";
                worksheet.Cell("B7").Value = "PAR CODE";
                worksheet.Cell("B7").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                worksheet.Range(7, 1, 7, modelCount + 3)
                    .Style.Font.SetBold(true)
                    .Font.SetFontColor(XLColor.White)
                    .Fill.SetBackgroundColor(XLColor.Black)
                    .Alignment.Vertical = XLAlignmentVerticalValues.Center;

                // car models heading
                int col = 4; // column D

                worksheet.Range(1, col, 7, col + modelCount - 1).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center)
                    .Alignment.SetVertical(XLAlignmentVerticalValues.Center);

                foreach (var carModel in carModels)
                {
                    string KD = carModel.KD ? "KD" : "";
                    
                    worksheet.Cell(1, col).Value = carModel.Doors + " " + carModel.Wheelbase + " " + carModel.BodyShape;
                    worksheet.Cell(2, col).Value = carModel.EngineSize + " " + carModel.Cylinder + " " + carModel.Turbo + " " + carModel.Power;
                    worksheet.Cell(3, col).Value = carModel.TrimName;
                    worksheet.Cell(4, col).Value = carModel.BMC;
                    worksheet.Cell(5, col).Value = carModel.TrimLevel + KD;
                    worksheet.Cell(6, col).Value = carModel.DPCK;

                    col = col + 1;
                }

                // output data
                int row = 8;
                string groupName = "";
                string subGroupName = "";

                foreach (var item in OXOData)
                {
                
                    // market grouping
                    if (groupName != item[1].ToString())
                    {
                        worksheet.Cell("A" + row).SetValue(item[1].ToString().ToUpper())
                            .Style.Font.SetFontColor(XLColor.White)
                            .Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left)
                            .Alignment.SetIndent(2)
                            .Font.SetBold(true);
                        worksheet.Range(row, 1, row, modelCount + 3).Style.Fill.SetBackgroundColor(XLColor.Black);
                        row = row + 1;
                        subGroupName = "";
                    }

                    groupName = item[1].ToString();

                    // market sub-grouping
                    if (subGroupName != item[8].ToString())
                    {
                        worksheet.Cell("A" + row).SetValue(item[8].ToString().ToUpper())
                            .Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left)
                            .Alignment.SetIndent(4)
                            .Font.SetBold(true);
                        worksheet.Range(row, 1, row, modelCount + 3).Style.Fill.SetBackgroundColor(XLColor.LightGray);
                        row = row + 1;
                    }

                    subGroupName = item[8].ToString();

                    worksheet.Cell("A" + row).Value = item[3];
                    worksheet.Cell("A" + row).Style.Alignment.SetIndent(6);
                    worksheet.Cell("B" + row).Value = item[2];

                    if (popDoc == true)
                    {
                        for (var n = 0; n < modelCount; n++)
                        {
                            int j = n + 10;
                            if (String.IsNullOrEmpty("" + item[j]))
                            {
                                worksheet.Cell(row, j - 6).Value = "NO";
                                worksheet.Cell(row, j - 6).Style.Font.SetFontColor(XLColor.Red);
                            }
                            else
                            {
                                worksheet.Cell(row, j - 6).Value = "YES";
                            }
                        }
                    }
                    row = row + 1;
                }

                // center align data columns
                worksheet.Range(10, 2, row, modelCount + 3).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                // allow car model headings to wrap
                worksheet.Range(1, 4, 6, modelCount + 3).Style.Alignment.SetWrapText();

                // black vertical band
                worksheet.Range(1, 3, worksheet.LastRowUsed().RowNumber(), 3).Style
                   .Font.SetFontColor(XLColor.White)
                   .Fill.SetBackgroundColor(XLColor.Black);

                // set border styles
                worksheet.RangeUsed().Style
                    .Border.SetTopBorder(XLBorderStyleValues.Thin)
                    .Border.SetRightBorder(XLBorderStyleValues.Thin)
                    .Border.SetOutsideBorder(XLBorderStyleValues.Thin);
                worksheet.Range("A1:A6").Style
                    .Border.SetTopBorder(XLBorderStyleValues.None)
                    .Border.SetRightBorder(XLBorderStyleValues.None)
                    .Border.SetOutsideBorder(XLBorderStyleValues.Thin);

                // adjust column widths
                worksheet.Columns().AdjustToContents();
                worksheet.Column(3).Width = 8;
                worksheet.Columns(4, modelCount + 7).Width = 14;

                // split the screen
                worksheet.SheetView.Freeze(7, 2);

                stopWatch.Stop();
                var executionTime = stopWatch.ElapsedMilliseconds;
            }
            catch (Exception ex)
            {
                AppHelper.LogError("ExcelHelper.GenerateExcelMBM", ex.Message, "SYSTEM");
            }

            return workbook;
        }

        public static XLWorkbook GenerateExcelFBM(XLWorkbook workbook, string sheetName, string marketName, int progid, int docid, string level, int objid, string cdsid, OXODoc OXODoc, OXODocDataStore ods, IEnumerable<Model> carModels, string option, bool popDoc)
        {      
            Stopwatch stopWatch = new Stopwatch();
            
            try
            {
                stopWatch.Reset();
                stopWatch.Start();
                
                IXLWorksheet worksheet = workbook.Worksheets.Add(sheetName);
                worksheet.Protect("Password123")
                    .SetFormatColumns()
                    .SetFormatRows()
                    .SetAutoFilter();
                worksheet.Style.Font.SetFontSize(11)
                    .Font.SetFontName("Arial");

                var test = (level == "mg") ? worksheet.TabColor = XLColor.Blue : worksheet.TabColor = XLColor.Green;
            
                // country code
                string parCode = "-";
            
                if (level == "m")
                {
                    MarketDataStore mkt = new MarketDataStore(cdsid);
                    parCode = mkt.MarketGet(objid).PAR_X;
                }
                
                // car models
                string modelIds = string.Join(",", carModels.Select(p => string.Format("[{0}]", p.Id.ToString())));
                int modelCount = carModels.Count();

                // data
                string make = OXODoc.VehicleMake;
                var OXOData = ods.OXODocGetItemData(make, docid, progid, "FBM", level, objid, modelIds, true);
                int rowCount = OXOData.Count();
                FeatureDataStore fds = new FeatureDataStore(cdsid);

                // page title
                worksheet.Cell("A1").Value = sheetName.ToUpper();
                worksheet.Cell("A2").Value = (OXODoc.VehicleName + " (" + OXODoc.VehicleAKA + ") " + OXODoc.ModelYear + " " + OXODoc.Gateway + " V" + OXODoc.VersionId + " " + OXODoc.Status).ToUpper();
                worksheet.Cell("A3").Value = DateTime.Now;
                worksheet.Cell("A4").Value = cdsid.ToUpper();
                worksheet.Range("A1:A4").Style.Font.SetBold()
                    .Font.SetFontSize(14)
                    .Alignment.Horizontal = XLAlignmentHorizontalValues.Left;

                // key
                worksheet.Cell("C1").Value = "Key:  S = Standard Feature, O = Optional Feature,  P = Feature part of Option Pack, NA = Not Available, (O) = Linked Option";
                worksheet.Cell("C1").Style.Font.SetFontSize(10);

                // heading row
                worksheet.Cell("A10").Value = "FEATURE GROUP";
                worksheet.Cell("B10").Value = "FEATURE CODE";
                worksheet.Cell("C10").Value = "MARKETING FEATURE DESCRIPTION" + Environment.NewLine + "(Standard Features for all derivatives are shown in the \"Standard Fitment\" sheet)";
                worksheet.Cell("D10").Value = "SYSTEM DESCRIPTION" + Environment.NewLine + "(Maximum 40 Characters)";
                worksheet.Cell("E10").Value = "RULES";
                worksheet.Cell("F10").Value = "COMMENTS";
                worksheet.Range(10, 1, 10, modelCount + 7)
                         .Style.Font.SetBold(true)
                         .Font.SetFontColor(XLColor.White)
                         .Fill.SetBackgroundColor(XLColor.Black)
                         .Alignment.Vertical = XLAlignmentVerticalValues.Center;
                worksheet.Range(1, 7, rowCount + 9, modelCount + 7)
                         .Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center)
                         .Alignment.SetVertical(XLAlignmentVerticalValues.Center);
                worksheet.Cell("F1").Value = "SPEC GROUP";
                worksheet.Cell("F2").Value = "BODY STYLE";
                worksheet.Cell("F3").Value = "ENGINE";
                worksheet.Cell("F4").Value = "DERIVATIVE";
                worksheet.Cell("F5").Value = "MODEL CODE";
                worksheet.Cell("F6").Value = "TRIM LEVEL";
                worksheet.Cell("F7").Value = "DERIVATIVE PACK CODE";
                worksheet.Cell("F8").Value = "PAR CODE";
                worksheet.Cell("F9").Value = "MODEL AVAILABILITY";
                worksheet.Range("F1:F9").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right)
                    .Alignment.SetVertical(XLAlignmentVerticalValues.Center);

                // gray top area
                worksheet.Range(1, 1, 9, modelCount + 7).Style.Font.SetBold(true)
                    .Fill.SetBackgroundColor(XLColor.LightGray);

                // car models heading - column H
                int col = 8; 

                worksheet.Cell(1, col).Value = marketName.ToString().ToUpper();
                worksheet.Range(1, col, 1, col + modelCount - 1).Merge();
                worksheet.Range(1, col, 1, col + modelCount - 1).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                foreach (var carModel in carModels)
                {
                    string KD = carModel.KD ? "KD" : "";
                    
                    worksheet.Cell(2, col).Value = carModel.Doors + " " + carModel.Wheelbase + " " + carModel.BodyShape;
                    worksheet.Cell(3, col).Value = carModel.EngineSize + " " + carModel.Cylinder + " " + carModel.Turbo + " " + carModel.Power;
                    worksheet.Cell(4, col).Value = carModel.TrimName;
                    worksheet.Cell(5, col).Value = carModel.BMC;
                    worksheet.Cell(6, col).Value = carModel.TrimLevel + KD;
                    worksheet.Cell(7, col).Value = carModel.DPCK;
                    worksheet.Cell(8, col).Value = parCode;
                    worksheet.Cell(9, col).Value = "";

                    col = col + 1;
                }
            
                // output data
                int row = 11;
                string groupName = "";

                foreach (var item in OXOData)
                {
                    // feature family grouping
                    if (groupName != item[1].ToString())
                    {
                        worksheet.Cell("A" + row).SetValue(item[1].ToString().ToUpper())
                            .Style.Font.SetFontColor(XLColor.White)
                            .Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left)
                            .Font.SetBold(true)
                            .Font.SetUnderline(XLFontUnderlineValues.Single);
                        worksheet.Range(row, 1, row, modelCount + 7).Style.Fill.SetBackgroundColor(XLColor.Black);
                        row = row + 1;
                    }
                    groupName = item[1].ToString();
                    worksheet.Cell("A" + row).Value = item[1];
                    worksheet.Cell("B" + row).Value = item[3];
                    worksheet.Cell("C" + row).Value = item[4];
                    worksheet.Cell("D" + row).Value = item[7];
                    worksheet.Cell("F" + row).Value = item[6];

                    // feature rules
                    if (Convert.ToInt32(item[8]) > 0)
                    {
                        string ruleText = "";
                        Feature feature = fds.ProgrammeFeatureGet(progid, 0, Convert.ToInt32(item[5]));
                        if (feature != null)
                        {
                            ruleText = "" + feature.RuleText;
                        } 
                        worksheet.Cell("E" + row).Value = ruleText;

                        // TODO : to be continued.....
                        // var featRules = fds.RuleToolTipGetByFeature(progid, Convert.ToInt32(item[5]));

                        // string newLine = Environment.NewLine;
                        // string output = "";
                        // int i = 1;

                        //foreach (var rule in featRules)
                        //{
                        //    if (rule.RuleActive == true && rule.RuleApproved == true)
                        //    {
                        //        if (i < featRules.Count())
                        //        {
                        //            output = output + rule.RuleResponse + newLine;
                        //        }
                        //        else
                        //        {
                        //            output = output + rule.RuleResponse;
                        //        }
                        //    }
                        //    i = i + 1;
                        //}

                    }

                    var columnOffSet = 10;

                    for (var n = 0; n < modelCount; n++)
                    {
                        var j = n + columnOffSet;
                        var k = j - 2; 

                        if (item[j].ToString().EndsWith("***"))
                        {
                            worksheet.Cell(9, k).Value = "NO";
                        }
                        else
                        {
                            worksheet.Cell(9, k).Value = "YES";
                        }

                        if (popDoc == true)
                        {
                            switch (option) // v: variance | f: full
                            {
                                case "v":
                                    if (String.IsNullOrEmpty("" + item[j]))
                                    {
                                        worksheet.Cell(row, k).Value = "";
                                    }
                                    else
                                    {
                                        if (item[j].ToString().EndsWith("*"))
                                        {
                                            worksheet.Cell(row, k).Value = "";
                                        }
                                        else
                                        {
                                            worksheet.Cell(row, k).Value = item[j];
                                        }
                                    }
                                    break;
                                case "f":
                                    if (String.IsNullOrEmpty("" + item[j]))
                                    {
                                        worksheet.Cell(row, k).Value = "";
                                    }
                                    else
                                    {
                                        worksheet.Cell(row, k).Value = item[j].ToString().TrimEnd('*');
                                    }
                                    break;
                            }
                        }
                    }
                    row = row + 1;
                }

                // packs headings
                var packHeaderItem = ods.OXODocGetItemData(make, docid, progid, "PCK", level, objid, modelIds);
            
                // pack features
                var packDataItem = ods.OXODocGetItemData(make, docid, progid, "FPS", level, objid, modelIds);

                if (packDataItem != null && packDataItem.Count() > 0)
                {
                    // packs heading row
                    worksheet.Cell("A" + row).SetValue("OPTION PACKS")
                           .Style.Font.SetFontColor(XLColor.White)
                           .Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left)
                           .Font.SetBold(true)
                           .Font.SetUnderline(XLFontUnderlineValues.Single);
                    worksheet.Range(row, 1, row, modelCount + 7).Style.Fill.SetBackgroundColor(XLColor.Black);
                
                    var currentPackName = "";
                    var packHeader = packHeaderItem[0];

                    foreach (var item in packDataItem)
                    {
                        var subGroup = item["PackName"].ToString();
                        var columnOffSet = 7;

                        if (currentPackName != subGroup)
                        {
                            currentPackName = subGroup;
                            foreach (var pack in packHeaderItem)
                            {
                                if (pack["PackName"].ToString() == subGroup)
                                {
                                    row = row + 1;
                                    packHeader = pack;
                                }
                            }
                        
                            // pack heading row
                            worksheet.Cell("A" + row).SetValue(item["PackName"].ToString().ToUpper());
                            worksheet.Cell("B" + row).SetValue(packHeader["FeatureCode"]);
                            worksheet.Range(row, 1, row, modelCount + 7).Style.Fill.SetBackgroundColor(XLColor.Black)
                                .Font.SetFontColor(XLColor.White);

                            if (popDoc == true)
                            {
                                switch (option) // v: variance | f: full
                                {
                                    case "v":
                                        for (var i = 0; i < modelCount; i++)
                                        {
                                            var j = i + columnOffSet;
                                            var oxoCode = (packHeader[j] == null ? "" : packHeader[j].ToString());

                                            if (oxoCode.ToString().EndsWith("*"))
                                            {
                                                worksheet.Cell(row, j + 1).Value = "";
                                            }
                                            else
                                            {
                                                worksheet.Cell(row, j + 1).Value = oxoCode.ToString().TrimEnd('*');
                                            }
                                        }
                                        break;
                                    case "f":
                                        for (var i = 0; i < modelCount; i++)
                                        {
                                            var j = i + columnOffSet;
                                            var oxoCode = (packHeader[j] == null ? "" : packHeader[j].ToString());

                                            worksheet.Cell(row, j + 1).Value = oxoCode.ToString().TrimEnd('*');
                                        }
                                        break;
                                }
                            }
                        }
                        row = row + 1;

                        // pack features
                        worksheet.Cell("A" + row).SetValue(item["PackName"].ToString());
                        worksheet.Cell("B" + row).SetValue(item["FeatureCode"]);
                        worksheet.Cell("C" + row).SetValue(item["BrandDescription"].ToString());
                        worksheet.Cell("D" + row).SetValue(item["SystemDescription"].ToString());

                        if (popDoc == true)
                        {
                            switch (option) // v: variance | f: full
                            {
                                case "v":
                                    for (var i = 0; i < modelCount; i++)
                                    {
                                        var j = i + columnOffSet;
                                        var oxoCode = (item[j] == null ? "" : item[j].ToString());

                                        if (oxoCode.ToString().EndsWith("*"))
                                        {
                                            worksheet.Cell(row, j + 1).Value = "";
                                        }
                                        else
                                        {
                                            worksheet.Cell(row, j + 1).Value = oxoCode.ToString().TrimEnd('*');
                                        }
                                    }
                                    break;
                                case "f":
                                    for (var i = 0; i < modelCount; i++)
                                    {
                                        var j = i + columnOffSet;
                                        var oxoCode = (item[j] == null ? "" : item[j].ToString());

                                        worksheet.Cell(row, j + 1).Value = oxoCode.ToString().TrimEnd('*');
                                    }
                                    break;
                            }
                        }
                    }
                }

                // market vertical black band
                worksheet.Cell(1, 7).Value = marketName.ToString().ToUpper();
                worksheet.Range(1, 7, 9, 7).Merge();
                worksheet.Range(1, 7, worksheet.LastRowUsed().RowNumber(), 7).Style
                    .Font.SetBold(true)
                    .Font.SetFontColor(XLColor.White)
                    .Fill.SetBackgroundColor(XLColor.Black)
                    .Alignment.SetVertical(XLAlignmentVerticalValues.Bottom)
                    .Alignment.SetTextRotation(90);
            
                // set border styles
                worksheet.RangeUsed().Style
                    .Border.SetTopBorder(XLBorderStyleValues.Thin)
                    .Border.SetRightBorder(XLBorderStyleValues.Thin)
                    .Border.SetOutsideBorder(XLBorderStyleValues.Thin);
                worksheet.Range("A1:F9").Style
                    .Border.SetTopBorder(XLBorderStyleValues.None)
                    .Border.SetRightBorder(XLBorderStyleValues.None)
                    .Border.SetOutsideBorder(XLBorderStyleValues.Thin);

                // center align all of the data columns
                worksheet.Range(12, 8, worksheet.LastRowUsed().RowNumber(), modelCount + 7).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
           
                // allow car model headings to wrap
                worksheet.Range(1, 8, 9, modelCount + 7).Style.Alignment.SetWrapText();

                // outline the models - commented out as you can't un-group on a protected worksheet
                // worksheet.Columns(8, modelCount + 7).Group();

                // adjust column widths
                worksheet.Column("A").Width = 36;
                worksheet.Column("B").Width = 20;
                worksheet.Column("B").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                worksheet.Columns("C:F").Width = 90;
                worksheet.Columns("C:F").Style.Alignment.SetWrapText();
                worksheet.Column("G").Width = 8;
                worksheet.Columns(8, modelCount + 7).Width = 14;

                // apply filter
                worksheet.Range(11, 1, worksheet.LastRowUsed().RowNumber(), 1).SetAutoFilter();

                // split the screen
                worksheet.SheetView.Freeze(10, 3);

                stopWatch.Stop();
                var executionTime = stopWatch.ElapsedMilliseconds;
            }
            catch (Exception ex)
            {
                AppHelper.LogError("ExcelHelper.GenerateExcelFBM", ex.Message, "SYSTEM");
            }

            return workbook;
        }

        public static XLWorkbook GenerateExcelGSF(XLWorkbook workbook, int progid, int docid, string cdsid, OXODoc OXODoc, OXODocDataStore ods, bool popDoc)
        {
            Stopwatch stopWatch = new Stopwatch();
            
            try
            {
                stopWatch.Reset();
                stopWatch.Start();

                IXLWorksheet worksheet = workbook.Worksheets.Add("Global Standard Features");
                worksheet.Protect("Password123")
                    .SetFormatColumns()
                    .SetFormatRows()
                    .SetAutoFilter();
                worksheet.Style.Font.SetFontSize(11)
                    .Font.SetFontName("Arial");
                worksheet.TabColor = XLColor.Orange;

                // car models
                ModelDataStore mds = new ModelDataStore(cdsid);
                var carModels = mds.GSFModelGetMany(progid, docid);
                string modelIds = string.Join(",", carModels.Select(p => string.Format("[{0}]", p.GSFId.ToString())));
                int modelCount = carModels.Count();

                // data
                string make = OXODoc.VehicleMake;
                var OXOData = ods.OXODocGetItemData(make, docid, progid, "GSF", "g", -1, modelIds);
                int rowCount = OXOData.Count();

                // page title
                worksheet.Cell("A1").Value = "GLOBAL STANDARD FEATURES";
                worksheet.Cell("A2").Value = (OXODoc.VehicleName + " (" + OXODoc.VehicleAKA + ") " + OXODoc.ModelYear + " " + OXODoc.Gateway + " V" + OXODoc.VersionId + " " + OXODoc.Status).ToUpper();
                worksheet.Cell("A3").Value = DateTime.Now;
                worksheet.Cell("A4").Value = cdsid.ToUpper();
                worksheet.Range("A1:A4").Style.Font.SetBold()
                    .Font.SetFontSize(14)
                    .Alignment.Horizontal = XLAlignmentHorizontalValues.Left;
            
                // heading row
                worksheet.Cell("A5").Value = "FEATURE GROUP";
                worksheet.Cell("B5").Value = "FEATURE CODE";
                worksheet.Cell("C5").Value = "MARKETING FEATURE DESCRIPTION";
                worksheet.Cell("D5").Value = "COMMENTS";
                worksheet.Range(5, 1, 5, modelCount + 4)
                         .Style.Font.SetBold(true)
                         .Font.SetFontColor(XLColor.White)
                         .Fill.SetBackgroundColor(XLColor.Black)
                         .Alignment.Vertical = XLAlignmentVerticalValues.Center;
                worksheet.Range(1, 5, 4, modelCount + 4)
                         .Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center)
                         .Alignment.SetVertical(XLAlignmentVerticalValues.Center);
                worksheet.Cell("D2").Value = "BODY STYLE";
                worksheet.Cell("D3").Value = "ENGINE";
                worksheet.Cell("D4").Value = "MODEL CODE";
                worksheet.Range("D1:D4").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Right)
                    .Alignment.SetVertical(XLAlignmentVerticalValues.Center);

                // key
                worksheet.Cell("C1").Value = "Key:  S = Standard Feature, NA = Not Available";
                worksheet.Cell("C1").Style.Font.SetFontSize(10);

                // gray top area
                worksheet.Range(1, 1, 4, modelCount + 4).Style.Font.SetBold(true)
                    .Fill.SetBackgroundColor(XLColor.LightGray);

                // car models heading
                int col = 5; // column E

                worksheet.Range(1, col, 4, col + modelCount - 1).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center)
                    .Alignment.SetVertical(XLAlignmentVerticalValues.Center)
                    .Alignment.SetWrapText();

                foreach (var carModel in carModels)
                {
                    worksheet.Cell(2, col).Value = carModel.GSFBody;
                    worksheet.Cell(3, col).Value = carModel.GSFEngine;
                    worksheet.Cell(4, col).Value = carModel.BMC;
                    
                    col = col + 1;
                }

                // output data
                int row = 6;
                string groupName = "";

                foreach (var item in OXOData)
                {
                    // feature family grouping
                    if (groupName != item[1].ToString())
                    {
                        worksheet.Cell("A" + row).SetValue(item[1].ToString().ToUpper())
                            .Style.Font.SetFontColor(XLColor.White)
                            .Alignment.SetHorizontal(XLAlignmentHorizontalValues.Left)
                            .Font.SetBold(true)
                            .Font.SetUnderline(XLFontUnderlineValues.Single);
                        worksheet.Range(row, 1, row, modelCount + 4).Style.Fill.SetBackgroundColor(XLColor.Black);
                        row = row + 1;
                    }
                    groupName = item[1].ToString();
                    worksheet.Cell("A" + row).Value = item[1];
                    worksheet.Cell("B" + row).Value = item[3];
                    worksheet.Cell("C" + row).Value = item[4];
                    worksheet.Cell("D" + row).Value = item[6];

                    var columnOffSet = 9;
                
                    if (popDoc == true)
                    {
                        for (var n = 0; n < modelCount; n++)
                        {
                            var j = n + columnOffSet;

                            if (String.IsNullOrEmpty("" + item[j]))
                            {
                                worksheet.Cell(row, j - 4).Value = "";
                            }
                            else
                            {
                                if (item[j].ToString() == "S")
                                {
                                    worksheet.Cell(row, j - 4).Value = "S";
                                }
                                else
                                {
                                    worksheet.Cell(row, j - 4).Value = "NA";
                                    worksheet.Cell(row, j - 4).Style.Fill.SetBackgroundColor(XLColor.LightGray);
                                }
                            }
                        }
                    }
                    row = row + 1;
                }

                // set border styles
                worksheet.RangeUsed().Style
                    .Border.SetTopBorder(XLBorderStyleValues.Thin)
                    .Border.SetRightBorder(XLBorderStyleValues.Thin)
                    .Border.SetOutsideBorder(XLBorderStyleValues.Thin);

                worksheet.Range("A1:D4").Style
                    .Border.SetTopBorder(XLBorderStyleValues.None)
                    .Border.SetRightBorder(XLBorderStyleValues.None)
                    .Border.SetOutsideBorder(XLBorderStyleValues.Thin);

                // center align all of the data columns
                worksheet.Range(7, 5, worksheet.LastRowUsed().RowNumber(), modelCount + 4).Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);

                // allow car model headings to wrap
                worksheet.Range(1, 5, 4, modelCount + 3).Style.Alignment.SetWrapText();

                // adjust column widths
                worksheet.Columns().AdjustToContents();
                worksheet.Column("A").Width = 32;
                worksheet.Column("B").Width = 20;
                worksheet.Column("B").Style.Alignment.SetHorizontal(XLAlignmentHorizontalValues.Center);
                worksheet.Columns("C:D").Width = 90;
                worksheet.Columns("C:D").Style.Alignment.SetWrapText();
                worksheet.Columns(5, modelCount + 4).Width = 14;

                // apply filter
                worksheet.Range(5, 1, worksheet.LastRowUsed().RowNumber(), 1).SetAutoFilter();
            
                // split the screen
                worksheet.SheetView.Freeze(5, 2);

                stopWatch.Stop();
                var executionTime = stopWatch.ElapsedMilliseconds;
            }
            catch (Exception ex)
            {
                AppHelper.LogError("ExcelHelper.GenerateExcelGSF", ex.Message, "SYSTEM");
            }

            return workbook;
        }

        public static XLWorkbook GenerateExcelOXO_NoMarkets(int progid, int docid, string cdsid, bool popDoc)
        {
            Stopwatch stopWatch = new Stopwatch();
            DateTime start = DateTime.Now;
            XLWorkbook workbook = new XLWorkbook();
            
            try
            {
                stopWatch.Reset();
                stopWatch.Start();

                // data
                OXODocDataStore ods = new OXODocDataStore(cdsid);
                var OXODoc = ods.OXODocGet(docid, progid);
                string make = OXODoc.VehicleMake;

                // car models
                ModelDataStore mds = new ModelDataStore(cdsid);
                var carModels = mds.ModelGetMany(new ProgrammeFilter() { ProgrammeId = progid, DocumentId = docid });
                string modelIds = string.Join(",", carModels.Select(p => string.Format("[{0}]", p.Id.ToString())));
                int modelCount = carModels.Count();
            
                // cover sheet
                GenerateExcelCoverSheet(workbook, progid, docid, cdsid, OXODoc, popDoc);
                workbook.Worksheet("Cover Sheet").Cell("L1").Value = "Finished Cover Sheet: " + DateTime.Now;
              
                // change log
                workbook.Worksheet("Cover Sheet").Cell("K2").Value = "Creating Change Log: " + DateTime.Now;
                GenerateExcelChangeLog(workbook, docid, cdsid, OXODoc);
                workbook.Worksheet("Cover Sheet").Cell("L2").Value = "Finished Change Log: " + DateTime.Now;

                // model market matrix
                workbook.Worksheet("Cover Sheet").Cell("K3").Value = "Creating Model Market Matrix: " + DateTime.Now;
                GenerateExcelMBM(workbook, progid, docid, cdsid, OXODoc, ods, carModels, popDoc);
                workbook.Worksheet("Cover Sheet").Cell("L3").Value = "Finished Model Market Matrix: " + DateTime.Now;

                // reasons for rules
                workbook.Worksheet("Cover Sheet").Cell("K4").Value = "Creating Reasons for Rules: " + DateTime.Now;
                GenerateExcelRFR(workbook, progid, cdsid, OXODoc);
                workbook.Worksheet("Reasons for Rules").Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A21");
                workbook.Worksheet("Cover Sheet").Cell("L4").Value = "Finished Reasons for Rules: " + DateTime.Now;

                // global standard features
                workbook.Worksheet("Cover Sheet").Cell("K5").Value = "Creating Global Standard Features: " + DateTime.Now;
                GenerateExcelGSF(workbook, progid, docid, cdsid, OXODoc, ods, popDoc);
                workbook.Worksheet("Global Standard Features").Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A22");
                workbook.Worksheet("Cover Sheet").Cell("L5").Value = "Finished Global Standard Features: " + DateTime.Now;
                          
                // world at a glance
                workbook.Worksheet("Cover Sheet").Cell("K6").Value = "Creating World At A Glance: " + DateTime.Now;
                GenerateExcelFBM(workbook, "World At A Glance", "Global Generic", progid, docid, "g", -1, cdsid, OXODoc, ods, carModels, "f", popDoc);
                workbook.Worksheet("World At A Glance").Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A23");
                workbook.Worksheet("Cover Sheet").Cell("A23").Hyperlink = new XLHyperlink("'World At A Glance'!A1");
                workbook.Worksheet("Cover Sheet").Cell("L6").Value = "Finished World At A Glance (core): " + DateTime.Now;

                // regions vs global generic - region variance
                //workbook.Worksheet("Cover Sheet").Cell("K7").Value = "Creating Regions vs Global Generic: " + DateTime.Now;
                //GenerateExcelFBM(workbook, "Regions vs Global Generic", "Global Generic", progid, docid, "g", -1, cdsid, OXODoc, ods, carModels, "f", popDoc);
                //workbook.Worksheet("Regions vs Global Generic").Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A25");
                //workbook.Worksheet("Cover Sheet").Cell("A25").Hyperlink = new XLHyperlink("'Regions vs Global Generic'!A1");
                //workbook.Worksheet("Cover Sheet").Cell("L7").Value = "Finished Regions vs Global Generic (core): " + DateTime.Now;

                MarketGroupDataStore mg = new MarketGroupDataStore(cdsid);
                var marketGroups = mg.MarketGroupGetMany(progid, docid, true);

                int logRow = 8;
                int row = 25;
                int groupCol = modelCount + 8;

                //foreach (var marketGroup in marketGroups)
                //{
                //    OXODocDataStore ds = new OXODocDataStore("system");
                //    int availCount = ds.OXODocAvailableModelsByMarketGroup(progid, docid, marketGroup.Id).Where(p => p.Available == true).Count();

                //    if (availCount > 0)
                //    {
                //        int marketCol = modelCount + 8;

                //        string groupSheetName = marketGroup.GroupName + " Variance";

                //        workbook.Worksheet("Cover Sheet").Cell(logRow, 11).Value = "Creating " + groupSheetName + ": " + DateTime.Now;

                //        GenerateExcelFBM(workbook, groupSheetName, marketGroup.GroupName, progid, docid, "mg", marketGroup.Id, cdsid, OXODoc, ods, carModels, "v", popDoc);

                //        workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished " + groupSheetName + " : " + DateTime.Now;

                //        workbook.Worksheet(groupSheetName).Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A" + row);

                //        // copy the market group to Regions vs Global Generic
                //        workbook.Worksheet("Regions vs Global Generic").Cell(1, groupCol).Value = workbook.Worksheet(groupSheetName).Range(1, 7, workbook.Worksheet(groupSheetName).LastRowUsed().RowNumber(), modelCount + 7);
                //        workbook.Worksheet("Regions vs Global Generic").Column(groupCol).Width = 8;
                //        workbook.Worksheet("Regions vs Global Generic").Columns(groupCol + 1, groupCol + modelCount + 1).Width = 14;
                //        // commented out as you can't un-group on a protected worksheet
                //        //workbook.Worksheet("Regions vs Global Generic").Columns(groupCol + 1, groupCol + modelCount).Group();
                        
                //        // delete the group variance sheet as it's no longer required
                //        workbook.Worksheet(groupSheetName).Delete();

                //        // hide derivatives with no availability
                //        HideNoDerivativeColumn(workbook.Worksheet("Regions vs Global Generic"), groupCol + 1);

                //        groupCol = groupCol + modelCount + 1;
                //        logRow = logRow + 1;
                //        row = row + 1;
                //    }
                //}

                //workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished Regions vs Global Generic (extended): " + DateTime.Now;
            
                // markets vs market group - variance

                logRow = logRow + 1;
                row = 26;
                groupCol = modelCount + 8;

                //foreach (var marketGroup in marketGroups)
                //{
                //    OXODocDataStore ds = new OXODocDataStore("system");
                //    int availGroupCount = ds.OXODocAvailableModelsByMarketGroup(progid, docid, marketGroup.Id).Where(p => p.Available == true).Count();

                //    if (availGroupCount > 0)
                //    {
                //        int marketCol = modelCount + 8;

                //        string groupSheetName = "Markets vs " + marketGroup.GroupName;

                //        workbook.Worksheet("Cover Sheet").Cell(logRow, 11).Value = "Creating " + groupSheetName + ": " + DateTime.Now;

                //        GenerateExcelFBM(workbook, groupSheetName, marketGroup.GroupName, progid, docid, "mg", marketGroup.Id, cdsid, OXODoc, ods, carModels, "f", popDoc);

                //        // hide derivatives with no availability
                //        HideNoDerivativeColumn(workbook.Worksheet(groupSheetName), 8);

                //        workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished " + groupSheetName + " (core): " + DateTime.Now;

                //        workbook.Worksheet(groupSheetName).Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A" + row);

                //        // generate hyperlinks
                //        workbook.Worksheet("Cover Sheet").Cell("A" + row).Value = groupSheetName;
                //        workbook.Worksheet("Cover Sheet").Cell("B" + row).Value = "Details the specification variance at market level versus the region generic specification";
                //        workbook.Worksheet("Cover Sheet").Cell("A" + row).Hyperlink = new XLHyperlink("'" + groupSheetName + "'!A1");

                //        groupCol = groupCol + modelCount + 1;
                //        logRow = logRow + 1;
                //        row = row + 1;

                //        var markets = marketGroup.Markets;

                //        // markets
                //        foreach (var market in markets)
                //        {
                //            int availMarketCount = ds.OXODocAvailableModelsByMarket(progid, docid, market.Id).Where(p => p.Available == true).Count();

                //            if (availMarketCount > 0)
                //            {
                //                string marketSheetName = market.Name + " Variance";

                //                workbook.Worksheet("Cover Sheet").Cell(logRow, 11).Value = "Creating " + marketSheetName + ": " + DateTime.Now;

                //                GenerateExcelFBM(workbook, marketSheetName, market.Name, progid, docid, "m", market.Id, cdsid, OXODoc, ods, carModels, "v", popDoc);

                //                // seperate KD models
                //                int kdCount = ds.OXODocAvailableModelsByMarket(progid, docid, market.Id).Where(p => p.Available == true && p.KD == true).Count();
                //                int kdSplit = 0;

                //                if (kdCount > 0)
                //                {
                //                    SplitKD(workbook.Worksheet(marketSheetName), market.Name, 8);
                //                    kdSplit = 1;
                //                }

                //                // copy the market to the market group
                //                if (kdCount > 0)
                //                {
                //                    workbook.Worksheet(groupSheetName).Cell(1, marketCol).Value = workbook.Worksheet(marketSheetName).Range(1, 7, workbook.Worksheet(marketSheetName).LastRowUsed().RowNumber(), modelCount + 7 + kdSplit);
                //                    workbook.Worksheet(groupSheetName).Column(marketCol).Width = 8;
                //                    workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount + 1).Width = 14;
                //                    workbook.Worksheet(groupSheetName).Column(marketCol + modelCount - kdCount + 1).Width = 8;
                //                    // commented out as you can't un-group on a protected worksheet
                //                    // workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount - kdCount).Group();
                //                    // workbook.Worksheet(groupSheetName).Columns(marketCol + 1 + modelCount - kdCount + 1, marketCol + 1 + modelCount).Group();
                //                }
                //                else
                //                {
                //                    workbook.Worksheet(groupSheetName).Cell(1, marketCol).Value = workbook.Worksheet(marketSheetName).Range(1, 7, workbook.Worksheet(marketSheetName).LastRowUsed().RowNumber(), modelCount + 7);
                //                    workbook.Worksheet(groupSheetName).Column(marketCol).Width = 8;
                //                    workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount + 1).Width = 14;
                //                    // commented out as you can't un-group on a protected worksheet
                //                    // workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount).Group();
                //                }

                //                // delete the market variance sheet as it's no longer required
                //                workbook.Worksheet(marketSheetName).Delete();

                //                // hide derivatives with no availability
                //                HideNoDerivativeColumn(workbook.Worksheet(groupSheetName), marketCol + 1);

                //                marketCol = marketCol + modelCount + kdSplit + 1;

                //                workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished " + marketSheetName + ": " + DateTime.Now;
                //                logRow = logRow + 1;
                //            }
                //        }
                //        workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished " + groupSheetName + " (extended): " + DateTime.Now;
                //        logRow = logRow + 1;
                //    }
                //}

                workbook.Worksheet("Cover Sheet").Range(26, 1, row, 1).Style
                    .Alignment.SetIndent(6)
                    .Font.SetBold(true);
            
                row = row + 2;
            
                workbook.Worksheet("Cover Sheet").Cell(row, 1).Value = "Global Generic";
                workbook.Worksheet("Cover Sheet").Cell(row, 2).Value = "Details the full specifications for the global generic";

                row = row + 1;

                workbook.Worksheet("Cover Sheet").Cell(row, 1).Value = "Region X in Full";
                workbook.Worksheet("Cover Sheet").Cell(row, 2).Value = "Details the full specifications for the generic region";

                row = row + 1;

                workbook.Worksheet("Cover Sheet").Cell(row, 1).Value = "Market";
                workbook.Worksheet("Cover Sheet").Cell(row, 2).Value = "Details the full specifications for the individual market";

                row = row + 3;

                workbook.Worksheet("Cover Sheet").Cell(row, 1).Value = "Quick links to full specifications ;";

                workbook.Worksheet("Cover Sheet").Range(row - 5, 1, row, 1).Style
                    .Alignment.SetIndent(3)
                    .Font.SetBold(true);

                row = row + 2;

                int startRow = row;

                // global generic
                //workbook.Worksheet("Cover Sheet").Cell(logRow, 11).Value = "Creating Global Generic: " + DateTime.Now;
                //GenerateExcelFBM(workbook, "Global Generic", "Global Generic", progid, docid, "g", -1, cdsid, OXODoc, ods, carModels, "f", popDoc);
                //workbook.Worksheet("Global Generic").Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A" + row);
                //workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished Global Generic: " + DateTime.Now;
                //workbook.Worksheet("Cover Sheet").Cell(row, 1).Value = "Global Generic";
                //workbook.Worksheet("Cover Sheet").Cell(row, 1).Hyperlink = new XLHyperlink("'Global Generic'!A1");

                logRow = logRow + 1;
                row = row + 1;

                // markets vs market groups - in full

                groupCol = modelCount + 8;

                foreach (var marketGroup in marketGroups)
                {
                    OXODocDataStore ds = new OXODocDataStore("system");
                    int availCount = ds.OXODocAvailableModelsByMarketGroup(progid, docid, marketGroup.Id).Where(p => p.Available == true).Count();

                    if (availCount > 0)
                    {
                        int marketCol = modelCount + 8;

                        string groupSheetName = marketGroup.GroupName + " in Full";

                        workbook.Worksheet("Cover Sheet").Cell(logRow, 11).Value = "Creating " + groupSheetName + ": " + DateTime.Now;

                        GenerateExcelFBM(workbook, groupSheetName, marketGroup.GroupName, progid, docid, "mg", marketGroup.Id, cdsid, OXODoc, ods, carModels, "f", popDoc);

                        workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished " + groupSheetName + " (core): " + DateTime.Now;

                        workbook.Worksheet(groupSheetName).Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A" + row);

                        // copy the market group to world at a glance
                        workbook.Worksheet("World At A Glance").Cell(1, groupCol).Value = workbook.Worksheet(groupSheetName).Range(1, 7, workbook.Worksheet(groupSheetName).LastRowUsed().RowNumber(), modelCount + 7);
                        workbook.Worksheet("World At A Glance").Column(groupCol).Width = 8;
                        workbook.Worksheet("World At A Glance").Columns(groupCol + 1, groupCol + modelCount + 1).Width = 14;
                        // commented out as you can't un-group on a protected worksheet
                        // workbook.Worksheet("World At A Glance").Columns(groupCol + 1, groupCol + modelCount).Group();

                        // hide derivatives with no availability
                        HideNoDerivativeColumn(workbook.Worksheet("World At A Glance"), groupCol + 1);

                        // generate hyperlinks
                        workbook.Worksheet("Cover Sheet").Cell("A" + row).Value = groupSheetName;
                        workbook.Worksheet("Cover Sheet").Cell("A" + row).Hyperlink = new XLHyperlink("'" + groupSheetName + "'!A1");

                        groupCol = groupCol + modelCount + 1;
                        logRow = logRow + 1;
                        row = row + 1;

                        var markets = marketGroup.Markets;

                        // markets
                        //foreach (var market in markets)
                        //{
                        //    int availMarketCount = ds.OXODocAvailableModelsByMarket(progid, docid, market.Id).Where(p => p.Available == true).Count();

                        //    if (availMarketCount > 0)
                        //    {
                        //        string marketSheetName = market.Name;

                        //        workbook.Worksheet("Cover Sheet").Cell(logRow, 11).Value = "Creating " + marketSheetName + ": " + DateTime.Now;
                        //        workbook.Worksheet("Cover Sheet").Cell("B" + row).Value = marketSheetName;
                        //        workbook.Worksheet("Cover Sheet").Cell("B" + row).Hyperlink = new XLHyperlink("'" + marketSheetName + "'!A1");

                        //        GenerateExcelFBM(workbook, marketSheetName, market.Name, progid, docid, "m", market.Id, cdsid, OXODoc, ods, carModels, "f", popDoc);
                        //        workbook.Worksheet(marketSheetName).Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!B" + row);

                        //        // seperate KD models
                        //        int kdSplit = 0;
                        //        int kdCount = ds.OXODocAvailableModelsByMarket(progid, docid, market.Id).Where(p => p.Available == true && p.KD == true).Count();

                        //        if (kdCount > 0)
                        //        {
                        //            SplitKD(workbook.Worksheet(marketSheetName), market.Name, 8);
                        //            kdSplit = 1;
                        //        }

                        //        // hide derivatives with no availability
                        //        HideNoDerivativeColumn(workbook.Worksheet(marketSheetName), 8);

                        //        // copy the market to the market group
                        //        if (kdCount > 0)
                        //        {
                        //            workbook.Worksheet(groupSheetName).Cell(1, marketCol).Value = workbook.Worksheet(marketSheetName).Range(1, 7, workbook.Worksheet(marketSheetName).LastRowUsed().RowNumber(), modelCount + 7 + kdSplit);
                        //            workbook.Worksheet(groupSheetName).Column(marketCol).Width = 8;
                        //            workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount + 1).Width = 14;
                        //            workbook.Worksheet(groupSheetName).Column(marketCol + modelCount - kdCount + 1).Width = 8;
                        //            // commented out as you can't un-group on a protected worksheet
                        //            // workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount - kdCount).Group();
                        //            // workbook.Worksheet(groupSheetName).Columns(marketCol + 1 + modelCount - kdCount + 1, marketCol + 1 + modelCount).Group();
                        //        }
                        //        else
                        //        {
                        //            workbook.Worksheet(groupSheetName).Cell(1, marketCol).Value = workbook.Worksheet(marketSheetName).Range(1, 7, workbook.Worksheet(marketSheetName).LastRowUsed().RowNumber(), modelCount + 7);
                        //            workbook.Worksheet(groupSheetName).Column(marketCol).Width = 8;
                        //            workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount + 1).Width = 14;
                        //            // commented out as you can't un-group on a protected worksheet
                        //            // workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount).Group();
                        //        }

                        //        // hide derivatives with no availability
                        //        HideNoDerivativeColumn(workbook.Worksheet(groupSheetName), marketCol + 1);

                        //        marketCol = marketCol + modelCount + kdSplit + 1;

                        //        workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished " + marketSheetName + ": " + DateTime.Now;

                        //        logRow = logRow + 1;
                        //        row = row + 1;
                        //    }
                        //}
                        //// hide derivatives with no availability
                        //HideNoDerivativeColumn(workbook.Worksheet(groupSheetName), 8);

                        //workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished " + groupSheetName + " (extended): " + DateTime.Now;
                        //logRow = logRow + 1;

                        row = row + 1;
                    }
                }

                workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished World At A Glance (extended): " + DateTime.Now;
                logRow = logRow + 1;

                workbook.Worksheet("Cover Sheet").Range(startRow, 1, row, 1).Style
                    .Alignment.SetIndent(18)
                    .Font.SetBold(true);
                workbook.Worksheet("Cover Sheet").Range(startRow, 2, row, 2).Style
                    .Alignment.SetIndent(3)
                    .Font.SetBold(true);

                // cover sheet footer - need to do it here due to flexible number of market groups / markets
                workbook.Worksheet("Cover Sheet").Cell(row + 2, 1).Value = "This file is classified as follows according to the Global Marketing GIS1 matrix";
                workbook.Worksheet("Cover Sheet").Cell(row + 2, 1).Style.Font.SetBold(true);
                workbook.Worksheet("Cover Sheet").Cell(row + 3, 1).Value = "Record title:";
                workbook.Worksheet("Cover Sheet").Cell(row + 3, 2).Value = "Product & Marketing Brief";
                workbook.Worksheet("Cover Sheet").Cell(row + 4, 1).Value = "Security Classification:";
                workbook.Worksheet("Cover Sheet").Cell(row + 4, 2).Value = "CONFIDENTIAL";
                workbook.Worksheet("Cover Sheet").Cell(row + 5, 1).Value = "Retention period:";
                workbook.Worksheet("Cover Sheet").Cell(row + 5, 2).Value = "10 years";
                workbook.Worksheet("Cover Sheet").Cell(row + 6, 1).Value = "Retention Qualifers:";
                workbook.Worksheet("Cover Sheet").Cell(row + 6, 2).Value = "T";
                workbook.Worksheet("Cover Sheet").Range(row + 3, 1, row + 11, 1).Style
                    .Alignment.SetIndent(3)
                    .Font.SetBold(true);

                workbook.Worksheet("Cover Sheet").Columns(11, 12)
                    .Style.Font.SetFontSize(8)
                    .Font.SetFontName("Courier New");
                workbook.Worksheet("Cover Sheet").Columns(11, 12).Hide();
            
                DateTime end = DateTime.Now;

                workbook.Worksheet("Cover Sheet").Cell("A1").Comment.AddText("Time to export this OxO: " + (end - start).TotalMinutes + " minutes");

                stopWatch.Stop();
                var executionTime = stopWatch.ElapsedMilliseconds;
            }
            catch (Exception ex)
            {
                AppHelper.LogError("ExcelHelper.GenerateExcelOXO", ex.Message, "SYSTEM");
            }

            return workbook;
        }

        public static XLWorkbook GenerateExcelOXO(int progid, int docid, string cdsid, bool popDoc)
        {
            Stopwatch stopWatch = new Stopwatch();
            DateTime start = DateTime.Now;
            XLWorkbook workbook = new XLWorkbook();

            try
            {
                stopWatch.Reset();
                stopWatch.Start();

                // data
                OXODocDataStore ods = new OXODocDataStore(cdsid);
                var OXODoc = ods.OXODocGet(docid, progid);
                string make = OXODoc.VehicleMake;

                // car models
                ModelDataStore mds = new ModelDataStore(cdsid);
                var carModels = mds.ModelGetMany(new ProgrammeFilter() { ProgrammeId = progid, DocumentId = docid });
                string modelIds = string.Join(",", carModels.Select(p => string.Format("[{0}]", p.Id.ToString())));
                int modelCount = carModels.Count();

                // cover sheet
                GenerateExcelCoverSheet(workbook, progid, docid, cdsid, OXODoc, popDoc);
                workbook.Worksheet("Cover Sheet").Cell("L1").Value = "Finished Cover Sheet: " + DateTime.Now;

                // change log
                workbook.Worksheet("Cover Sheet").Cell("K2").Value = "Creating Change Log: " + DateTime.Now;
                GenerateExcelChangeLog(workbook, docid, cdsid, OXODoc);
                workbook.Worksheet("Cover Sheet").Cell("L2").Value = "Finished Change Log: " + DateTime.Now;

                // model market matrix
                workbook.Worksheet("Cover Sheet").Cell("K3").Value = "Creating Model Market Matrix: " + DateTime.Now;
                GenerateExcelMBM(workbook, progid, docid, cdsid, OXODoc, ods, carModels, popDoc);
                workbook.Worksheet("Cover Sheet").Cell("L3").Value = "Finished Model Market Matrix: " + DateTime.Now;

                // reasons for rules
                workbook.Worksheet("Cover Sheet").Cell("K4").Value = "Creating Reasons for Rules: " + DateTime.Now;
                GenerateExcelRFR(workbook, progid, cdsid, OXODoc);
                workbook.Worksheet("Reasons for Rules").Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A21");
                workbook.Worksheet("Cover Sheet").Cell("L4").Value = "Finished Reasons for Rules: " + DateTime.Now;

                // global standard features
                workbook.Worksheet("Cover Sheet").Cell("K5").Value = "Creating Global Standard Features: " + DateTime.Now;
                GenerateExcelGSF(workbook, progid, docid, cdsid, OXODoc, ods, popDoc);
                workbook.Worksheet("Global Standard Features").Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A22");
                workbook.Worksheet("Cover Sheet").Cell("L5").Value = "Finished Global Standard Features: " + DateTime.Now;

                // world at a glance
                workbook.Worksheet("Cover Sheet").Cell("K6").Value = "Creating World At A Glance: " + DateTime.Now;
                GenerateExcelFBM(workbook, "World At A Glance", "Global Generic", progid, docid, "g", -1, cdsid, OXODoc, ods, carModels, "f", popDoc);
                workbook.Worksheet("World At A Glance").Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A23");
                workbook.Worksheet("Cover Sheet").Cell("A23").Hyperlink = new XLHyperlink("'World At A Glance'!A1");
                workbook.Worksheet("Cover Sheet").Cell("L6").Value = "Finished World At A Glance (core): " + DateTime.Now;

                // regions vs global generic - region variance
                workbook.Worksheet("Cover Sheet").Cell("K7").Value = "Creating Regions vs Global Generic: " + DateTime.Now;
                GenerateExcelFBM(workbook, "Regions vs Global Generic", "Global Generic", progid, docid, "g", -1, cdsid, OXODoc, ods, carModels, "f", popDoc);
                workbook.Worksheet("Regions vs Global Generic").Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A25");
                workbook.Worksheet("Cover Sheet").Cell("A25").Hyperlink = new XLHyperlink("'Regions vs Global Generic'!A1");
                workbook.Worksheet("Cover Sheet").Cell("L7").Value = "Finished Regions vs Global Generic (core): " + DateTime.Now;

                MarketGroupDataStore mg = new MarketGroupDataStore(cdsid);
                var marketGroups = mg.MarketGroupGetMany(progid, docid, true);

                int logRow = 8;
                int row = 25;
                int groupCol = modelCount + 8;

                foreach (var marketGroup in marketGroups)
                {
                    OXODocDataStore ds = new OXODocDataStore("system");
                    int availCount = ds.OXODocAvailableModelsByMarketGroup(progid, docid, marketGroup.Id).Where(p => p.Available == true).Count();

                    if (availCount > 0)
                    {
                        int marketCol = modelCount + 8;

                        string groupSheetName = marketGroup.GroupName + " Variance";

                        workbook.Worksheet("Cover Sheet").Cell(logRow, 11).Value = "Creating " + groupSheetName + ": " + DateTime.Now;

                        GenerateExcelFBM(workbook, groupSheetName, marketGroup.GroupName, progid, docid, "mg", marketGroup.Id, cdsid, OXODoc, ods, carModels, "v", popDoc);

                        workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished " + groupSheetName + " : " + DateTime.Now;

                        workbook.Worksheet(groupSheetName).Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A" + row);

                        // copy the market group to Regions vs Global Generic
                        workbook.Worksheet("Regions vs Global Generic").Cell(1, groupCol).Value = workbook.Worksheet(groupSheetName).Range(1, 7, workbook.Worksheet(groupSheetName).LastRowUsed().RowNumber(), modelCount + 7);
                        workbook.Worksheet("Regions vs Global Generic").Column(groupCol).Width = 8;
                        workbook.Worksheet("Regions vs Global Generic").Columns(groupCol + 1, groupCol + modelCount + 1).Width = 14;
                        // commented out as you can't un-group on a protected worksheet
                        //workbook.Worksheet("Regions vs Global Generic").Columns(groupCol + 1, groupCol + modelCount).Group();

                        // delete the group variance sheet as it's no longer required
                        workbook.Worksheet(groupSheetName).Delete();

                        // hide derivatives with no availability
                        HideNoDerivativeColumn(workbook.Worksheet("Regions vs Global Generic"), groupCol + 1);

                        groupCol = groupCol + modelCount + 1;
                        logRow = logRow + 1;
                        row = row + 1;
                    }
                }

                workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished Regions vs Global Generic (extended): " + DateTime.Now;

                // markets vs market group - variance

                logRow = logRow + 1;
                row = 26;
                groupCol = modelCount + 8;

                foreach (var marketGroup in marketGroups)
                {
                    OXODocDataStore ds = new OXODocDataStore("system");
                    int availGroupCount = ds.OXODocAvailableModelsByMarketGroup(progid, docid, marketGroup.Id).Where(p => p.Available == true).Count();

                    if (availGroupCount > 0)
                    {
                        int marketCol = modelCount + 8;

                        string groupSheetName = "Markets vs " + marketGroup.GroupName;

                        workbook.Worksheet("Cover Sheet").Cell(logRow, 11).Value = "Creating " + groupSheetName + ": " + DateTime.Now;

                        GenerateExcelFBM(workbook, groupSheetName, marketGroup.GroupName, progid, docid, "mg", marketGroup.Id, cdsid, OXODoc, ods, carModels, "f", popDoc);

                        // hide derivatives with no availability
                        HideNoDerivativeColumn(workbook.Worksheet(groupSheetName), 8);

                        workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished " + groupSheetName + " (core): " + DateTime.Now;

                        workbook.Worksheet(groupSheetName).Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A" + row);

                        // generate hyperlinks
                        workbook.Worksheet("Cover Sheet").Cell("A" + row).Value = groupSheetName;
                        workbook.Worksheet("Cover Sheet").Cell("B" + row).Value = "Details the specification variance at market level versus the region generic specification";
                        workbook.Worksheet("Cover Sheet").Cell("A" + row).Hyperlink = new XLHyperlink("'" + groupSheetName + "'!A1");

                        groupCol = groupCol + modelCount + 1;
                        logRow = logRow + 1;
                        row = row + 1;

                        var markets = marketGroup.Markets;

                        // markets
                        foreach (var market in markets)
                        {
                            int availMarketCount = ds.OXODocAvailableModelsByMarket(progid, docid, market.Id).Where(p => p.Available == true).Count();

                            if (availMarketCount > 0)
                            {
                                string marketSheetName = market.Name + " Variance";

                                workbook.Worksheet("Cover Sheet").Cell(logRow, 11).Value = "Creating " + marketSheetName + ": " + DateTime.Now;

                                GenerateExcelFBM(workbook, marketSheetName, market.Name, progid, docid, "m", market.Id, cdsid, OXODoc, ods, carModels, "v", popDoc);

                                // seperate KD models
                                int kdCount = ds.OXODocAvailableModelsByMarket(progid, docid, market.Id).Where(p => p.Available == true && p.KD == true).Count();
                                int kdSplit = 0;

                                if (kdCount > 0)
                                {
                                    SplitKD(workbook.Worksheet(marketSheetName), market.Name, 8);
                                    kdSplit = 1;
                                }

                                // copy the market to the market group
                                if (kdCount > 0)
                                {
                                    workbook.Worksheet(groupSheetName).Cell(1, marketCol).Value = workbook.Worksheet(marketSheetName).Range(1, 7, workbook.Worksheet(marketSheetName).LastRowUsed().RowNumber(), modelCount + 7 + kdSplit);
                                    workbook.Worksheet(groupSheetName).Column(marketCol).Width = 8;
                                    workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount + 1).Width = 14;
                                    workbook.Worksheet(groupSheetName).Column(marketCol + modelCount - kdCount + 1).Width = 8;
                                    // commented out as you can't un-group on a protected worksheet
                                    // workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount - kdCount).Group();
                                    // workbook.Worksheet(groupSheetName).Columns(marketCol + 1 + modelCount - kdCount + 1, marketCol + 1 + modelCount).Group();
                                }
                                else
                                {
                                    workbook.Worksheet(groupSheetName).Cell(1, marketCol).Value = workbook.Worksheet(marketSheetName).Range(1, 7, workbook.Worksheet(marketSheetName).LastRowUsed().RowNumber(), modelCount + 7);
                                    workbook.Worksheet(groupSheetName).Column(marketCol).Width = 8;
                                    workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount + 1).Width = 14;
                                    // commented out as you can't un-group on a protected worksheet
                                    // workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount).Group();
                                }

                                // delete the market variance sheet as it's no longer required
                                workbook.Worksheet(marketSheetName).Delete();

                                // hide derivatives with no availability
                                HideNoDerivativeColumn(workbook.Worksheet(groupSheetName), marketCol + 1);

                                marketCol = marketCol + modelCount + kdSplit + 1;

                                workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished " + marketSheetName + ": " + DateTime.Now;
                                logRow = logRow + 1;
                            }
                        }
                        workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished " + groupSheetName + " (extended): " + DateTime.Now;
                        logRow = logRow + 1;
                    }
                }

                workbook.Worksheet("Cover Sheet").Range(26, 1, row, 1).Style
                    .Alignment.SetIndent(6)
                    .Font.SetBold(true);

                row = row + 2;

                workbook.Worksheet("Cover Sheet").Cell(row, 1).Value = "Global Generic";
                workbook.Worksheet("Cover Sheet").Cell(row, 2).Value = "Details the full specifications for the global generic";

                row = row + 1;

                workbook.Worksheet("Cover Sheet").Cell(row, 1).Value = "Region X in Full";
                workbook.Worksheet("Cover Sheet").Cell(row, 2).Value = "Details the full specifications for the generic region";

                row = row + 1;

                workbook.Worksheet("Cover Sheet").Cell(row, 1).Value = "Market";
                workbook.Worksheet("Cover Sheet").Cell(row, 2).Value = "Details the full specifications for the individual market";

                row = row + 3;

                workbook.Worksheet("Cover Sheet").Cell(row, 1).Value = "Quick links to full specifications ;";

                workbook.Worksheet("Cover Sheet").Range(row - 5, 1, row, 1).Style
                    .Alignment.SetIndent(3)
                    .Font.SetBold(true);

                row = row + 2;

                int startRow = row;

                // global generic
                workbook.Worksheet("Cover Sheet").Cell(logRow, 11).Value = "Creating Global Generic: " + DateTime.Now;
                GenerateExcelFBM(workbook, "Global Generic", "Global Generic", progid, docid, "g", -1, cdsid, OXODoc, ods, carModels, "f", popDoc);
                workbook.Worksheet("Global Generic").Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A" + row);
                workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished Global Generic: " + DateTime.Now;
                workbook.Worksheet("Cover Sheet").Cell(row, 1).Value = "Global Generic";
                workbook.Worksheet("Cover Sheet").Cell(row, 1).Hyperlink = new XLHyperlink("'Global Generic'!A1");

                logRow = logRow + 1;
                row = row + 1;

                // markets vs market groups - in full

                groupCol = modelCount + 8;

                foreach (var marketGroup in marketGroups)
                {
                    OXODocDataStore ds = new OXODocDataStore("system");
                    int availCount = ds.OXODocAvailableModelsByMarketGroup(progid, docid, marketGroup.Id).Where(p => p.Available == true).Count();

                    if (availCount > 0)
                    {
                        int marketCol = modelCount + 8;

                        string groupSheetName = marketGroup.GroupName + " in Full";

                        workbook.Worksheet("Cover Sheet").Cell(logRow, 11).Value = "Creating " + groupSheetName + ": " + DateTime.Now;

                        GenerateExcelFBM(workbook, groupSheetName, marketGroup.GroupName, progid, docid, "mg", marketGroup.Id, cdsid, OXODoc, ods, carModels, "f", popDoc);

                        workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished " + groupSheetName + " (core): " + DateTime.Now;

                        workbook.Worksheet(groupSheetName).Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!A" + row);

                        // copy the market group to world at a glance
                        workbook.Worksheet("World At A Glance").Cell(1, groupCol).Value = workbook.Worksheet(groupSheetName).Range(1, 7, workbook.Worksheet(groupSheetName).LastRowUsed().RowNumber(), modelCount + 7);
                        workbook.Worksheet("World At A Glance").Column(groupCol).Width = 8;
                        workbook.Worksheet("World At A Glance").Columns(groupCol + 1, groupCol + modelCount + 1).Width = 14;
                        // commented out as you can't un-group on a protected worksheet
                        // workbook.Worksheet("World At A Glance").Columns(groupCol + 1, groupCol + modelCount).Group();

                        // hide derivatives with no availability
                        HideNoDerivativeColumn(workbook.Worksheet("World At A Glance"), groupCol + 1);

                        // generate hyperlinks
                        workbook.Worksheet("Cover Sheet").Cell("A" + row).Value = groupSheetName;
                        workbook.Worksheet("Cover Sheet").Cell("A" + row).Hyperlink = new XLHyperlink("'" + groupSheetName + "'!A1");

                        groupCol = groupCol + modelCount + 1;
                        logRow = logRow + 1;
                        row = row + 1;

                        var markets = marketGroup.Markets;

                        // markets
                        foreach (var market in markets)
                        {
                            int availMarketCount = ds.OXODocAvailableModelsByMarket(progid, docid, market.Id).Where(p => p.Available == true).Count();

                            if (availMarketCount > 0)
                            {
                                string marketSheetName = market.Name;

                                workbook.Worksheet("Cover Sheet").Cell(logRow, 11).Value = "Creating " + marketSheetName + ": " + DateTime.Now;
                                workbook.Worksheet("Cover Sheet").Cell("B" + row).Value = marketSheetName;
                                workbook.Worksheet("Cover Sheet").Cell("B" + row).Hyperlink = new XLHyperlink("'" + marketSheetName + "'!A1");

                                GenerateExcelFBM(workbook, marketSheetName, market.Name, progid, docid, "m", market.Id, cdsid, OXODoc, ods, carModels, "f", popDoc);
                                workbook.Worksheet(marketSheetName).Cell("A1").Hyperlink = new XLHyperlink("'Cover Sheet'!B" + row);

                                // seperate KD models
                                int kdSplit = 0;
                                int kdCount = ds.OXODocAvailableModelsByMarket(progid, docid, market.Id).Where(p => p.Available == true && p.KD == true).Count();

                                if (kdCount > 0)
                                {
                                    SplitKD(workbook.Worksheet(marketSheetName), market.Name, 8);
                                    kdSplit = 1;
                                }

                                // hide derivatives with no availability
                                HideNoDerivativeColumn(workbook.Worksheet(marketSheetName), 8);

                                // copy the market to the market group
                                if (kdCount > 0)
                                {
                                    workbook.Worksheet(groupSheetName).Cell(1, marketCol).Value = workbook.Worksheet(marketSheetName).Range(1, 7, workbook.Worksheet(marketSheetName).LastRowUsed().RowNumber(), modelCount + 7 + kdSplit);
                                    workbook.Worksheet(groupSheetName).Column(marketCol).Width = 8;
                                    workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount + 1).Width = 14;
                                    workbook.Worksheet(groupSheetName).Column(marketCol + modelCount - kdCount + 1).Width = 8;
                                    // commented out as you can't un-group on a protected worksheet
                                    // workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount - kdCount).Group();
                                    // workbook.Worksheet(groupSheetName).Columns(marketCol + 1 + modelCount - kdCount + 1, marketCol + 1 + modelCount).Group();
                                }
                                else
                                {
                                    workbook.Worksheet(groupSheetName).Cell(1, marketCol).Value = workbook.Worksheet(marketSheetName).Range(1, 7, workbook.Worksheet(marketSheetName).LastRowUsed().RowNumber(), modelCount + 7);
                                    workbook.Worksheet(groupSheetName).Column(marketCol).Width = 8;
                                    workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount + 1).Width = 14;
                                    // commented out as you can't un-group on a protected worksheet
                                    // workbook.Worksheet(groupSheetName).Columns(marketCol + 1, marketCol + modelCount).Group();
                                }

                                // hide derivatives with no availability
                                HideNoDerivativeColumn(workbook.Worksheet(groupSheetName), marketCol + 1);

                                marketCol = marketCol + modelCount + kdSplit + 1;

                                workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished " + marketSheetName + ": " + DateTime.Now;

                                logRow = logRow + 1;
                                row = row + 1;
                            }
                        }
                        // hide derivatives with no availability
                        HideNoDerivativeColumn(workbook.Worksheet(groupSheetName), 8);

                        workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished " + groupSheetName + " (extended): " + DateTime.Now;
                        logRow = logRow + 1;

                        row = row + 1;
                    }
                }

                workbook.Worksheet("Cover Sheet").Cell(logRow, 12).Value = "Finished World At A Glance (extended): " + DateTime.Now;
                logRow = logRow + 1;

                workbook.Worksheet("Cover Sheet").Range(startRow, 1, row, 1).Style
                    .Alignment.SetIndent(18)
                    .Font.SetBold(true);
                workbook.Worksheet("Cover Sheet").Range(startRow, 2, row, 2).Style
                    .Alignment.SetIndent(3)
                    .Font.SetBold(true);

                // cover sheet footer - need to do it here due to flexible number of market groups / markets
                workbook.Worksheet("Cover Sheet").Cell(row + 2, 1).Value = "This file is classified as follows according to the Global Marketing GIS1 matrix";
                workbook.Worksheet("Cover Sheet").Cell(row + 2, 1).Style.Font.SetBold(true);
                workbook.Worksheet("Cover Sheet").Cell(row + 3, 1).Value = "Record title:";
                workbook.Worksheet("Cover Sheet").Cell(row + 3, 2).Value = "Product & Marketing Brief";
                workbook.Worksheet("Cover Sheet").Cell(row + 4, 1).Value = "Security Classification:";
                workbook.Worksheet("Cover Sheet").Cell(row + 4, 2).Value = "CONFIDENTIAL";
                workbook.Worksheet("Cover Sheet").Cell(row + 5, 1).Value = "Retention period:";
                workbook.Worksheet("Cover Sheet").Cell(row + 5, 2).Value = "10 years";
                workbook.Worksheet("Cover Sheet").Cell(row + 6, 1).Value = "Retention Qualifers:";
                workbook.Worksheet("Cover Sheet").Cell(row + 6, 2).Value = "T";
                workbook.Worksheet("Cover Sheet").Range(row + 3, 1, row + 11, 1).Style
                    .Alignment.SetIndent(3)
                    .Font.SetBold(true);

                workbook.Worksheet("Cover Sheet").Columns(11, 12)
                    .Style.Font.SetFontSize(8)
                    .Font.SetFontName("Courier New");
                workbook.Worksheet("Cover Sheet").Columns(11, 12).Hide();

                DateTime end = DateTime.Now;

                workbook.Worksheet("Cover Sheet").Cell("A1").Comment.AddText("Time to export this OxO: " + (end - start).TotalMinutes + " minutes");

                stopWatch.Stop();
                var executionTime = stopWatch.ElapsedMilliseconds;
            }
            catch (Exception ex)
            {
                AppHelper.LogError("ExcelHelper.GenerateExcelOXO", ex.Message, "SYSTEM");
            }

            return workbook;
        }


        public static XLWorkbook GenerateExcelChangeSet(int progid, int docid, string cdsid)
        {
            Stopwatch stopWatch = new Stopwatch();
            XLWorkbook workbook = new XLWorkbook();

            try
            {
                stopWatch.Reset();
                stopWatch.Start();
                
                IXLWorksheet worksheet = workbook.Worksheets.Add("Change Set");
                worksheet.Protect("Password123")
                    .SetFormatColumns()
                    .SetFormatRows();
                worksheet.Style
                    .Fill.SetBackgroundColor(XLColor.White)
                    .Font.SetFontSize(11)
                    .Font.SetFontName("Arial");
                worksheet.TabColor = XLColor.Orange;

                // data
                OXODocDataStore ods = new OXODocDataStore(cdsid);
                var OXODoc = ods.OXODocGet(docid, progid);
                ChangeSetDataStore cds = new ChangeSetDataStore(cdsid);
                var changeSet = cds.ChangeSetDetailDownload(docid, progid);

                // page title
                worksheet.Cell("A1").Value = "CHANGE SET";
                worksheet.Cell("A2").Value = (OXODoc.VehicleName + " (" + OXODoc.VehicleAKA + ") " + OXODoc.ModelYear + " " + OXODoc.Status + " " + OXODoc.Gateway + " V" + OXODoc.VersionId).ToUpper();
                worksheet.Cell("A3").Value = DateTime.Now;
                worksheet.Cell("A4").Value = cdsid.ToUpper();
                worksheet.Range("A1:A4").Style.Font.SetBold()
                    .Font.SetFontSize(14)
                    .Alignment.Horizontal = XLAlignmentHorizontalValues.Left;

                // heading row
                worksheet.Cell("A6").Value = "Set Id";
                worksheet.Column("A").Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Left;
                worksheet.Cell("B6").Value = "Version Id";
                worksheet.Column("B").Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
                worksheet.Cell("C6").Value = "Reminder";
                worksheet.Cell("D6").Value = "Updated By";
                worksheet.Column("D").Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
                worksheet.Cell("E6").Value = "Last Updated";
                worksheet.Column("E").Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Left;
                worksheet.Cell("F6").Value = "Market Name";
                worksheet.Cell("G6").Value = "Model Name";
                worksheet.Cell("H6").Value = "Feature Name";
                worksheet.Cell("I6").Value = "Prev. Fitment";
                worksheet.Column("I").Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
                worksheet.Cell("J6").Value = "Curr. Fitment";
                worksheet.Column("J").Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
                worksheet.Range("A6:J6")
                         .Style.Font.SetBold(true)
                         .Font.SetFontColor(XLColor.White)
                         .Fill.SetBackgroundColor(XLColor.Black)
                         .Alignment.Vertical = XLAlignmentVerticalValues.Center;

                // output data
                int row = 7;

                foreach (var item in changeSet)
                {
                    worksheet.Cell(row, 1).Value = "'" + item.ChangeSetLabel;
                    worksheet.Cell(row, 2).Value = item.VersionLabel;
                    worksheet.Cell(row, 3).Value = item.Reminder;
                    worksheet.Cell(row, 4).Value = item.UpdatedBy;
                    worksheet.Cell(row, 5).Value = item.LastUpdatedLabel;
                    worksheet.Cell(row, 6).Value = item.MarketName;
                    worksheet.Cell(row, 7).Value = item.ModelName;
                    worksheet.Cell(row, 8).Value = item.FeatureName;
                    worksheet.Cell(row, 9).Value = item.PrevFitment;
                    worksheet.Cell(row, 10).Value = item.CurrFitment;

                    row = row + 1;
                }

                // adjust column widths
                worksheet.Columns().AdjustToContents();
                worksheet.Column(1).Width = 14;
                worksheet.Column(2).Width = 12;
                worksheet.Column(3).Width = 50;
                worksheet.Column(3).Style.Alignment.SetWrapText();
                worksheet.Column(4).Width = 13;
                worksheet.Column(5).Width = 17;
                worksheet.Column(6).Width = 20;
                worksheet.Column(7).Width = 40;
                worksheet.Column(7).Style.Alignment.SetWrapText();
                worksheet.Column(8).Width = 40;
                worksheet.Column(8).Style.Alignment.SetWrapText();
                worksheet.Column(9).Width = 16;
                worksheet.Column(10).Width = 16;

                // set border styles
                worksheet.Range(6, 1, worksheet.LastRowUsed().RowNumber(), 10).Style
                    .Border.SetTopBorder(XLBorderStyleValues.Thin)
                    .Border.SetRightBorder(XLBorderStyleValues.Thin)
                    .Border.SetOutsideBorder(XLBorderStyleValues.Thin);

                // split the screen
                worksheet.SheetView.Freeze(6, 0);

                stopWatch.Stop();
                var executionTime = stopWatch.ElapsedMilliseconds;
            }
            catch (Exception ex)
            {
                AppHelper.LogError("ExcelHelper.GenerateExcelChangeSet", ex.Message, "SYSTEM");
            }

            return workbook;
        }

        private static void HideNoDerivativeColumn(IXLWorksheet worksheet, int column)
        {
            const int row = 9;

            try
            {
                while (!worksheet.Cell(row, column).IsEmpty() || worksheet.Cell(row, column).Style.Fill.BackgroundColor == XLColor.Black)
                {
                    if (worksheet.Cell(row, column).GetString() == "NO")
                    {
                        worksheet.Column(column).Hide();
                    }
                    column = column + 1;
                }
            }
            catch (Exception ex)
            {
                AppHelper.LogError("ExcelHelper.HideNoDerivativeColumn", ex.Message, "SYSTEM");
            }

        }

        private static bool SplitKD(IXLWorksheet worksheet, string title, int column)
        {
            // row to scan for KD
            const int row = 6;

            try
            {
                while (!worksheet.Cell(row, column).IsEmpty())
                {
                    // scan for first KD derivative in TRIM LEVEL row
                    if (worksheet.Cell(row, column).GetString().EndsWith("KD"))
                    {
                        // remove existing column grouping - commented out as grouping no longer applied as you can't un-group on a protected worksheet
                        // worksheet.Columns(8, worksheet.LastColumnUsed().ColumnNumber()).Ungroup();
                        // add KD SPEC GROUP heading
                        worksheet.Cell(1, column).Value = title.ToUpper() + " KD";
                        // insert and size new divider column before KD derivatives
                        worksheet.Column(column).InsertColumnsBefore(1);
                        worksheet.Column(column).Width = 8;
                        // group non-KD derivatives - commented out as you can't un-group on a protected worksheet
                        // worksheet.Columns(8, column - 1).Group();
                        // merge non-KD SPEC GROUP heading
                        worksheet.Range(1, 8, 1, column - 1).Merge();
                        // group KD derivatives - commented out as you can't un-group on a protected worksheet
                        // worksheet.Columns(column + 1, worksheet.LastColumnUsed().ColumnNumber()).Group();
                        // merge KD SPEC GROUP heading
                        worksheet.Range(1, column + 1, 1, worksheet.LastColumnUsed().ColumnNumber()).Merge();
                        // add vertical KD title
                        worksheet.Cell(1, column).Value = title.ToUpper() + " KD";
                        // merge and format vertical divider heading
                        worksheet.Range(1, column, 9, column).Merge();
                        worksheet.Range(1, column, worksheet.LastRowUsed().RowNumber(), column).Style
                            .Font.SetBold(true)
                            .Font.SetFontColor(XLColor.White)
                            .Fill.SetBackgroundColor(XLColor.Black)
                            .Alignment.SetVertical(XLAlignmentVerticalValues.Bottom)
                            .Alignment.SetTextRotation(90);
                        // do for first KD derivative then break out
                        return true;
                    }
                    column = column + 1;
                }
                return false;
            }
            catch (Exception ex)
            {
                AppHelper.LogError("ExcelHelper.SplitKD", ex.Message, "SYSTEM");
                return false;
            }

        }

    }
}
