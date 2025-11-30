export class Validator {
  constructor(schema) {
    this.schema = schema;
  }

  parse(data) {
    const result = this.validate(data, this.schema);
    if (!result.valid) {
      // Fail gracefully by returning data but logging warning? 
      // Or throw? The prompt says "validate the shape ... before returning JSON".
      // It implies we should probably throw or ensure data matches.
      // "validate the shape ... before returning JSON ... without silent failures"
      // So throwing is correct, but for the hook, we might want to catch and return a fallback.
      throw new Error(`Validation failed: ${result.errors.join(', ')}`);
    }
    return data;
  }

  validate(data, schema, path = '') {
    if (schema.type === 'object') {
      if (typeof data !== 'object' || data === null) {
        return { valid: false, errors: [`${path}: expected object, got ${typeof data}`] };
      }
      const errors = [];
      for (const [key, subSchema] of Object.entries(schema.properties)) {
        const subPath = path ? `${path}.${key}` : key;
        if (data[key] === undefined) {
          if (!subSchema.optional) {
            errors.push(`${subPath}: required field missing`);
          }
          continue;
        }
        const result = this.validate(data[key], subSchema, subPath);
        if (!result.valid) {
          errors.push(...result.errors);
        }
      }
      return { valid: errors.length === 0, errors };
    }

    if (schema.type === 'array') {
      if (!Array.isArray(data)) {
        return { valid: false, errors: [`${path}: expected array, got ${typeof data}`] };
      }
      const errors = [];
      data.forEach((item, index) => {
        const result = this.validate(item, schema.items, `${path}[${index}]`);
        if (!result.valid) {
          errors.push(...result.errors);
        }
      });
      return { valid: errors.length === 0, errors };
    }

    if (schema.type === 'string') {
      if (typeof data !== 'string') {
        return { valid: false, errors: [`${path}: expected string, got ${typeof data}`] };
      }
      if (schema.enum && !schema.enum.includes(data)) {
        return { valid: false, errors: [`${path}: invalid value '${data}', expected one of ${schema.enum.join(', ')}`] };
      }
      return { valid: true, errors: [] };
    }

    if (schema.type === 'number') {
      if (typeof data !== 'number') {
        return { valid: false, errors: [`${path}: expected number, got ${typeof data}`] };
      }
      return { valid: true, errors: [] };
    }

    if (schema.type === 'boolean') {
      if (typeof data !== 'boolean') {
        return { valid: false, errors: [`${path}: expected boolean, got ${typeof data}`] };
      }
      return { valid: true, errors: [] };
    }

    return { valid: true, errors: [] };
  }

  static object(properties) {
    return { type: 'object', properties };
  }

  static array(items) {
    return { type: 'array', items };
  }

  static string() {
    return { type: 'string' };
  }

  static number() {
    return { type: 'number' };
  }

  static boolean() {
    return { type: 'boolean' };
  }

  static enum(values) {
    return { type: 'string', enum: values };
  }

  static optional(schema) {
    return { ...schema, optional: true };
  }
}

// Helper to create a Validator instance
const v = {
  object: (props) => new Validator(Validator.object(props)),
  string: () => Validator.string(),
  number: () => Validator.number(),
  boolean: () => Validator.boolean(),
  enum: (values) => Validator.enum(values),
  array: (items) => Validator.array(items),
  optional: (schema) => Validator.optional(schema)
};

export const HookOutputSchema = v.object({
  hookSpecificOutput: v.object({
    hookEventName: v.string(),
    additionalContext: v.optional(v.string()),
  }),
});

export const FeatureSchema = {
  type: 'object',
  properties: {
    id: v.string(),
    title: v.string(),
    status: v.enum(['initialize', 'specification', 'clarification', 'planning', 'implementation', 'complete']),
    priority: v.optional(v.string()),
    progress: v.optional(Validator.object({
      total: v.number(),
      done: v.number(),
    })),
    artifacts: Validator.array(v.string()),
  }
};

export const ContextSchema = v.object({
  initialized: v.optional(v.boolean()),
  features: Validator.array(FeatureSchema),
  architecture: v.optional(v.object({
    has_prd: v.boolean(),
    has_tdd: v.boolean(),
  })),
  suggestion: v.optional(v.string()), 
});

export const ValidationResultSchema = v.object({
  valid: v.boolean(),
  missing: v.optional(Validator.array(v.string())),
  suggestion: v.optional(v.string()),
});