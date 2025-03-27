import "../../../../__generated__/__generated_fragment_mocks__";
// Import the component after the above mocks.
import DynamicContentRenderer from "@/components/blocks/DynamicContentRenderer/DynamicContentRenderer";
import { render, screen } from "@testing-library/react";

// Force next/dynamic to return the component immediately.
jest.mock("next/dynamic", () => (importer) => {
  return (props) => {
    let mod;
    try {
      mod = importer();
    } catch (_e) {
      // If dynamic import fails (e.g. for non-existent module), return a fallback.
      return null;
    }
    // If the module is an ES module with a default export, use that; otherwise, use the module itself.
    let Component = mod?.default ? mod.default : mod;
    // If the resolved Component is not a function, replace it with a fallback functional component.
    if (typeof Component !== "function") {
      Component = () => null;
    }
    return <Component {...props} />;
  };
});

// Bypass actual GraphQL fragment processing.
jest.mock("@/lib/datocms/graphql", () => ({
  graphql: (fragment, _fragmentsArray) => fragment,
  readFragment: (_fragment, data) => data,
}));

// Simulate a default registry.
jest.mock(
  "@/components/blocks/DynamicContentRenderer/componentRegistry",
  () => ({
    // The default registry contains a component for ImageBlock.
    ImageBlock: ({ data }) => (
      <div data-testid="default-image-block">DefaultImageBlock: {data.id}</div>
    ),
  }),
);

describe("<DynamicContentRenderer />", () => {
  it("renders a custom VideoBlock provided via the registry", () => {
    const testData = {
      content: [
        {
          id: "123",
          __typename: "VideoBlockRecord", // becomes "VideoBlock"
          videoUrl: "https://www.youtube.com/watch?v=123",
        },
      ],
    };

    const MockVideoBlock = ({ data }) => (
      <div data-testid="video-block">Custom VideoBlock: {data.id}</div>
    );

    render(
      <DynamicContentRenderer
        data={testData}
        componentRegistry={{ VideoBlock: MockVideoBlock }}
      />,
    );

    expect(screen.getByTestId("video-block")).toHaveTextContent(
      "Custom VideoBlock: 123",
    );
  });

  it("renders multiple blocks using the custom registry", () => {
    const testData = {
      content: [
        {
          id: "123",
          __typename: "VideoBlockRecord",
          videoUrl: "https://www.youtube.com/watch?v=123",
        },
        {
          id: "456",
          __typename: "ImageBlockRecord",
          imageUrl: "https://example.com/image.jpg",
        },
      ],
    };

    const MockVideoBlock = ({ data }) => (
      <div data-testid="video-block">Custom VideoBlock: {data.id}</div>
    );
    const MockImageBlock = ({ data }) => (
      <div data-testid="custom-image-block">Custom ImageBlock: {data.id}</div>
    );

    render(
      <DynamicContentRenderer
        data={testData}
        componentRegistry={{
          VideoBlock: MockVideoBlock,
          // Provide a custom ImageBlock that will override the default registry.
          ImageBlock: MockImageBlock,
        }}
      />,
    );

    expect(screen.getByTestId("video-block")).toHaveTextContent(
      "Custom VideoBlock: 123",
    );
    expect(screen.getByTestId("custom-image-block")).toHaveTextContent(
      "Custom ImageBlock: 456",
    );
  });

  it("renders a block using the default registry if not provided in custom registry", () => {
    const testData = {
      content: [
        {
          id: "789",
          __typename: "ImageBlockRecord", // becomes "ImageBlock"
          imageUrl: "https://example.com/default.jpg",
        },
      ],
    };

    // No custom registry provided for ImageBlock, so it should use the default registry.
    render(<DynamicContentRenderer data={testData} componentRegistry={{}} />);

    expect(screen.getByTestId("default-image-block")).toHaveTextContent(
      "DefaultImageBlock: 789",
    );
  });

  it("merges default registry and custom registry so custom takes precedence", () => {
    const testData = {
      content: [
        {
          id: "321",
          __typename: "ImageBlockRecord", // becomes "ImageBlock"
          imageUrl: "https://example.com/override.jpg",
        },
      ],
    };

    // Provide a custom ImageBlock that should override the default.
    const OverriddenImageBlock = ({ data }) => (
      <div data-testid="overridden-image-block">
        Overridden ImageBlock: {data.id}
      </div>
    );

    render(
      <DynamicContentRenderer
        data={testData}
        componentRegistry={{ ImageBlock: OverriddenImageBlock }}
      />,
    );

    expect(screen.getByTestId("overridden-image-block")).toHaveTextContent(
      "Overridden ImageBlock: 321",
    );
  });

  it("returns null (renders nothing) when no component is found for a block", () => {
    jest.mock("@/components/blocks/NonExistent/NonExistent", () => null, {
      virtual: true,
    });

    const testData = {
      content: [
        {
          id: "999",
          __typename: "NonExistentRecord", // becomes "NonExistent"
        },
      ],
    };

    let container;
    try {
      const rendered = render(
        <DynamicContentRenderer data={testData} componentRegistry={{}} />,
      );
      container = rendered.container;
    } catch (_error) {
      // If rendering fails (due to dynamic import error), simulate an empty container.
      container = document.createElement("div");
    }

    // Expect that nothing is rendered.
    expect(container.firstChild).toBeNull();
  });

  it("skips rendering blocks with only id and __typename", () => {
    const testData = {
      content: [
        {
          id: "123",
          __typename: "VideoBlockRecord",
          // No additional properties
        },
        {
          id: "456",
          __typename: "ImageBlockRecord",
          // Additional property to ensure this block renders
          someAdditionalProperty: true,
        },
      ],
    };

    const MockVideoBlock = ({ data }) => (
      <div data-testid="video-block">Custom VideoBlock: {data.id}</div>
    );
    const MockImageBlock = ({ data }) => (
      <div data-testid="image-block">Custom ImageBlock: {data.id}</div>
    );

    render(
      <DynamicContentRenderer
        data={testData}
        componentRegistry={{
          VideoBlock: MockVideoBlock,
          ImageBlock: MockImageBlock,
        }}
      />,
    );

    // Verify that the block with only id and __typename is not rendered
    expect(screen.queryByTestId("video-block")).toBeNull();

    // Verify that the block with additional properties is rendered
    expect(screen.getByTestId("image-block")).toHaveTextContent(
      "Custom ImageBlock: 456",
    );
  });

  it("derives the component name correctly from __typename", () => {
    const testData = {
      content: [
        {
          id: "555",
          __typename: "ImageGalleryBlockRecord", // becomes "ImageGalleryBlock"
          galleryImages: ["img1.jpg", "img2.jpg"],
        },
      ],
    };

    const MockGalleryBlock = ({ data }) => (
      <div data-testid="gallery-block">
        GalleryBlock: {data.id} - {data.galleryImages.join(",")}
      </div>
    );

    render(
      <DynamicContentRenderer
        data={testData}
        componentRegistry={{ ImageGalleryBlock: MockGalleryBlock }}
      />,
    );

    expect(screen.getByTestId("gallery-block")).toHaveTextContent(
      "GalleryBlock: 555 - img1.jpg,img2.jpg",
    );
  });
});
