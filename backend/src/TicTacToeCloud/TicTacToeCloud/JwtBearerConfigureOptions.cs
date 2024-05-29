using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.Options;

namespace TicTacToeCloud
{
    public class JwtBearerConfigureOptions : IConfigureNamedOptions<JwtBearerOptions>
    {
        private readonly IConfiguration _configuration;
        private const string ConfigurationSectionName = "JwtBearer";

        public JwtBearerConfigureOptions(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public void Configure(string? name, JwtBearerOptions options)
        {
            _configuration.GetSection(ConfigurationSectionName).Bind(options);
        }

        public void Configure(JwtBearerOptions options)
        {
            Configure(Options.DefaultName, options);
        }
    }
}
