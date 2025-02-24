<#
.SYNOPSIS
    This script performs DNS resolution (A records) on a list of URLs and saves the results to a text file.
    The script will exclude IPv6 addresses and list each resolved IP address on a new line in the output file.

.DESCRIPTION
    The script reads a list of fully qualified domain names (FQDNs), performs a DNS lookup for each using Resolve-DNSName,
    filters out any IPv6 addresses, and writes the results to a file. The output includes both the original FQDN -> IP mapping
    and a separate list of all resolved IP addresses (one per line).

.PARAMETER urls
    A list of domain names to be resolved (In this case Five9 URLs).

.EXAMPLE
    .\nslookup_script.ps1
    This example runs the script, resolving the domain names and saving the results to 'nslookup_results.txt'.

.NOTES
    File Name      : nslookup_script.ps1
    Author         : Alan Matson
    Version        : 1.0
    Date           : 2025-02-24
    PowerShell     : v5.1 or higher
    Dependencies   : None

#>

# List of URLs (cleaned up without 'https://' and trailing slashes)
$urls = @(
    "login.five9.com", "app.five9.com", "app-scl.five9.com", "app-atl.five9.com",
    "us1.five9.com", "us8.five9.com", "us6.five9.com", "us9.five9.com",
    "webstatic.five9.com", "ws1.five9.com", "ws8.five9.com", "ws6.five9.com",
    "ws9.five9.com", "api.prod.us.five9.net", "cdn.prod.us.five9.net",
    "login.auth.five9.com", "auth.five9.com", "sso1.auth.five9.com",
    "migrate.auth.five9.com", "admin.us.five9.net", "www.five9university.com",
    "documentation.five9.com", "community.five9.com", "webswing.prod.us.five9.net"
)

# Create or open the file for writing results
$outputFile = "nslookup_results.txt"
New-Item -Path $outputFile -Force

# Function to perform Resolve-DNSName and filter out IPv6 addresses
function Get-IPAddresses {
    param (
        [string]$url
    )

    try {
        # Perform Resolve-DNSName
        $result = Resolve-DNSName -Name $url -Type A

        # Extract only IPv4 addresses
        $ips = $result | Where-Object { $_.IPAddress -match "^\d+\.\d+\.\d+\.\d+$" } | ForEach-Object { $_.IPAddress }
        return $ips
    } catch {
        return @()
    }
}

# Initialize an empty array to hold IP addresses for separate listing
$allIPAddresses = @()

# Iterate over each URL and resolve its IP addresses
Add-Content -Path $outputFile -Value "# List of Resolved addresses:"
foreach ($url in $urls) {
    $ipAddresses = Get-IPAddresses -url $url
    if ($ipAddresses.Count -gt 0) {
        # If there are IPs, write them to the output file
        $ipList = $ipAddresses -join ", "
        Add-Content -Path $outputFile -Value "$url -> $ipList"

        # Append each IP (one per line) to the allIPAddresses array
        $allIPAddresses += $ipAddresses
    } else {
        # If no IPs found, indicate so in the file
        Add-Content -Path $outputFile -Value "$url -> No IP addresses found"
    }
}

# Remove duplicate IP addresses by converting the array to a hash set
$uniqueIPAddresses = $allIPAddresses | Sort-Object -Unique

# Append the list of all unique IP addresses (one per line)
Add-Content -Path $outputFile -Value "`n# List of all IP addresses (one per line):"
foreach ($ip in $uniqueIPAddresses) {
    Add-Content -Path $outputFile -Value $ip
}

Write-Host "NSLOOKUP results saved to '$outputFile'."
