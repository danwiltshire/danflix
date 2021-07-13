using System;
using System.Diagnostics;
using System.Collections.Generic;
using System.Text;
using System.Net.Http;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using System.Threading.Tasks;
using Windows.Foundation;
using Windows.UI.Core;
using Windows.Media.Core;
using Windows.Media.Streaming.Adaptive;
using System.Text.Json;
using System.Timers;
using QRCoder;
using System.Drawing;
using Windows.UI.Xaml.Media.Imaging;
using Windows.Storage.Streams;

// The Blank Page item template is documented at https://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x409

namespace Violet
{
    public class Auth0DeviceCodeModel
    {
        public string device_code { get; set; }
        public string user_code { get; set; }
        public string verification_uri { get; set; }
        public int expires_in { get; set; }
        public int interval { get; set; }
        public string verification_uri_complete { get; set; }
    }

    public class Auth0Token
    {
        public string access_token { get; set; }
        public string refresh_token { get; set; }
        public string id_token { get; set; }
        public string token_type { get; set; }
        public int expires_in { get; set; }

        // Optional properties
        public string error { get; set; }
        public string error_description { get; set; }
    }

    public class Auth0
    {

        public string client_id = System.Environment.GetEnvironmentVariable("AUTH0_CLIENT_ID");
        public string audience = System.Environment.GetEnvironmentVariable("AUTH0_AUDIENCE");
        public string domain = System.Environment.GetEnvironmentVariable("AUTH0_DOMAIN");

        public async Task<Auth0Token> GetToken(string deviceCode, int retryInterval)
        {
            int maximumRetries = 3;
            int retries = 0;
            while(retries <= maximumRetries)
            {
                retries++;
                Debug.WriteLine("Starting GetToken for device_code: " + deviceCode);
                var dict = new Dictionary<string, string>{
                    {"Content-Type", "application/x-www-form-urlencoded"},
                    {"grant_type", "urn:ietf:params:oauth:grant-type:device_code"},
                    {"device_code", deviceCode},
                    {"client_id", client_id},
                };

                // Construct the HttpClient and Uri. This endpoint is for test purposes only.
                HttpClient httpClient = new HttpClient();
                Uri uri = new Uri($"https://{domain}/oauth/token");

                // Post the JSON and wait for a response.
                HttpResponseMessage httpResponseMessage = await httpClient.PostAsync(
                    uri,
                    new FormUrlEncodedContent(dict));

                var httpResponseBody = await httpResponseMessage.Content.ReadAsStringAsync();
                Debug.WriteLine("GetToken HTTP response code: " + (int)httpResponseMessage.StatusCode);

                if ((int)httpResponseMessage.StatusCode == 200)
                {
                    return JsonSerializer.Deserialize<Auth0Token>(httpResponseBody);
                }
                await Task.Delay(retryInterval);
            }
            throw new Exception("Failed to get the token after X attempts.");
        }

    }

    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        Auth0 auth = new Auth0();

        public MainPage()
        {
            this.InitializeComponent();
        }

        private async Task<Auth0DeviceCodeModel> GetDeviceCode()
        {
            var dict = new Dictionary<string, string>();
            dict.Add("Content-Type", "application/x-www-form-urlencoded");
            dict.Add("client_id", auth.client_id);
            dict.Add("audience", auth.audience);

            // Construct the HttpClient and Uri. This endpoint is for test purposes only.
            HttpClient httpClient = new HttpClient();
            Uri uri = new Uri($"https://{auth.domain}/oauth/device/code?client_id={auth.client_id}&audience={auth.audience}");

            // Post the JSON and wait for a response.
            HttpResponseMessage httpResponseMessage = await httpClient.PostAsync(
                uri,
                new FormUrlEncodedContent(dict));

            // Make sure the post succeeded, and write out the response.
            httpResponseMessage.EnsureSuccessStatusCode();
            var httpResponseBody = await httpResponseMessage.Content.ReadAsStringAsync();
            
            Debug.WriteLine(httpResponseBody);

            return JsonSerializer.Deserialize<Auth0DeviceCodeModel>(httpResponseBody);
        }

