using System;
using System.Diagnostics;
using System.Threading.Tasks;

namespace NamedPipesInteropDemo
{
    public sealed class PipeInteropDispatcher
    {
        private const string c_pipeName = @"interop.demo";
        private const string c_pipeServerName = "NamedPipesInteropDelphi.exe";

        private static async Task CreatePipeServer(string pipeName)
        {
            try
            {
                Process.Start(c_pipeServerName, "pipe=" + pipeName);
                await new PipeClient(pipeName).WaitForPipe(10000);
            }
            catch (Exception ex)
            {
                throw new InvalidOperationException(string.Format("Unable to instantiate Server: {0}", ex.Message), ex);
            }
        }

        public static async Task<PipeMessage> ProcessRequestAsync(PipeMessage request)
        {
            var needInstance = false;
            var result = default (PipeMessage);
            var pipe = new PipeClient(c_pipeName);

            try
            {
                result = await pipe.ProcessRequest(request);
            }
            catch (PipeServerBrokenPipeException)
            {
                needInstance = true;
            }
            catch (PipeServerNotFoundException)
            {
                needInstance = true;
            }

            if (needInstance)
            {
                await CreatePipeServer(c_pipeName);
                result = await pipe.ProcessRequest(request);
            }

            return result;
        }
    }
}