import { exec } from "node:child_process";
import type { Actions, NodePlopAPI } from "node-plop";

export default function (plop: NodePlopAPI): void {
  // Component Generator
  plop.setGenerator("component", {
    description:
      "Generate a Next.js TSX component with Storybook and test files inside src/components",
    prompts: [
      {
        type: "input",
        name: "name",
        message: "Component name (e.g., Button):",
        validate: (value: string) =>
          value ? true : "Component name is required",
      },
    ],
    actions: [
      {
        type: "add",
        path: "../../src/components/{{pascalCase name}}/{{pascalCase name}}.tsx",
        templateFile: "templates/component/Component.tsx.hbs",
      },
      {
        type: "add",
        path: "../../src/components/{{pascalCase name}}/{{pascalCase name}}.stories.tsx",
        templateFile: "templates/component/Component.stories.tsx.hbs",
      },
      {
        type: "add",
        path: "../../src/components/{{pascalCase name}}/{{pascalCase name}}.test.tsx",
        templateFile: "templates/component/Component.test.tsx.hbs",
      },
    ],
  });

  // Block Generator
  plop.setGenerator("block", {
    description:
      "Generate a Next.js TSX block with GraphQL fragment file inside src/components/blocks",
    prompts: [
      {
        type: "input",
        name: "name",
        message: "Block name (e.g., VideoBlock):",
        validate: (value: string) => (value ? true : "Block name is required"),
      },
      {
        type: "confirm",
        name: "updateDynamicRenderer",
        message:
          "Do you want to add this block's fragment to the DynamicContentRenderer?",
        default: true,
      },
    ],
    actions: (data) => {
      const actions: Actions = [
        // Create the new block file.
        {
          type: "add",
          path: "../../src/components/blocks/{{pascalCase name}}/{{pascalCase name}}.tsx",
          templateFile: "templates/block/Block.tsx.hbs",
        },
      ];

      if (data?.updateDynamicRenderer) {
        // Update DynamicContentRenderer: fragment import.
        actions.push({
          type: "modify",
          path: "../../src/components/blocks/DynamicContentRenderer/DynamicContentRenderer.tsx",
          pattern: /(.*\/\/ plop: DynamicContentRendererFragmentImport)/,
          template:
            'import { {{pascalCase name}}Fragment } from "@/components/blocks/{{pascalCase name}}/{{pascalCase name}}";\n$1',
        });

        // Update DynamicContentRenderer: fragment spread.
        actions.push({
          type: "modify",
          path: "../../src/components/blocks/DynamicContentRenderer/DynamicContentRenderer.tsx",
          pattern: /^(\s*)# plop: DynamicContentRendererFragmentSpreads/m,
          template:
            "$1... on {{pascalCase name}}Record {\n$1    ...{{pascalCase name}}Fragment\n$1}\n$1# plop: DynamicContentRendererFragmentSpreads",
        });

        // Update DynamicContentRenderer: fragments array.
        actions.push({
          type: "modify",
          path: "../../src/components/blocks/DynamicContentRenderer/DynamicContentRenderer.tsx",
          pattern:
            /^(\s*)\/\/ plop: DynamicContentRendererFragmentComposition/m,
          template:
            "$1{{pascalCase name}}Fragment,\n$1// plop: DynamicContentRendererFragmentComposition",
        });
      }

      actions.push(
        "Running generate-schema script to update GraphQL schema...",
      );

      exec("npm run generate-schema", (error, _, stderr) => {
        if (error) {
          console.error(`Execution error: ${error}`);
          return;
        }

        if (stderr) {
          console.error(`Standard Error:\n${stderr}`);
        }
      });

      return actions;
    },
  });
}
