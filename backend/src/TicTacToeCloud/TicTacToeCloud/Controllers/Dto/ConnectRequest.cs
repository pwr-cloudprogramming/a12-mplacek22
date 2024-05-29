using TicTacToeCloud.Models;

namespace TicTacToeCloud.Controllers.Dto
{
    public class ConnectRequest
    {
        public Player Player {  get; set; }

        public string GameId { get; set; }

    }
}
