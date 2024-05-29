using Amazon.S3;
using Amazon.S3.Model;
using Microsoft.AspNetCore.Mvc;

namespace TicTacToeCloud.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FilesController : ControllerBase
    {
        private readonly IAmazonS3 _s3Client;
        private readonly string _bucketName = "tic-tac-toe-pic-bucket";

        public FilesController(IAmazonS3 s3Client)
        {
            _s3Client = s3Client;
        }

        [HttpPost("upload")]
        public async Task<IActionResult> UploadFileAsync(IFormFile file, string username)
        {
            if (file == null || file.Length == 0)
                return BadRequest("No file uploaded.");

            if (string.IsNullOrEmpty(username))
                return BadRequest("Username is required.");

            var bucketExists = await _s3Client.DoesS3BucketExistAsync(_bucketName);
            if (!bucketExists) return NotFound($"Bucket {_bucketName} does not exist.");

            var request = new PutObjectRequest()
            {
                BucketName = _bucketName,
                Key = $"{username?.TrimEnd('/')}/{file.FileName}",
                InputStream = file.OpenReadStream(),
                ContentType = file.ContentType
            };
            request.Metadata.Add("Content-Type", file.ContentType);
            await _s3Client.PutObjectAsync(request);
            return Ok(new { url = $"{_s3Client.Config.DetermineServiceURL()}/{_bucketName}/{username?.TrimEnd('/')}/{file.FileName}" });
        }

        [HttpGet("get-by-username")]
        public async Task<IActionResult> GetFileByUsernameAsync(string username)
        {
            var bucketExists = await _s3Client.DoesS3BucketExistAsync(_bucketName);
            if (!bucketExists) return NotFound($"Bucket {_bucketName} does not exist.");

            var listObjectsRequest = new ListObjectsV2Request
            {
                BucketName = _bucketName,
                Prefix = username
            };

            var listObjectsResponse = await _s3Client.ListObjectsV2Async(listObjectsRequest);
            var s3Object = listObjectsResponse.S3Objects.FirstOrDefault();

            if (s3Object == null) return NotFound($"No file found for username {username}");

            var getObjectRequest = new GetObjectRequest
            {
                BucketName = _bucketName,
                Key = s3Object.Key
            };

            var getObjectResponse = await _s3Client.GetObjectAsync(getObjectRequest);

            return File(getObjectResponse.ResponseStream, getObjectResponse.Headers.ContentType);
        }
    }
}
