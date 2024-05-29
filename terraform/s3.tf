resource "aws_s3_bucket" "profile_pictures" {
  bucket = "tictactoe-profile-pictures"
  acl    = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

output "bucket_name" {
  value = aws_s3_bucket.profile_pictures.bucket
}
