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
                        "~/Scripts/jquery-ui-{version}.js"
                        ));

            bundles.Add(new ScriptBundle("~/bundles/shared"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new ScriptBundle("~/bundles/js/bootstrap").Include(
                "~/Content/Bootstrap/js/bootstrap.min.js",
                "~/Scripts/bootstrap-slider.js"));

            bundles.Add(new StyleBundle("~/bundles/css/bootstrap").Include(
                "~/Content/Bootstrap/css/bootstrap.css",
                "~/Content/Responsive/css/responsive.bootstrap.min.css",
                "~/Content/bootstrap-slider.css"
                ));                     

            bundles.Add(new ScriptBundle("~/bundles/Forecast")
                .Include("~/Scripts/Forecast/vehicle.js",
                         "~/Scripts/Forecast/forecast.js"));

            bundles.Add(new StyleBundle("~/bundles/site/css").Include(
                      "~/Content/css/site.css",
                      "~/Content/css/BrushedMetal.css"
                      ));

            bundles.Add(new ScriptBundle("~/bundles/js/dataTables").Include(
                    "~/Content/DataTables/js/jquery.dataTables.js",
                    "~/Content/DataTables/js/dataTables.bootstrap.min.js",
                    "~/Content/DataTables/js/dataTables.fixedColumns.min.js",
                    "~/Content/DataTables/js/jquery.dataTables.rowGrouping.js",
                    "~/Content/Responsive/js/dataTables.responsive.min.js"
                ));

            bundles.Add(new StyleBundle("~/bundles/css/dataTables").Include(
                    "~/Content/DataTables/css/dataTables.bootstrap.min.css",
                    "~/Content/Responsive/css/responsive.dataTables.min.css"
                ));
        }
    }
}
