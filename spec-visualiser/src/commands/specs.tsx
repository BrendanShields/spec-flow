import React from 'react';
import { render } from 'ink';
import { SpecsBrowser } from '../components/SpecsBrowser.js';

export async function renderSpecs(
  projectRoot: string,
  featureId?: string
): Promise<void> {
  const { waitUntilExit } = render(
    <SpecsBrowser projectRoot={projectRoot} initialFeatureId={featureId} />
  );
  await waitUntilExit();
}
