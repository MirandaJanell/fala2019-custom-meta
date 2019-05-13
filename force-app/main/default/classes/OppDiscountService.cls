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
		Map<String, Set<String>> objFieldsMap = new Map<String, Set<String>> {
			'Opportunity' => new Set<String>(),
			'OpportunityLineItem' => new Set<String> { 'Id', 'Discount' },
			'PricebookEntry' => new Set<String>(),
			'Product2' => new Set<String>()
		};
		List<Opp_Line_Discount_Rule__mdt> discountRules = queryDiscountRulesMetadata();
		processMetadataFields(discountRules, objFieldsMap);

		List<OpportunityLineItem> oppLines = (List<OpportunityLineItem>) queryRecords('OpportunityLineItem', objFieldsMap, 'OpportunityId', oppIdsSet);
		
		for(OpportunityLineItem item : oppLines) {
			item.Discount  = 0;
			priceEntryIds.add(item.PricebookEntryId);
		}

		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
			(List<Opportunity>) queryRecords('Opportunity', objFieldsMap, 'Id', oppIdsSet));
		Map<Id, PricebookEntry> priceEntryMap = new Map<Id, PricebookEntry>(
			(List<PricebookEntry>) queryRecords('PricebookEntry', objFieldsMap, 'Id', priceEntryIds));

		for(PricebookEntry priceEntry : priceEntryMap.values()) {
			productIds.add(priceEntry.Product2Id);
		}

		Map<Id, Product2> prodMap = new Map<Id, Product2>(
			(List<Product2>) queryRecords('Product2', objFieldsMap, 'Id', productIds));
			
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

	private void processMetadataFields(List<Opp_Line_Discount_Rule__mdt> discountRules, Map<String, Set<String>> objFieldsMap) {
		for(Opp_Line_Discount_Rule__mdt rule : discountRules) {
			Set<String> fields = objFieldsMap.get(rule.Object__c);
			fields.add(rule.Field__r.QualifiedApiName);

			if(rule.Object__c == 'Opportunity') {
				 fields = objFieldsMap.get('OpportunityLineItem');
				 fields.add('OpportunityId');
			} else if(rule.Object__c == 'PricebookEntry') {
				 fields = objFieldsMap.get('OpportunityLineItem');
				 fields.add('PricebookEntryId');
			} else if(rule.Object__c == 'Product2') {
				 fields = objFieldsMap.get('PricebookEntry');
				 fields.add('Product2Id');
				 fields = objFieldsMap.get('OpportunityLineItem');
				 fields.add('PricebookEntryId');
			}
		}
	}

	private List<Opp_Line_Discount_Rule__mdt> queryDiscountRulesMetadata() {
		return [SELECT Id, Object__c, Field__r.QualifiedApiName, Value__c, Min_Value__c, Max_Value__c, Discount_Percent__c, Allow_Additional_Discounts__c FROM Opp_Line_Discount_Rule__mdt ORDER BY Order__c, Min_Value__c];
	}

	private List<SObject> queryRecords(String objName, Map<String, Set<String>> objFieldsMap, String whereField, Set<Id> whereIds) {
		List<SObject> records = new List<SObject>();
		List<String> fields = new List<String>(objFieldsMap.get(objName));

		if(!fields.isEmpty()) {
			String query = String.format(
				'SELECT {0} FROM {1} WHERE {2} IN :whereIds', 
				new List<String> {
					String.join(fields, ', '),
					objName,
					whereField
				});

			records = Database.query(query);
		}
		
		return records;
	}
}
