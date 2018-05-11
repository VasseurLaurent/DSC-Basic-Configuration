Configuration Dhcpserver{

    Import-DscResource -ModuleName xDhcpServer
    Import-DscResource -ModuleName PsDesiredStateConfiguration
    
    Node localhost {
    
        foreach ($range in $Node.Range.value){
            xDhcpServerScope Scope 
            {
                Ensure = 'Present'
                Name = $range.NameRange
                IPStartRange = $range.StartRange
                IPEndRange = $range.IPEndRange
                SubnetMask = $range.SubnetMaskRange
                State = $range.StateRange
                AddressFamily = 'IPv4'
            }
        }
    }
}

Dhcpserver -ConfigurationData Data.psd1