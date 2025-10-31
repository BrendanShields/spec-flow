import React from 'react';
import { render } from 'ink';
import { Dashboard } from '../components/Dashboard.js';

export async function renderDashboard(projectRoot: string): Promise<void> {
  const { waitUntilExit } = render(<Dashboard projectRoot={projectRoot} />);
  await waitUntilExit();
}
