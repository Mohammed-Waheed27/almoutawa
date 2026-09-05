# Data Layer

This layer handles data operations and implements the contracts defined in the domain layer.

## Structure

- **models/**: Data models that extend/implement domain entities
- **datasources/**: Data source implementations
  - **remote/**: API calls, network data sources
  - **local/**: Local storage (SharedPreferences, SQLite, Hive, etc.)
- **repositories/**: Repository implementations that implement domain repository interfaces

## Principles

- Implements domain layer interfaces
- Handles data transformation (JSON to models, models to entities)
- Manages caching and offline storage
- Handles network errors and retries

