public with sharing class OpportunityDiscountsAction {
	@InvocableMethod(label='Apply Line Item Discounts' description='Applies discounts to the associated line items.')
	public static void ApplyDiscounts(List<Id> oppIds) {
		System.debug(System.LoggingLevel.INFO, 'Apply Discounts Action called: oppIds: ' + oppIds);
		OppDiscountService serv = new OppDiscountService();
		serv.updateLineItemDiscounts(oppIds);
	}
}
