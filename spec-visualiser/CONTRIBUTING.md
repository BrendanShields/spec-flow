# Contributing to Spec Visualiser

Thank you for your interest in contributing to Spec Visualiser! This document provides guidelines and instructions for contributing.

## Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/spec-visualiser.git
   cd spec-visualiser
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Build the project**
   ```bash
   npm run build
   ```

4. **Link for local testing**
   ```bash
   npm link
   ```

5. **Test in a Spec project**
   ```bash
   cd /path/to/spec/project
   spec-viz
   ```

## Project Structure

```
src/
├── cli.ts                # CLI entry point and command definitions
├── index.ts              # Main entry point
├── commands/             # Command implementations
│   ├── dashboard.ts
│   ├── specs.ts
│   ├── metrics.ts
│   ├── watch.ts
│   ├── list.ts
│   └── validate.ts
├── components/           # React/Ink UI components
│   ├── Dashboard.tsx
│   ├── SpecsBrowser.tsx
│   ├── MetricsView.tsx
│   └── WatchView.tsx
├── services/             # Business logic
│   ├── specParser.ts
│   ├── fileWatcher.ts
│   └── metricsCalculator.ts
├── types/                # TypeScript type definitions
│   └── spec.ts
└── utils/                # Utility functions
    ├── markdown.ts
    └── git.ts
```

## Development Workflow

### Making Changes

1. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write clean, readable code
   - Follow existing code style
   - Add comments for complex logic
   - Update types as needed

3. **Test your changes**
   ```bash
   npm run build
   npm link
   # Test in a real Spec project
   ```

4. **Lint and format**
   ```bash
   npm run lint
   npm run format
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: Add your feature description"
   ```

### Commit Message Convention

Follow conventional commits:
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `perf:` - Performance improvements
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

Examples:
```
feat: Add export functionality to metrics view
fix: Correct task parsing in specs browser
docs: Update README with new commands
refactor: Simplify metrics calculation logic
```

## Adding New Features

### Adding a New Command

1. **Create command file**
   ```typescript
   // src/commands/mycommand.ts
   export async function myCommand(projectRoot: string, options: any): Promise<void> {
     // Implementation
   }
   ```

2. **Add to CLI**
   ```typescript
   // src/cli.ts
   program
     .command('mycommand')
     .description('Description of command')
     .option('-f, --flag', 'Flag description')
     .action(async (options) => {
       const projectRoot = options.project || findProjectRoot();
       await myCommand(projectRoot, options);
     });
   ```

3. **Update README**
   - Add command documentation
   - Include examples
   - Document options

### Adding a New Component

1. **Create component file**
   ```typescript
   // src/components/MyComponent.tsx
   import React from 'react';
   import { Box, Text } from 'ink';

   export const MyComponent: React.FC<Props> = ({ prop }) => {
     return (
       <Box>
         <Text>Component content</Text>
       </Box>
     );
   };
   ```

2. **Use in command**
   ```typescript
   import { render } from 'ink';
   import { MyComponent } from '../components/MyComponent';

   export async function myCommand(projectRoot: string) {
     const { waitUntilExit } = render(<MyComponent projectRoot={projectRoot} />);
     await waitUntilExit();
   }
   ```

### Adding New Metrics

1. **Add to MetricsCalculator**
   ```typescript
   // src/services/metricsCalculator.ts
   calculateMyMetric(data: SomeType): number {
     // Calculation logic
     return result;
   }
   ```

2. **Update types**
   ```typescript
   // src/types/spec.ts
   export interface MyMetrics {
     myValue: number;
     // ...
   }
   ```

3. **Display in UI**
   ```typescript
   // In component
   const myMetric = calculator.calculateMyMetric(data);
   ```

## Testing

### Manual Testing

Test in a real Spec project:

```bash
# Build and link
npm run build && npm link

# Test each command
cd /path/to/spec/project
spec-viz
spec-viz specs
spec-viz metrics
spec-viz watch
spec-viz list
spec-viz validate
```

### Test Cases to Cover

- Empty project (no features)
- Single feature project
- Multiple features with various states
- Features with no tasks
- Features with many tasks (100+)
- Long feature names
- Special characters in names
- Missing files
- Corrupted markdown
- Git repository vs non-git
- Different terminal sizes

## Code Style

### TypeScript

- Use explicit types where helpful
- Avoid `any` when possible
- Use interfaces for complex types
- Export types that might be reused

### React/Ink

- Use functional components
- Use hooks for state management
- Keep components focused and small
- Extract reusable logic to custom hooks
- Handle keyboard input with `useInput`

### Formatting

- 2 spaces for indentation
- Single quotes for strings
- Semicolons required
- 100 character line limit
- Trailing commas in multiline

## Documentation

### Code Comments

Add comments for:
- Complex algorithms
- Non-obvious business logic
- Workarounds or hacks
- Performance considerations

```typescript
// Good comment
// Calculate health score based on blocked tasks and completion rate
// Score ranges from 0-100 with penalties for blockers

// Not needed
// Set the variable to 5
const value = 5;
```

### README Updates

Update README when:
- Adding new commands
- Changing command behavior
- Adding new features
- Changing metrics calculations

### JSDoc

Add JSDoc for public APIs:

```typescript
/**
 * Calculates the health score for a feature
 * @param tasks - Array of tasks for the feature
 * @param phase - Current workflow phase
 * @returns Health score object with score, status, and factors
 */
calculateHealthScore(tasks: Task[], phase: WorkflowPhase): HealthScore {
  // ...
}
```

## Pull Request Process

1. **Update documentation**
   - README.md for user-facing changes
   - CONTRIBUTING.md for development changes
   - Code comments for complex logic

2. **Test thoroughly**
   - Test in multiple scenarios
   - Check edge cases
   - Verify no regressions

3. **Create pull request**
   - Clear title describing the change
   - Detailed description of what and why
   - Screenshots/recordings for UI changes
   - Reference any related issues

4. **Address review feedback**
   - Respond to all comments
   - Make requested changes
   - Re-test after changes

## Questions or Issues?

- Open an issue for bugs or feature requests
- Use discussions for questions
- Tag maintainers for urgent issues

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
