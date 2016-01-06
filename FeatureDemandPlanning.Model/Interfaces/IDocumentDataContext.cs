namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IDocumentDataContext
    {
        int ValidateXclDoc(int id, string mode, int progid, int objectId);
        void GetConfiguration(OXODoc doc);
        bool Export(OXODoc documentToExport, string comment, string PACN);
    }
}
