
Configuration hyperV {

    Import-DscResource -ModuleName PsDesiredStateConfiguration
    Import-DscResource -ModuleName xHyper-V

    Node localhost
    {
        WindowsFeature HyperV
        {
            Ensure = 'Present'
            Name = 'Hyper-V'
            IncludeAllSubFeature = $true
        }

        WindowsFeature Hype
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

        $HyperVDependency = '[WindowsFeature]HyperV','[WindowsFeature]HyperVPowerShell'
        $OSdisk = "$($Node.VMName)-OSDisk.vhdx"

        xVHD NewVhd
        {
            Ensure              = 'Present'
            Name                = $OSdisk
            Path                = $Node.PathVM
            Generation          = 'vhdx'
            MaximumSizeBytes    = $Node.Size
            DependsOn           = $HyperVDependency
        }

        xVMSwitch switch 
        { 
            Name =  $Node.SwitchName
            Ensure = "Present"         
            Type = "Internal" 
        } 

        xVMHyperV newVM
        {
            Ensure              = 'Present'
            Name                = $Node.VMName
            VhdPath             = (Join-Path -Path $Node.PathVM -ChildPath $OSdisk)
            SwitchName          = $Node.SwitchName
            State               = $Node.State
            Path                = $Node.PathVM
            Generation          = 2
            StartupMemory       = $Node.StartupMemory
            MinimumMemory       = $Node.MinimumMemory
            MaximumMemory       = $Node.MaximumMemory
            ProcessorCount      = $Node.ProcessorCount
            RestartIfNeeded     = $true
            DependsOn           = '[xVHD]NewVhd'
        }

        xVMDvdDrive Os
        {
            Ensure              = 'Present'
            VMname              = $Node.VMName
            ControllerNumber    = 0
            ControllerLocation  = 1
            Path                = "C:\Users\Administrateur.WIN-DT20MVGI1JM\Documents\debian-8.3.0-amd64-i386-netinst.iso"
            DependsOn           = '[xVMHyperV]newVM'
        }   


    }

}
hyperV -ConfigurationData Data.psd1