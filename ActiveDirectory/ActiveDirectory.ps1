Configuration ActiveDirectory {

    Param(
        [Parameter(Mandatory)]
        [pscredential]$safemodeAdministratorCred,
        [Parameter(Mandatory)]
        [pscredential]$domainCred
    )

    Install-Module xActiveDirectory
    Install-Module xDnsServer
    Install-Module xNetworking
    Install-Module xDHCpServer
    Install-Module xHyper-V
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -module 'xDnsServer', 'xNetworking', 'xActiveDirectory', 'xDHCpServer', 'xHyper-V'

    Node $AllNodes.Where{$_.Role -eq "HyperV"}.NodeName
    {
        LocalConfigurationManager
        {
            ActionAfterReboot = "ContinueConfiguration"
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }

        WindowsFeature HyperV
        {
            Ensure = 'Present'
            Name = 'Hyper-V'
            IncludeAllSubFeature = $true
        }

        WindowsFeature HyperV-Tools
        {
            Ensure = 'Present'
            Name = 'Hyper-V-Tools'
            IncludeAllSubFeature = $true
        }

        WindowsFeature HyperVPowershell
        {
            Ensure = 'Present'
            Name = 'Hyper-V-PowerShell'
        }

        [Int]$Count=0
        foreach($VM in $Node.Vms)
        {
            $Count++
            xVMSwitch "Switch$Count"
            {
                Name = $VM.SwitchName
                Ensure = 'Present'
                Type = 'Internal'
            }

            xVHD "VHD$Count"
            {
                Name = "DATA$Count"
                Ensure = 'Present'
                Path = $VM.PathHddVM
                Generation = "vhd"
                MaximumSizeBytes = $VM.SizeHDD
                DependsOn = "[WindowsFeature]HyperVPowershell", "[WindowsFeature]HyperV-Tools", "[WindowsFeature]HyperV" 
            }

            xVMHyperV "VM$Count"
            {
                Ensure = 'Present'
                Name = $VM.Name
                VhdPath = $VM.PathOsHdd
                Generation = 1
                SwitchName = $VM.SwitchName
                StartupMemory = $VM.StartupMemory
                MinimumMemory = $VM.MinimumMemory
                MaximumMemory = $VM.MaximumMemory
                ProcessorCount = $VM.ProcessorCount
                State = $VM.State
                RestartIfNeeded = $true
                DependsOn = "[WindowsFeature]HyperVPowershell", "[WindowsFeature]HyperV-Tools", "[WindowsFeature]HyperV"
            }

            xVMHardDiskDrive "ExtraDisk$Count"
            {
                VMName = $VM.Name
                Path = (Join-Path -Path $VM.PathHddVM -ChildPath "DATA$Count.Vhd")
                ControllerType = 'IDE'
                ControllerNumber = 0
                ControllerLocation = 1
                Ensure = 'Present'
            }
        }
    }

    Node $AllNodes.Where{$_.Role -eq "ActiveDirectory"}.NodeName
    {
        LocalConfigurationManager
        {
            ActionAfterReboot = "ContinueConfiguration"
            ConfigurationMode = 'ApplyOnly'
            RebootNodeIfNeeded = $true
        }        
        File ADFiles
        {
            DestinationPath = 'C:\Windows\NTDS'
            Type = 'Directory'
            Ensure = 'Present' 
        }

        WindowsFeature ADDSInstall
        {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        }

        WindowsFeature ADDSTools
        {
            Ensure = 'Present'
            Name = 'RSAT-ADDS'
        }

        xADDomain FirstDS
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCred
            SafemodeAdministratorPassword = $safemodeAdministratorCred 
            DatabasePath = 'C:\Windows\NTDS'
            LogPath = 'C:\Windows\NTDS'
            SysvolPath = 'C:\Windows\SYSVOL'
            DependsOn = "[WindowsFeature]ADDSInstall","[File]ADFiles"
        }

        xADDomainDefaultPasswordPolicy Policy
        {
            DomainName = $Node.DomainName
            MinPasswordLength = 4
            ComplexityEnabled = $true
        }
    }

    Node $AllNodes.Where{$_.Role -eq "DNS"}.NodeName {

        WindowsFeature DNS
        {
            Ensure = 'Present'
            Name = 'DNS'
        }
        
        foreach ($ARec in $Node.ARecords.keys){
            xDNSRecord $ARec
            {
                Ensure  = 'Present'
                Name    = $ARec
                Zone    = $Node.zone
                Type    = 'ARecord'
                Target  = $Node.ARecords[$ARec]
                DependsON = '[WindowsFeature]DNS'
            }
        }

        foreach ($CName in $Node.CNameRecords.keys) {
            xDnsRecord $CName
            {
                Ensure    = 'Present'
                Name      = $CName
                Zone      = $Node.zone
                Type      = 'CName'
                Target    = $Node.CNameRecords[$CName]
                DependsOn = '[WindowsFeature]DNS'
            }
        }
    }

    Node $AllNodes.Where{$_.Role -eq "DHCP"}.NodeName {

        WindowsFeature DHCP
        {
            Ensure = 'Present'
            Name = 'DHCP'
            IncludeAllSubFeature = $true
        }

        WindowsFeature DHCP-tools
        {
            Ensure = 'Present'
            Name = 'RSAT-DHCP'
            IncludeAllSubFeature = $true
        }

        [Int]$Count=0
        foreach ($Scope in $Node.Scopes) {
            $Count++
            xDhcpServerScope "Scope$Count"
            {
                Ensure = 'Present'
                IPStartRange = $Scope.Start
                IPEndRange = $Scope.End
                Name = $Scope.Name
                SubnetMask = $Scope.SubnetMask
                State = 'Active'
                LeaseDuration = '00:08:00'
                AddressFamily = $Scope.AddressFamily
                DependsOn = '[WindowsFeature]DHCP'
            }
        }

        [Int]$Count=0
        foreach ($Reservation in $Node.Reservations) {
            $Count++
            xDhcpServerReservation "Reservation$Count"
            {
                Ensure = 'Present'
                ScopeID = $Reservation.ScopeId
                ClientMACAddress = $Reservation.ClientMACAddress
                IPAddress = $Reservation.IPAddress
                Name = $Reservation.Name
                AddressFamily = $Reservation.AddressFamily
                DependsOn = '[WindowsFeature]DHCP'
            }
        }

        [Int]$Count=0
        foreach ($ScopeOption in $Node.ScopeOptions) {
            $Count++
            xDhcpServerOption "ScopeOption$Count"
            {
                Ensure = 'Present'
                ScopeID = $ScopeOption.ScopeId
                DnsDomain = $Node.DomainName
                DnsServerIPAddress = $ScopeOption.DNServerIPAddress
                Router = $ScopeOption.Router
                AddressFamily = $ScopeOption.AddressFamily
                DependsOn = '[WindowsFeature]DHCP'
            }
        }
    }
}

ActiveDirectory -configurationData '.\host.psd1'`
-safemodeAdministratorCred (Get-Credential -UserName '(Password Only)' `
-Message "New Domain Safe Mode Administrator Password") `
-domainCred (Get-Credential `
-Message "New Domain Admin Credential") 

Set-DSCLocalConfigurationManager -Path .\ActiveDirectory -Verbose
Start-DscConfiguration -Wait -Force -Path .\ActiveDirectory -Verbose 