using FeatureDemandPlanning.Model.Context;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class UserViewModel : SharedModelBase
    {
        public User User { get; set; }
        public PagedResults<User> Users { get; set; }
        public UserAction CurrentAction { get; set; }
        public IEnumerable<CarLine> CarLines { get; set; }
        public IEnumerable<Programme> Programmes { get; set; }

        public UserViewModel() : base()
        {
            InitialiseMembers();
        }
        public static async Task<UserViewModel> GetModel(IDataContext context,
                                                           UserFilter filter)
        {
            if (!string.IsNullOrEmpty(filter.CDSId))
            {
                return await GetFullAndPartialViewModelForUser(context, filter);
            }
            return await GetFullAndPartialViewModelForUsers(context, filter);
        }
        public static async Task<UserViewModel> GetModel(IDataContext context,
                                                           UserFilter filter,
                                                           UserAction action)
        {
            var model = await GetModel(context, filter);
            model.CurrentAction = action;
            if (action != UserAction.NotSet)
            {
                model.IdentifierPrefix = Enum.GetName(action.GetType(), action);
            }

            return model;
        }
        private static async Task<UserViewModel> GetFullAndPartialViewModelForUser(IDataContext context,
                                                                                   UserFilter filter)
        {
            var model = new UserViewModel()
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue,
                Configuration = context.ConfigurationSettings
            };
            model.User = await context.User.GetUser(filter);
            model.Programmes = context.Vehicle.ListProgrammes(new ProgrammeFilter());
            model.CarLines = model.Programmes.ListCarLines();

            return model;
        }
        private static async Task<UserViewModel> GetFullAndPartialViewModelForUsers(IDataContext context,
                                                                                    UserFilter filter)
        {
            var baseModel = SharedModelBase.GetBaseModel(context);
            var model = new UserViewModel()
            {
                PageIndex = filter.PageIndex.HasValue ? filter.PageIndex.Value : 1,
                PageSize = filter.PageSize.HasValue ? filter.PageSize.Value : Int32.MaxValue,
                Configuration = context.ConfigurationSettings,
                CurrentUser = baseModel.CurrentUser,
                CurrentVersion = baseModel.CurrentVersion
            };
            model.Users = await context.User.ListUsers(filter);
            model.TotalPages = model.Users.TotalPages;
            model.TotalRecords = model.Users.TotalRecords;
            model.TotalDisplayRecords = model.Users.TotalDisplayRecords;

            return model;
        }

        private void InitialiseMembers()
        {
            User = new EmptyUser();
            IdentifierPrefix = "Page";
            Programmes = Enumerable.Empty<Programme>();
        }
    }
}
