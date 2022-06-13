# Set-AADAUDynamic
This script automates the population of Scoped Users, Groups, Devices and Scoped Administrators to Azure AD Administrative Units.

Automation is completed by targeting Dynamic or Static Azure AD Groups which will populate the Administrative Unit with Users and Administrators for the selected scope. 

``` Powershell
Set-AADAUDynamic.ps1 [-AADAdminUnit <array[ObjectID],[ObjectID]>] [-UserGroup <string[ObjectID]>] 
[-AdminGroup <array[ObjectID]>] [-GroupFilter <string[description_field*]>] [-RoleIds <array[ObjectID]>]
 [-RoleIds <array[ObjectID]>] [-AutomationPSCredential <string[Name]>] 
 [-AutomationPSCertificate <string[Name]>] [-AutomationPSConnection <string[Name]>]  
 
 ```

### Extra Notes ###

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

``` powershell
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
