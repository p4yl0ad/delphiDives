using System;
using System.IO;
using System.IO.Pipes;
using System.Text;
using System.Threading.Tasks;

namespace NamedPipesInteropDemo
{
    public sealed class PipeClient
    {
        private readonly string m_serverName;

        private readonly string m_pipeName;

        public PipeClient(string pipeName)
            : this(".", pipeName) { }

        public PipeClient(string serverName, string pipeName)
        {
            m_serverName = serverName;
            m_pipeName = pipeName;
        }

        private static async Task<bool> CopyStream(Stream src, Stream dst, int bytes, int bufferSize)
        {
            var buffer = new byte[bufferSize];
            int read;
            while (bytes > 0 && (read = await src.ReadAsync(buffer, 0, Math.Min(buffer.Length, bytes))) > 0)
            {
                await dst.WriteAsync(buffer, 0, read);
                bytes -= read;
            }
            return bytes == 0;
        }

        private async Task<string> ProcessRequest(string message)
        {
            var dataBuffer = Encoding.ASCII.GetBytes(message);
            var dataSize = dataBuffer.Length;

            if (dataSize == 0)
                return null;

            using (var pipe = new NamedPipeClientStream(m_serverName, m_pipeName, PipeDirection.InOut, PipeOptions.Asynchronous | PipeOptions.WriteThrough))
            {
                try
                {
                    await Task.Run(() => pipe.Connect(500));
                }
                catch (TimeoutException e)
                {
                    throw new PipeServerNotFoundException(e.Message, e);
                }

                pipe.ReadMode = PipeTransmissionMode.Message;

                const int cBufferSize = 4096;

                try
                {
                    var dataSizeBuffer = BitConverter.GetBytes(dataSize);
                    await pipe.WriteAsync(dataSizeBuffer, 0, dataSizeBuffer.Length);
                    using (var stream = new MemoryStream(dataBuffer))
                        await CopyStream(stream, pipe, dataSize, cBufferSize);
                    await pipe.FlushAsync();

                    dataSizeBuffer = new byte[sizeof(Int32)];
                    var bytesRead = await pipe.ReadAsync(dataSizeBuffer, 0, sizeof(Int32));
                    if (bytesRead <= 0)
                        throw new PipeServerBrokenPipeException();

                    dataSize = BitConverter.ToInt32(dataSizeBuffer, 0);
                    if (dataSize <= 0)
                        return null;

                    using (var stream = new MemoryStream(dataSize))
                    {
                        if (!await CopyStream(pipe, stream, dataSize, cBufferSize))
                            throw new PipeServerBrokenPipeException();
                        var resultBuffer = stream.GetBuffer();
                        var decoder = Encoding.ASCII.GetDecoder();
                        var charCount = decoder.GetCharCount(resultBuffer, 0, dataSize, false);
                        var charResultBuffer = new char[charCount];
                        decoder.GetChars(resultBuffer, 0, dataSize, charResultBuffer, 0, false);
                        decoder.Reset();
                        return new string(charResultBuffer);
                    }
                }
                catch (IOException ex)
                {
                    // Console.WriteLine(ex.Message);
                    // NOTE: This is not relyable, but will do for now
                    if (ex.Message.Contains("Pipe is broken"))
                        throw new PipeServerBrokenPipeException();
                    throw;
                }
            }
        }

        public async Task<PipeMessage> ProcessRequest(PipeMessage message)
        {
            var resultMessage = await ProcessRequest(message.ToString());
            var result = PipeMessage.FromString(resultMessage);
            if (result.IsError)
                throw new PipeServerException(result.ErrorCode, result.ErrorText);
            return result;
        }

        public async Task WaitForPipe(int timeout)
        {
            await Task.Run(() =>
            {
                using (var pipe = new NamedPipeClientStream(m_serverName, m_pipeName,
                    PipeDirection.InOut, PipeOptions.Asynchronous | PipeOptions.WriteThrough))
                    pipe.Connect(timeout);
            });
        }
    }
}
