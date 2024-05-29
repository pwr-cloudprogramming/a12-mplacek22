using Microsoft.AspNetCore.SignalR;
namespace TicTacToeCloud.Hubs
{
    public class GameHub : Hub
    {
        public async Task SendGameUpdate(string gameId, string gameData)
        {
            await Clients.All.SendAsync("ReceiveGameUpdate", gameId, gameData);
        }

        public async Task SubscribeToGame(string gameId, string gameData)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, gameId);
            await Clients.Group(gameId).SendAsync("JoinedGame", gameId, gameData, $"New subscriber joined game {gameId}.");
        }

        public async Task UnsubscribeFromGame(string gameId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, gameId);
            await Clients.Group(gameId).SendAsync("LeftGame", gameId, $"A subscriber left game {gameId}.");
        }
    }
}
