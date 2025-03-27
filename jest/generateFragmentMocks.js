const fs = require("node:fs");
const path = require("node:path");

// Path to your DynamicContentRenderer file (adjust as needed)
const rendererPath = path.join(
  __dirname,
  "../src/components/blocks/DynamicContentRenderer/DynamicContentRenderer.tsx",
);
// Define the output directory and file for the generated mocks.
// In this example, we output the file to a __generated__ folder at the project root.
const outputDir = path.join(__dirname, "../__generated__");
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}
const outputPath = path.join(outputDir, "__generated_fragment_mocks__.js");

// Read the source file
const code = fs.readFileSync(rendererPath, "utf8");

// Use a regular expression to extract all occurrences of a fragment name ending in "Fragment"
const regex = /(\w+Fragment)/g;
const fragments = new Set();
let match;
while (true) {
  match = regex.exec(code);
  if (match === null) {
    break;
  }
  fragments.add(match[1]);
}

// Modules you want to skip (i.e. not to generate mocks for)
const modulesToSkip = new Set([
  "@/components/blocks/read/read",
  "@/components/blocks/DynamicContentRenderer/DynamicContentRenderer",
]);

// For each fragment, assume the module to mock is at "@/components/blocks/<Name>/<Name>"
// (i.e. remove the "Fragment" suffix to get the component name)
let output = "";
for (const fragment of fragments) {
  const componentName = fragment.replace(/Fragment$/, "");
  const moduleName = `@/components/blocks/${componentName}/${componentName}`;

  // Only generate a mock if the module name is not in the skip list.
  if (!modulesToSkip.has(moduleName)) {
    output += `jest.mock("${moduleName}", () => ({\n`;
    output += `  ${fragment}: "MOCK_${fragment}"\n`;
    output += "}));\n\n";
  }
}

// Write the generated mocks to the output file.
fs.writeFileSync(outputPath, output);

// biome-ignore lint/suspicious/noConsole: It's a script, so we want to log to the console.
console.log(`Generated fragment mocks for: ${[...fragments].join(", ")}`);
// biome-ignore lint/suspicious/noConsole: It's a script, so we want to log to the console.
console.log(`Output file: ${outputPath}`);
