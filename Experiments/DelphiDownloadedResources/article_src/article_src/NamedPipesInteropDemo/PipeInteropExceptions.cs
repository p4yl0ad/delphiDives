using System;
using System.Runtime.Serialization;

namespace NamedPipesInteropDemo
{
    public class PipeInteropException : Exception
    {
        public PipeInteropException()
            : base("Pipe Interop Exception")
        {
        }

        public PipeInteropException(string message)
            : base(message)
        {
        }

        public PipeInteropException(string message, Exception innerException)
            : base(message, innerException)
        {
        }

        protected PipeInteropException(SerializationInfo info, StreamingContext context)
            : base(info, context)
        {
        }
    }

    [Serializable]
    public sealed class PipeServerNotFoundException : PipeInteropException
    {
        public PipeServerNotFoundException(string message)
            : base(message)
        {
        }

        public PipeServerNotFoundException(string message, Exception innerException)
            : base(message, innerException)
        {
        }
    }

    [Serializable]
    public sealed class PipeServerBrokenPipeException : PipeInteropException
    {
        public PipeServerBrokenPipeException()
            : base("Pipe is broken")
        {
        }
    }

    [Serializable]
    public sealed class PipeServerException : PipeInteropException
    {
        public PipeServerException(string exceptionName, string message)
            : base(string.Format("{0}: {1}", exceptionName, message))
        {
            ExceptionName = exceptionName;
            Message = message;
        }

        public string ExceptionName { get; set; }
        public string Message { get; set; }
    }
}