public with sharing class OppDiscountService {
	/**
	 * Updates Opportunity Line Item discounts based on hard coded business rules.
	 * @param  oppIds The Opportunitiy Record Ids 
	 */
	public void updateLineItemDiscounts(List<Id> oppIds) {
		Set<Id> oppIdsSet = new Set<Id>(oppIds);
		Set<Id> priceEntryIds = new Set<Id>();
		Set<Id> productIds = new Set<Id>();
		// Collect the fields that need to be queried for each object
		Set<String> oppFields = new Set<String>();
		Set<String> oppLineFields = new Set<String> { 'Id', 'Discount' };
		Set<String> priceEntryFields = new Set<String>();
		Set<String> productFields = new Set<String>();

		List<OpportunityLineItem> oppLines = (List<OpportunityLineItem>) queryRecords('OpportunityLineItem', oppLineFields, 'OpportunityId', oppIdsSet);
		
		for(OpportunityLineItem item : oppLines) {
			item.Discount  = 0;
			priceEntryIds.add(item.PricebookEntryId);
		}

		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
			(List<Opportunity>) queryRecords('Opportunity', oppFields, 'Id', oppIdsSet));
		Map<Id, PricebookEntry> priceEntryMap = new Map<Id, PricebookEntry>(
			(List<PricebookEntry>) queryRecords('PricebookEntry', priceEntryFields, 'Id', priceEntryIds));

		for(PricebookEntry priceEntry : priceEntryMap.values()) {
			productIds.add(priceEntry.Product2Id);
		}

		Map<Id, Product2> prodMap = new Map<Id, Product2>(
			(List<Product2>) queryRecords('Product2', productFields, 'Id', productIds));
			
		for(OpportunityLineItem item : oppLines) {
			Opportunity opp = oppMap.get(item.OpportunityId);
			PricebookEntry priceEntry = priceEntryMap.get(item.PricebookEntryId);
			Product2 prod = prodMap.get(priceEntry.Product2Id);

			if(opp.AccountId == '0011F00000RQ2VDQA1') {
				item.Discount = 20;
			} else if(prod.Name == 'Tie Fighter') {
				item.Discount = 0;
			} else {
				if(opp.Type == 'Existing Customer - Upgrade') {
					item.Discount = item.Discount + 12.5;
				}

				if(opp.Type == 'Existing Customer - Replacement') {
					item.Discount = item.Discount + 7.5;
				}

				if(item.Quantity > 100) {
					item.Discount = item.Discount + 2.5;
				} else if(item.Quantity > 500) {
					item.Discount = item.Discount + 5;
				} else if(item.Quantity > 1000) {
					item.Discount = item.Discount + 10;
				} else if(item.Quantity > 2500) {
					item.Discount = item.Discount + 15;
				}
			}
		}

		update oppLines;
	}

	private List<SObject> queryRecords(String objName, Set<String> fieldsSet, String whereField, Set<Id> whereIds) {
		List<String> fields = new List<String>(fieldsSet);
		String query = String.format(
			'SELECT {0} FROM {1} WHERE {2} IN :whereIds', 
			new List<String> {
				String.join(fields, ', '),
				objName,
				whereField
			});

		return Database.query(query);
	}
}
