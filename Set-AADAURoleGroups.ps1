<# 
.SYNOPSIS
This script automates the population of Users and Administrators to Azure AD Administrative Units.

.DESCRIPTION
Automation is completed by targeting Dynamic or Static Azure AD Groups which will populate the Administrative Unit with Users and Administrators for the selected scope. 

## Set-AADAURoleGroups [-AADAdminUnit <string[ObjectID]>] [-UserGroup <string[ObjectID]>] [-AdminGroup <array[ObjectID]>] [-GroupFilter <string[description_field*]>] [-HelpDeskAdministrator <switch>] [-UserAccountAdministrator <switch>] [-AuthenticationAdministrator <switch>] [-GroupsAdministrator <switch>] 

.PARAMETER AADAdminUnit
The AADAdminUnit parameter specifies the ObjectId of the Administrative Unit. You can find this value by running Get-AzureADAdministrativeUnit 

.PARAMETER UserGroup
The UserGroup parameter details the ObjectId of the Administrative Unit. Get-AzureADGroup -SearchString "All Users"

.PARAMETER AdminGroup
The AdminGroup parameter details the ObjectId of the Administrative Unit. Get-AzureADGroup -SearchString "All Scoped Admins"

.PARAMETER GroupFilter
The GroupFilter parameter allows to identifiy Groups that can also be added to the Administrative Unit. By default we target the Description field of the Group. Wild cards need to be added to your group filter. 

.PARAMETER DifferentialScope
The DifferentialScope parameter defines how many objects can be added or removed from the Administrative Units in a single operation of the script. The goal of this setting is throttle bulk changes to limit the impact of misconfigurationby an administrator. What value you choose here will be dictated by your userbase and your script schedule. The default value is set to 10 Objects. 

.PARAMETER HelpDeskAdministrator
The HelpDeskAdministrator Switch enables the Helpdesk role for administrative permissions. 

.PARAMETER UserAccountAdministrator
The UserAccountAdministrator Switch enables the User Account Administrator role for administrative permissions. 

.PARAMETER AuthenticationAdministrator
The AuthenticationAdministrator Switch enables the Authentication Administrator role for administrative permissions. 

.PARAMETER GroupsAdministrator
The GroupsAdministrator Switch enables the Groups Administrator role for administrative permissions. 

.PARAMETER AutomationPSCredential
The AutomationPSCredential parameter defines the automation account that should be used. Please note that this requires basic authnetication and is not prefered. Please consider using AutomationPSCertificate & AutomationPSConnection  

.PARAMETER AutomationPSCertificate
 The AutomationCertificate parameter defines which Azure Automation Certificate you would like to use which grants access to Azure AD. Parameter must be used with -AutomationPSConnection.

.PARAMETER AutomationPSConnection
 The AutomationPSConnection parameter defines the connection details such as AppID, Tenant ID. Parameter must be used with -AutomationPSCertificate.

.EXAMPLE
Set-AADUDRoleGroups -AADAdminUnit '7b7c4926-c6d7-4ca8-9bbf-5965751022c2' -UserGroup '0e55190c-73ee-e811-80e9-005056a31be6' -AdminGroup '0e55190c-73ee-e811-80e9-005056a3' -HelpDeskAdministrator

-- SET USERS AND HELPDESK ADMINISTRATORS FOR ADMIN UNIT --

In this example we add Users and Administrators (with Helpdesk Role) to the Administrative Unit '7b7c4926-c6d7-4ca8-9bbf-5965751022c2' 

.EXAMPLE
Set-AADUDRoleGroups -AADAdminUnit '7b7c4926-c6d7-4ca8-9bbf-5965751022c2' -UserGroup '0e55190c-73ee-e811-80e9-005056a31be6' -AdminGroup '0e55190c-73ee-e811-80e9-005056a3' -HelpDeskAdministrator -UserAccountAdministrator

-- SET USERS AND HELPDESK & USER ADMINISTRATORS FOR ADMIN UNIT --

In this example we add Users and Administrators (with Helpdesk & User Account Role) to the Administrative Unit '7b7c4926-c6d7-4ca8-9bbf-5965751022c2' 

.LINK

Azure AD Dynamic Group Membership - https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/groups-dynamic-membership

Log Analytics Workspace - https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-create-workspace

Enable-AzureADDirectoryRole - https://docs.microsoft.com/en-us/powershell/module/azuread/enable-azureaddirectoryrole?view=azureadps-2.0 

