using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects.Context
{
    [DataContract]
    public class PagedResults<T>
    {
        [DataMember(Name = "sEcho")]
        public int Echo { get { return 1; } }
        
        [DataMember(Name = "aaData")]
        public IEnumerable<T> CurrentPage { get; set; }

        [IgnoreDataMember]
        public int TotalPages
        {
            get
            {
                return (int)Math.Ceiling((decimal)TotalRecords / PageSize);
            }
        }

        [DataMember(Name = "iTotalRecords")]
        public int TotalRecords { get; set; }
        
        [IgnoreDataMember]
        public int PageIndex { get; set; }

        [DataMember(Name = "iTotalDisplayRecords")]
        public int PageSize { get { return _pageSize; } set { _pageSize = value; } }

        public PagedResults()
        {
            CurrentPage = new List<T>();
        }

        public PagedResults(IEnumerable<T> currentPage)
        {
            CurrentPage = currentPage;
        }

        private int _pageSize = Int32.MaxValue;
    }
}