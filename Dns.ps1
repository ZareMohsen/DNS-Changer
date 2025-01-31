# First Step: Get the list of network adapters
function List-NetworkAdapters {
    # Get the list of network adapters
    $adaptersMan = Get-NetAdapter

    # Check if any adapters were found
    if ($adaptersMan.Count -eq 0) {
        Write-Host "No network adapters found."
        return
    }

    # Display information for each adapter
    $counterMan = 1
    foreach ($adapterMan in $adaptersMan) {
        Write-Host "${counterMan}: Name: $($adapterMan.Name), Status: $($adapterMan.Status), Link Speed: $($adapterMan.LinkSpeed)"
        $counterMan++
    }

    # Prompt user to select an adapter
    $choiceMan = Read-Host "Select a network adapter by number"     
    # Validate choice
    if ($choiceMan -gt 0 -and $choiceMan -le $adaptersMan.Count) {
        # Call the shabake function with the selected adapter name
        shabake $adaptersMan[$choiceMan - 1].Name
    } else {
        Write-Host "Invalid selection!"
    }
}

function shabake {
    param (
        [string]$adapterNameMan
    )
    
    # Display the selected adapter name
    # Write-Host "You have selected the adapter: $adapterNameMan"
      $global:adapterNameMan=$adapterNameMan
}

# Call the function to display the list of adapters
List-NetworkAdapters


$dnsOptions = @{
    1 = @("1.1.1.1", "1.0.0.1", "Cloudflare")
    2 = @("8.8.8.8", "8.8.4.4", "Google")
    3 = @("178.22.122.100", "185.51.200.2", "Shecan")
    4 = @("208.67.222.222", "208.67.220.220", "OpenDNS")
    5 = @("9.9.9.9", "149.112.112.112", "Quad9")
}

function Display-AdapterInfo {
    # Get the specified network adapter's information
    $adapters = Get-NetAdapter | Where-Object { $_.Name -ieq $global:adapterNameMan }
    
    if ($adapters.Count -eq 0) {
        Write-Host "Network adapter not found."
        return $null
    }

    $adapter = $adapters[0]
    Write-Host "Selected Adapter: $($adapter.Name) (Status: $($adapter.Status))"

    # Get IP configuration for the selected adapter
    try {
        $ipConfig = Get-NetIPConfiguration | Where-Object { $_.NetAdapter.Name -eq $adapter.Name }

        if ($ipConfig) {
            # Extract IPv4 Address and Default Gateway
            $ipv4Address = $ipConfig.IPv4Address | ForEach-Object { $_.IPAddress }
            $defaultGateway = $ipConfig.IPv4DefaultGateway | ForEach-Object { $_.NextHop }

            if ($ipv4Address) {
                Write-Host "IP Address: $ipv4Address"
            } else {
                Write-Host "No IP address assigned."
            }

            if ($defaultGateway) {
                Write-Host "Default Gateway: $defaultGateway"
            } else {
                Write-Host "No default gateway configured."
            }
        } else {
            Write-Host "No IP configuration found for this adapter."
        }
    } catch {
        Write-Host "Error retrieving network information: $_"
    }

    Write-Host "----------------------------------------"
    return $adapter
}







function Test-DnsSpeed {
    param (
        [string[]]$dnsServers,
        [string[]]$testDomains
    )

    $results = @()

    foreach ($dns in $dnsServers) {
        foreach ($domain in $testDomains) {
            try {
                $startTime = Get-Date
                Resolve-DnsName -Name $domain -Server $dns -ErrorAction Stop | Out-Null
                $elapsedTime = (Get-Date) - $startTime
                $results += [PSCustomObject]@{
                    DnsServer   = $dns
                    Domain      = $domain
                    ResponseTime = $elapsedTime.TotalMilliseconds
                }
            } catch {
                $results += [PSCustomObject]@{
                    DnsServer   = $dns
                    Domain      = $domain
                    ResponseTime = "Failed"
                }
            }
        }
    }

    return $results
}

