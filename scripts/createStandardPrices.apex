// Load the Standard Pricebook
Pricebook2 stdPb = [SELECT Id, IsActive FROM Pricebook2 WHERE IsStandard = true];
List<PricebookEntry> priceEntries = new List<PricebookEntry>();

// Activate the Standard Pricebook
stdPb.IsActive = true;
update stdPb;

// Create PricebookEntry records for each Product
for(Product2 prod : [SELECT Id FROM Product2]) {
	PricebookEntry priceEntry = new PricebookEntry();
	priceEntry.Pricebook2Id = stdPb.Id;
	priceEntry.Product2Id = prod.Id;
	priceEntry.UnitPrice = 1000;
	priceEntry.IsActive = true;
	priceEntries.add(priceEntry);
}

// insert the new PricebookEntry records
insert priceEntries;