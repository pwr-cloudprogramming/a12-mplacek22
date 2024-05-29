using TicTacToeCloud.Models;

namespace TicTacToeCloud.Storage
{
    public class GameStorage
    {
        public Dictionary<string, Game> Games { get; private set; }

        private static GameStorage _instance;

        private GameStorage() 
        {
            Games = new Dictionary<string, Game>();
        }

        public static GameStorage Instance
        {
            get
            {
                _instance ??= new GameStorage();
                return _instance;
            }
        }

        public void SetGame(Game game)
        {
            Games.TryAdd(game.Id, game);
        }
    }
}
