resource "aws_dynamodb_table" "tictactoe_scores" {
  name           = "TicTacToeScores"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "GameId"

  attribute {
    name = "GameId"
    type = "S"
  }

  attribute {
    name = "Player1"
    type = "S"
  }

  attribute {
    name = "Player2"
    type = "S"
  }

  attribute {
    name = "Winner"
    type = "N"
  }

  global_secondary_index {
    name            = "Player1-index"
    hash_key        = "Player1"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "Player2-index"
    hash_key        = "Player2"
    projection_type = "ALL"
  }

  tags = {
    Name = "TicTacToeScores"
    Environment = "Dev"
  }
}
