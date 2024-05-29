namespace TicTacToeCloud.Exceptions
{
    public class InvalidGameException : Exception
    {
        public string Message { get; set; }

        public InvalidGameException(string message)
        {
            Message = message;
        }
    }
}
