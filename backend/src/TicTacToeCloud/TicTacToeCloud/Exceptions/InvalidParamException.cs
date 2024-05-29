namespace TicTacToeCloud.Exceptions
{
    public class InvalidParamException : Exception
    {
        public string Message { get; set; }

        public InvalidParamException(string message)
        {
            Message = message;
        }
    }
}
