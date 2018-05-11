@{
    AllNodes = @(

        @{
            NodeName    = "localhost"
            Range = @{
                Range1 = @{
                    NameRange = 'rangeDHCP'
                    StartRange = '192.168.17.10'
                    EndRange = '192.168.17.250'
                    SubnetMaskRange = '255.255.255.0'
                    StateRange = 'Active'
                }
                Range2 = @{
                    NameRange = 'rangeDHCP'
                    StartRange = '192.168.18.10'
                    EndRange = '192.168.18.250'
                    SubnetMaskRange = '255.255.255.0'
                    StateRange = 'Active'
                }
                Range3 = @{
                    NameRange = 'rangeDHCP'
                    StartRange = '192.168.19.10'
                    EndRange = '192.168.19.250'
                    SubnetMaskRange = '255.255.255.0'
                    StateRange = 'Active'
                }     
            } 
        }
    )
}
