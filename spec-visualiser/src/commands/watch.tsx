import React from 'react';
import { render } from 'ink';
import { WatchView } from '../components/WatchView.js';

export async function renderWatch(
  projectRoot: string,
  options: { verbose?: boolean }
): Promise<void> {
  const { waitUntilExit } = render(
    <WatchView projectRoot={projectRoot} verbose={options.verbose || false} />
  );
  await waitUntilExit();
}
