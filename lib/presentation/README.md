# Presentation Layer

This layer handles the UI and user interactions using Flutter widgets and BLoC for state management.

## Structure

- **features/**: Feature-based modules (each feature has its own folder)
  - Each feature folder contains:
    - **sections/**: Main sections/components of the feature
    - **widgets/**: Widgets specific to this feature
    - **bloc/**: BLoC files (events, states, bloc)
    - **pages/**: Page/screen files
- **routes/**: Navigation and routing configuration
- **bloc/**: Shared BLoC components if needed
- **widgets/**: Shared presentation widgets

## Feature Structure Example

```
features/
  home/
    sections/
      home_header.dart
      home_content.dart
    widgets/
      category_card.dart
      product_card.dart
    bloc/
      home_event.dart
      home_state.dart
      home_bloc.dart
    pages/
      home_page.dart
```

