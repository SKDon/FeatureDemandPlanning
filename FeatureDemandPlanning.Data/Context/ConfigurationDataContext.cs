using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model.Extensions;
using FeatureDemandPlanning.Model;
using System;
using System.Collections.Generic;
using System.Reflection;
using System.Reflection.Emit;

namespace FeatureDemandPlanning.DataStore
{
    public class ConfigurationDataContext : BaseDataContext, IConfigurationDataContext
    {
        public dynamic Configuration { get { return _configuration; } }

        public ConfigurationDataContext(string cdsId) : base(cdsId)
        {
            LoadConfigurationData();
            BuildDynamicType();
        }
 
        private void LoadConfigurationData()
        {
            var dataStore = new ConfigurationDataStore(CDSID);
            _configurationData = dataStore.ConfigurationGetMany();
        }

        private void BuildDynamicType()
        {
            var appDomain = AppDomain.CurrentDomain;
            var assemblyName = new AssemblyName("FeatureDemandPlanning.Configuration");
            var assemblyBuilder = appDomain.DefineDynamicAssembly(assemblyName, AssemblyBuilderAccess.RunAndSave);
            var moduleBuilder = assemblyBuilder.DefineDynamicModule(assemblyName.Name, String.Format("{0}.dll", assemblyName));

            _typeBuilder = moduleBuilder.DefineType("ConfigurationSettings", TypeAttributes.Public);

            AddConstructor();
            AddProperties();

            Type newDynamicType = _typeBuilder.CreateType();

            _configuration = Activator.CreateInstance(newDynamicType);
        }

        private void AddConstructor()
        {
            // Create the constructor for the type
            var constructorBuilder = _typeBuilder.DefineConstructor(MethodAttributes.Public |
                MethodAttributes.HideBySig |
                MethodAttributes.SpecialName |
                MethodAttributes.RTSpecialName, CallingConventions.Standard, Type.EmptyTypes);

            ILGenerator constructorIL = constructorBuilder.GetILGenerator();

            constructorIL.Emit(OpCodes.Ldarg_0);

            ConstructorInfo conObj = typeof(object).GetConstructor(new Type[0]);

            constructorIL.Emit(OpCodes.Call, conObj);
            constructorIL.Emit(OpCodes.Nop);
            constructorIL.Emit(OpCodes.Nop);

            // Set the field values

            foreach (var setting in _configurationData)
            {
                var settingType = Type.GetType(setting.DataType);
                var backingFieldName = String.Format("_{0}", setting.ConfigurationKey.ToCamelCase());
                var backingFieldBuilder = _typeBuilder.DefineField(backingFieldName,
                                                                    settingType,
                                                                    FieldAttributes.Private);

                switch (settingType.FullName)
                {
                    case "System.Int32":

                        constructorIL.Emit(OpCodes.Ldarg_0);
                        constructorIL.Emit(OpCodes.Ldc_I4_S, Convert.ToInt32(setting.Value));
                        constructorIL.Emit(OpCodes.Stfld, backingFieldBuilder);

                        break;

                    case "System.String":

                        constructorIL.Emit(OpCodes.Ldarg_0);
                        constructorIL.Emit(OpCodes.Ldstr, setting.Value);
                        constructorIL.Emit(OpCodes.Stfld, backingFieldBuilder);

                        break;

                    default:

                        break;
                }

                _fields.Add(backingFieldName, backingFieldBuilder);
            }

            constructorIL.Emit(OpCodes.Nop);
            constructorIL.Emit(OpCodes.Ret);
        }

        private void AddProperties()
        {
            foreach (var setting in _configurationData)
            {
                AddProperty(setting);
            }
        }

        private void AddProperty(ConfigurationItem setting)
        {
            var settingType = Type.GetType(setting.DataType);

            // Create the backing field definition for the configuration setting

            var backingFieldName = String.Format("_{0}", setting.ConfigurationKey.ToCamelCase());
            var backingFieldBuilder = _fields[backingFieldName];

            // Define the property

            var propBuilder = _typeBuilder.DefineProperty(setting.ConfigurationKey,
                                                            PropertyAttributes.HasDefault,
                                                            settingType,
                                                            null);

            // Create the get and set methods

            var getSetAttr = MethodAttributes.Public | MethodAttributes.SpecialName | MethodAttributes.HideBySig;

            var getBuilder = _typeBuilder.DefineMethod(String.Format("get_", setting.ConfigurationKey),
                                                        getSetAttr,
                                                        settingType,
                                                        Type.EmptyTypes);

            ILGenerator getIL = getBuilder.GetILGenerator();

            getIL.Emit(OpCodes.Ldarg_0);
            getIL.Emit(OpCodes.Ldfld, backingFieldBuilder);
            getIL.Emit(OpCodes.Ret);

            var setBuilder = _typeBuilder.DefineMethod(String.Format("set_", setting.ConfigurationKey),
                                                        getSetAttr,
                                                        null,
                                                        new Type[] { settingType });

            ILGenerator setIL = setBuilder.GetILGenerator();

            setIL.Emit(OpCodes.Ldarg_0);
            setIL.Emit(OpCodes.Ldarg_1);
            setIL.Emit(OpCodes.Stfld, backingFieldBuilder);
            setIL.Emit(OpCodes.Ret);

            propBuilder.SetGetMethod(getBuilder);
            propBuilder.SetSetMethod(setBuilder);
        }

        #region "Private members"

        private dynamic _configuration = null;
        private TypeBuilder _typeBuilder = null;
        private IEnumerable<ConfigurationItem> _configurationData = null;
        private IDictionary<string, FieldBuilder> _fields = new Dictionary<string, FieldBuilder>();

        #endregion
    }
}
