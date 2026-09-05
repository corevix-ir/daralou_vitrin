import { defineConfig, globalIgnores } from "eslint/config";
import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";

const eslintConfig = defineConfig([
  ...nextVitals,
  ...nextTs,
  {
    rules: {
      // This app fetches from an external REST API with plain useState/useEffect
      // (no data-fetching library, by design). The compiler-derived heuristic
      // flags any effect that transitively calls a setState it captured — which
      // includes the standard, React-docs-sanctioned "fetch on mount" pattern
      // used throughout every screen here, not just the synchronous-derived-state
      // anti-pattern it's meant to catch.
      "react-hooks/set-state-in-effect": "off",
    },
  },
  // Override default ignores of eslint-config-next.
  globalIgnores([
    // Default ignores of eslint-config-next:
    ".next/**",
    "out/**",
    "build/**",
    "next-env.d.ts",
  ]),
]);

export default eslintConfig;
