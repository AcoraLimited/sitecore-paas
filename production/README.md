# Sitecore XM Environment (customized, non official!)

This template creates a Sitecore XM Environment with all resources necessary to run Sitecore.

Resources provisioned:
 
  * Azure SQL databases : core, master, web
  * Azure Search Service for content search
  * Azure Redis Cache for session state
  * Application Insights for diagnostics and monitoring
  * 2 Sitecore roles: Content Delivery, Content Management

    * Hosting plans: one per role
    * Preconfigured Web Applications, based on the provided WebDeploy packages
    
# What are the differences with the official XM template/repo?

Here is the list of the differences:
* Remove the `.parameters.json` file, for my mind, values shouldn't be in the source control.
* Format the files (tab, space, newline, etc.).
* Add the PowerShell script files to be reused.
* Have the `parameters` in Camel Casing like explained in this PR#3
* Remove some extra `dependsOn` to have a faster deployment like explained in this PR#4
* Integrate Connection Strings on the Azure Web Apps on itself.
* Add the "Deploy on Azure" button accordingly.
* Split the azuredeploy.json to have separately 2 deployments: Azure services and the MSDeploy (PR#6).
* Add the `allowedValues` when possible (PR#8).
* Fix the Search service `replicacount` property name + `apiVersion` date value (PR#8).
* Assign `alwaysOn` and `use32BitWorkerProcess` according the `web.sku.name` value (PR#8).
* Take into account the `linkedTemplate` pattern with these PR#9 and PR#11.
* Integrate Azure KeyVault to store and get value of: login/passwords, Sitecore license file and Sitecore MS Deploy Package URLs (PR#10 and PR#11).
* Integrate and adapt official `sitecoreSku` implementation, see PR#13 and PR#14 for more details.

# ARM Templates

* [azuredeploy.json](./azuredeploy.json) - manage both the Azure services deployment and the MSDeploy deployment  by taking into account Azure KeyVault secrets.
* [azuredeploy-services.json](./azuredeploy-services.json) - manage just the Azure services deployment (without the MSDeploy) by taking into account Azure KeyVault secrets and invoking the nested template: [azuredeploy-nested-services.json](./azuredeploy-nested-services.json).
* [azuredeploy-msdeploy.json](./azuredeploy-msdeploy.json) - manage just the MSDeploy (CM and CD) deployments by taking into account Azure KeyVault secrets and invoking the nested template: [azuredeploy-nested-msdeploy.json](./azuredeploy-nested-msdeploy.json).

# Deployments' Prerequisities

Before running any deployment script here, you should manage your secrets in Azure KeyVault by running the associated script in the [keyvault](../keyvault) folder. The secrets stored will be then used by the deployments.

# Full deployment

You could use [this script](./deploy.ps1) and adapt it for your own deployments.

This will deploy first [azuredeploy-services.json](./azuredeploy-services.json) and then [azuredeploy-msdeploy.json](./azuredeploy-msdeploy.json).

# Azure services only deployment

You could use [this script](./deploy-services.ps1) and adapt it for your own deployments.

Furthermore, to deploy just the Azure services (without deploying the MSDeploy packages nor restoring the DACPAC files) you could use this button with Azure KeyVault secrets:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathieu-benoit%2FSitecore-Azure-Quickstart-Templates%2Fmaster%2FSitecore%208.2.1%2Fmy-xm%2Fazuredeploy-services.json" target="_blank">![Deploy to Azure](http://azuredeploy.net/deploybutton.png)</a>

or without Azure KeyVault secrets:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmathieu-benoit%2FSitecore-Azure-Quickstart-Templates%2Fmaster%2FSitecore%208.2.1%2Fmy-xm%2Fazuredeploy-nested-services.json" target="_blank">![Deploy to Azure](http://azuredeploy.net/deploybutton.png)</a>

# MSDeploy only deployment

Important note: before running this "MSDeploy deployment" the Azure Web App should have been created by running the above "Full deployment" or "Azure services only deployment".

You could use [this script](./deploy.ps1) and change the `TemplateFile` parameter to target the [azuredeploy-msdeploy.json](./azuredeploy-msdeploy.json) file.

# Visual Studio Team Service (VSTS) deployment

You could find my entire documentation to setup the associated Visual Studio Team Service (VSTS) deployment with this [blog article](https://alwaysupalwayson.blogspot.com/2017/03/advanced-sitecore-arm-templates.html).