# Domain Layer

This layer contains the business logic and is independent of external frameworks. It defines what the application does.

## Structure

- **entities/**: Business objects/models that represent core concepts
- **repositories/**: Repository interfaces (abstractions, not implementations)
- **usecases/**: Business logic use cases that orchestrate repository calls

## Principles

- No dependencies on Flutter or external frameworks
- Pure Dart code
- Defines contracts (interfaces) that the data layer must implement
- Contains business rules and validation logic

