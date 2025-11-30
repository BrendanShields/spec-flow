import { z } from 'zod';

export const HookOutputSchema = z.object({
  hookSpecificOutput: z.object({
    hookEventName: z.string(),
    additionalContext: z.string().optional(),
  }),
});

export const FeatureSchema = z.object({
  id: z.string(),
  title: z.string(),
  status: z.enum(['initialize', 'specification', 'clarification', 'planning', 'implementation', 'complete']),
  priority: z.string().optional(),
  progress: z.object({
    total: z.number(),
    done: z.number(),
  }).optional(),
  artifacts: z.array(z.string()),
});

export const ContextSchema = z.object({
  features: z.array(FeatureSchema),
  architecture: z.object({
    has_prd: z.boolean(),
    has_tdd: z.boolean(),
  }),
  suggestion: z.string().nullable(),
});

export const ValidationResultSchema = z.object({
  valid: z.boolean(),
  missing: z.array(z.string()).optional(),
  suggestion: z.string().optional(),
});
