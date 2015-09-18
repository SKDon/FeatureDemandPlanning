using System.Web;
using System.Web.Optimization;

namespace FeatureDemandPlanning
{
    public class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.validate*"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryform").Include(
                        "~/Scripts/jquery.form.min.js"));

            bundles.Add(new ScriptBundle("~/bundles/jquery.dataTables").Include(
                        "~/Extensions/DataTables-1.10.7/media/js/jquery.dataTables.js",
                        "~/Extensions/DataTables-1.10.7/plugins/jquery.dataTables.columnFilter.js",
                        "~/Extensions/Jeditable/jquery.jeditable.mini.js",
                        "~/Extensions/dataTables.bootstrap/dataTables.bootstrap.js",
                        "~/Extensions/malihu-custom-scrollbar-plugin-master/jquery.mCustomScrollbar.concat.min.js"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                      "~/Scripts/bootstrap.js",
                      "~/Scripts/respond.js"));

            bundles.Add(new ScriptBundle("~/bundles/Forecast")
                .Include("~/Scripts/Forecast/vehicle.js",
                         "~/Scripts/Forecast/forecast.js"));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                      "~/Content/bootstrap.css",
                      "~/Content/site.css",
                      "~/Content/BrushedMetal.css",
                      "~/Extensions/dataTables.bootstrap/dataTables.bootstrap.css",
                      "~/Extensions/malihu-custom-scrollbar-plugin-master/jquery.mCustomScrollbar.css"));

        }
    }
}
