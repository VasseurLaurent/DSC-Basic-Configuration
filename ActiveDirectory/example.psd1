@{
    AllNodes = @(
        @{
            NodeName = "*"
        },

        @{
            NodeName = "localhost"
            Role = "ActiveDirectory","DHCP", "DNS"
#            Role = "HyperV"
            DomainName = "domain.com"
            Zone = "domain.com"
            RetryCount = 20
            RetryIntervalSec = 30
            PsDscAllowPlainTextPassword = $true

            ARecords = @{
                'laurent' = '192.168.22.2'
                'thedns' = '192.168.22.100'
            }
            CNameRecords = @{
                'DNS' = 'thedns.domain.com'
            }
            Scopes = @(
                @{
                    Name = 'Site A Primary';
                    Start = '192.168.22.150';
                    End = '192.168.22.200';
                    SubnetMask = '255.255.255.0';
                    AddressFamily = 'IPv4'
                }
            )
            Reservations = @(
                @{
                    Name = 'SA-DC1';
                    ScopeID = '192.168.22.0';
                    ClientMACAddress = '000000000000';
                    IPAddress = '192.168.22.205';
                    AddressFamily = 'IPv4'
                },
                @{
                    Name = 'SA-DC2';
                    ScopeID = '192.168.22.0';
                    ClientMACAddress = '0000000000fef';
                    IPAddress = '192.168.22.206';
                    AddressFamily = 'IPv4'
                }
            )
            ScopeOptions = @(
                @{
                    ScopeID = '192.168.22.0';
                    DNServerIPAddress = @('192.168.22.12','8.8.8.8');
                    Router = '192.168.22.2';
                    AddressFamily = 'IPv4'
                }
            )
            Vms = @(
                @{
                    Name = 'VMtest1'
                    SwitchName = 'Switchtest'
                    PathHddVM = 'C:\Users\Administrateur\Documents\'
                    SizeHDD = 20GB
                    PathOsHdd = "C:\Users\Administrateur\Documents\OS2012R2.vhdx"
                    StartupMemory = 3GB
                    MinimumMemory = 3GB
                    MaximumMemory = 4GB
                    ProcessorCount = 2
                    State = 'off'
                }
            )
        }
    )
}