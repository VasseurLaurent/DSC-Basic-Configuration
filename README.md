# Welcome to my Powershell-DSC Configuration repository
Hello everybody, my name is Laurent VASSEUR , and I am an IT engineering student.

This repository has been created to gathers all my personal work on Windows server 2016 configuration through Powershell DSC script. 

Into this repository you will find one script written in Powershell DSC with 4 different feature : 
- Configuration of Active Directory server 
- Configuration of DNS server
- Configuration of DHCP server 
- Configuration of Hyper-V server

## How does it work ? 
To configure servers through Powershell DSC script, you will need two kind of script : 

-  Host file (with extension .psd1), in this file you will describe your server feature 
For example : 
I want my server to have the role DHCP 

```
@{
 
   @{
      NodeName = "localhost"
      Role = "DHCP"
    }
 
}
```

To see all available variable please read the example.psd1 file 

- The Role file, in this file I will define what are roles 

In this file I defined 4 roles : 

- Hyper V 
--> This role installs HyperV, HyperV-tools, HypervPowershell, create a VM (switch + vhd)
- Active directory
--> This role installs ADDS and create a forest
- DHCP
--> This role installs DHCP feature, creates range, reservation etc ..
- DNS
--> This role installs DNS feature, creates record etc ...


If you like my work and want to know more about me : 
* [Linkedin](https://www.linkedin.com/in/laurent-vasseur-b87b60130/)
* Email : vasseur.laurent@outlook.com