function Display-DnsOptions {
    $testDomains = @("www.codeyad.com", "www.w3schools.com")
    Write-Host "Testing DNS servers..."
    $allResults = @()

    foreach ($key in ($dnsOptions.Keys | Sort-Object)) {
        $primaryDns = $dnsOptions[$key][0]
        $dnsGroup = $dnsOptions[$key][2]

        Write-Host "Testing DNS: ${primaryDns} ($dnsGroup)"
        
        $results = Test-DnsSpeed -dnsServers @($primaryDns) -testDomains $testDomains

        foreach ($result in $results) {
            $allResults += [PSCustomObject]@{
                DnsOption   = "${primaryDns} ($dnsGroup)"
                Domain      = $result.Domain
                ResponseTime = if ($result.ResponseTime -ne "Failed") { [int]$result.ResponseTime } else { [int]::MaxValue }
                Group       = $dnsGroup
            }
        }
    }

    Write-Host "Available DNS options with response times:"
    Write-Host "----------------------------------------"
    $groupedResults = $allResults | Group-Object -Property Group
    $groupNumber = 1

    foreach ($group in $groupedResults) {
        Write-Host " $groupNumber. $($group.Name) DNS Servers:"
        foreach ($result in $group.Group) {
            Write-Host "$($result.DnsOption): Response Time for $($result.Domain): $(if ($result.ResponseTime -ne [int]::MaxValue) { "$($result.ResponseTime) ms" } else { "Failed" })"
        }
        Write-Host "----------------------------------------"
        $groupNumber++
    }

    Write-Host "6: Restore to Automatic (DHCP)"
    Write-Host "7: Run DNS tests again"
      Write-Host "8: Change DNS for other Network Device (Restart Script)"

    $choice = Read-Host "Please select a number (1-8)"

    if ($choice -ge 1 -and $choice -le 5) {
        if ($dnsOptions.ContainsKey([int]$choice)) {
            $selectedDnsServers = @($dnsOptions[[int]$choice][0], $dnsOptions[[int]$choice][1])

            # Ensure the selected adapter is valid
            if ($adapter -ne $null) {
		# Show the adapter name before applying the DNS change
		Write-Host "----------------------------------------"
            	Write-Host "	Changing DNS settings for adapter: $($adapter.Name)"
                Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses @($selectedDnsServers)
                Write-Host "	DNS changed to: $(($selectedDnsServers -join ', '))"
            } else {
                Write-Host "Invalid adapter selected."
            }
        } else {
            Write-Host "Invalid selection!"
        }
    } elseif ([int]$choice -eq 6) {
        # Reset DNS settings to DHCP
        if ($adapter -ne $null) {
            Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ResetServerAddresses
            Write-Host "DNS restored to automatic (DHCP)."

            Write-Host "Executing network reset commands..."

            Write-Host "Resetting Winsock..."
            netsh winsock reset
            Write-Host "Successfully reset the Winsock Catalog."

            Write-Host "Flushing DNS cache..."
            ipconfig /flushdns

            Write-Host "Releasing current IP address..."
            ipconfig /release

            Write-Host "Renewing IP address..."
            ipconfig /renew
	      # Show the adapter name before applying the DNS change
	      Write-Host "----------------------------------------"
            Write-Host "	Changing DNS settings for adapter: $($adapter.Name)"
            Write-Host "	DNS changed to: automatic (DHCP)"
	      List-NetworkAdapters
	      

        } else {
            Write-Host "No adapter found to reset."
        }
    } elseif ([int]$choice -eq 7) {
        Display-DnsOptions
    } elseif ([int]$choice -eq 8) {
        List-NetworkAdapters
    }  else {
        Write-Host "Invalid selection!"
    }
}

# Step 1: Display shabake adapter info and ensure it's correctly selected
$adapter = Display-AdapterInfo

# Step 2: Apply DNS changes for the shabake adapter only if the adapter is found
if ($adapter -ne $null) {
    Display-DnsOptions
} else {
    Write-Host "No valid shabake adapter found. Exiting..."
}
$currentPID = $PID
Start-Sleep -Seconds 4
Stop-Process -Id $currentPID
