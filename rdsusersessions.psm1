import-module remotedesktop
<#
      .SYNOPSIS 
      Disconnects all users from a RDS Session host based on their connection 
      state.

      .DESCRIPTION
      Retrieves a list of connected sessions from a specificed RDS Session 
      Host and recursively disconnects each one for quick flush down of connections
      to a Session Host

      .PARAMETER server
      Specifies the Session host to use. Use tab to cycle through the options.
      
      .PARAMETER connectionState
      Specifies what connection state is necessary

      .NOTES
        AUTHOR: Edward Snow
        LAST EDIT: 01/08/2016 10:31

      .EXAMPLE
      C:\PS> disconnect-allRdsUser -server rds-serv-1 -connectionState disconnected
      
      This will log off all sessions from rds-serv-1 which are in a disconnected state.

      .EXAMPLE
      C:\PS> disconnect-allRdsUser -server rds-serv-2 -connectionState all
      
      This will log off all sessions from rds-serv-2, regardless of their session state.
#>

function disconnect-allRdsUser {

    param(
        [Parameter(Mandatory=$true)][ValidateSet("rds-serv-1", "rds-serv-2", "rds-serv-3")][string]$server,
        [Parameter(Mandatory=$true)][ValidateSet("disconnected", "active", "all")][string]$connectionState
    )

    if ($connectionState -eq "disconnected") {

        $sessions = (get-rdusersession | where {(($_.hostserver -like "*$server*") -and ($_.sessionstate -eq "STATE_DISCONNECTED"))}).UnifiedSessionId

    } elseif ($connectionState -eq "active") {

        $sessions = (get-rdusersession | where {(($_.hostserver -like "*$server*") -and ($_.sessionstate -eq "STATE_ACTIVE"))}).UnifiedSessionId

    } elseif ($connectionState -eq "all") {

        $sessions = (get-rdusersession | where {$_.hostserver -like "*$server*"}).UnifiedSessionId

    } else {

        write-warning "Please select a valid state for the connectionState parameter ('disconnected', 'active' or 'all')"

    }

    foreach ($session in $sessions) {

        Invoke-RDUserLogoff -HostServer $server -UnifiedSessionID $session -Force
        write-host "Disconnecting session ID: $session..."

    }

}

<#
      .SYNOPSIS 
      Displays all users from a RDS Session host based on their connection 
      state.

      .DESCRIPTION
      Retrieves a list of connected sessions from a specificed RDS Session 
      Host.

      .PARAMETER server
      Specifies the Session host to use. Use tab to cycle through the options.
      
      .PARAMETER connectionState
      Specifies what connection state is necessary
      
      .NOTES
        AUTHOR: Edward Snow
        LAST EDIT: 01/08/2016 10:31

      .EXAMPLE
      C:\PS> disconnect-allRdsUser -server rds-serv-1 -connectionState disconnected
      
      This will log off all sessions from rds-serv-1 which are in a disconnected state.

      .EXAMPLE
      C:\PS> disconnect-allRdsUser -server rds-serv-2 -connectionState all
      
      This will log off all sessions from rds-serv-2, regardless of their session state.
#>

function get-allrdsuser {

    param(
        [ValidateSet("rds-serv-1", "rds-serv-2", "rds-serv-3")][string]$server,
        [ValidateSet("disconnected", "active", "all")][string]$connectionState
    )

    if ($connectionState -eq "disconnected") {

        get-rdusersession | where {(($_.hostserver -like "*$server*") -and ($_.sessionstate -eq "STATE_DISCONNECTED"))}

    } elseif ($connectionState -eq "active") {

        get-rdusersession | where {(($_.hostserver -like "*$server*") -and ($_.sessionstate -eq "STATE_ACTIVE"))}

    } elseif ($connectionState -eq "all") {

        get-rdusersession | where {$_.hostserver -like "*$server*"}

    } else {

        write-warning "Please select a valid state for the connectionState parameter ('disconnected', 'active' or 'all')"

    }

}
