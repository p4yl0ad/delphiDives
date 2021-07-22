using System;
using System.Collections.Generic;
using System.Linq;

namespace NamedPipesInteropDemo
{
    public static class EnumHelper
    {
        public static T FromString<T>(string value)
        {
            if (value == null)
                throw new ArgumentNullException("value");
            return GetValues<T>().Single(x => x.ToString() == value);
        }

        public static T FromStringDef<T>(string value, T defValue)
        {
            return value == null ? defValue : GetValues<T>().DefaultIfEmpty(defValue).FirstOrDefault(x => x.ToString() == value);
        }

        public static T FromStringDef<T>(string value)
        {
            if (value == null)
                return default(T);
            return GetValues<T>().DefaultIfEmpty(default(T)).FirstOrDefault(x => x.ToString() == value);
        }

        public static IEnumerable<T> GetValues<T>()
        {
            if (!typeof(T).IsEnum)
                throw new InvalidOperationException("Type must be enumeration type.");

            return GetValuesImpl<T>();
        }

        private static IEnumerable<T> GetValuesImpl<T>()
        {
            return from field in typeof(T).GetFields()
                where field.IsLiteral && !string.IsNullOrEmpty(field.Name)
                select (T)field.GetValue(null);
        }
    }
}