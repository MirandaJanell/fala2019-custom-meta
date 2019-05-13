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

### Assign the Developer Permission Set
```sh
sfdx force:user:permset:assign -n DemoAppDeveloper -u fala19-meta
```

### Load Test Data in Scratch Org
In order to test our example app, we need to load sample data to work with.

```sh
sfdx force:data:tree:import -p data/Account-Opportunity-plan.json -u fala19-meta
sfdx force:data:tree:import -f data/Product2.json -u fala19-meta
```

### Create Standard Pricebook Entry records
Our example works with Opportunity Products, and in order to add Products to Opportunities those products need price information. To keep it simple we will run some Anonymous Apex that activates our Standard Pricebook and adds a PricebookEntry record for each Product with a UnitPrice of 1000.

```sh
sfdx force:apex:execute -f scripts/createStandardPrices.apex -u fala19-meta
```

### Open Scratch Org in Browser
```sh
sfdx force:org:open -u fala19-meta
```
## Step 1: Update Queries to allow for Configurable Fields
Our ultimate goal is to be make discount rules configurable. Since we won't know all the possible fields when we write the code, we will need to update our queries to be dynamic queries in this step.

## Step 2: Create the Custom Metadata Type
In this step we will be creating the Opp Line Discount Rules Custom Metadata Type. We will need to add the following fields
Object - Metadata Relationship (Entity Definition) - Required
Field - Metadata Relationship (Field Definition) - Required
Discount Percent - Percent (16,2) - Required
Order - Number (18,0)
Value - Text(255)
Min Value - Number (16,2)
Max Value - Number (16,2)
Allow Additional Discounts - Checkbox

## Step 3: Create the Custom Metadata Records
Now that the Opp Line Discount Rules Custom Metadata Type has been created our next step is to add records. We will be creating records based on the values in the OppDiscountService Apex Class.

Step 4: Update the Apex Class
The final step is to update the OppDiscountService Apex Class to load the metadata, query the data with the configured custom fields, and apply the discounts based on the data loaded.

## Resources

## Description of Files and Directories

## Issues
