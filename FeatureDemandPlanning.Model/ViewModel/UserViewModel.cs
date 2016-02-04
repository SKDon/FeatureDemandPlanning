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
        public PagedResults<UserDataItem> Users { get; set; }
        public UserAdminAction CurrentAction { get; set; }
        public IEnumerable<CarLine> CarLines { get; set; }
        public IEnumerable<Programme> Programmes { get; set; }
        public IEnumerable<Market> Markets { get; set; } 

        public UserViewModel()
        {
            InitialiseMembers();
        }
        public UserViewModel(SharedModelBase baseModel) : base(baseModel)
        {
            InitialiseMembers();
        }
        public static async Task<UserViewModel> GetModel(IDataContext context)
        {
            return await Task.FromResult(GetFullAndPartialViewModel(context));
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
                                                           UserAdminAction action)
        {
            var model = await GetModel(context, filter);
            model.CurrentAction = action;
            if (action != UserAdminAction.NoAction)
            {
                model.IdentifierPrefix = Enum.GetName(action.GetType(), action);
            }

            return model;
        }
        private static UserViewModel GetFullAndPartialViewModel(IDataContext context)
        {
            var modelBase = GetBaseModel(context);

            return new UserViewModel(modelBase);
        }
        private static async Task<UserViewModel> GetFullAndPartialViewModelForUser(IDataContext context,
                                                                                   UserFilter filter)
        {
            var modelBase = GetBaseModel(context);
            var model = new UserViewModel(modelBase)
            {
                PageIndex = filter.PageIndex ?? 1,
                PageSize = filter.PageSize ?? int.MaxValue,
                Configuration = context.ConfigurationSettings,
                User = await context.User.GetUser(filter),
                Programmes = context.Vehicle.ListProgrammes(new ProgrammeFilter()),
                Markets = await context.Market.ListAvailableMarkets()
            };
            model.CarLines = model.Programmes.ListCarLines();

            return model;
        }
        private static async Task<UserViewModel> GetFullAndPartialViewModelForUsers(IDataContext context,
                                                                                    UserFilter filter)
        {
            var baseModel = GetBaseModel(context);
            var model = new UserViewModel(baseModel)
            {
                PageIndex = filter.PageIndex ?? 1,
                PageSize = filter.PageSize ?? int.MaxValue,
                Configuration = context.ConfigurationSettings,
                Users = await context.User.ListUsers(filter)
            };
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
