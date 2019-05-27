# Set-AADAURoleGroups
This script automates the population of Scoped Users and Scoped Administrators to Azure AD Administrative Units.

Automation is completed by targeting Dynamic or Static Azure AD Groups which will populate the Administrative Unit with Users and Administrators for the selected scope. 

```Set-AADAURoleGroups [-AADAdminUnit <string[ObjectID]>] [-UserGroup <string[ObjectID]>] [-AdminGroup <string[ObjectID]>] [-UserAdmin <string[ObjectID]>] [-Helpdesk <string[ObjectID]>] ```

### Extra Notes ###

This function requires that you have already created your Adminstrative Unit, the Group containing user objects and the Group containing Admin objects. You will also need the ObjectID for roles Helpdesk Administrator or User Account Administrator which can be obtained by running Get-AzureADDirectoryRole

Please be aware that the DifferentialScope applies to both users and Administrators meaning that large changes will also impact the provensioning of Scoped Administrators.  We used AzureADPreview Version: 2.0.2.5 () You may need to first Enable-AzureADDirectoryRole for both the Helpdesk Administrator & User Account Administrator.

```
.PARAMETER AADAdminUnit
The AADAdminUnit parameter specifies the ObjectId of the Administrative Unit. You can find this value by running Get-AzureADAdministrativeUnit 

.PARAMETER UserGroup
The UserGroup parameter details the ObjectId of the Administrative Unit. Get-AzureADGroup -SearchString "All Users"

.PARAMETER AdminGroup
The AdminGroup parameter details the ObjectId of the Administrative Unit. Get-AzureADGroup -SearchString "All Scoped Admins"

.PARAMETER DifferentialScope
The DifferentialScope parameter defines how many objects can be added or removed from the Administrative Units in a single operation of the script. The goal of this setting is throttle bulk changes to limit the impact of misconfigurationby an administrator. What value you choose here will be dictated by your userbase and your script schedule. The default value is set to 10 Objects. 

.PARAMETER HelpDeskAdministrator
The HelpDeskAdministrator Switch enables the O365 Helpdesk role for administrative permissions. 

.PARAMETER UserAccountAdministrator
The UserAccountAdministrator Switch enables the O365 User Account Administrator role for administrative permissions. ```

EXAMPLE 2
Set-AADUDRoleGroups -AADAdminUnit '7b7c4926-c6d7-4ca8-9bbf-5965751022c2' -UserGroup '0e55190c-73ee-e811-80e9-005056a31be6' -AdminGroup '0e55190c-73ee-e811-80e9-005056a3' -HelpDeskAdministrator

-- SET USERS AND HELPDESK ADMINISTRATORS FOR ADMIN UNIT --
In this example we add Users and Administrators (with Helpdesk Role) to the Administrative Unit '7b7c4926-c6d7-4ca8-9bbf-5965751022c2' 

EXAMPLE 2
Set-AADUDRoleGroups -AADAdminUnit '7b7c4926-c6d7-4ca8-9bbf-5965751022c2' -UserGroup '0e55190c-73ee-e811-80e9-005056a31be6' -AdminGroup '0e55190c-73ee-e811-80e9-005056a3' -HelpDeskAdministrator -UserAccountAdministrator

-- SET USERS AND HELPDESK & USER ADMINISTRATORS FOR ADMIN UNIT --
In this example we add Users and Administrators (with Helpdesk & User Account Role) to the Administrative Unit '7b7c4926-c6d7-4ca8-9bbf-5965751022c2' 

LINKS
Azure AD Dynamic Group Membership - https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/groups-dynamic-membership
Log Analytics Workspace - https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-create-workspace
Enable-AzureADDirectoryRole - https://docs.microsoft.com/en-us/powershell/module/azuread/enable-azureaddirectoryrole?view=azureadps-2.0 
