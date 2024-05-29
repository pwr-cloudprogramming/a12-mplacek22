using Amazon.DynamoDBv2.DataModel;

namespace TicTacToeCloud.Models
{
    [DynamoDBTable("TicTacToeScores")]
    public class GameScore
    {
        [DynamoDBHashKey]
        public string GameId { get; set; }

        [DynamoDBGlobalSecondaryIndexHashKey("Player1-index")]
        public string Player1 { get; set; }

        [DynamoDBGlobalSecondaryIndexHashKey("Player2-index")]
        public string Player2 { get; set; }

        public int Winner { get; set; }
    }
}
