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

            bundles.Add(new ScriptBundle("~/bundles/js/jquery").Include(
                        "~/Content/js/jquery-1.12.0.js",
                        "~/Content/js/jquery.jeditable.js",
                        "~/Content/js/jquery.spin.js"));

            bundles.Add(new ScriptBundle("~/bundles/js/bootstrap").Include(
                "~/Content/js/bootstrap.js"));

            bundles.Add(new ScriptBundle("~/bundles/js/dataTables").Include(
                    "~/Content/js/jquery.dataTables.js",
                    "~/Content/js/dataTables.bootstrap.js",
                    "~/Content/js/dataTables.fixedColumns.js",
                    "~/Content/js/jquery.dataTables.rowGrouping.js",
                    "~/Content/js/dataTables.responsive.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/admin").Include(
                    "~/Content/js/Admin/admin.js",
                    "~/Content/js/Admin/enginecodemapping.js",
                    "~/Content/js/Admin/enginecodemappingpage.js",
                    "~/Content/js/Admin/market.js",
                    "~/Content/js/Admin/model.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/derivative").Include(
                    "~/Content/js/Derivative/delete.js",
                    "~/Content/js/Derivative/model.js",
                    "~/Content/js/Derivative/page.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/derivativemapping").Include(
                    "~/Content/js/DerivativeMapping/copy.js",
                    "~/Content/js/DerivativeMapping/delete.js",
                    "~/Content/js/DerivativeMapping/model.js",
                    "~/Content/js/DerivativeMapping/page.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/feature").Include(
                    "~/Content/js/Feature/delete.js",
                    "~/Content/js/Feature/model.js",
                    "~/Content/js/Feature/page.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/featuremapping").Include(
                    "~/Content/js/FeatureMapping/copy.js",
                    "~/Content/js/FeatureMapping/delete.js",
                    "~/Content/js/FeatureMapping/model.js",
                    "~/Content/js/FeatureMapping/page.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/ignoredexception").Include(
                    "~/Content/js/IgnoredException/delete.js",
                    "~/Content/js/IgnoredException/model.js",
                    "~/Content/js/IgnoredException/page.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/import").Include(
                    "~/Content/js/Import/addderivativeaction.js",
                    "~/Content/js/Import/addfeatureaction.js",
                    "~/Content/js/Import/addtrimaction.js",
                    "~/Content/js/Import/derivative.js",
                    "~/Content/js/Import/exceptions.js",
                    "~/Content/js/Import/exceptionspage.js",
                    "~/Content/js/Import/feature.js",
                    "~/Content/js/Import/ignore.js",
                    "~/Content/js/Import/ignoreaction.js",
                    "~/Content/js/Import/importqueue.js",
                    "~/Content/js/Import/importqueuepage.js",
                    "~/Content/js/Import/mapderivativeaction.js",
                    "~/Content/js/Import/mapfeatureaction.js",
                    "~/Content/js/Import/mapmarketaction.js",
                    "~/Content/js/Import/maptrimaction.js",
                    "~/Content/js/Import/market.js",
                    "~/Content/js/Import/specialfeatureaction.js",
                    "~/Content/js/Import/trim.js",
                    "~/Content/js/Import/upload.js",
                    "~/Content/js/Import/uploadaction.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/marketmapping").Include(
                    "~/Content/js/MarketMapping/copy.js",
                    "~/Content/js/MarketMapping/delete.js",
                    "~/Content/js/MarketMapping/model.js",
                    "~/Content/js/MarketMapping/page.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/marketreview").Include(
                    "~/Content/js/MarketReview/model.js",
                    "~/Content/js/MarketReview/page.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/shared").Include(
                    "~/Content/js/Shared/namespace.js",
                    "~/Content/js/Shared/modal.js",
                    "~/Content/js/Shared/contextmenu.js",
                    "~/Content/js/Shared/cookie.js",
                    "~/Content/js/Shared/pager.js",
                    "~/Content/js/Shared/vehicle.js",
                    "~/Content/js/Shared/takeratefilter.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/specialfeaturemapping").Include(
                    "~/Content/js/SpecialFeatureMapping/copy.js",
                    "~/Content/js/SpecialFeatureMapping/delete.js",
                    "~/Content/js/SpecialFeatureMapping/model.js",
                    "~/Content/js/SpecialFeatureMapping/page.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/takerate").Include(
                    "~/Content/js/TakeRate/model.js",
                    "~/Content/js/TakeRate/page.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/takeratedata").Include(
                    "~/Content/js/TakeRateData/addnote.js",
                    "~/Content/js/TakeRateData/addnoteaction.js",
                    "~/Content/js/TakeRateData/changeset.js",
                    "~/Content/js/TakeRateData/details.js",
                    "~/Content/js/TakeRateData/filter.js",
                    "~/Content/js/TakeRateData/filteraction.js",
                    "~/Content/js/TakeRateData/history.js",
                    "~/Content/js/TakeRateData/historyaction.js",
                    "~/Content/js/TakeRateData/marketreview.js",
                    "~/Content/js/TakeRateData/marketreviewaction.js",
                    "~/Content/js/TakeRateData/model.js",
                    "~/Content/js/TakeRateData/page.js",
                    "~/Content/js/TakeRateData/save.js",
                    "~/Content/js/TakeRateData/saveaction.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/Forecast")
                .Include("~/Content/js/Forecast/vehicle.js",
                         "~/Content/js/Forecast/forecast.js"));

            bundles.Add(new ScriptBundle("~/bundles/js/trim").Include(
                    "~/Content/js/Trim/delete.js",
                    "~/Content/js/Trim/model.js",
                    "~/Content/js/Trim/page.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/trimmapping").Include(
                    "~/Content/js/TrimMapping/copy.js",
                    "~/Content/js/TrimMapping/delete.js",
                    "~/Content/js/TrimMapping/model.js",
                    "~/Content/js/TrimMapping/page.js"
                ));

            bundles.Add(new ScriptBundle("~/bundles/js/user").Include(
                    "~/Content/js/User/addnewuseraction.js",
                    "~/Content/js/User/disableuseraction.js",
                    "~/Content/js/User/enableuseraction.js",
                    "~/Content/js/User/manageprogrammesaction.js",
                    "~/Content/js/User/setadministratoraction.js",
                    "~/Content/js/User/unsetadministratoraction.js",
                    "~/Content/js/User/model.js",
                    "~/Content/js/User/page.js"
                ));

            var cssFixer = new CssRewriteUrlTransformFixed();

            bundles.Add(new StyleBundle("~/bundles/css")
                .Include("~/Content/css/bootstrap.css", cssFixer)
                .Include("~/Content/css/responsive.bootstrap.css", cssFixer)
                .Include("~/Content/css/site.css", cssFixer)
                .Include("~/Content/css/BrushedMetal.css", cssFixer));

            bundles.Add(new StyleBundle("~/bundles/css/dataTables").Include(
                    "~/Content/css/dataTables.bootstrap.css",
                    "~/Content/css/responsive.dataTables.css"
                ));
        }
    }
}
