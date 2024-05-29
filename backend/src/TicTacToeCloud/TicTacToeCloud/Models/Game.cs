using TicTacToeCloud.Converters;
using System.Text.Json.Serialization;

namespace TicTacToeCloud.Models
{
    public class Game
    {
        public string Id { get; set; }

        public Player Player1 { get; set; }

        public Player Player2 { get; set; }

        public GameStatus Status { get; set; }

        [JsonConverter(typeof(TwoDimensionalArrayConverter<int>))]
        public int[,] Board { get; set; }

        public TicToe Winner { get; set; } = 0;

        public TicToe CurrentPlayer { get; set; } = TicToe.X;

        public int MovesCount { get; set; }
    }
}
