using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using TicTacToeCloud.Models;
using Amazon.DynamoDBv2.DocumentModel;

namespace TicTacToeCloud.Services
{
    public class ScoreService
    {
        private readonly IDynamoDBContext _context;

        public ScoreService(IAmazonDynamoDB dynamoDb)
        {
            _context = new DynamoDBContext(dynamoDb);
        }

        public async Task SaveGameScore(GameScore score)
        {
            await _context.SaveAsync(score);
        }

        public async Task<List<GameScore>> GetGamesByPlayer(string playerName)
        {
            var player1Conditions = new List<ScanCondition>
            {
                new ScanCondition("Player1", ScanOperator.Equal, playerName)
            };
            var player1Search = _context.ScanAsync<GameScore>(player1Conditions);
            var player1Results = await player1Search.GetRemainingAsync();

            var player2Conditions = new List<ScanCondition>
            {
                new ScanCondition("Player2", ScanOperator.Equal, playerName)
            };

            var player2Search = _context.ScanAsync<GameScore>(player2Conditions);
            var player2Results = await player2Search.GetRemainingAsync();

            var allResults = player1Results.Concat(player2Results).ToList();

            return allResults;
        }
    }
}
