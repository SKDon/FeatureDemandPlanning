using ClosedXML.Excel;
using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Helpers;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.IO;

namespace FeatureDemandPlanning.DataStore
{
    public class DocumentDataContext : BaseDataContext, IDocumentDataContext
    {
        private OXODocDataStore _documentDataStore = null;
        private OXOProgrammeFileDataStore _programmeFileDataStore = null;
        
        public DocumentDataContext(string cdsId) : base(cdsId)
        {
            _documentDataStore = new OXODocDataStore(cdsId);
            _programmeFileDataStore = new OXOProgrammeFileDataStore(cdsId);
        }

        public bool Export(OXODoc documentToExport, string comment, string PACN)
        {
            var retVal = false;

            XLWorkbook workbook = ClosedXmlExcelGenerator.GenerateExcelOXO(documentToExport.ProgrammeId, documentToExport.Id, CDSID, true);

            OXOProgrammeFile file = new OXOProgrammeFile();
            file.ProgrammeId = documentToExport.ProgrammeId;
            file.FileCategory = ProgrammFileCategory.Publish.ToString();
            file.FileComment = comment;
            file.PACN = PACN;
            file.FileName = String.Format("{0} {1} {2} {3} v{4}.{5} {6}.xlsx", 
                documentToExport.VehicleName, 
                documentToExport.VehicleAKA, 
                documentToExport.ModelYear, 
                documentToExport.Gateway, 
                documentToExport.VersionMajor, 
                documentToExport.VersionMinor, 
                documentToExport.Status);
            file.FileType = "application/vnd.open";
            file.FileExt = "xlsx";
            file.Gateway = documentToExport.Gateway;
            MemoryStream m = new MemoryStream();
            workbook.SaveAs(m);
            file.FileContent = m.ToArray();
            file.FileSize = file.FileContent.Length;
            _programmeFileDataStore.OXOProgrammeFileSave(file);

            retVal = true;

            return retVal;
        }

        
        public int ValidateXclDoc(int id, string mode, int progid, int objectId)
        {
            int retval = _documentDataStore.OXODocValidateEFG(id, progid);
            retval = retval + _documentDataStore.OXODocValidateEmptyCells(id, progid);
            return retval;
        }

        public void GetConfiguration(OXODoc doc)
        {
            var ds = new OXODocDataStore("system");
            ds.DocGetConfiguration(doc);
        }
    }
}