        private async Task<Auth0Token> GetToken(string deviceCode)
        {
            var dict = new Dictionary<string, string>();
            dict.Add("Content-Type", "application/x-www-form-urlencoded");
            dict.Add("grant_type", "urn:ietf:params:oauth:grant-type:device_code");
            dict.Add("device_code", deviceCode);
            dict.Add("client_id", auth.client_id);

            // Construct the HttpClient and Uri. This endpoint is for test purposes only.
            HttpClient httpClient = new HttpClient();
            Uri uri = new Uri($"https://{auth.domain}/oauth/token");
            
            // Post the JSON and wait for a response.
            HttpResponseMessage httpResponseMessage = await httpClient.PostAsync(
                uri,
                new FormUrlEncodedContent(dict));
            
            var httpResponseBody = await httpResponseMessage.Content.ReadAsStringAsync();
            Debug.WriteLine("GetToken HTTP response code: ", httpResponseMessage.StatusCode);
            Debug.WriteLine("Stopping timer...");
            return JsonSerializer.Deserialize<Auth0Token>(httpResponseBody);
        }

        private async void openMediaFileAdaptive()
        {
            var httpClient = new Windows.Web.Http.HttpClient();
            // httpClient.DefaultRequestHeaders.TryAppendWithoutValidation("X-CustomHeader", "This is a custom header");
            AdaptiveMediaSourceCreationResult result = await AdaptiveMediaSource.CreateFromUriAsync(new Uri("https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"), httpClient);

            MediaSource source;

            if (result.Status == AdaptiveMediaSourceCreationStatus.Success)
            {
                var adaptiveMediaSource = result.MediaSource;
                source = MediaSource.CreateFromAdaptiveMediaSource(adaptiveMediaSource);
                mediaPlayerElement.Source = source;
            }
            else
            {
                Debug.WriteLine("Borked");
            }


            mediaPlayerElement.Visibility = Visibility.Visible;
            mediaPlayerElement.IsFullWindow = true;
            mediaPlayerElement.MediaPlayer.Play();
        }

        private async void LoginButton_Click(object sender, RoutedEventArgs e)
        {
            var deviceCode = await GetDeviceCode();

            StringBuilder sb = new StringBuilder();

            sb.AppendLine($"verification_uri: {deviceCode.verification_uri}");
            sb.AppendLine($"user_code: {deviceCode.user_code}");
            sb.AppendLine("Please visit ^ and do stuff.");

            resultTextBox.Text = sb.ToString();



            //Create raw qr code data
            QRCodeGenerator qrGenerator = new QRCodeGenerator();
            QRCodeData qrCodeData = qrGenerator.CreateQrCode(deviceCode.verification_uri_complete, QRCodeGenerator.ECCLevel.M);

            //Create byte/raw bitmap qr code
            BitmapByteQRCode qrCodeBmp = new BitmapByteQRCode(qrCodeData);
            byte[] qrCodeImageBmp = qrCodeBmp.GetGraphic(25);
            using (InMemoryRandomAccessStream stream = new InMemoryRandomAccessStream())
            {
                using (DataWriter writer = new DataWriter(stream.GetOutputStreamAt(0)))
                {
                    writer.WriteBytes(qrCodeImageBmp);
                    await writer.StoreAsync();
                }
                var image = new BitmapImage();

                await image.SetSourceAsync(stream);

                qrCodeImageView.Source = image;
            }

            try
            {
                Auth0Token token = await auth.GetToken(deviceCode.device_code, deviceCode.interval = 5000);
                resultTextBox.Text = "Authentication successful";
            } catch (Exception ef)
            {
                Debug.WriteLine("Failed to authenticate with error: " + ef);
                resultTextBox.Text = "Authentication timed out.";
            }
        }

        private void PlayVideoButton_Click(object sender, RoutedEventArgs e)
        {
            openMediaFileAdaptive();
        }
    }
}
