package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

var apiGatewayEndpoints = []struct {
	terraformOutput    string
	path               string
	expectedHTTPStatus int
	expectedHTTPBody   string
}{
	{"api_invoke_url", "listobjects", 401, "{\"message\":\"Unauthorized\"}"},
	{"api_invoke_url", "presignedurl", 401, "{\"message\":\"Unauthorized\"}"},
}

var cloudfrontDomainsEndpoint = []struct {
	terraformOutput          string
	HTTPProtocol             string
	path                     string
	expectedHTTPStatus       int
	expectedHTTPBodyContains string
}{
	{"cloudfront_distribution_domain", "https", "/", 403, "AccessDenied"},
}

func TestAPIGatewayEndpoints(t *testing.T) {

	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
	}

	//defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	for _, endpoint := range apiGatewayEndpoints {
		url := fmt.Sprintf("%s%s", terraform.Output(t, terraformOptions, endpoint.terraformOutput), endpoint.path)
		http_helper.HttpGetWithRetry(t, url, nil, endpoint.expectedHTTPStatus, endpoint.expectedHTTPBody, 5, 5*time.Second)
	}

}

func TestCloudFrontDomainEndpoints(t *testing.T) {

	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
	}

	//defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	for _, endpoint := range cloudfrontDomainsEndpoint {
		url := fmt.Sprintf("%s://%s/%s", endpoint.HTTPProtocol, terraform.Output(t, terraformOptions, endpoint.terraformOutput), endpoint.path)

		http_helper.HttpGetWithRetryWithCustomValidation(t, url, nil, 5, 5*time.Second, func(status int, body string) bool {
			return status == endpoint.expectedHTTPStatus && strings.Contains(body, endpoint.expectedHTTPBodyContains)
		})
	}

}
