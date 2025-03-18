/**
 * @description Interface for the Products selector
 * Defines the contract for querying Product2 records
 */
public interface IProductsSelector extends IApplicationSObjectSelector {
    
    /**
     * @description Select products by ID
     * @param productIds Set of product IDs
     * @return List<Product2> List of product records
     */
    List<Product2> selectById(Set<Id> productIds);
    
    /**
     * @description Select products by product code
     * @param productCodes Set of product codes
     * @return List<Product2> List of product records
     */
    List<Product2> selectByProductCode(Set<String> productCodes);
    
    /**
     * @description Select products by family
     * @param families Set of product families
     * @param activeOnly Only include active products if true
     * @return List<Product2> List of product records
     */
    List<Product2> selectByFamily(Set<String> families, Boolean activeOnly);
    
    /**
     * @description Select products with pricing information
     * @param productIds Set of product IDs
     * @param pricebookId Optional pricebook ID
     * @return List<Product2> List of product records with price entries
     */
    List<Product2> selectWithPricingById(Set<Id> productIds, Id pricebookId);
    
    /**
     * @description Search products by name or description
     * @param searchTerm Search term
     * @param limitCount Maximum number of records to return
     * @return List<Product2> List of matching product records
     */
    List<Product2> searchProducts(String searchTerm, Integer limitCount);
}