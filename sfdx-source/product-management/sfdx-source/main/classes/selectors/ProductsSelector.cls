/**
 * @description Selector for Product2 SObject
 * Implements querying logic for Product2 records
 */
public with sharing class ProductsSelector extends ApplicationSObjectSelector implements IProductsSelector {
    
    /**
     * @description Constructor for dependency injection
     */
    public ProductsSelector() {
        super();
    }
    
    /**
     * @description Factory method to create a new instance
     * @return IProductsSelector New instance of the selector
     */
    public static IProductsSelector newInstance() {
        return (IProductsSelector) Application.Selector.newInstance(Product2.SObjectType);
    }
    
    /**
     * @description Get the SObject type for this selector
     * @return Schema.SObjectType The Product2 SObject type
     */
    public Schema.SObjectType getSObjectType() {
        return Product2.SObjectType;
    }
    
    /**
     * @description Get the list of fields to query
     * @return List<Schema.SObjectField> List of fields
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Product2.Id,
            Product2.Name,
            Product2.ProductCode,
            Product2.Description,
            Product2.Family,
            Product2.IsActive,
            Product2.QuantityUnitOfMeasure,
            Product2.DisplayUrl,
            Product2.ExternalId,
            Product2.StockKeepingUnit,
            Product2.CreatedDate,
            Product2.CreatedById,
            Product2.LastModifiedDate,
            Product2.LastModifiedById
        };
    }
    
    /**
     * @description Select products by ID
     * @param productIds Set of product IDs
     * @return List<Product2> List of product records
     */
    public List<Product2> selectById(Set<Id> productIds) {
        return (List<Product2>) selectSObjectsById(productIds);
    }
    
    /**
     * @description Select products by product code
     * @param productCodes Set of product codes
     * @return List<Product2> List of product records
     */
    public List<Product2> selectByProductCode(Set<String> productCodes) {
        fflib_QueryFactory qf = newQueryFactory();
        
        qf.setCondition('ProductCode IN :productCodes');
        
        return Database.query(qf.toSOQL());
    }
    
    /**
     * @description Select products by family
     * @param families Set of product families
     * @param activeOnly Only include active products if true
     * @return List<Product2> List of product records
     */
    public List<Product2> selectByFamily(Set<String> families, Boolean activeOnly) {
        fflib_QueryFactory qf = newQueryFactory();
        
        String condition = 'Family IN :families';
        if (activeOnly) {
            condition += ' AND IsActive = true';
        }
        
        qf.setCondition(condition);
        qf.addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING);
        
        // Apply field set inclusions (this enables selector field injection from other packages)
        for (FieldSet fs : this.sObjectFieldSetList) {
            qf.selectFieldSet(fs);
        }
        
        return Database.query(qf.toSOQL());
    }
    
    /**
     * @description Select products with pricing information
     * @param productIds Set of product IDs
     * @param pricebookId Optional pricebook ID
     * @return List<Product2> List of product records with price entries
     */
    public List<Product2> selectWithPricingById(Set<Id> productIds, Id pricebookId) {
        fflib_QueryFactory qf = newQueryFactory();
        
        // Add field sets from other packages
        for (FieldSet fs : this.sObjectFieldSetList) {
            qf.selectFieldSet(fs);
        }
        
        // Add subquery for pricebook entries
        fflib_QueryFactory pbeQF = new fflib_QueryFactory(PricebookEntry.SObjectType);
        pbeQF.selectField('Id');
        pbeQF.selectField('UnitPrice');
        pbeQF.selectField('IsActive');
        pbeQF.selectField('UseStandardPrice');
        pbeQF.selectField('Pricebook2Id');
        
        if (pricebookId != null) {
            pbeQF.setCondition('Pricebook2Id = :pricebookId AND IsActive = true');
        }
        
        // Add the pricebook entry subquery to the main query
        qf.subselectQuery(pbeQF);
        
        qf.setCondition('Id IN :productIds');
        
        return Database.query(qf.toSOQL());
    }
    
    /**
     * @description Search products by name or description
     * @param searchTerm Search term
     * @param limitCount Maximum number of records to return
     * @return List<Product2> List of matching product records
     */
    public List<Product2> searchProducts(String searchTerm, Integer limitCount) {
        fflib_QueryFactory qf = newQueryFactory();
        
        // Prepare the search term for LIKE query
        String likeSearchTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';
        
        qf.setCondition('(Name LIKE :likeSearchTerm OR Description LIKE :likeSearchTerm OR ProductCode LIKE :likeSearchTerm)');
        qf.addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING);
        
        if (limitCount != null) {
            qf.setLimit(limitCount);
        }
        
        // Apply field set inclusions
        for (FieldSet fs : this.sObjectFieldSetList) {
            qf.selectFieldSet(fs);
        }
        
        return Database.query(qf.toSOQL());
    }
}