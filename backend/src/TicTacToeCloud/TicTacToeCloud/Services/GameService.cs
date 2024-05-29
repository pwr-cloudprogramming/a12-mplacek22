using TicTacToeCloud.Exceptions;
using TicTacToeCloud.Models;
using TicTacToeCloud.Storage;

namespace TicTacToeCloud.Services
{
    public class GameService
    {
        public Game CreateGame(Player player)
        {
            var game =  new Game()
            {
                Board = new int[3, 3],
                Id = Guid.NewGuid().ToString(),
                Player1 = player,
                Status = GameStatus.New
            };
            GameStorage.Instance.SetGame(game);
            return game;
        }

        public Game ConnectToGame(Player player2, string gameId) 
        {
            if (!GameStorage.Instance.Games.ContainsKey(gameId))
            {
                throw new InvalidParamException($"Game with provided id = {gameId} doesn't exist!");
            }
            var game = GameStorage.Instance.Games[gameId];

            if(game.Player2 != null && game.Status != GameStatus.InProgress)
            {
                throw new InvalidGameException($"Game {gameId} already has 2 players");
            }

            game.Player2 = player2;
            game.Status = GameStatus.InProgress;

            GameStorage.Instance.Games[gameId] = game;

            return game;
        }

        public Game ConnectToRandomGame(Player player2)
        {
            var game = GameStorage.Instance.Games.Values.FirstOrDefault(g => g.Status == GameStatus.New)
                ?? throw new NotFoundException("Game not found. There are no available games to connect to!");
            game.Player2 = player2;
            game.Status = GameStatus.InProgress;
            GameStorage.Instance.Games[game.Id] = game;
            return game;
        }

        public Game GamePlay(GamePlay gamePlay)
        {
           
            if (!GameStorage.Instance.Games.TryGetValue(gamePlay.GameId, out Game? game))
            {
                throw new NotFoundException($"Game {gamePlay.GameId} not found!");
            }

            if(game.Status == GameStatus.Finished) 
            {
                throw new InvalidGameException($"Game {game.Id} is already finished!");
            }

            if (gamePlay.Type != game.CurrentPlayer)
            {
                throw new InvalidGameException($"Wait for opponents turn!");
            }

            game.Board[gamePlay.CoordinateX, gamePlay.CoordinateY] = (int) gamePlay.Type;
            game.MovesCount++;
            

            if(CheckWinner(game.Board, TicToe.X))
            {
                game.Winner = TicToe.X;
                game.Status = GameStatus.Finished;
            }
            else if(CheckWinner(game.Board, TicToe.O))
            {
                game.Winner = TicToe.O;
                game.Status = GameStatus.Finished;
            }
            else if(game.MovesCount == game.Board.Length)
            {
                game.Status = GameStatus.Finished; //Draw
            }
            

            game.CurrentPlayer = game.CurrentPlayer == TicToe.X ? TicToe.O : TicToe.X;
            

            GameStorage.Instance.Games[game.Id] = game;

            return game;
        }

        private bool CheckWinner(int[,] board, TicToe ticToe)
        {
            int playerValue = (int)ticToe; // Assuming TicToe has a property `Value` returning the player's marker as an int
                                           // Winning combinations based on board indices
            int[,] winCombinations = new int[,]
            {
                {0, 1, 2}, {3, 4, 5}, {6, 7, 8}, // Rows
                {0, 3, 6}, {1, 4, 7}, {2, 5, 8}, // Columns
                {0, 4, 8}, {2, 4, 6}             // Diagonals
             };

            for (int i = 0; i < winCombinations.GetLength(0); i++)
            {
                // Check if the current winning combination has the same playerValue
                if ((board[winCombinations[i, 0] / 3, winCombinations[i, 0] % 3] == playerValue) &&
                    (board[winCombinations[i, 1] / 3, winCombinations[i, 1] % 3] == playerValue) &&
                    (board[winCombinations[i, 2] / 3, winCombinations[i, 2] % 3] == playerValue))
                {
                    return true; // Winner found
                }
            }
            return false; // No winner found
        }
    }
}
