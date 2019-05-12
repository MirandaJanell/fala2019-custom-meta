public with sharing class OppDiscountServiceOriginal {
	/**
	 * Updates Opportunity Line Item discounts based on hard coded business rules.
	 * @param  oppIds The Opportunitiy Record Ids 
	 */
	public void updateLineItemDiscounts(List<Id> oppIds) {
		Set<Id> acctIds = new Set<Id>();
		Set<Id> priceEntryIds = new Set<Id>();
		List<OpportunityLineItem> oppLines = 
			[SELECT Id, OpportunityId, PricebookEntryId, Discount, Quantity FROM OpportunityLineItem WHERE OpportunityId IN :oppIds];
		
		for(OpportunityLineItem item : oppLines) {
			item.Discount  = 0;
			priceEntryIds.add(item.PricebookEntryId);
		}

		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
			[SELECT Id, AccountId FROM Opportunity WHERE Id IN :oppIds]);
		Map<Id, PricebookEntry> priceEntryMap = new Map<Id, PricebookEntry>(
			[SELECT Id, Product2Id, Product2.Name FROM PricebookEntry WHERE Id IN :priceEntryIds]);

		for(OpportunityLineItem item : oppLines) {
			Opportunity opp = oppMap.get(item.OpportunityId);
			PricebookEntry priceEntry = priceEntryMap.get(item.PricebookEntryId);

			if(opp.AccountId == '0011F00000RQ2VDQA1') {
				item.Discount = 20;
			} else if(priceEntry.Product2.Name == 'Tie Fighter') {
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
}
