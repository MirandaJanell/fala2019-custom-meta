# Reducing Code Complexity With Custom Metadata

Complex business processes often require supporting custom code, which can have its own complexity in both logic and unit testing, and is less responsive to changing business needs. Custom Metadata is a feature that can be used along with custom code to create solutions that are easier to understand, administer and support long term. Together we will explore creating Custom Metadata powered solutions in custom code as well as making an existing custom code solution more admin friendly, easier to unit test, and easier to support long term. 

## Dev, Build and Test
The example code for this project has been developed with Salesforce DX development model. To get your Salesforce DX Environment setup, please refer to the first step of the [Quick Start: Salesforce DX](https://trailhead.salesforce.com/en/content/learn/projects/quick-start-salesforce-dx/set-up-your-salesforce-dx-environment) Trailhead Module.

All examples assume a scratch org alias of *fala19-meta*

### Create a Scratch Org
Create a scratch org with the alias of *fala19-meta*

```sh
sfdx force:org:create -f config/project-scratch-def.json -a fala19-meta
```

### Push Source to Scratch Org
In order to test our example app, we will first need to push our source to our scratch org.

```sh
sfdx force:source:push -u fala19-meta
```

### Load Test Data in Scratch Org
In order to test our example app, we need to load sample data to work with.

```sh
sfdx force:data:tree:import -u fala19-meta -f data/Product2.json
```

### Open Scratch Org in Browser
```sh
sfdx force:org:open -u fala19-meta
```



## Resources

## Description of Files and Directories

## Issues
