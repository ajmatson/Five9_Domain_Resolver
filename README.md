# Five9_Domain_Resolver

The script reads a list of fully qualified domain names (FQDNs) manually added for Five9 per their Technical Requirements Documentation, performs a DNS lookup for each using Resolve-DNSName,
filters out any IPv6 addresses, and writes the results to a file. The output includes both the original FQDN -> IP mapping and a separate list of all resolved IP addresses (one per line).

This list can then be used for enasureing your proxies/firewalls have the correct IP mapping for items such as WCCP exclusions, Policy Based Routes, etc. This list is only for the Advertised
Five9 Domains, this list does not include what IP addresses they specifcially provide without FQDN in the same document.