.NOTES
Important! - You may need to first Enable-AzureADDirectoryRole for roles Helpdesk Administrator, User Administrator etc | See .Links

This function requires that you have already created your Adminstrative Unit, the Group containing user objects and the Group containing Admin objects. You will also need the ObjectID for roles Helpdesk Administrator or User Account Administrator which can be obtained by running Get-AzureADDirectoryRole

Please be aware that the DifferentialScope applies to both users and Administrators meaning that large changes will also impact the provensioning of Scoped Administrators. 

We used AzureAD GA Version: 2.0.2.140 ()


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

[TO DO LIST / PRIORITY]
    Migrate to Graph API / MED
    Azure Managed Idenities / MED
#>

Param 
(
    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [String]
    $AADAdminUnit,
    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [String]$UserGroup,
    [Parameter(Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [Array]$AdminGroups,
    [ValidateNotNullOrEmpty()]
    [string]$GroupFilter,
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [Int]$DifferentialScope = 30,
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [String]$AutomationPSCredential,
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [String]$AutomationPSConnection,
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [String]$AutomationPSCertificate,    
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [switch]$HelpDeskAdministrator = $False,
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [switch]$UserAccountAdministrator = $False,
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [switch]$AuthenticationAdministrator = $False,
    [Parameter(Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [switch]$GroupsAdministrator = $False
)

    #Set VAR
    $counter = 0

# Success Strings
    $sString0 = "OUT-CMDlet:Remove-AzureADAdministrativeUnitMember;AADAU:$AADAdminUnit"
    $sString1 = "IN-CMDlet:Add-AzureADAdministrativeUnitMember;AADAU:$AADAdminUnit"
    $sString2 = "OUT-CMDlet:Remove-AzureADScopedRoleMembership;AADAU:$AADAdminUnit"
    $sString3 = "IN-CMDlet:Add-AzureADScopedRoleMembership;AADAU:$AADAdminUnit;Role:UserAccount"
    $sString4 = "IN-CMDlet:Add-AzureADScopedRoleMembership;AADAU:$AADAdminUnit;Role:Helpdesk"
    $sString5 = "IN-CMDlet:Add-AzureADScopedRoleMembership;AADAU:$AADAdminUnit;Role:Auth"
    $sString6 = "IN-CMDlet:Add-AzureADScopedRoleMembership;AADAU:$AADAdminUnit;Role:Groups"

    
# Info Strings
    $iString0 = "Starting AAD AU Scoped Administrator Role Members"
    $iString1 = "Starting AAD AU User Scope Members"

# Warn Strings
    $wString0 = "CMDlet:Compare-Object;ReferenceObject:Group membership is equal to NULL"
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

# Debug Strings
    $dString0 = "CMDlet:Get-AzureADAdministrativeUnit;ObjectId:$AADAdminUnit;DisplayName:$AADAdminUnit.DisplayName"
    $dString1 = "Starting Scoped Role Members"

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

    #Validate Input Values From Parameter 

    Try{
        If($AutomationPSCertificate -and $AutomationPSConnection){
            
            $AzureADCert = Get-AutomationCertificate -Name $AutomationPSCertificate
            $AzureADConnection = Get-AutomationConnection -Name $AutomationPSConnection

            Connect-AzureAD -TenantId $AzureADConnection.TenantId -ApplicationId $AzureADConnection.ApplicationId -CertificateThumbprint $AzureADCert.Thumbprint 

                #Remove-Variable AutomationPSCertificate
                #Remove-Variable AutomationPSConnection
                #Remove-Variable AutomationPSCredential

        }
        else {

            If($AutomationPSCertificate -or $AutomationPSConnection){

                #Remove-Variable AutomationPSCertificate
                #Remove-Variable AutomationPSConnection

                Write-Log -Message "Script requires both variables: AutomationCertificate and AutomationConnection. Please ensure both are in use or consider another authenication method" -LogLevel ERROR -ConsoleOutput 

            }

        }

            if ($AutomationPSCredential) {
            
            $Credential = Get-AutomationPSCredential -Name $AutomationPSCredential

            Connect-AzureAD -Credential $Credential
            #1.3.0 removed this requirement! Yay!
            #Connect-MsolService -Credential $Credential 

            }
    
        #Check Admin Unit
        $objAADAdminUnit = Get-AzureADMSAdministrativeUnit -Id $AADAdminUnit -ErrorAction Stop

        #If($?){Write-Log -Message $dString0 -LogLevel DEBUG -ConsoleOutput}

        $objUserGroup = Get-AzureADGroup -ObjectId $UserGroup -ErrorAction Stop
        
        #New Array and Count of Users from Azure Group
        $userGroupMembers = Get-AzureADGroupMember -ObjectId $UserGroup -All:$true

        #New Array and Count of Users from Administrative Unit
        ##$administrativeUnitMembers = Get-MsolAdministrativeUnitMember -AdministrativeUnitObjectId $AADAdminUnit -All
        $administrativeUnitMembers = Get-AzureADMSAdministrativeUnitMember -Id $AADAdminUnit -All:$true

        #Check hows many roles are in use by the function. 
        $uaadmin = $False
        $helpdeskadmin = $False
        $authadmin = $False
        $groupsadmin = $False
                
        $admins = Get-AzureADDirectoryRole
        $adDirectoryRoleCount = 0
        foreach($i in $admins) {
            if(($UserAccountAdministrator)-and($i.DisplayName -eq "User Administrator")) {
                $uaadmin = $i
                $adDirectoryRoleCount ++
            }

            if(($HelpDeskAdministrator)-and($i.DisplayName -eq "Helpdesk Administrator")) {
                $helpdeskadmin = $i
                $adDirectoryRoleCount ++
            }

            if(($AuthenticationAdministrator)-and($i.DisplayName -eq "Authentication Administrator")) {
                $authadmin = $i
                $adDirectoryRoleCount ++
            }

            if(($GroupsAdministrator)-and($i.DisplayName -eq "Groups Administrator")) {
                $groupsadmin = $i
                $adDirectoryRoleCount ++
            }
        }
        
        #New Array of Administrators from Administrative Unit
        #$administrativeUnitScopedRole = (Get-AzureADScopedRoleMembership -ObjectId $AADAdminUnit).RoleMemberInfo
        $administrativeUnitScopedRole = (Get-AzureADMSScopedRoleMembership -Id $AADAdminUnit).RoleMemberInfo

        $administrativeUnitScopedRoleMembers = $administrativeUnitScopedRole | Select-Object id -Unique
        
        #Check AzureADDirectoryRole - Note Only Helpdesk and Service Desk is currently supported. Who know maybe that will change in the future. (Yes it did!:-)
        $objUserGroup = @($AdminGroups | ForEach-Object {Get-AzureADGroupMember -ObjectId $_ -All:$true -ErrorAction Stop})

        $adminGroupMembers = $objUserGroup | Select-Object -Unique

        #Quick Count compare Admins in group vs in the AADAU
        $adDirectoryRoleCountCheck = $administrativeUnitScopedRole.Count / $adminGroupMembers.count

        if ($adDirectoryRoleCountCheck -lt $adDirectoryRoleCount) {
            $administrativeUnitScopedRoleMembers = $null
        }
        
        $administrativeUnitScopedRoleMembersNull = $false

        #Find groups by GroupFilter Switch
        If($GroupFilter){

          $Groups = Get-AzureADGroup -All:$true | Where-Object{$_.Description -like $GroupFilter}

        }

        #Join Groups and User Arrays together
        $UnitMembers = $userGroupMembers.ObjectId 
        if ($Groups.count -gt 0) {
            $UnitMembers += $Groups.ObjectId 
        } 

    }
    
    Catch{
    
        $ErrorMessage = $_.Exception.Message
        Write-Output $_.Exception.Message
        Write-Output "Begin - Catch"

            If($?){Write-Log -Message $ErrorMessage -LogLevel Error -ConsoleOutput}

        Break

    }

    Write-Log -Message $iString1 -LogLevel INFO -ConsoleOutput

    Try{

        #Compare Lists and find missing users those who should be removed. 
        $assessUsers = Compare-Object -ReferenceObject $UnitMembers -DifferenceObject $administrativeUnitMembers.ID | Where-Object {$_.SideIndicator -ne "="}
    }

    Catch {

        #Set VAR
        $userGroupMembersNull = $false
        $administrativeUnitMembersNull = $false

        #Check Error for Blank Array
        $userGroupMembersCount = $userGroupMembers.Count
        $administrativeUnitMembersCount = $administrativeUnitMembers.Count

        if(($userGroupMembersCount -eq 0)-and($administrativeUnitMembersCount -eq 0)){
            
            If($?){Write-Log -Message $wString0 -LogLevel WARN -ConsoleOutput;Write-Log -Message $wString1 -LogLevel WARN -ConsoleOutput}
            $userGroupMembersNull = $True
            $administrativeUnitMembersNull = $True

        }
        elseif($userGroupMembersCount -eq 0){
            
            If($?){Write-Log -Message $wString0 -LogLevel WARN -ConsoleOutput}
            $userGroupMembersNull = $True

        }
        elseif ($administrativeUnitMembersCount -eq 0) {
            
            If($?){Write-Log -Message $wString1 -LogLevel WARN -ConsoleOutput}
            $administrativeUnitMembersNull = $True

        }
        Else{

            Write-Error -Message $_.Exception.Message
            Break
        }
    }

    # <= -eq Add Object
    # = -eq Skip
    # => -eq Remove Object

    if(($administrativeUnitMembersNull -ne $true) -and ($userGroupMembersNull -ne $true)) {

        Foreach($objUser in $assessUsers){  

            if ($counter -lt $DifferentialScope) {
                
                Switch ($objUser.SideIndicator) {

                    "=>" { 
                    
                        $objID = $objUser.InputObject

                        Remove-AzureADMSAdministrativeUnitMember -Id $AADAdminUnit -MemberId $objID
                            if($?){Write-Log -Message "$sString0;ObjectId:$objID" -LogLevel SUCCESS -ConsoleOutput}
                        
                        #Increase the count post change
                        $counter++

                        $objID = $null
                                
                            }

                    "<=" { 
                            
                        $objID = $objUser.InputObject

                        Add-AzureADMSAdministrativeUnitMember -Id $AADAdminUnit -RefObjectId $objID
                            if($?){Write-Log -Message "$sString1;ObjectId:$objID" -LogLevel SUCCESS -ConsoleOutput}
                        
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
        if ($userGroupMembersNull -and (-not($administrativeUnitMembersNull))) {
            if (-not($administrativeUnitMembersNull)) {

                foreach($objAADAdminUnitMember in $administrativeUnitMembers){

                    if($counter -lt $DifferentialScope){
                        $objID = $objAADAdminUnitMember.ID

                        Remove-AzureADMSAdministrativeUnitMember -Id $AADAdminUnit -MemberId $objID
                        if($?){Write-Log -Message "$sString0;ObjectId:$objID" -LogLevel SUCCESS -ConsoleOutput}
                        
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
        if ($administrativeUnitMembersNull -and (-not($userGroupMembersNull))) {

            if (-not($userGroupMembersNull)) {

                foreach($objuserGroupMembers in $userGroupMembers){

                    if($counter -lt $DifferentialScope){
                        $objID = $objuserGroupMembers.objectID
                        $objDisplayName = $objuserGroupMembers.displayname

                        Add-AzureADMSAdministrativeUnitMember -Id $AADAdminUnit -RefObjectId $objID
                        if($?){Write-Log -Message "$sString1;ObjectId:$objID" -LogLevel SUCCESS -ConsoleOutput}
                        
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
        $assessAdministrators = Compare-Object -ReferenceObject $adminGroupMembers.ObjectId -DifferenceObject $administrativeUnitScopedRoleMembers.Id

    }
    Catch {
        #Set VAR
        $adminGroupMembersNull = $false
        $administrativeUnitScopedRoleMembersNull = $false

        #Check Error for Blank Array
        $adminGroupMembersCount = $adminGroupMembers.Count
        $administrativeUnitScopedRoleMembersCount = $administrativeUnitScopedRoleMembers.Count    

        if(($adminGroupMembersCount -eq 0)-and($administrativeUnitScopedRoleMembersCount -eq 0)){
            
            If($?){Write-Log -Message $wString2 -LogLevel WARN -ConsoleOutput;Write-Log -Message $wString3 -LogLevel WARN -ConsoleOutput}
            $adminGroupMembersNull = $True
            $administrativeUnitScopedRoleMembersNull = $True
        }
        elseif($adminGroupMembersCount -eq 0){
            
            If($?){Write-Log -Message $wString2 -LogLevel WARN -ConsoleOutput}
            $adminGroupMembersNull = $True

        }
        elseif ($administrativeUnitScopedRoleMembersCount -eq 0) {
            
            If($?){Write-Log -Message $wString3 -LogLevel WARN -ConsoleOutput}
            $administrativeUnitScopedRoleMembersNull = $True

        }
        Else{

            Write-Error -Message $_.Exception.Message
            Break
        }
    }

    # <= -eq Add Object
    # == -eq Skip
    # => -eq Remove Object

    if (($adminGroupMembersNull -ne $true) -and ($administrativeUnitScopedRoleMembersNull -ne $true)) {
        
        Foreach($objUser in $assessAdministrators){  

            if ($counter -lt $DifferentialScope) {
                
                Switch ($objUser.SideIndicator) {

                    "=>" { 
                    
                        $objID = $objUser.InputObject
                        
                        $objRoles = Get-AzureADMSScopedRoleMembership -Id $AADAdminUnit  | Where-Object {$_.RoleMemberInfo.Id -eq $objID}

                        foreach($objRole in $objRoles){

                            Remove-AzureADMSScopedRoleMembership -Id $objRole.AdministrativeUnitId -ScopedRoleMembershipId $objRole.Id
                            if($?){Write-Log -Message "$sString2;ObjectId:$objID" -LogLevel SUCCESS -ConsoleOutput}
                        }
                        
                        #Increase the count post change
                        $counter++

                        $objID = $null
                        $objRole = $null
                                
                            }

                    "<=" { 
                        
                        $uaadminTrue = $null
                        $helpdeskadminTrue = $null
                        $authadminTrue = $null
                        $groupsadminTrue = $null

                        $objID = $objUser.InputObject
                        $objDisplayName = $objadminGroupMembers.displayname

                        $objRoles = Get-AzureADMSScopedRoleMembership -Id $AADAdminUnit  | Where-Object {$_.RoleMemberInfo.Id -eq $objID}

                        $uaadminTrue = $objRoles | Where-Object {$_.RoleId -eq $uaadmin.ObjectId}
                        $helpdeskadminTrue = $objRoles | Where-Object {$_.RoleId -eq $helpdeskadmin.ObjectId}
                        $authadminTrue = $objRoles | Where-Object {$_.RoleId -eq $authadmin.ObjectId}
                        $groupsadminTrue = $objRoles | Where-Object {$_.RoleId -eq $groupsadmin.ObjectId}

                        #$RoleMember = New-Object -TypeName Microsoft.Open.AzureAD.Model.RoleMemberInfo
                        #$RoleMember.ObjectId = $objID
                        
                        $RoleMember = New-Object -TypeName Microsoft.Open.MSGraph.Model.MsRolememberinfo
                        $RoleMember.Id = $objID

                        if($UserAccountAdministrator -and $uaadmin) {
                            if ($uaadminTrue) {
                                Write-Log -Message "$wString4 Role:UserAdministrator;UserObjectID:$objID" -LogLevel WARN -ConsoleOutput
                            }
                            else {
                                Add-AzureADMSScopedRoleMembership -Id $AADAdminUnit -RoleId $uaadmin.ObjectId -RoleMemberInfo $RoleMember
                                if($?){Write-Log -Message "$sString3;UserObjectID:$objID" -LogLevel SUCCESS -ConsoleOutput}
                                }
                            }
                        if($HelpDeskAdministrator -and $helpdeskadmin) {
                            if ($helpdeskadminTrue) {
                                Write-Log -Message "$wString4 Role:HelpDeskAdministrator;UserObjectID:$objID" -LogLevel WARN -ConsoleOutput
                            }
                            else {
                                Add-AzureADMSScopedRoleMembership -Id $AADAdminUnit -RoleId $helpdeskadmin.ObjectId -RoleMemberInfo $RoleMember
                                if($?){Write-Log -Message "$sString4;UserObjectID:$objID" -LogLevel SUCCESS -ConsoleOutput}    
                            }
                            
                            }
                        if($AuthenticationAdministrator -and $authadmin) {
                            if ($authadminTrue) {
                                Write-Log -Message "$wString4 Role:AuthenticationAdministrator;UserObjectID:$objID" -LogLevel WARN -ConsoleOutput
                            }
                            else {
                                Add-AzureADMSScopedRoleMembership -Id $AADAdminUnit -RoleId $authadmin.ObjectId -RoleMemberInfo $RoleMember
                                if($?){Write-Log -Message "$sString5;UserObjectID:$objID" -LogLevel SUCCESS -ConsoleOutput}    
                            }
                            }
                        if($GroupsAdministrator -and $groupsadmin) {
                            if ($groupsadminTrue) {
                                Write-Log -Message "$wString4 Role:AuthenticationAdministrator;UserObjectID:$objID" -LogLevel WARN -ConsoleOutput
                            }
                            else {
                                Add-AzureADMSScopedRoleMembership -Id $AADAdminUnit -RoleId $groupsadmin.ObjectId -RoleMemberInfo $RoleMember
                                if($?){Write-Log -Message "$sString6;UserObjectID:$objID" -LogLevel SUCCESS -ConsoleOutput}
                                }
                            }
                
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

            foreach($objAADAdminUnitMember in $administrativeUnitScopedRoleMembers){

                if($counter -lt $DifferentialScope){
                    $objID = $objAADAdminUnitMember.ID
                    #$objID = $objUser.InputObject

                    $objRoles = Get-AzureADMSScopedRoleMembership -Id $AADAdminUnit  | Where-Object {$_.RoleMemberInfo.Id -eq $objID}

                    foreach($objRole in $objRoles){

                        Remove-AzureADMSScopedRoleMembership -Id $objRole.AdministrativeUnitId -ScopedRoleMembershipId $objRole.Id
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
                    $objID = $objadminGroupMember.objectID
                    $objDisplayName = $objadminGroupMember.displayname
                    #$RoleMember = New-Object -TypeName Microsoft.Open.AzureAD.Model.RoleMemberInfo
                    #$RoleMember.ObjectId = $objID

                    $RoleMember = New-Object -TypeName Microsoft.Open.MSGraph.Model.MsRolememberinfo
                    $RoleMember.Id = $objID

                    $objRoles = Get-AzureADMSScopedRoleMembership -Id $AADAdminUnit  | Where-Object {$_.RoleMemberInfo.Id -eq $objID}

                    $uaadminTrue = $objRoles | Where-Object {$_.RoleId -eq $uaadmin.ObjectId}
                    $helpdeskadminTrue = $objRoles | Where-Object {$_.RoleId -eq $helpdeskadmin.ObjectId}
                    $authadminTrue = $objRoles | Where-Object {$_.RoleId -eq $authadmin.ObjectId}
                    $groupsadminTrue = $objRoles | Where-Object {$_.RoleId -eq $groupsadmin.ObjectId}

                    if($UserAccountAdministrator -and $uaadmin) {
                            if ($uaadminTrue) {
                                Write-Log -Message "$wString4 Role:UserAdministrator;UserObjectID:$objID" -LogLevel WARN -ConsoleOutput
                            }
                            else {
                                Add-AzureADMSScopedRoleMembership -Id $AADAdminUnit -RoleId $uaadmin.ObjectId -RoleMemberInfo $RoleMember
                                if($?){Write-Log -Message "$sString3;UserObjectID:$objID" -LogLevel SUCCESS -ConsoleOutput}
                            }
                            
                        }
                    if($HelpDeskAdministrator -and $helpdeskadmin) {
                            if ($helpdeskadminTrue) {
                                Write-Log -Message "$wString4 Role:HelpDeskAdministrator;UserObjectID:$objID" -LogLevel WARN -ConsoleOutput
                            }
                            else {
                                Add-AzureADMSScopedRoleMembership -Id $AADAdminUnit -RoleId $helpdeskadmin.ObjectId -RoleMemberInfo $RoleMember
                                if($?){Write-Log -Message "$sString4;UserObjectID:$objID" -LogLevel SUCCESS -ConsoleOutput}    
                            }
                        }
                    if($AuthenticationAdministrator -and $authadmin) {
                            if ($authadminTrue) {
                                Write-Log -Message "$wString4 Role:AuthenticationAdministrator;UserObjectID:$objID" -LogLevel WARN -ConsoleOutput
                            }
                            else {
                                Add-AzureADMSScopedRoleMembership -Id $AADAdminUnit -RoleId $authadmin.ObjectId -RoleMemberInfo $RoleMember
                                if($?){Write-Log -Message "$sString5;UserObjectID:$objID" -LogLevel SUCCESS -ConsoleOutput}    
                            }
                        }
                    if($GroupsAdministrator -and $groupsadmin) {
                            if ($groupsadminTrue) {
                                Write-Log -Message "$wString4 Role:AuthenticationAdministrator;UserObjectID:$objID" -LogLevel WARN -ConsoleOutput
                            }
                            else {
                                Add-AzureADMSScopedRoleMembership -Id $AADAdminUnit -RoleId $groupsadmin.ObjectId -RoleMemberInfo $RoleMember
                                if($?){Write-Log -Message "$sString6;UserObjectID:$objID" -LogLevel SUCCESS -ConsoleOutput}
                            }
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

#Disconnect-AzureAD    
