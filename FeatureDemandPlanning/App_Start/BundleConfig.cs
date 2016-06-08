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

            bundles.Add(new ScriptBundle("~/Content/js/jquery").Include(
                        "~/Content/js/jquery-1.12.0.js",
                        "~/Content/js/jquery.jeditable.js",
                        "~/Content/js/jquery.spin.js",
                        "~/Content/js/jquery.contextMenu.js",
                        "~/Content/js/jcookies.js",
                        "~/Content/js/typeahead.bundle.js"));

            bundles.Add(new ScriptBundle("~/Content/js/bootstrap").Include(
                "~/Content/js/bootstrap.js"));

            bundles.Add(new ScriptBundle("~/Content/js/dataTables").Include(
                    "~/Content/js/jquery.dataTables.js",
                    "~/Content/js/dataTables.bootstrap.js",
                    "~/Content/js/dataTables.fixedColumns.js",
                    "~/Content/js/dataTables.fixedHeader.min.js",
                    "~/Content/js/jquery.dataTables.rowGrouping.js",
                    "~/Content/js/dataTables.responsive.js",
                    "~/Content/js/dataTables.scroller.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/bootstrapmultiselect").Include(
                    "~/Content/js/bootstrap-multiselect.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/adminbundle").Include(
                    "~/Content/js/Admin/admin.js",
                    "~/Content/js/Admin/enginecodemapping.js",
                    "~/Content/js/Admin/enginecodemappingpage.js",
                    "~/Content/js/Admin/market.js",
                    "~/Content/js/Admin/model.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/derivativebundle").Include(
                    "~/Content/js/Shared/contextmenu.js",
                    "~/Content/js/Derivative/delete.js",
                    "~/Content/js/Derivative/model.js",
                    "~/Content/js/Derivative/page.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/derivativemappingbundle").Include(
                    "~/Content/js/Shared/contextmenu.js",
                    "~/Content/js/DerivativeMapping/copy.js",
                    "~/Content/js/DerivativeMapping/delete.js",
                    "~/Content/js/DerivativeMapping/bmc.js",
                    "~/Content/js/DerivativeMapping/model.js",
                    "~/Content/js/DerivativeMapping/page.js",
                    "~/Content/js/DerivativeMapping/bmcpage.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/featurebundle").Include(
                    "~/Content/js/Shared/contextmenu.js",
                    "~/Content/js/Feature/delete.js",
                    "~/Content/js/Feature/model.js",
                    "~/Content/js/Feature/page.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/featuremappingbundle").Include(
                    "~/Content/js/Shared/contextmenu.js",
                    "~/Content/js/FeatureMapping/copy.js",
                    "~/Content/js/FeatureMapping/delete.js",
                    "~/Content/js/FeatureMapping/model.js",
                    "~/Content/js/FeatureMapping/page.js",
                     "~/Content/js/FeatureMapping/featurecode.js",
                    "~/Content/js/FeatureMapping/featurecodepage.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/ignoredexceptionbundle").Include(
                    "~/Content/js/Shared/contextmenu.js",
                    "~/Content/js/IgnoredException/delete.js",
                    "~/Content/js/IgnoredException/model.js",
                    "~/Content/js/IgnoredException/page.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/importbundle").Include(
                    "~/Content/js/Import/addderivativeaction.js",
                    "~/Content/js/Import/addfeatureaction.js",
                    "~/Content/js/Import/addtrimaction.js",
                    "~/Content/js/Shared/contextmenu.js",
                    "~/Content/js/Import/derivative.js",
                    "~/Content/js/Import/deleteimportaction.js",
                    "~/Content/js/Import/exceptions.js",
                    "~/Content/js/Import/exceptionspage.js",
                    "~/Content/js/Import/feature.js",
                    "~/Content/js/Import/ignore.js",
                    "~/Content/js/Import/ignoreaction.js",
                    "~/Content/js/Import/ignoreallaction.js",
                    "~/Content/js/Import/importqueue.js",
                    "~/Content/js/Import/importqueuepage.js",
                    "~/Content/js/Import/mapoxoderivativeaction.js",
                    "~/Content/js/Import/mapderivativeaction.js",
                    "~/Content/js/Import/mapfeatureaction.js",
                    "~/Content/js/Import/mapoxofeatureaction.js",
                    "~/Content/js/Import/mapmarketaction.js",
                    "~/Content/js/Import/maptrimaction.js",
                    "~/Content/js/Import/mapoxotrimaction.js",
                    "~/Content/js/Import/market.js",
                    "~/Content/js/Import/process.js",
                    "~/Content/js/Import/processdataaction.js",
                    "~/Content/js/Import/specialfeatureaction.js",
                    "~/Content/js/Import/trim.js",
                    "~/Content/js/Import/upload.js",
                    "~/Content/js/Import/uploadaction.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/marketmappingbundle").Include(
                    "~/Content/js/Shared/contextmenu.js",
                    "~/Content/js/MarketMapping/copy.js",
                    "~/Content/js/MarketMapping/delete.js",
                    "~/Content/js/MarketMapping/model.js",
                    "~/Content/js/MarketMapping/page.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/marketreviewbundle").Include(
                    "~/Content/js/Shared/contextmenu.js",
                    "~/Content/js/MarketReview/model.js",
                    "~/Content/js/MarketReview/page.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/publishbundle").Include(
                    "~/Content/js/Shared/contextmenu.js",
                    "~/Content/js/Publish/model.js",
                    "~/Content/js/Publish/page.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/sharedbundle").Include(
                    "~/Content/js/Shared/namespace.js",
                    "~/Content/js/Shared/modal.js",
                    "~/Content/js/Shared/cookie.js",
                    "~/Content/js/Shared/pager.js",
                    "~/Content/js/Shared/vehicle.js",
                    "~/Content/js/Shared/takeratefilter.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/specialfeaturemappingbundle").Include(
                    "~/Content/js/Shared/contextmenu.js",
                    "~/Content/js/SpecialFeatureMapping/copy.js",
                    "~/Content/js/SpecialFeatureMapping/delete.js",
                    "~/Content/js/SpecialFeatureMapping/model.js",
                    "~/Content/js/SpecialFeatureMapping/page.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/takeratebundle").Include(
                    "~/Content/js/Shared/contextmenu.js",
                    "~/Content/js/TakeRate/model.js",
                    "~/Content/js/TakeRate/page.js",
                    "~/Content/js/TakeRate/clone.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/takeratedatabundle").Include(
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
                    "~/Content/js/TakeRateData/powertrain.js",
                    "~/Content/js/TakeRateData/powertrainaction.js",
                    "~/Content/js/TakeRateData/publish.js",
                    "~/Content/js/TakeRateData/publishaction.js",
                    "~/Content/js/TakeRateData/save.js",
                    "~/Content/js/TakeRateData/saveaction.js",
                    "~/Content/js/TakeRateData/validationsummary.js",
                    "~/Content/js/TakeRateData/validationsummaryaction.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/Forecast")
                .Include("~/Content/js/Forecast/vehicle.js",
                         "~/Content/js/Forecast/forecast.js"));

            bundles.Add(new ScriptBundle("~/Content/js/trimbundle").Include(
                    "~/Content/js/Shared/contextmenu.js",
                    "~/Content/js/Trim/delete.js",
                    "~/Content/js/Trim/model.js",
                    "~/Content/js/Trim/page.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/trimmappingbundle").Include(
                    "~/Content/js/Shared/contextmenu.js",
                    "~/Content/js/TrimMapping/copy.js",
                    "~/Content/js/TrimMapping/delete.js",
                    "~/Content/js/TrimMapping/dpck.js",
                    "~/Content/js/TrimMapping/model.js",
                    "~/Content/js/TrimMapping/page.js",
                    "~/Content/js/TrimMapping/dpckpage.js"
                ));

            bundles.Add(new ScriptBundle("~/Content/js/userbundle").Include(
                    "~/Content/js/Shared/contextmenu.js",
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

            bundles.Add(new StyleBundle("~/Content/styles")
                .Include("~/Content/css/bootstrap.css", cssFixer)
                .Include("~/Content/css/responsive.bootstrap.css", cssFixer)
                .Include("~/Content/css/site.css", cssFixer)
                .Include("~/Content/css/BrushedMetal.css", cssFixer)
                .Include("~/Content/css/jquery.contextMenu.css", cssFixer)
                .Include("~/Content/css/bootstrap-multiselect.css", cssFixer)
                .Include("~/Content/css/jquery.spin.css", cssFixer));

            bundles.Add(new StyleBundle("~/Content/styles/dataTables").Include(
                    "~/Content/css/dataTables.bootstrap.css",
                    "~/Content/css/scroller.bootstrap.css",
                    "~/Content/css/responsive.dataTables.css"
                ));
        }
    }
}
