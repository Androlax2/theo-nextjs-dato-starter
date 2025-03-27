import { ImageGalleryBlockFragment } from "@/components/blocks/ImageGalleryBlock/ImageGalleryBlock";
import { VideoBlockFragment } from "@/components/blocks/VideoBlock/VideoBlock";
// plop: DynamicContentRendererFragmentImport

import { type FragmentOf, graphql, readFragment } from "@/lib/datocms/graphql";
import dynamic from "next/dynamic";
import type React from "react";

import { handleError } from "@/lib/utils";
import defaultComponentRegistry from "./componentRegistry";

/**
 * Let's define the GraphQL fragment needed for the component to function.
 *
 * GraphQL fragment colocation keeps queries near the components using them,
 * improving maintainability and encapsulation. Fragment composition enables
 * building complex queries from reusable parts, promoting code reuse and
 * efficiency. Together, these practices lead to more modular, maintainable, and
 * performant GraphQL implementations by allowing precise data fetching and
 * easier code management.
 *
 * Learn more: https://gql-tada.0no.co/guides/fragment-colocation
 */
export const DynamicContentRendererFragment = graphql(
  /* GraphQL */ `
    fragment DynamicContentRendererFragment on ContentRecord {
        content {
            __typename
            ... on RecordInterface {
                id
            }
            ... on ImageGalleryBlockRecord {
                ...ImageGalleryBlockFragment
            }
            ... on VideoBlockRecord {
                ...VideoBlockFragment
            }
            # plop: DynamicContentRendererFragmentSpreads
        }
    }
  `,
  [
    ImageGalleryBlockFragment,
    VideoBlockFragment,
    // plop: DynamicContentRendererFragmentComposition
  ],
);

/**
 * Cache for dynamic components to avoid re-importing on every render.
 *
 * biome-ignore lint/suspicious/noExplicitAny: any is used to allow any component type.
 */
const dynamicComponents: Record<string, React.ComponentType<any>> = {};

/**
 * Returns a dynamically imported component based on the provided name.
 * The function caches the dynamic import, so it only happens once per component.
 *
 * biome-ignore lint/suspicious/noExplicitAny: any is used to allow any component type.
 */
function getDynamicComponent(componentName: string): React.ComponentType<any> {
  if (!dynamicComponents[componentName]) {
    try {
      dynamicComponents[componentName] = dynamic(
        () => import(`@/components/blocks/${componentName}/${componentName}`),
      );
    } catch (error) {
      // Log or handle the error as needed.
      handleError(`Error loading ${componentName}: ${error}`);
      return () => null;
    }
  }
  return dynamicComponents[componentName];
}

type Props = {
  data: FragmentOf<typeof DynamicContentRendererFragment>;
  /**
   * Optional registry of components to use instead of the default one.
   *
   * biome-ignore lint/suspicious/noExplicitAny: any is used to allow any component type.
   */
  componentRegistry?: Record<string, React.ComponentType<any>>;
};

export default function DynamicContentRenderer({
  data,
  componentRegistry,
}: Props) {
  // Merge the default registry with any registry passed via props.
  const combinedRegistry = {
    ...defaultComponentRegistry,
    ...componentRegistry,
  };

  // Read unmasked data from fragment
  const unmaskedData = readFragment(DynamicContentRendererFragment, data);

  return unmaskedData.content.map((block) => {
    // Derive the component name by removing the "Record" suffix.
    const componentName = block.__typename.replace(/Record$/, "");

    // Check if the block only contains id and __typename (that means that it hasn't been fetched)
    const blockKeys = Object.keys(block);
    const isMinimalBlock =
      blockKeys.length <= 2 &&
      blockKeys.includes("id") &&
      blockKeys.includes("__typename");

    if (isMinimalBlock) {
      // If block only has id and __typename, skip rendering
      return null;
    }

    const Component =
      combinedRegistry[componentName] || getDynamicComponent(componentName);

    if (!Component) {
      handleError(
        `Component "${componentName}" not found. 
        
Please ensure that:
 - The component file exists at "@/components/blocks/${componentName}/${componentName}" and exports the component correctly.
 - The GraphQL "__typename" follows the naming convention (i.e. ends with "Record" so that "${componentName}" is derived properly).
 - If you are using a custom component override, it is correctly registered in the "src/blocks/DynamicContentRenderer/componentRegistry.ts".
 - The file path and naming are case-sensitive and match exactly.`,
      );

      return null;
    }

    return <Component key={block.id} data={block} />;
  });
}
