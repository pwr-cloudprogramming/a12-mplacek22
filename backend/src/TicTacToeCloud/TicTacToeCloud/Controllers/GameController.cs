using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using TicTacToeCloud.Controllers.Dto;
using TicTacToeCloud.Exceptions;
using TicTacToeCloud.Hubs;
using TicTacToeCloud.Models;
using TicTacToeCloud.Services;

namespace TicTacToeCloud.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize]
    public class GameController : Controller
    {
        private readonly GameService _gameService;
        private readonly IHubContext<GameHub> _hubContext;

        public GameController(GameService gameService, IHubContext<GameHub> hubContext)
        {
            _gameService = gameService;
            _hubContext = hubContext;
        }

        [HttpPost("start")]
        public ActionResult<Game> Start([FromBody] Player player)
        {
            var game = _gameService.CreateGame(player);
            return Ok(game);
        }

        [HttpPost("connect")]
        public ActionResult<Game> Connect([FromBody] ConnectRequest request)
        {
            try
            {
                var game = _gameService.ConnectToGame(request.Player, request.GameId);
                _hubContext.Clients.All.SendAsync("JoinedGame", game);
                return Ok(game);
            }
            catch (InvalidParamException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (InvalidGameException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("connect/random")]
        public ActionResult<Game> ConnectRandom([FromBody] Player player)
        {
            try
            {
                var game = _gameService.ConnectToRandomGame(player);
                _hubContext.Clients.All.SendAsync("JoinedGame", game);
                return Ok(game);
            }
            catch (NotFoundException ex)
            {
                return NotFound(ex.Message);
            }
        }

        [HttpPost("gameplay")]
        public ActionResult<Game> Gameplay([FromBody] GamePlay request)
        {
            try
            {
                var game = _gameService.GamePlay(request);
                _hubContext.Clients.All.SendAsync("ReceiveGameUpdate", game);
                return Ok(game);
            }
            catch (NotFoundException ex)
            {
                return NotFound(ex.Message);
            }
            catch (InvalidGameException ex)
            {
                return BadRequest(ex.Message);
            }
        }
        
    }
}
