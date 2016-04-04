using System;
using System.Collections.Generic;
using FluentValidation;
using System.Data;
using System.Globalization;
using System.Linq;

namespace FeatureDemandPlanning.Model.Validators
{
    /// <summary>
    /// Sanity check validation to ensure that the import PPO data conforms to the agreed format
    /// </summary>
    public class ImportDataValidator : AbstractValidator<ImportQueue>
    {
        public int MinimumColumnCount { get; set; }
        public int ActualColumnCount { get; set; }
        public int LineNumber { get; set; }
        
        public IList<KeyValuePair<int, string>> MissingColumns { get; set; }
        public IList<KeyValuePair<int, string>> UnexpectedColumns { get; set; }
        public IEnumerable<KeyValuePair<int, string>> ActualColumns { get; set; }

        public IDictionary<int, string> ColumnOrder { get; set; }

        public ImportDataValidator()
        {
            MinimumColumnCount = 10;
            ActualColumnCount = 0;
            LineNumber = 0;
            MissingColumns = new List<KeyValuePair<int, string>>();
            UnexpectedColumns = new List<KeyValuePair<int, string>>();
            SetColumnOrder();

            CascadeMode = CascadeMode.StopOnFirstFailure;

            RuleFor(i => i.ImportData)
                .NotNull()
                .WithMessage("Import data is empty");

            RuleFor(i => i)
                .Cascade(CascadeMode.StopOnFirstFailure)
                .Must(HaveCorrectNumberOfColumns)
                .WithMessage(string.Format("Incorrect number of columns in import data, expected {0}",
                    MinimumColumnCount))
                .Must(i => HaveColumn(i, ColumnOrder[0]))
                .WithMessage(string.Format("Missing Column '{0}' at position {1}", ColumnOrder[0], 1))
                .Must(i => HaveColumn(i, ColumnOrder[1]))
                .WithMessage(string.Format("Missing Column '{0}' at position {1}", ColumnOrder[1], 2))
                .Must(i => HaveColumn(i, ColumnOrder[2]))
                .WithMessage(string.Format("Missing Column '{0}' at position {1}", ColumnOrder[2], 3))
                .Must(i => HaveColumn(i, ColumnOrder[3]))
                .WithMessage(string.Format("Missing Column '{0}' at position {1}", ColumnOrder[3], 4))
                .Must(i => HaveColumn(i, ColumnOrder[4]))
                .WithMessage(string.Format("Missing Column '{0}' at position {1}", ColumnOrder[4], 5))
                .Must(i => HaveColumn(i, ColumnOrder[5]))
                .WithMessage(string.Format("Missing Column '{0}' at position {1}", ColumnOrder[5], 6))
                .Must(i => HaveColumn(i, ColumnOrder[6]))
                .WithMessage(string.Format("Missing Column '{0}' at position {1}", ColumnOrder[6], 7))
                .Must(i => HaveColumn(i, ColumnOrder[7]))
                .WithMessage(string.Format("Missing Column '{0}' at position {1}", ColumnOrder[7], 8))
                .Must(i => HaveColumn(i, ColumnOrder[8]))
                .WithMessage(string.Format("Missing Column '{0}' at position {1}", ColumnOrder[8], 9))
                .Must(i => HaveColumn(i, ColumnOrder[9]))
                .WithMessage(string.Format("Missing Column '{0}' at position {1}", ColumnOrder[9], 10))
                .Must(HaveNoMissingData)
                .WithMessage("Import data contains empty values")
                .WithState(i => "LINE:" + (LineNumber + 4).ToString())
                .Must(HaveValidVolumeData)
                .WithMessage("Volume data at position 10 must be numeric")
                .WithState(i => "LINE:" + (LineNumber + 4).ToString());
        }
        private void SetColumnOrder()
        {
            ColumnOrder = new Dictionary<int, string>()
            {
                { 0, "Pipeline Code" },
                { 1, "Model Year Desc" },
                { 2, "NSC or Importer Description (Vista Market)" },
                { 3, "Country Description" },
                { 4, "Derivative Code" },
                { 5, "Derivative Description" },
                { 6, "Trim Pack Description" },
                { 7, "Bff Feature Code" },
                { 8, "Feature Desc" },
                { 9, "Count of Specific Order No" }
            };   
        }
        private void SetColumnCount(ImportQueue queuedItem)
        {
            if (queuedItem.ImportData == null)
                return;

            ActualColumnCount = queuedItem.ImportData.Columns.Count;
        }
        private bool HaveCorrectNumberOfColumns(ImportQueue queuedItem)
        {
            SetColumnCount(queuedItem);
            
            return ActualColumnCount == MinimumColumnCount;
        }
        private bool HaveNoMissingData(ImportQueue queuedItem)
        {
            LineNumber = 1;
          
            foreach (DataRow row in queuedItem.ImportData.Rows)
            {
                foreach (var item in row.ItemArray)
                {
                    if (string.IsNullOrEmpty(item.ToString()))
                    {
                        return false;
                    }
                }

                LineNumber++;
            }
            return true;
        }

        //private bool HaveNoUnexpectedColumns(ImportQueue queuedItem)
        //{
        //    if (queuedItem.ImportData == null)
        //        return false;

        //    var columnIndex = 0;
        //    foreach (DataColumn column in queuedItem.ImportData.Columns)
        //    {
        //        if (!column.ColumnName.Equals(ColumnOrder[columnIndex], StringComparison.OrdinalIgnoreCase))
        //        {
        //            UnexpectedColumns.Add(new KeyValuePair<int, string>(columnIndex, column.ColumnName));
        //        }
        //        columnIndex++;
        //    }

        //    return UnexpectedColumns.Count > 0;
        //}
        private static bool HaveColumn(ImportQueue queuedItem, string columnName)
        {
            if (queuedItem.ImportData == null)
                return false;

            return queuedItem.ImportData.Columns.Contains(columnName);
        }
        private bool HaveValidVolumeData(ImportQueue queuedItem)
        {
            LineNumber = 1;
            const int volumeDataIndex = 9;

            foreach (DataRow row in queuedItem.ImportData.Rows)
            {
                try
                {
                    var numberFormat = new NumberFormatInfo {NumberGroupSeparator = ","};

                    int.Parse(row.ItemArray[volumeDataIndex].ToString(),
                        NumberStyles.AllowThousands, numberFormat);
                }
                catch
                {
                    return false;
                }

                LineNumber++;
            }
            return true;
        }
        private string GetMissingColumnError()
        {
            if (!MissingColumns.Any())
                return "No missing columns"; // Would rather return string.Empty, but that breaks the validation, as WithMessage cannot be empty

            var firstMissingColumn = MissingColumns.First();

            return string.Format("Missing column '{0}' at position {1}", firstMissingColumn.Value,
                firstMissingColumn.Key + 1);
        }
        private string GetUnexpectedColumnError()
        {
            if (!UnexpectedColumns.Any())
                return "No unexpected columns"; // Would rather return string.Empty, but that breaks the validation, as WithMessage cannot be empty

            var firstUnexpectedColumn = UnexpectedColumns.First();

            return string.Format("Unexpected column '{0}' at position {1}", firstUnexpectedColumn.Value,
                firstUnexpectedColumn.Key + 1);
        }
    }
}
