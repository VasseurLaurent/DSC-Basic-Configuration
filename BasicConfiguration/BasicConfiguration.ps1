# Start-DscConfiguration -Path "Z:\Script\DSC-Configuration\BasicConfiguration" -Verbose -Credential (Get-Credential)

Configuration BasicConfiguration {

        Import-DscResource -ModuleName PsDesiredStateConfiguration
        Import-DscResource -ModuleName xRemoteDesktopAdmin
        Import-DscResource -ModuleName xNetworking
        Import-DscResource -ModuleName xComputerManagement

        Node localhost {

            # Activate SNMP service 
            WindowsFeature SNMP-Service
            {
                Name = "SNMP-Service"
                Ensure = "Present"
            }
            # Allow Secure RDP connection
            xRemoteDesktopAdmin RemoteDesktopSettings
            {
                Ensure = "Present"
                UserAuthentication = "Secure"
            }
            # Create Firewall rules
            xFirewall AllowRDP
            {
                Name = 'DSC Remote Desktop Admin Connections'
                Group = 'Remote Desktop'
                Ensure = 'Present'
                Enabled = "True"
                Action = 'Allow'
                Profile = 'Private'
            }

            # Administrateur account in RDP group
            Group RDPGroup
            {
                Ensure = 'Present'
                GroupName = "Remote Desktop Users"
                Members = 'WIN2016\Administrateur'
            }

            xComputer ComputerName
            {
                Name = "WIN2016"
            }

            xIPAddress ipaddress
            {
                AddressFamily = "IPv4"
                InterfaceAlias = "Ethernet0"
                IPAddress = $Node.IPAddress
            }

            xDNSServerAddress dnsaddress 
            {
                AddressFamily = "IPv4"
                InterfaceAlias = "Ethernet0"
                Address = $Node.Dnsserver
            }

            xDefaultGatewayAddress gatewayaddress 
            {
                AddressFamily = "IPv4"
                InterfaceAlias = "Ethernet0"
                Address = $Node.Gateway
            }

            xDHCPClient dhcpstate 
            {
                AddressFamily = "IPv4"
                InterfaceAlias = "Ethernet0"
                State = "Disabled"
            }

        }
}
BasicConfiguration -ConfigurationData Data.psd1