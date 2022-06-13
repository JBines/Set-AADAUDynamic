<# 
.SYNOPSIS
This script automates the population of Users and Administrators to Azure AD Administrative Units.

.DESCRIPTION
Automation is completed by targeting Dynamic or Static Azure AD Groups which will populate the 
Administrative Unit with Users and Administrators for the selected scope. 

## Set-AADAUDynamic.ps1 [-AADAdminUnit <array[ObjectID],[ObjectID]>] [-UserGroup <string[ObjectID]>] 
[-AdminGroup <array[ObjectID]>] [-GroupFilter <string[description_field*]>] [-RoleIds <array[ObjectID]>]
 [-RoleIds <array[ObjectID]>] [-AutomationPSCredential <string[Name]>] 
 [-AutomationPSCertificate <string[Name]>] [-AutomationPSConnection <string[Name]>]

.PARAMETER AADAdminUnit
The AADAdminUnit parameter specifies the ObjectId of the Administrative Unit. You can find this 
value by running Get-AzureADAdministrativeUnit 

.PARAMETER UserGroup
The UserGroup parameter details the ObjectId of the Administrative Unit. 
Get-AzureADGroup -SearchString "All Users"

.PARAMETER AdminGroups
The AdminGroup parameter details the ObjectId of the Administrative Unit. 
Get-AzureADGroup -SearchString "All Scoped Admins"

.PARAMETER GroupFilter
The GroupFilter parameter allows to identifiy Groups that can also be added to the Administrative 
Unit. By default we target the Description field of the Group. This uses the default search function
so wild cards are not needed but we recommend choosing something unique so false positives are not 
included in your group filter. 

.PARAMETER DeviceGroups
The DeviceFilter parameter allows for Devices be added to the Administrative Unit. Add the Object 
GUID for Device groups you would like to add and all Devices within these groups will be added to the AU. 

.PARAMETER DifferentialScope
The DifferentialScope parameter defines how many objects can be added or removed from the Administrative 
Units in a single operation of the script. The goal of this setting is throttle bulk changes to limit the 
impact of misconfigurationby an administrator. What value you choose here will be dictated by your userbase 
and your script schedule. The default value is set to 10 Objects. 

.PARAMETER RoleIds
The RoleIds array includes all Object GUIDs for the roles which you would like to assign. Use the 
Get-AzureADDirectoryRole CMDlet to identify the the roles you would like to target. 

.PARAMETER AutomationPSCredential
The AutomationPSCredential parameter defines the automation account that should be used. Please note that 
this requires basic authnetication and is not prefered. Please consider using AutomationPSCertificate & 
AutomationPSConnection  

.PARAMETER AutomationPSCertificate
 The AutomationCertificate parameter defines which Azure Automation Certificate you would like to use which 
 grants access to Azure AD. Parameter must be used with -AutomationPSConnection.

.PARAMETER AutomationPSConnection
 The AutomationPSConnection parameter defines the connection details such as AppID, Tenant ID. Parameter 
 must be used with -AutomationPSCertificate.

.EXAMPLE
.\Set-AADAUDynamic.ps1 -AADAdminUnit '7b7c4926-c6d7-4ca8-9bbf-5965751022c2' -UserGroup '0e55190c-73ee-e811-80e9-005056a31be6' -AdminGroup '0e55190c-73ee-e811-80e9-005056a3' -RoleIds ('947776ed-f72c-41d3-a3c4-d97378087558','556a69f3-7b0b-45a7-b4c0-f35f1eb06dab') -GroupFilter "BU2 Managed Group*" -DeviceGroups 'b1f0f94e-7525-4292-9cc4-3cb053b9599c' -RoleIds ('0a37a06a-5eef-46a1-a3bb-c9e51ff53e72','4e8ab09b-443c-458a-8df0-c9746f4e407c')

-- SET USERS AND HELPDESK ADMINISTRATORS FOR AU --

In this example we add Users and Administrators (with Helpdesk Role) to the Administrative Unit '7b7c4926-c6d7-4ca8-9bbf-5965751022c2' 

.EXAMPLE
.\Set-AADAUDynamic.ps1 -AADAdminUnit '7b7c4926-c6d7-4ca8-9bbf-5965751022c2' -UserGroup '0e55190c-73ee-e811-80e9-005056a31be6' -AdminGroup '0e55190c-73ee-e811-80e9-005056a3' -RoleIds ('569bbd46-9742-4130-ad44-0ebc4fb18374')

-- SET USERS AND HELPDESK & USER ADMINISTRATORS FOR AU --

In this example we add Users and Administrators (with Helpdesk & User Account Role) to the Administrative Unit '7b7c4926-c6d7-4ca8-9bbf-5965751022c2' 

.EXAMPLE
.\Set-AADAUDynamic.ps1 -AADAdminUnit "7b7c4926-c6d7-4ca8-9bbf-5965751022c2"  -UserGroup "0e55190c-73ee-e811-80e9-005056a31be6" -AdminGroups ('0e55190c-73ee-e811-80e9-005056a3','3587ebfc-bb8f-41eb-a043-02bf66361af2') -GroupFilter "Contso Managed Group" -DeviceGroups '3db29ad3-5804-41ac-82d5-4937f71f10e9' -RoleIds ('569bbd46-9742-4130-ad44-0ebc4fb18374')

-- ADD USERS, ADMINISTRATORS, GROUPS AND DEVICES TO AU --

In this example we add Users and Administrators (with Helpdesk & User Account Role) to the Administrative Unit '7b7c4926-c6d7-4ca8-9bbf-5965751022c2' 


.LINK

