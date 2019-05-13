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

		Map<String, Map<Id, SObject>> recordsMapMap = new Map<String, Map<Id, SObject>> {
			'Opportunity' => oppMap,
			'PricebookEntry' => priceEntryMap,
			'Product2' => prodMap
		};
			
		for(OpportunityLineItem item : oppLines) {
			for(Opp_Line_Discount_Rule__mdt rule : discountRules) {
				SObject record = getRuleRecord(rule, item, recordsMapMap);

				if(rule.Object__c == 'OpportunityLineItem') {
					record = item;
				} else {
					SObject parentRec;

					if(rule.Object__c == 'Product2') {
						parentRec = recordsMapMap.get('PricebookEntry').get(item.PricebookEntryId);
					} else if(item.get(rule.Object__c + 'Id') != null) {
						parentRec = item;
					}

					if(parentRec != null) {
						Map<Id, SObject> objMap = recordsMapMap.get(rule.Object__c);
						record = objMap.get((Id) parentRec.get(rule.Object__c + 'Id'));
					}
				}

				Object val = record.get(rule.Field__r.QualifiedApiName);
				
				if(val != null) {
					if(String.isNotBlank(rule.Value__c)) {
						String strVal = (String) val;

						if(rule.Value__c.equals(strVal)) {
							item.Discount = item.Discount + rule.Discount_Percent__c;
						}
					} else {
						Decimal numVal = (Decimal) val;

						if(rule.Min_Value__c != null) {	// We have a min value rule
							if(rule.Max_Value__c != null) { // And a max value rule
								if(numVal >= rule.Min_Value__c && numVal <= rule.Max_Value__c) {	// value is between min and max values
									item.Discount = item.Discount + rule.Discount_Percent__c;
								}
							} else { // just a min value rule
								if(numVal >= rule.Min_Value__c) {	// value is greater than or equal max value
									item.Discount = item.Discount + rule.Discount_Percent__c;
								}
							}
						} else if(rule.Max_Value__c != null && numVal <= rule.Max_Value__c) { // just a max value rule and value is less than or equal max value
							item.Discount = item.Discount + rule.Discount_Percent__c;
						}
					}

					if(!rule.Allow_Additional_Discounts__c) {
						break;
					}
				}
			}
		}

		update oppLines;
	}

	private SObject getRuleRecord(Opp_Line_Discount_Rule__mdt rule, OpportunityLineItem item, Map<String, Map<Id, SObject>> recordsMapMap) {
		SObject record;

		if(rule.Object__c == 'OpportunityLineItem') {
			record = item;
		} else {
			SObject parentRec;

			if(rule.Object__c == 'Product2') {
				parentRec = recordsMapMap.get('PricebookEntry').get(item.PricebookEntryId);
			} else if(item.get(rule.Object__c + 'Id') != null) {
				parentRec = item;
			}

			if(parentRec != null) {
				Map<Id, SObject> objMap = recordsMapMap.get(rule.Object__c);
				record = objMap.get((Id) parentRec.get(rule.Object__c + 'Id'));
			}
		}

		return record;
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
