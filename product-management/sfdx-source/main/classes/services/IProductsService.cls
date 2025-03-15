/**
 * @description Interface for the Products service
 * Defines business operations for Product2 records
 */
public interface IProductsService {
    
    /**
     * @description Create a new product
     * @param name Product name
     * @param productCode Product code
     * @param family Product family
     * @param isActive Whether the product is active
     * @return Id The ID of the created product
     */
    Id createProduct(String name, String productCode, String family, Boolean isActive);
    
    /**
     * @description Update product details
     * @param productId Product ID
     * @param fields Map of field names to values
     */
    void updateProduct(Id productId, Map<String, Object> fields);
    
    /**
     * @description Activate products
     * @param productIds Products to activate
     */
    void activateProducts(Set<Id> productIds);
    
    /**
     * @description Deactivate products
     * @param productIds Products to deactivate
     */
    void deactivateProducts(Set<Id> productIds);
    
    /**
     * @description Create or update a price book entry
     * @param productId Product ID
     * @param pricebookId Price book ID
     * @param unitPrice Unit price
     * @param isActive Whether the price book entry is active
     * @return Id The ID of the price book entry
     */
    Id createOrUpdatePricebookEntry(Id productId, Id pricebookId, Decimal unitPrice, Boolean isActive);
    
    /**
     * @description Search for products by term
     * @param searchTerm Search term
     * @param limitCount Maximum number of records to return
     * @return List<Product2> List of matching products
     */
    List<Product2> searchProducts(String searchTerm, Integer limitCount);
}