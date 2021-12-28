# Set-AADAUDynamic
This script automates the population of Scoped Users and Scoped Administrators to Azure AD Administrative Units.

Automation is completed by targeting Dynamic or Static Azure AD Groups which will populate the Administrative Unit with Users and Administrators for the selected scope. 

```Set-AADAURoleGroups [-AADAdminUnit <string[ObjectID]>] [-UserGroup <string[ObjectID]>] [-AdminGroup <array[ObjectID]>] [-GroupFilter <string[description_field*]>] [-HelpDeskAdministrator <switch>] [-UserAccountAdministrator <switch>] [-AuthenticationAdministrator <switch>] [-GroupsAdministrator <switch>]  ```

### Extra Notes ###

This function requires that you have already created your Adminstrative Unit, the Group containing user objects and the Group containing Admin objects. You will also need the ObjectID for roles Helpdesk Administrator or User Account Administrator which can be obtained by running Get-AzureADDirectoryRole

Please be aware that the DifferentialScope applies to both users and Administrators meaning that large changes will also impact the provensioning of Scoped Administrators.  

We also upgraded from AzureADPreview to GA AzureAD Module Version: 2.0.2.140 () You may need to first Enable-AzureADDirectoryRole for both the Helpdesk Administrator & User Account Administrator.

```
<# 
.SYNOPSIS
This script automates the population of Users and Administrators to Azure AD Administrative Units.

.DESCRIPTION
Automation is completed by targeting Dynamic or Static Azure AD Groups which will populate the Administrative Unit with Users and Administrators for the selected scope. 

## Set-AADAUDynamic [-AADAdminUnit <array[ObjectID],[ObjectID]>] [-UserGroup <string[ObjectID]>] [-AdminGroup <array[ObjectID]>] [-GroupFilter <string[description_field*]>] [-HelpDeskAdministrator <switch>] [-UserAccountAdministrator <switch>] [-AuthenticationAdministrator <switch>] [-GroupsAdministrator <switch>] [-AutomationPSCredential <string[Name]>] [-AutomationPSCertificate <string[Name]>] [-AutomationPSConnection <string[Name]>]

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

    - Run Get-AzureADDirectoryRoleTemplate
    - Then Enable-AzureADDirectoryRole -RoleTemplateId <ObjectId>

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
