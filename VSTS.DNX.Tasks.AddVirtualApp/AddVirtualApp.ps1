﻿[CmdletBinding(DefaultParameterSetName = 'None')]
param (
    [String] [Parameter(Mandatory = $true)]
    $ConnectedServiceName,
    [String] [Parameter(Mandatory = $true)]
    $WebAppName,
    [String] [Parameter(Mandatory = $false)]
    $DeployToSlotFlag,
    [String] [Parameter(Mandatory = $false)]
    $ResourceGroupName,
    [String] [Parameter(Mandatory = $false)]
    $SlotName,

    [String] [Parameter(Mandatory = $true)]
    $VirtualApplicationName
)

Write-Verbose "Entering script AddVirtualApp.ps1"

Write-Host "Parameter Values:"
foreach($key in $PSBoundParameters.Keys)
{
    Write-Host ("    $key = $($PSBoundParameters[$key])")
}
Write-Host " "

Function Main
{
    $web = Get-AzureRmResource -ResourceGroupName SWMH-O365-Dashboard -ResourceType Microsoft.Web/sites/slots/config -ResourceName swmh-o365-dashboard/feature/web -ApiVersion 2015-08-01

    $newApp = @"
{
    "virtualPath": "/$VirtualApplicationName",
    "physicalPath": "site\\$VirtualApplicationName",
    "preloadEnabled": false,
    "virtualDirectories": null
}
"@ | ConvertFrom-Json

    if(-Not( $web.properties.virtualApplications.virtualPath -contains $newApp.virtualPath) )
    {
        $web.properties.virtualApplications += $newApp | select *
        Set-AzureRmResource -PropertyObject $web.properties -ResourceGroupName SWMH-O365-Dashboard -ResourceType Microsoft.Web/sites/slots/config -ResourceName swmh-o365-dashboard/feature/web -ApiVersion 2015-08-01 -Force
        Write-Host "Virtual application added."
    }
    else
    {
        Write-Host "Virtual application allready exists."
    }
}

Main

Write-Verbose "Leaving script BuildWebPackage.ps1"