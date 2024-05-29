resource "aws_s3_bucket" "profile_pictures" {
  bucket = "tic-tac-toe-pic-bucket"
}

output "bucket_name" {
  value = aws_s3_bucket.profile_pictures.bucket
}
