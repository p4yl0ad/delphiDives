using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;

namespace NamedPipesInteropDemo
{
    class Program
    {
        private enum Operation
        {
            Add,
            Subtract,
            Mult,
            Div,
            PingServer,
            KillServer
        }

        static void Main(string[] args)
        {
            var canExit = false;
            while (!canExit)
            {
                Console.WriteLine("Enter Operation ID:");
                foreach (var demoId in typeof(Operation).GetEnumValues())
                    Console.WriteLine("\t{0}. {1}", (int)demoId + 1, demoId);
                Console.Write("\n|> ");
                int id;
                var entry = Console.ReadLine();
                if (string.IsNullOrEmpty(entry))
                    canExit = true;
                else if (int.TryParse(entry, out id))
                    RunDemo((Operation)id - 1).GetAwaiter().GetResult();
                Console.WriteLine();
            }
        }

        private static async Task RunDemo(Operation operation)
        {
            try
            {
                var methods = EnumHelper.GetValues<Operation>().ToDictionary(d => d, d => d.ToString());

                if (!methods.ContainsKey(operation))
                    throw new InvalidOperationException("Invalid Operation ID");

                if (operation == Operation.PingServer)
                    await PipeInteropDispatcher.ProcessRequestAsync(new PipeMessage("Ping"));
                else if (operation == Operation.KillServer)
                    await PipeInteropDispatcher.ProcessRequestAsync(new PipeMessage("ExitProcess"));
                else
                {
                    Console.Write("Enter value of X: ");
                    var x = decimal.Parse(Console.ReadLine());
                    Console.Write("Enter value of Y: ");
                    var y = decimal.Parse(Console.ReadLine());

                    var result = await CalcAsync(methods[operation], x, y);

                    var color = Console.ForegroundColor;
                    Console.ForegroundColor = ConsoleColor.Yellow;
                    Console.WriteLine("\nRESULT: {0}", result);
                    Console.ForegroundColor = color;
                }
            }
            catch (Exception ex)
            {
                var color = Console.ForegroundColor;
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine();
                Console.WriteLine(ex.Message);
                Console.ForegroundColor = color;
            }
        }

        private static async Task<decimal> CalcAsync(string method, decimal x, decimal y)
        {
            var args = new Dictionary<string, string>
            {
                {"X", x.ToString(CultureInfo.InvariantCulture)},
                {"Y", y.ToString(CultureInfo.InvariantCulture)}
            };
            var result = await PipeInteropDispatcher.ProcessRequestAsync(new PipeMessage(method, args));
            return decimal.Parse(result["Result"]);
        }
    }
}
