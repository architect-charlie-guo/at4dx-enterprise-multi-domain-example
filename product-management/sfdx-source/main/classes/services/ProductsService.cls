/**
 * @description Service implementation for Product operations
 * Provides business operations for Product2 records
 */
public with sharing class ProductsService implements IProductsService {
    
    /**
     * @description Create a new product
     * @param name Product name
     * @param productCode Product code
     * @param family Product family
     * @param isActive Whether the product is active
     * @return Id The ID of the created product
     */
    public Id createProduct(String name, String productCode, String family, Boolean isActive) {
        // Create a new product record
        Product2 newProduct = new Product2(
            Name = name,
            ProductCode = productCode,
            Family = family,
            IsActive = isActive
        );
        
        // Get a Unit of Work instance
        IApplicationSObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        // Register the new product
        uow.registerNew(newProduct);
        
        // Commit the work
        uow.commitWork();
        
        // Publish an event about the new product
        EventPublisher.publish(
            'Product',
            'PRODUCT_CREATED',
            new Map<String, Object> {
                'productId' => newProduct.Id,
                'productName' => name,
                'productCode' => productCode
            }
        );
        
        return newProduct.Id;
    }
    
    /**
     * @description Update product details
     * @param productId Product ID
     * @param fields Map of field names to values
     */
    public void updateProduct(Id productId, Map<String, Object> fields) {
        // Get the product selector
        IProductsSelector productsSelector = ProductsSelector.newInstance();
        
        // Get the product by ID
        List<Product2> products = productsSelector.selectById(new Set<Id>{ productId });
        
        if (products.isEmpty()) {
            throw new ProductsServiceException('Product not found: ' + productId);
        }
        
        Product2 product = products[0];
        
        // Update the fields
        for (String fieldName : fields.keySet()) {
            Object value = fields.get(fieldName);
            product.put(fieldName, value);
        }
        
        // Get a Unit of Work instance
        IApplicationSObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        // Register the dirty product
        uow.registerDirty(product);
        
        // Commit the work
        uow.commitWork();
        
        // Publish an event about the updated product
        EventPublisher.publish(
            'Product',
            'PRODUCT_UPDATED',
            new Map<String, Object> {
                'productId' => productId,
                'updatedFields' => new List<String>(fields.keySet())
            }
        );
    }
    
    /**
     * @description Activate products
     * @param productIds Products to activate
     */
    public void activateProducts(Set<Id> productIds) {
        // Get the product selector
        IProductsSelector productsSelector = ProductsSelector.newInstance();
        
        // Get the products by ID
        List<Product2> products = productsSelector.selectById(productIds);
        
        // Get the domain layer to handle activation
        IProducts productsDomain = (IProducts) Application.Domain.newInstance(products);
        
        // Set the products to active
        productsDomain.setProductActiveStatus(productIds, true);
    }
    
    /**
     * @description Deactivate products
     * @param productIds Products to deactivate
     */
    public void deactivateProducts(Set<Id> productIds) {
        // Get the product selector
        IProductsSelector productsSelector = ProductsSelector.newInstance();
        
        // Get the products by ID
        List<Product2> products = productsSelector.selectById(productIds);
        
        // Get the domain layer to handle deactivation
        IProducts productsDomain = (IProducts) Application.Domain.newInstance(products);
        
        // Set the products to inactive
        productsDomain.setProductActiveStatus(productIds, false);
    }
    
    /**
     * @description Create or update a price book entry
     * @param productId Product ID
     * @param pricebookId Price book ID
     * @param unitPrice Unit price
     * @param isActive Whether the price book entry is active
     * @return Id The ID of the price book entry
     */
    public Id createOrUpdatePricebookEntry(Id productId, Id pricebookId, Decimal unitPrice, Boolean isActive) {
        // Query for an existing price book entry
        List<PricebookEntry> existingEntries = [
            SELECT Id, UnitPrice, IsActive
            FROM PricebookEntry
            WHERE Product2Id = :productId AND Pricebook2Id = :pricebookId
            LIMIT 1
        ];
        
        // Get a Unit of Work instance
        IApplicationSObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        
        PricebookEntry pbe;
        Boolean isNew = existingEntries.isEmpty();
        
        if (isNew) {
            // Create a new price book entry
            pbe = new PricebookEntry(
                Product2Id = productId,
                Pricebook2Id = pricebookId,
                UnitPrice = unitPrice,
                IsActive = isActive
            );
            
            // Register the new price book entry
            uow.registerNew(pbe);
        } else {
            // Update the existing price book entry
            pbe = existingEntries[0];
            pbe.UnitPrice = unitPrice;
            pbe.IsActive = isActive;
            
            // Register the dirty price book entry
            uow.registerDirty(pbe);
        }
        
        // Commit the work
        uow.commitWork();
        
        // Publish an event about the price book entry
        EventPublisher.publish(
            'Product',
            isNew ? 'PRICEBOOK_ENTRY_CREATED' : 'PRICEBOOK_ENTRY_UPDATED',
            new Map<String, Object> {
                'productId' => productId,
                'pricebookId' => pricebookId,
                'pricebookEntryId' => pbe.Id,
                'unitPrice' => unitPrice
            }
        );
        
        return pbe.Id;
    }
    
    /**
     * @description Search for products by term
     * @param searchTerm Search term
     * @param limitCount Maximum number of records to return
     * @return List<Product2> List of matching products
     */
    public List<Product2> searchProducts(String searchTerm, Integer limitCount) {
        // Get the product selector
        IProductsSelector productsSelector = ProductsSelector.newInstance();
        
        // Search for products
        return productsSelector.searchProducts(searchTerm, limitCount);
    }
    
    /**
     * @description Custom exception class for ProductsService
     */
    public class ProductsServiceException extends Exception {}
}