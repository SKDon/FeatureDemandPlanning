using FeatureDemandPlanning.BusinessObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Interfaces
{
    public interface IDocumentDataContext
    {
        int ValidateXclDoc(int id, string mode, int progid, int objectId);
        void GetConfiguration(OXODoc doc);
        bool Export(OXODoc documentToExport, string comment, string PACN);
    }
}
