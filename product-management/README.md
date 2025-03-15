# Product Management Package

This package provides the core Product domain implementation for the enterprise application. It's a foundation package that other packages depend on for product-related functionality.

## Key Components

### Domain Layer

- **Products** - Domain class implementing business logic for Product2 objects
- **IProducts** - Interface defining the Product domain contract

### Selector Layer 

- **ProductsSelector** - Selector for querying Product2 records
- **IProductsSelector** - Interface defining the Product selector contract

### Service Layer

- **ProductsService** - Service providing business operations for Products
- **IProductsService** - Interface defining the Product service contract

## Extension Points

The Product Management package provides several extension points for other packages:

1. **Domain Process Injection** - Other packages can inject behavior into Product domain operations
2. **Selector Field Injection** - Other packages can add fields to Product queries
3. **Event Publishing** - Other packages can subscribe to Product events

## Events Published

This package publishes the following events that other packages can subscribe to:

| Category | Event Name | Description | Payload |
|----------|------------|-------------|---------|
| Product | PRODUCT_CREATED | Published when a new product is created | productId, productName, productCode |
| Product | PRODUCT_UPDATED | Published when a product is updated | productId, updatedFields |
| Product | PRODUCTS_ACTIVATED | Published when products are activated | productIds |
| Product | PRODUCTS_DEACTIVATED | Published when products are deactivated | productIds |
| Product | PRICEBOOK_ENTRY_CREATED | Published when a price book entry is created | productId, pricebookId, pricebookEntryId, unitPrice |
| Product | PRICEBOOK_ENTRY_UPDATED | Published when a price book entry is updated | productId, pricebookId, pricebookEntryId, unitPrice |

## Usage Examples

### Creating a Product

```java
// Get the products service
IProductsService productsService = (IProductsService) Application.Service.newInstance(IProductsService.class);

// Create a new product
Id newProductId = productsService.createProduct(
    'Wireless Headphones',
    'WH-2000',
    'Electronics',
    true
);
```

### Querying Products

```java
// Get the products selector
IProductsSelector productsSelector = ProductsSelector.newInstance();

// Get products by family
List<Product2> products = productsSelector.selectByFamily(
    new Set<String>{'Electronics', 'Accessories'},
    true // Active only
);
```

### Managing Products

```java
// Get the products service
IProductsService productsService = (IProductsService) Application.Service.newInstance(IProductsService.class);

// Update a product
productsService.updateProduct(
    productId,
    new Map<String, Object>{
        'Description' => 'Premium wireless headphones with noise cancellation',
        'Family' => 'Audio Equipment'
    }
);

// Create a price book entry
Id pricebookEntryId = productsService.createOrUpdatePricebookEntry(
    productId,
    pricebookId,
    199.99,
    true
);
```

## Testing

When testing components that depend on this package:

1. Mock the ProductsSelector for testing product queries
2. Mock the ProductsService for testing product operations
3. Use dependency injection to replace implementations with test doubles

## Dependencies

This package depends on:

- Shared Services Package
- fflib-apex-common
- fflib-apex-mocks
- AT4DX Framework
