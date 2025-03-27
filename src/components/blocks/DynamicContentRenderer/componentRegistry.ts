import type React from "react";

/**
 * A registry of custom React components that override the default dynamic imports.
 *
 * This registry maps component names (without the "Record" suffix) to their custom implementations.
 * You can add or modify entries here to override the default components that are dynamically imported.
 *
 * For example, if you have a CMS block with a typename "ImageBlockRecord", the registry should contain an
 * entry with the key "ImageBlock" mapping to the corresponding React component.
 *
 * biome-ignore lint/suspicious/noExplicitAny: any is used to allow any component type.
 */
const defaultComponentRegistry: Record<string, React.ComponentType<any>> = {
  // ImageBlock: CustomImageBlock,
};

export default defaultComponentRegistry;
