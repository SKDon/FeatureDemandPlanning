using System.Web;
using System.Web.Optimization;

namespace FeatureDemandPlanning
{
    public static class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            if (bundles == null)
                return;

            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js",
                        "~/Scripts/jquery-ui-{version}.js",
                        //"~/Extensions/DataTables-1.10.7/media/js/jquery.dataTables.js",
                        //"~/Extensions/DataTables-1.10.7/plugins/jquery.dataTables.columnFilter.js",
                        "~/Extensions/Jeditable/jquery.jeditable.mini.js",
                        "~/Extensions/malihu-custom-scrollbar-plugin-master/jquery.mCustomScrollbar.concat.min.js",
                        "~/Extensions/jquery.dataTables.rowGrouping/jquery.dataTables.rowGrouping.js",
                        "~/Extensions/jquery.nivo.slider/jquery.nivo.slider.js",
                        "~/Scripts/jquery.dataTables.fixColumn.js",
                        "~/Scripts/jquery.dataTables.js",
                        "~/Scripts/jquery.dataTables.grouping.mnh.js",
                        "~/Extensions/dataTables.bootstrap/dataTables.bootstrap.js",
                        "~/Scripts/jquery.cookie.js",
                        "~/Scripts/jquery.tipsy.js",
                        "~/Scripts/jquery.simplePager.js",
                        "~/Scripts/jquery.smartmenu.js",
                        "~/Scripts/jquery.mouseWheel.js",
                        "~/Scripts/jqueryFileTree.js"));

            bundles.Add(new ScriptBundle("~/bundles/shared").Include(
                        "~/Scripts/Shared/taffy.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.validate*"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryform").Include(
                        "~/Scripts/jquery.form.min.js"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                      "~/Scripts/bootstrap.js",
                      "~/Scripts/respond.js",
                      "~/Scripts/bootstrap-slider.js"));

            bundles.Add(new ScriptBundle("~/bundles/Forecast")
                .Include("~/Scripts/Forecast/vehicle.js",
                         "~/Scripts/Forecast/forecast.js"));

            bundles.Add(new StyleBundle("~/Content/css").Include(
                      "~/Content/bootstrap.css",
                      "~/Content/site.css",
                      "~/Content/Editor/oxo-editor.css",
                      "~/Content/BrushedMetal.css",
                      "~/Content/jquery.tipsy.css",
                      "~/Content/jquery.simplePager.css",
                      "~/Extensions/dataTables.bootstrap/dataTables.bootstrap.css",
                      "~/Extensions/malihu-custom-scrollbar-plugin-master/jquery.mCustomScrollbar.css",
                      "~/Extensions/nivo-slider/nivo-slider.css",
                      "~/Content/bootstrap-slider.css"));

        }
    }
}