Azure AD Dynamic Group Membership - https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/groups-dynamic-membership

Log Analytics Workspace - https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-create-workspace

.NOTES

IMPORTANT! This function requires that you have already created your Adminstrative Unit, the Group containing user objects and the Group containing Admin objects. You will also need the ObjectID for roles Helpdesk Administrator or User Account Administrator which can be obtained by running Get-AzureADDirectoryRole

IMPORTANT! Hey! You must use user creds or an Azure Application which is granted the following GRAPH API permissions. 
    
    Directory.Read.All                  - Access Groups and User Information
    AdministrativeUnit.ReadWrite.All    - Add/remove users, groups and devices to administrative units 
    RoleManagement.ReadWrite.Directory  - Add/remove Scoped administrators
    
    Quickstart: https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app
    
NOTE! Please be aware that the DifferentialScope applies to both users and Administrators meaning that large changes will also impact the provensioning of Scoped Administrators. 

NOTE! Script Requires the MSAL.PS Module. Run - Install-Module -Name MSAL.PS - https://www.powershellgallery.com/packages/MSAL.PS

IMPORTANT! The use of client secret is not recommended in production. It is highly recommended that you use 
Certifcate based authenication.

#This code-sample is provided "AS IT IS" without warranty of any kind, either expressed or implied, including but not limited to the implied warranties of merchantability and/or fitness for a particular purpose.
#This sample is not supported under any standard support program or service.
#The entire risk arising out of the use or performance of the sample and documentation remains with you. 
#In no event shall Microsoft, its authors, or anyone else involved in the creation, production, or delivery of the script be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of  the use of or inability to use the sample or documentation, even if Microsoft or others has been advised of the possibility of such damages.

[AUTHOR]
Joshua Bines, Consultant

Find me on:
* Web:     https://theinformationstore.com.au
* LinkedIn:  https://www.linkedin.com/in/joshua-bines-4451534
* Github:    https://github.com/jbines
  
[VERSION HISTORY / UPDATES]
0.0.1 20190514 - JBINES - Created the bare bones
0.0.2 20190221 - JBines - [Feature] Added DifferentialScope Switch, Membership Feeds. 
                            [BUGFIX] Fixed Compare-Object bug on null values. 
0.0.2 20190222 - JBines - [Feature] Added suport for Scoped Administrators, Change script error string to VAR.
0.0.3 20190304 - JBines - [Feature] Added switch for helpdesk and User admin roles. Added Loop. 
                            [BUGFIX] Lots of testing and bug fixes. 
0.0.4 20190305 - JBines - [Feature] Add support for Azure Runbook Creds
1.0.0 20190314 - JBines - [BUGFIX] Begin Process End not supported in azure automation so it has been removed. Other than that it works like a dream... 
1.0.1 20190401 - JBines - [BUGFIX] Found errors with if(-not()) statements with azure automation. Also added a -top for group membership over 100 members. 
1.0.2 20190402 - JBines - [BUGFIX] Reset the counter DifferentialScope for administrators so the DifferentialScope is applied independently for users and Scoped Admins
                            [BUGFIX] Get-AzureADAdministrativeUnitMember is limited to 100 members moved to Get-MsolAdministrativeUnitMember pull all members. 
1.0.3 20191001 - CG     - Changed variable $AdminGroup from String type to $AdminGroups of Array type for maximum flexibility.
1.0.4 20191021 - JBines - [BUGFIX] Added Select-Object -Unique on the $AdminGroups Array and Cleaned Up Code as suggested by CG.
1.1.0 20210621 - JBines - [Feature] Added Support for Modern Authenication via Service Principals.
1.2.0 20210713 - JBines - [Feature] Added Roles Authenication Administrator & Groups Administrator.
1.2.1 20211011 - JBines - [BUGFIX] Fixed role name change from User Account Admin to User Administrator. Allow scoped roles to be updated without removing all objects out of the group. 
1.3.0 20211021 - JBines - [Feature] Script updated to support GA Azure Ad module and options to use modern auth. Removed Requirement for Connect-MsolService with improved GA scope.
                            [Feature] - Add Groups to Admin Unit via GroupFilter Switch.
1.3.1 20211227 - JBines - [Feature] Added switches for the Get-AutomationConnection and removed extra variables which were needed.
1.4.0 20220405 - JBines - [Feature] Added Support for the Devices population of devices. Added RoleIds array and updated script to allow targeted mangement of Roles. 
2.0.0 20220419 - JBines - [Feature] Converted to use Graph API! Major rewrite and Azure AD Module discontinued. Script name changed to Set-AADAUDynamic
2.0.1 20220602 - JBines - [Feature] Added support for PS Version 7

[TO DO LIST / PRIORITY]
    Migrate to Graph API / MED
    Azure Managed Idenities / MED
#>

Param 
(
    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [String]$AADAdminUnit,
    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [String]$UserGroup,
    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [Array]$AdminGroups,
    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [Array]$RoleIds,
    [ValidateNotNullOrEmpty()]
    [string]$GroupFilter,
    [ValidateNotNullOrEmpty()]
    [Array]$DeviceGroups,
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [Int]$DifferentialScope = 30,
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [String]$AppID,
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [String]$TenantID,
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [String]$CertificatePath,
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [String]$ClientSecret,
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [String]$AutomationPSConnection,
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [String]$AutomationPSCertificate
)

    #Set VAR
    $counter = 0

    #Powershell v7
    $PSDefaultParameterValues['Invoke-RestMethod:SkipHeaderValidation'] = $true
    $PSDefaultParameterValues['Invoke-WebRequest:SkipHeaderValidation'] = $true

