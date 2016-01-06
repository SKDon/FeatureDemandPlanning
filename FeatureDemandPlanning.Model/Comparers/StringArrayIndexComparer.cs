using System.Collections.Generic;

namespace FeatureDemandPlanning.Model.Comparers
{
    public class StringArrayIndexComparer : IComparer<string[]>
    {
        public StringArrayIndexComparer(int sortIndex, bool descending)
        {
            _sortIndex = sortIndex;
            _descending = descending;
        }

        public int Compare(string[] x, string[] y)
        {
            if (_descending)
            {
                return y[_sortIndex].CompareTo(x[_sortIndex]);
            }
            else
            {
                return x[_sortIndex].CompareTo(y[_sortIndex]);
            }
        }

        private int _sortIndex = 0;
        private bool _descending = false;
    }
}
