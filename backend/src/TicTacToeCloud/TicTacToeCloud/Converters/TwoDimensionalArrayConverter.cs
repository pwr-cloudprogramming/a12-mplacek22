using System.Text.Json.Serialization;
using System.Text.Json;

namespace TicTacToeCloud.Converters
{
    public class TwoDimensionalArrayConverter<T> : JsonConverter<T[,]>
    {
        public override T[,] Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            var elements = JsonSerializer.Deserialize<T[][]>(ref reader, options);
            var height = elements.Length;
            var width = elements[0].Length;
            var result = new T[height, width];
            for (int i = 0; i < height; i++)
            {
                for (int j = 0; j < width; j++)
                {
                    result[i, j] = elements[i][j];
                }
            }
            return result;
        }

        public override void Write(Utf8JsonWriter writer, T[,] value, JsonSerializerOptions options)
        {
            var height = value.GetLength(0);
            var width = value.GetLength(1);
            var elements = new T[height][];
            for (int i = 0; i < height; i++)
            {
                elements[i] = new T[width];
                for (int j = 0; j < width; j++)
                {
                    elements[i][j] = value[i, j];
                }
            }
            JsonSerializer.Serialize(writer, elements, options);
        }
    }
}