# Success Strings
    $sString0 = "OUT-GraphAPI:Remove-AzureADAdministrativeUnitMember;AADAU:$AADAdminUnit"
    $sString1 = "IN-GraphAPI:Add-AzureADAdministrativeUnitMember;AADAU:$AADAdminUnit"
    $sString2 = "OUT-GraphAPI:Remove-AzureADScopedRoleMembership;AADAU:$AADAdminUnit"
    $sString3 = "IN-GraphAPI:Add-AzureADScopedRoleMembership;AADAU:$AADAdminUnit;RoleId:"
    
# Info Strings
    $iString0 = "Starting AAD AU Scoped Administrator Role Members"
    $iString1 = "Starting AAD AU User Scope Members"

# Warn Strings
    $wString0 = "CMDlet:Compare-Object;ReferenceObject:Input memberships for Users, Groups or devices is equal to NULL"
    $wString1 = "CMDlet:Compare-Object;DifferenceObject:AAD AU membership is equal to NULL"
    $wString2 = "CMDlet:Compare-Object;ReferenceObject:Admin Group membership is equal to NULL"
    $wString3 = "CMDlet:Compare-Object;DifferenceObject:AAD AU Scoped Role membership is equal to NULL"
    $wString4 = "CMDlet:Compare-Object;DifferenceObject:AAD AU Scoped Role already a member of"

# Error Strings
    $eString0 = "AzureADDirectoryRole not found or more than one exists"
    $eString1 = '$_.Exception.Message'
    $eString2 = "Hey! You made it to the default switch. That shouldn't happen might be a null or returned value."
    $eString3 = "Hey! You hit the -DifferentialScope limit of $DifferentialScope. Let's break out of this loop"
    $eString4 = "Hey! Help us out and put some users in the group."
    $eString5 = "objRoleIdCheck Failed. Please check and confirm the Object GUID is correct: "

