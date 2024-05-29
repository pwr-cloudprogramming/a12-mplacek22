namespace TicTacToeCloud.Exceptions
{
    public class NotFoundException : Exception
    {
        public string Message { get; set; }

        public NotFoundException(string message)
        {
            Message = message;
        }
    }
}
