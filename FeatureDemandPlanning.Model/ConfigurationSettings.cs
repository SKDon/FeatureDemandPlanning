using System;
using System.Collections.Generic;
using System.Reflection;
using log4net;

namespace FeatureDemandPlanning.Model
{
    public class ConfigurationSettings
    {
        public ConfigurationSettings()
        {
            _intDictionary = new Dictionary<string, int>();
            _boolDictionary = new Dictionary<string, bool>();
            _stringDictionary = new Dictionary<string, string>();
        }

        public void AddIntegerSetting(string key, string value)
        {
            //Log.Debug(string.Format("Adding integer configuration {0}:{1}", key, value));

            int parsedValue;
            if (!_intDictionary.ContainsKey(key) && int.TryParse(value, out parsedValue))
            {
                
                _intDictionary.Add(key, parsedValue);
            }
        }
        public void AddStringSetting(string key, string value)
        {
            //Log.Debug(string.Format("Adding string configuration {0}:{1}", key, value));

            if (!_stringDictionary.ContainsKey(key))
            {
                _stringDictionary.Add(key, value);
            }
        }
        public void AddBooleanSetting(string key, string value)
        {
            //Log.Debug(string.Format("Adding boolean configuration {0}:{1}", key, value));

            bool parsedValue;

            // Allow for 0 and 1 in the settings

            if (value == "0") value = "false";
            if (value == "1") value = "true";

            if (!_boolDictionary.ContainsKey(key) && bool.TryParse(value, out parsedValue))
            {
                _boolDictionary.Add(key, parsedValue);
            }   
        }
        public int GetInteger(string key)
        {
            if (!_intDictionary.ContainsKey(key))
                throw new ArgumentException(string.Format("Configuration key '{0}' not found", key));

            return _intDictionary[key];
        }
        public bool GetBoolean(string key)
        {
            if (!_boolDictionary.ContainsKey(key))
                throw new ArgumentException(string.Format("Configuration key '{0}' not found", key));

            return _boolDictionary[key];
        }
        public string GetString(string key)
        {
            if (!_stringDictionary.ContainsKey(key))
                throw new ArgumentException(string.Format("Configuration key '{0}' not found", key));

            return _stringDictionary[key];
        }

        private readonly IDictionary<string, int> _intDictionary;
        private readonly IDictionary<string, bool> _boolDictionary;
        private readonly IDictionary<string, string> _stringDictionary;

        private static readonly ILog Log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);
    }
}