# Debug Strings
    $dString0 = "CMDlet:Get-AzureADAdministrativeUnit;ObjectId:$AADAdminUnit;DisplayName:$AADAdminUnit.DisplayName"
    $dString1 = "Starting Scoped Role Members"
    $dString2 = "RoleID Check Appling Role: "

    #Load Functions

    function Write-Log([string[]]$Message, [string]$LogFile = $Script:LogFile, [switch]$ConsoleOutput, [ValidateSet("SUCCESS", "INFO", "WARN", "ERROR", "DEBUG")][string]$LogLevel)
    {
           $Message = $Message + $Input
           If (!$LogLevel) { $LogLevel = "INFO" }
           switch ($LogLevel)
           {
                  SUCCESS { $Color = "Green" }
                  INFO { $Color = "White" }
                  WARN { $Color = "Yellow" }
                  ERROR { $Color = "Red" }
                  DEBUG { $Color = "Gray" }
           }
           if ($Message -ne $null -and $Message.Length -gt 0)
           {
                  $TimeStamp = [System.DateTime]::Now.ToString("yyyy-MM-dd HH:mm:ss")
                  if ($LogFile -ne $null -and $LogFile -ne [System.String]::Empty)
                  {
                         Out-File -Append -FilePath $LogFile -InputObject "[$TimeStamp] [$LogLevel] $Message"
                  }
                  if ($ConsoleOutput -eq $true)
                  {
                         Write-Host "[$TimeStamp] [$LogLevel] :: $Message" -ForegroundColor $Color

                    if($AutomationPSCredential -or $AutomationPSCertificate -or $AutomationPSConnection)
                    {
                         Write-Output "[$TimeStamp] [$LogLevel] :: $Message"
                    } 

                  }
                  if($LogLevel -eq "ERROR")
                    {
                        Write-Error "[$TimeStamp] [$LogLevel] :: $Message"
                    }
           }
    }
    Function Test-CommandExists 
    {

     Param ($command)

         $oldPreference = $ErrorActionPreference

         $ErrorActionPreference = 'stop'

         try {if(Get-Command $command){RETURN $true}}

         Catch {Write-Host "$command does not exist"; RETURN $false}

         Finally {$ErrorActionPreference=$oldPreference}

    } #end function test-CommandExists

    #Validate Input Values From Parameter 

    Try{


        #Check cred Account has all the required permissions ,Get-MailUser,Set-MailUser
        If(Test-CommandExists Get-Item,Get-MsalToken){

            Write-Log -Message "Correct RBAC Access Confirmed" -LogLevel DEBUG -ConsoleOutput

        }
            
        Else {Write-Log -Message "Script requires a higher level of access! You are missing the MSAL.PS PowerShell Module" -LogLevel ERROR -ConsoleOutput; Break}

        If($RemoveExpiredGuests -or $RemoveInactiveGuests -and (-not $InactiveTimeSpan)){

            Write-Log -Message "InactiveTimeSpan parameter is required when using RemoveExpiredGuests or RemoveInactiveGuests" -LogLevel ERROR -ConsoleOutput; 
            Break
        }

        if($CertificatePath) { 

                If($AppID -and $TenantID){
                    ##Import Certificate
                    $Certificate = Get-Item $certificatePath
                    if($Certificate){
                        $Token = Get-MsalToken -ClientId $AppId -TenantId $TenantId -ClientCertificate $Certificate 
                        if($?){ Write-Log -Message "Authenication via Certificate - Completed!" -LogLevel SUCCESS -ConsoleOutput }
                        else {
                            Write-Log -Message "Authenication via Certificate - Failed!" -LogLevel ERROR -ConsoleOutput;
                            break
                        }
                    }
                    else {
                        Write-Log -Message "No Certificate could be found! Try Get-Item certificatePath. Session will require admin access to get the private key." -LogLevel ERROR -ConsoleOutput; 
                        Break
                    }
                    ##Request Token - Cert
                }
                else {
                    Write-Log -Message "Certificate Auth also requires Switches AppID & TenantID" -LogLevel ERROR -ConsoleOutput; 
                    Break
                }
        }
        if($AppID -and $TenantID -and $ClientSecret) { 
            Write-Log -Message "Using ClientSecret for testing ONLY. Folks - not recommended!" -LogLevel WARN -ConsoleOutput
            ##Request Token - Cert
            $Token = Get-MsalToken -clientID $AppID -ClientSecret (ConvertTo-SecureString $ClientSecret -AsPlainText -Force) -tenantID $tenantID
            if($?){ Write-Log -Message "Authenication via ClientSecret - Completed!" -LogLevel SUCCESS -ConsoleOutput }
            else {
                Write-Log -Message "Authenication via ClientSecret - Failed!" -LogLevel ERROR -ConsoleOutput;
                break
            }
        }
        if($AutomationPSConnection -and $AutomationPSCertificate) { 

            #Azure Automation - Certicate Auth
            $Connection = Get-AutomationConnection -Name $AutomationPSConnection
            $Certificate = Get-AutomationCertificate -Name  $AutomationPSCertificate
            $Token = Get-MsalToken -ClientId $Connection.ApplicationId -TenantId $Connection.TenantId -ClientCertificate $Certificate
            if($?){ Write-Log -Message "Azure AUTOMATION - Authenication via Certificate - Completed!" -LogLevel SUCCESS -ConsoleOutput }
            Else{break}

            }
        Else
        {
            Remove-Variable AutomationPSConnection
            Remove-Variable AutomationPSCertificate
        }

        #Obtain Access Token from $token VAR
        $AccessToken = $Token.AccessToken
        
        #Form request headers with the acquired $AccessToken
        #$headers = @{'Content-Type'="application\json";'Authorization'="Bearer $AccessToken"}
        $headers = @{'Content-Type'="application\json";'ConsistencyLevel'="eventual";'Authorization'="Bearer $AccessToken"}

        #Check Admin Unit
        #$objAADAdminUnit = Get-AzureADMSAdministrativeUnit -Id $AADAdminUnit -ErrorAction Stop

        $urlAADAdminUnit = "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$AADAdminUnit"
        $objAADAdminUnit = Invoke-WebRequest -Method 'GET' -Uri $urlAADAdminUnit -Headers $headers -ContentType "application\json" -UseBasicParsing -ErrorAction Stop | ConvertFrom-Json

        #If($?){Write-Log -Message $dString0 -LogLevel DEBUG -ConsoleOutput}

        #$objUserGroup = Get-AzureADGroup -ObjectId $UserGroup -ErrorAction Stop
        $urlUserGroup = "https://graph.microsoft.com/v1.0/groups/$UserGroup"
        $objUserGroup = Invoke-WebRequest -Method 'GET' -Uri $urlUserGroup -Headers $headers -ContentType "application\json" -UseBasicParsing -ErrorAction Stop | ConvertFrom-Json

        
        #New Array and Count of Users from Azure Group
        #$userGroupMembers = Get-AzureADGroupMember -ObjectId $UserGroup -All:$true
        $urlUserGroupMembers = "https://graph.microsoft.com/v1.0/groups/$UserGroup/transitiveMembers/microsoft.graph.user?`$count=true&`$select=displayName,id&`$top=999"
        $userGroupMembers = @()
        while ($null -ne $urlUserGroupMembers) {

            $userGroupMembersResponse = Invoke-WebRequest -Method 'GET' -Uri $urlUserGroupMembers -Headers $headers -UseBasicParsing | ConvertFrom-Json
            If($userGroupMembersResponse."@odata.count"){
                $userGroupMembersCount = $userGroupMembersResponse."@odata.count"
            }
            $userGroupMembers += $userGroupMembersResponse.value
            $urlUserGroupMembers = $userGroupMembersResponse."@odata.nextLink"
        }

        #New Array and Count of Users from Administrative Unit
        #$administrativeUnitMembers = Get-AzureADMSAdministrativeUnitMember -Id $AADAdminUnit -All:$true
        $urlAdministrativeUnitMembers = "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$AADAdminUnit/members?`$select=id&`$top=99"

        $administrativeUnitMembers = @()
        while ($urlAdministrativeUnitMembers -ne $null) {

            $AdministrativeUnitMembersResponse = Invoke-WebRequest -Method 'GET' -Uri $urlAdministrativeUnitMembers -Headers $headers -UseBasicParsing | ConvertFrom-Json
            If($AdministrativeUnitMembersResponse."@odata.count"){
                $AdministrativeUnitMembersCount = $AdministrativeUnitMembersResponse."@odata.count"
            }
            $administrativeUnitMembers += $AdministrativeUnitMembersResponse.value
            $urlAdministrativeUnitMembers = $AdministrativeUnitMembersResponse."@odata.nextLink"
        }

        #Check all role ID's are vaild
        Foreach($objRoleIdCheck in $roleIds){
            $urlRoleIdCheckValue = $null
            $RoleIdCheckValueResponse = $null

            $urlRoleIdCheckValue = "https://graph.microsoft.com/v1.0/directoryRoles/$objRoleIdCheck"
            $RoleIdCheckValueResponse = Invoke-WebRequest -Method 'GET' -Uri $urlRoleIdCheckValue -Headers $headers -UseBasicParsing -ErrorAction Stop | ConvertFrom-Json
            if($RoleIdCheckValueResponse.displayName){Write-Log -Message "$dString2 $($RoleIdCheckValueResponse.displayName)" -LogLevel DEBUG -ConsoleOutput}

        }
        
        #New Array of Administrators from Administrative Unit
        $administrativeUnitScopedRole = @()
        Foreach($objRoleId in $roleIds){

            #$administrativeUnitScopedRole += Get-AzureADMSScopedRoleMembership -Id $AADAdminUnit | Where-Object{$_.RoleId -eq $objRoleId}
            $urladministrativeUnitScopedRole = "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$AADAdminUnit/scopedRoleMembers"

            while ($null -ne $urladministrativeUnitScopedRole) {
    
                $administrativeUnitScopedRoleResponse = Invoke-WebRequest -Method 'GET' -Uri $urladministrativeUnitScopedRole -Headers $headers -UseBasicParsing | ConvertFrom-Json
                If($administrativeUnitScopedRoleResponse."@odata.count"){
                    $AdministrativeUnitMembersCount = $administrativeUnitScopedRoleResponse."@odata.count"
                }
                $administrativeUnitScopedRole += $administrativeUnitScopedRoleResponse.value | Where-Object{$_.roleId -eq $objRoleId}
                $urladministrativeUnitScopedRole = $administrativeUnitScopedRoleResponse."@odata.nextLink"
            }
        }
        
        $administrativeUnitScopedRoleMembers = $administrativeUnitScopedRole.RoleMemberInfo | Select-Object id -Unique
        
        #Create single array of admin users
        #$objUserGroup = @($AdminGroups | ForEach-Object {Get-AzureADGroupMember -ObjectId $_ -All:$true -ErrorAction Stop})
        $objadminGroup = @()
        Foreach($objAdminGroups in $AdminGroups){
            $urlAdminGroupMembers = "https://graph.microsoft.com/v1.0/groups/$objAdminGroups/transitiveMembers/microsoft.graph.user?`$select=id&`$count=true&`$top=999"
            
            while ($null -ne $urlAdminGroupMembers) {
                
                $adminGroupMembersResponse = Invoke-WebRequest -Method 'GET' -Uri $urlAdminGroupMembers -Headers $headers -UseBasicParsing | ConvertFrom-Json
                If($adminGroupMembersResponse."@odata.count"){
                    $adminGroupMembersCount = $adminGroupMembersResponse."@odata.count"
                }
                $objadminGroup += $adminGroupMembersResponse.value
                $urlAdminGroupMembers = $adminGroupMembersResponse."@odata.nextLink"                
            }
        }
        
        $adminGroupMembers = $null
        $adminGroupMembers = $objadminGroup | Select-Object Id -Unique

        #$administrativeUnitScopedRoleMembersNull = $false

        #Find groups by GroupFilter Switch
        If($GroupFilter){
            $Groups = @()
            #$Groups = Get-AzureADGroup -All:$true | Where-Object{$_.Description -like $GroupFilter}

            #Switched to searchfilter based on description field 
            $urlGroupFilter = "https://graph.microsoft.com/v1.0/groups?`$search=`"description:$($GroupFilter)`"&`$count=true&`$top=99"
            while ($null -ne $urlGroupFilter) {
                
                $userGroupFilterResponse = Invoke-WebRequest -Method 'GET' -Uri $urlGroupFilter -Headers $headers -UseBasicParsing | ConvertFrom-Json
                If($userGroupFilterResponse."@odata.count"){
                    $urlGroupFilter = $adminGroupMembersResponse."@odata.count"
                }

                $Groups += $userGroupFilterResponse.value
                $urlGroupFilter = $userGroupFilterResponse."@odata.nextLink"
            }
        }

        #Join Groups and User Arrays together
        $UnitMembers = $null
        $UnitMembers = $userGroupMembers.Id
        if ($Groups.count -gt 0) {
            $UnitMembers += $Groups.Id 
        }

        #Find Devices 
        $Devices = $null
        If($DeviceGroups){
            #$objDevices = @($DeviceGroups | ForEach-Object {Get-AzureADGroupMember -ObjectId $_ -All:$true -ErrorAction Stop})

            $objDeviceGroupMembers = @()
                Foreach($objDeviceGroup in $DeviceGroups){
                    $deviceGroupsMembersResponse = $null
                    $urlDeviceGroup = "https://graph.microsoft.com/v1.0/groups/$objDeviceGroup/transitiveMembers/microsoft.graph.device?`$select=id&`$count=true&`$top=999"
                    
                    while ($null -ne $urlDeviceGroup) {
                        
                        $deviceGroupsMembersResponse = Invoke-WebRequest -Method 'GET' -Uri $urlDeviceGroup -Headers $headers -UseBasicParsing | ConvertFrom-Json
                        $objDeviceGroupMembers += $deviceGroupsMembersResponse.value

                        If($deviceGroupsMembersResponse."@odata.count"){
                            $deviceGroupsMembersCount = $deviceGroupsMembersResponse."@odata.count"
                        }
                        $urlDeviceGroup = $deviceGroupsMembersResponse."@odata.nextLink"                        
                    }
                }
            
            $Devices = $objDeviceGroupMembers | Select-Object ID -Unique
            
          }

        #Join Unitmember and Groups Arrays together
        if ($Devices.count -gt 0) {
            $UnitMembers += $Devices.id
        }

    }
    
    Catch{
		
		if(-not $RoleIdCheckValueResponse){Write-Log -Message $eString5 -LogLevel ERROR -ConsoleOutput}
        $ErrorMessage = $_.Exception.Message
        Write-Output "Try - Catch - Data Collection Failure"

            If($?){Write-Log -Message $ErrorMessage -LogLevel Error -ConsoleOutput}

        Break

    }

    Write-Log -Message $iString1 -LogLevel INFO -ConsoleOutput

    Try{

        #Set VAR
        #$userGroupMembersNull = $false
        $UnitMembersNull = $false
        $administrativeUnitMembersNull = $false
        $UnitMembersCount = $null
        $administrativeUnitMembersCount_2 = $null

        $CompareUsers = @()
        $assessUsers = @()
        #Compare Lists and find missing users those who should be removed. 
        $CompareUsers = Compare-Object -ReferenceObject $UnitMembers -DifferenceObject $administrativeUnitMembers.ID | Where-Object {$_.SideIndicator -ne "="}
        
        If(($CompareUsers | Measure-Object).count -gt 0){
            Foreach($obj in $CompareUsers){
                $resultId = $obj.InputObject
                $urlFindDataType = "https://graph.microsoft.com/v1.0/directoryObjects/$resultId"
                
                $assessUsers += [pscustomobject] @{
                    Id = $resultId
                    SideIndicator = $obj.SideIndicator
                    '@odata.type' = (Invoke-WebRequest -Method 'GET' -Uri $urlFindDataType -Headers $headers  -ContentType 'application/json' -UseBasicParsing | ConvertFrom-Json).'@odata.type'
                    
                }
            }    
        }


    }

    Catch {

        #Check Error for Blank Arrays
        $UnitMembersCount = ($UnitMembers | measure-object).Count
        $administrativeUnitMembersCount_2 = ($administrativeUnitMembers | measure-object).Count

        if ($administrativeUnitMembersCount_2 -eq 0) {
            
            If($?){Write-Log -Message $wString1 -LogLevel WARN -ConsoleOutput}
            $administrativeUnitMembersNull = $True
        }
        if ($UnitMembersCount -eq 0) {
            
            If($?){Write-Log -Message $wString0 -LogLevel WARN -ConsoleOutput}
            $UnitMembersNull = $True
        }
    }

    # <= -eq Add Object
    # = -eq Skip
    # => -eq Remove Object

    if(($administrativeUnitMembersNull -ne $true) -and ($UnitMembersNull -ne $true)) {

        Foreach($objUser in $assessUsers){  

            if ($counter -lt $DifferentialScope) {
                
                Switch ($objUser.SideIndicator) {

                    "=>" { 
                    
                        $objID = $objUser.Id

                        $urlRemoveAUMember = "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$AADAdminUnit/members/$objID/`$ref"

                        $objRemoveAUMemberResponse = Invoke-WebRequest -Method 'DELETE' -Uri $urlRemoveAUMember -Headers $headers  -ContentType 'application/json' -UseBasicParsing
                        
                        #Write Sucess String
                        if($objRemoveAUMemberResponse.StatusCode -eq 204){Write-Log -Message "$sString0;DataType:$($objUser.'@odata.type');ObjectId:$objID" -LogLevel SUCCESS -ConsoleOutput}

                        #Increase the count post change
                        $counter++

                        $objID = $null
                                
                            }

                    "<=" { 
                        
                        $objID = $objUser.Id
                        $body = $null
                        switch -Wildcard ($objUser.'@odata.type'){
                            "*.User" {
                                        $body = @{
                                            "@odata.id" = "https://graph.microsoft.com/v1.0/users/$objID"
                                        }
                                    }
                                "*.group" {
                                        $body = @{
                                            "@odata.id" = "https://graph.microsoft.com/v1.0/groups/$objID"
                                        }
                                    }
                                "*.Device" {
                                        $body = @{
                                            "@odata.id" = "https://graph.microsoft.com/v1.0/devices/$objID"
                                        }
                                    }
                            Default {Write-Log -Message "Unable to confirm Object DataType for ObjectId:$objID" -LogLevel ERROR -ConsoleOutput}
                        }
                        If($body){
                            $urlAddAUMember = "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$AADAdminUnit/members/`$ref"

                            $bodyAddAUMember = $body | ConvertTo-Json
                                    
                            $objAddAUMemberResponse = Invoke-WebRequest -Method 'POST' -Uri $urlAddAUMember -Headers $headers  -ContentType 'application/json' -UseBasicParsing -Body $bodyAddAUMember
                            
                            #Write Sucess String
                            if($objAddAUMemberResponse.StatusCode -eq 204){Write-Log -Message "$sString1;DataType:$($objUser.'@odata.type');ObjectId:$objID" -LogLevel SUCCESS -ConsoleOutput}    
                        }
                        
                        #Increase the count post change
                        $counter++

                        $objID = $null

                            }

                    Default {Write-log -Message $eString2 -ConsoleOutput -LogLevel ERROR }
                }
            }

            else {
                       
                #Exceeded couter limit
                Write-log -Message $eString3 -ConsoleOutput -LogLevel ERROR
                Break

            }  

        }
    }

    else {

        #Blank group remove members from AAD AU
        if ($UnitMembersNull -and (-not($administrativeUnitMembersNull))) {
            if (-not($administrativeUnitMembersNull)) {

                foreach($objAADAdminUnitMember in $administrativeUnitMembers){

                    if($counter -lt $DifferentialScope){
                        $objID = $objAADAdminUnitMember.ID

                        $urlRemoveAUMember = "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$AADAdminUnit/members/$objID/`$ref"
                        
                        $objRemoveAUMemberResponse = Invoke-WebRequest -Method 'DELETE' -Uri $urlRemoveAUMember -Headers $headers  -ContentType 'application/json' -UseBasicParsing
                        
                        #Write Sucess String
                        if($objRemoveAUMemberResponse.StatusCode -eq 204){Write-Log -Message "$sString0;ObjectId:$objID" -LogLevel SUCCESS -ConsoleOutput}
                        
                        #Increase the count post change
                        $counter++

                        $objID = $null
                    }
                    else {
                       
                        #Exceeded counter limit
                        Write-log -Message $eString3 -ConsoleOutput -LogLevel ERROR
                        Break

                    }   
                }   
            }            
            
        }

        #Blank AAD AU add members from the User Group.
        if ($administrativeUnitMembersNull -and (-not($UnitMembersNull))) {

            if (-not($UnitMembersNull)) {

                foreach($objUnitMember in $UnitMembers){

                    if($counter -lt $DifferentialScope){
                        $objType = $null
                        $body = $null
                        $objID = $objUnitMember
                        $urlFindDataType = "https://graph.microsoft.com/v1.0/directoryObjects/$objID"
                        $objType = (Invoke-WebRequest -Method 'GET' -Uri $urlFindDataType -Headers $headers  -ContentType 'application/json' -UseBasicParsing | ConvertFrom-Json).'@odata.type'

                        switch -Wildcard ($objType){
                            "*.User" {
                                        $body = @{
                                            "@odata.id" = "https://graph.microsoft.com/v1.0/users/$objID"
                                        }
                                    }
                                "*.group" {
                                        $body = @{
                                            "@odata.id" = "https://graph.microsoft.com/v1.0/groups/$objID"
                                        }
                                    }
                                "*.Device" {
                                        $body = @{
                                            "@odata.id" = "https://graph.microsoft.com/v1.0/devices/$objID"
                                        }
                                    }
                            Default {Write-Log -Message "Unable to confirm Object DataType for ObjectId:$objID" -LogLevel ERROR -ConsoleOutput}
                        }
                        If($body){
                            $urlAddAUMember = "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$AADAdminUnit/members/`$ref"

                            $bodyAddAUMember = $body | ConvertTo-Json
                                    
                            $objAddAUMemberResponse = Invoke-WebRequest -Method 'POST' -Uri $urlAddAUMember -Headers $headers  -ContentType 'application/json' -UseBasicParsing -Body $bodyAddAUMember
                            
                            #Write Sucess String
                            if($objAddAUMemberResponse.StatusCode -eq 204){Write-Log -Message "$sString1;DataType:$objType;ObjectId:$objID" -LogLevel SUCCESS -ConsoleOutput}    
                        }

                        #Increase the count post change
                        $counter++

                        $objID = $null
                        $objDisplayName = $null
                    }

                    else {
                       
                        #Exceeded couter limit
                        Write-log -Message $eString3 -ConsoleOutput -LogLevel ERROR
                        Break

                    }  
                }
            }
        }
            
        else {
            
            #Both AAD AU and the User Group are blank
            Write-log -Message $eString4 -ConsoleOutput -LogLevel ERROR
        }
    }#End Else

    Write-Log -Message $iString0 -LogLevel INFO -ConsoleOutput

    #Start ScopedRoleMembers
    
    #Reset counter for the administrators
    $counter = 0

    Try{
        
        #Compare Lists and find missing administrators those who should be removed. 
        $CompareAdministrators = @()
        $assessAdministrators = @()
        Foreach($objRoleId in $roleIds){
                
            $administrativeUnitScopedRoleMembers = ($administrativeUnitScopedRole | Where-Object{$_.RoleId -eq $objRoleId}).RoleMemberInfo
            If($administrativeUnitScopedRoleMembers -and $adminGroupMembers){
                
                $CompareAdministrators = Compare-Object -ReferenceObject $adminGroupMembers.Id -DifferenceObject $administrativeUnitScopedRoleMembers.Id | Where-Object {$_.SideIndicator -ne "="}
                
            }

            If(($CompareAdministrators | Measure-Object).count -gt 0){
                Foreach($result in $CompareAdministrators){
                    $resultId = $result.InputObject
                    $assessAdministrators += [pscustomobject] @{
                        Id = $resultId
                        RoleId = $objRoleId
                        SideIndicator = $result.SideIndicator
                        ScopedRoleMembershipId = ($administrativeUnitScopedRole | Where-Object{($_.RoleId -eq $objRoleId)-and($_.RoleMemberInfo.Id -eq $resultId)}).id
                        
                    }
                }    
            }
        }

        #Set VAR
        $adminGroupMembersNull = $false
        $administrativeUnitScopedRoleMembersNull = $false
        $adminGroupMembersCount = $null
        $administrativeUnitScopedRoleMembersCount = $null

        #Check Error for Blank Array
        $adminGroupMembersCount = $adminGroupMembers.Count
        $administrativeUnitScopedRoleMembersCount = $administrativeUnitScopedRoleMembers.Count

        if($adminGroupMembersCount -eq 0){
            
            If($?){Write-Log -Message $wString2 -LogLevel WARN -ConsoleOutput}
            $adminGroupMembersNull = $True

        }
        if ($administrativeUnitScopedRoleMembersCount -eq 0) {
            
            If($?){Write-Log -Message $wString3 -LogLevel WARN -ConsoleOutput}
            $administrativeUnitScopedRoleMembersNull = $True

        }

    }
    Catch {

        Write-Error -Message $_.Exception.Message
        Break

    }

    # <= -eq Add Object
    # == -eq Skip
    # => -eq Remove Object

    if (($adminGroupMembersNull -ne $true) -and ($administrativeUnitScopedRoleMembersNull -ne $true)) {
        
        Foreach($objAdmin in $assessAdministrators){  

            if ($counter -lt $DifferentialScope) {
                
                Switch ($objAdmin.SideIndicator) {

                    "=>" { 
                    
                        $objID = $objAdmin.Id
                        $objRoleId = $objAdmin.RoleId
                        $objScopedRoleMembershipId = $objAdmin.ScopedRoleMembershipId
                        
                        $urlRemoveAUAdmin = "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$AADAdminUnit/scopedRoleMembers/$objScopedRoleMembershipId"

                        $objRemoveAUAdmin = Invoke-WebRequest -Method 'DELETE' -Uri $urlRemoveAUAdmin -Headers $headers  -ContentType 'application/json' -UseBasicParsing
                        
                        if($?){Write-Log -Message "$sString2;ObjectId:$objID" -LogLevel SUCCESS -ConsoleOutput}
                        
                        #Increase the count post change
                        $counter++

                        $objID = $null
                        $objRoleID = $null
                        $objScopedRoleMembershipId = $null
                                
                            }

                    "<=" { 
                        
                        $objID = $objAdmin.Id

                        $body = $null
                        $objRoleId = $objAdmin.RoleId

                        $body = @{
                            "roleId" =  $objRoleId
                        }
                        $data = @{"id" = $objID}
                        $body.Add("roleMemberInfo",$data)
                        
                        $urlAddAUAdmin = "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$AADAdminUnit/scopedRoleMembers"

                        $bodyAddAUAdmin = $body | ConvertTo-Json
                        
                        $objAddAUAdmin = Invoke-WebRequest -Method 'POST' -Uri $urlAddAUAdmin -Headers $headers  -ContentType 'application/json' -UseBasicParsing -Body $bodyAddAUAdmin
                        
                        #Write Sucess String
                        if($?){Write-Log -Message "$sString3$$objRoleId;UserObjectID:$objID" -LogLevel SUCCESS -ConsoleOutput}
                
                        #Increase the count post change
                        $counter++

                        $objID = $null
                        $RoleMember = $null
                            }

                    Default {Write-log -Message $eString2 -ConsoleOutput -LogLevel ERROR }
                }
            }

            else {
                       
                #Exceeded couter limit
                Write-log -Message $eString3 -ConsoleOutput -LogLevel ERROR
                Break

            }  

        }
    }

    else {
            
        #Blank Admin group remove Scoped Administrators from AAD AU
        if ($adminGroupMembersNull -and (-not($administrativeUnitScopedRoleMembersNull))) {

            foreach($objAADAdminUnitMember in $administrativeUnitScopedRole){

                if($counter -lt $DifferentialScope){
                    $objID = $objAADAdminUnitMember.ID

                    If($objAADAdminUnitMember.roleId -match $RoleIds){

                        $objID = $objAADAdminUnitMember.roleMemberInfo.Id
                        $objRoleId = $objAADAdminUnitMember.RoleId
                        $objScopedRoleMembershipId = $objAADAdminUnitMember.Id
                        
                        $urlRemoveAUAdmin = "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$AADAdminUnit/scopedRoleMembers/$objScopedRoleMembershipId"

                        $objRemoveAUAdmin = Invoke-WebRequest -Method 'DELETE' -Uri $urlRemoveAUAdmin -Headers $headers  -ContentType 'application/json' -UseBasicParsing

                        if($?){Write-Log -Message "$sString2;ObjectId:$objID" -LogLevel SUCCESS -ConsoleOutput}

                    }

                    #Increase the count post change
                    $counter++

                    $objID = $null
                    $objRole = $null

                }
                else {
                    
                    #Exceeded counter limit
                    Write-log -Message $eString3 -ConsoleOutput -LogLevel ERROR
                    Break

                }   
            }   
        }

        #Blank AAD AU Scoped Add members from the User Group.
        elseif ($administrativeUnitScopedRoleMembersNull -and (-not($adminGroupMembersNull))) {

            foreach($objadminGroupMember in $adminGroupMembers){

                if($counter -lt $DifferentialScope){
                    
                    foreach($objRoleId in $RoleIds){

                        $body = $null

                        $objID = $objadminGroupMember.Id

                        $body = @{
                            "roleId" =  $objRoleId
                        }
                        $data = @{"id" = $objID}
                        $body.Add("roleMemberInfo",$data)
                        
                        $urlAddAUAdmin = "https://graph.microsoft.com/v1.0/directory/administrativeUnits/$AADAdminUnit/scopedRoleMembers"

                        $bodyAddAUAdmin = $body | ConvertTo-Json
                        
                        $objAddAUAdmin = Invoke-WebRequest -Method 'POST' -Uri $urlAddAUAdmin -Headers $headers  -ContentType 'application/json' -UseBasicParsing -Body $bodyAddAUAdmin

                        if($?){Write-Log -Message "$sString3$($objAdmin.RoleId);UserObjectID:$objID" -LogLevel SUCCESS -ConsoleOutput}

                    }
                    
                    #Increase the count post change
                    $counter++

                    $objID = $null
                    $objDisplayName = $null
                    $RoleMember = $null
                }

                else {
                    
                    #Exceeded couter limit
                    Write-log -Message $eString3 -ConsoleOutput -LogLevel ERROR
                    Break

                }  
            }
        }
            
        else {
            
            #Both AAD AU and the User Group are blank
            Write-log -Message $eString4 -ConsoleOutput -LogLevel ERROR
        }
    }#End Else
	
