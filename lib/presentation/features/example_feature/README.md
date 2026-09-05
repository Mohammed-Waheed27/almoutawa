# Example Feature Structure

This is an example of how to structure a feature. Replace `example_feature` with your actual feature name.

## Structure

```
example_feature/
├── sections/          # Main sections/components of the page
│   └── example_section.dart
├── widgets/          # Widgets specific to this feature
│   └── example_widget.dart
├── bloc/             # BLoC state management
│   ├── example_event.dart
│   ├── example_state.dart
│   └── example_bloc.dart
└── pages/            # Page/screen files
    └── example_page.dart
```

## Guidelines

1. **Sections**: Break down the page into logical sections
2. **Widgets**: Create reusable widgets for this feature only
3. **BLoC**: Use BLoC pattern for state management
4. **Pages**: Main page file that combines sections and widgets

## Example Implementation

### Page
```dart
// pages/example_page.dart
class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExampleBloc(),
      child: Scaffold(
        body: Column(
          children: [
            ExampleSection(),
            ExampleWidget(),
          ],
        ),
      ),
    );
  }
}
```

### Section
```dart
// sections/example_section.dart
class ExampleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Section content
    );
  }
}
```

### Widget
```dart
// widgets/example_widget.dart
class ExampleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Widget content
    );
  }
}
```

