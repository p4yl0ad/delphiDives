using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;

namespace NamedPipesInteropDemo
{
    public sealed class PipeMessage : Dictionary<string, string>
    {
        public PipeMessage()
        {
        }

        public PipeMessage(string name)
        {
            Name = name;
        }

        public PipeMessage(string name, IDictionary<string, string> data)
            : base(data)
        {
            Name = name;
        }

        public static PipeMessage Empty = new PipeMessage(null);

        public static PipeMessage FromString(string request)
        {
            if (string.IsNullOrEmpty(request))
                return Empty;

            var xml = XElement.Parse(request);

            if (xml.Name != "Message")
                throw new InvalidOperationException("Invalid request format");

            var result = new PipeMessage
            {
                Name = (string) xml.Attribute("Name"),
                IsError = ((int?) xml.Attribute("IsError") ?? 0) > 0,
                ErrorCode = (string) xml.Attribute("ErrorCode"),
                ErrorText = (string) xml.Attribute("ErrorText")
            };

            foreach (var element in xml.Elements("Data"))
                result[(string) element.Attribute("Key")] = element.Value;

            return result;
        }

        public override string ToString()
        {
            return string.IsNullOrEmpty(Name)
                ? "Empty PipeMessage"
                : new XElement(
                    "Message",
                    new XAttribute("Name", Name),
                    IsError ? new XAttribute("IsError", IsError) : null,
                    IsError ? new XAttribute("ErrorCode", ErrorCode) : null,
                    IsError ? new XAttribute("ErrorText", ErrorText) : null,
                    this.Select(x => new XElement("Data",
                        x.Key == null ? null : new XAttribute("Key", x.Key),
                        x.Value))).ToString();
        }

        public void ThrowIfError()
        {
            if (IsError)
            {
                var errorCode = !string.IsNullOrEmpty(ErrorCode) ? ErrorCode : "Exception";
                var errorText = !string.IsNullOrEmpty(ErrorText) ? ErrorText : "Unknown Internal Error (PipeMessage)";
                throw new Exception(string.Format("{0}: {1}", errorCode, errorText));
            }
        }

        public string Name { get; set; }

        public bool IsError { get; set; }

        public string ErrorText { get; set; }

        public string ErrorCode { get; set; }
    }
}