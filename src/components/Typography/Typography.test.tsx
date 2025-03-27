import { render } from "@testing-library/react";
import { axe, toHaveNoViolations } from "jest-axe";
import React from "react";
import Typography, { typographyVariantMapping } from "./Typography";

expect.extend(toHaveNoViolations);

describe("<Typography />", () => {
  it("renders without crashing", () => {
    const { container } = render(<Typography>Test Prop</Typography>);
    expect(container.firstChild).toBeInTheDocument();
  });

  it("has no accessibility violations", async () => {
    const { container } = render(<Typography>Accessible Prop</Typography>);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  it("applies the correct variant classes based on the variant prop", () => {
    for (const variant in typographyVariantMapping) {
      const { container } = render(
        <Typography variant={variant as keyof typeof typographyVariantMapping}>
          Variant {variant}
        </Typography>,
      );

      const expectedClassName =
        typographyVariantMapping[
          variant as keyof typeof typographyVariantMapping
        ];

      expect(container.firstChild).toHaveClass(expectedClassName);
    }
  });

  it("renders the default element type based on the variant mapping", () => {
    // When variant is "h1", it should render an <h1> element.
    const { container: containerH1 } = render(
      <Typography variant="h1">Heading 1</Typography>,
    );
    expect(containerH1.querySelector("h1")).toBeInTheDocument();

    // When variant is "p" (default), it should render a <p> element.
    const { container: containerP } = render(
      <Typography variant="p">Paragraph</Typography>,
    );
    expect(containerP.querySelector("p")).toBeInTheDocument();
  });

  it("renders a custom component if provided", () => {
    // Use a custom component (e.g. render a heading as an h3)
    const { container } = render(
      <Typography variant="h2" component="h3">
        Custom Heading
      </Typography>,
    );
    expect(container.querySelector("h3")).toBeInTheDocument();
  });

  it("forwards additional props to the rendered element", () => {
    const { container } = render(
      <Typography data-testid="typography" aria-label="typography">
        With extra props
      </Typography>,
    );
    const element = container.firstChild;
    expect(element).toHaveAttribute("data-testid", "typography");
    expect(element).toHaveAttribute("aria-label", "typography");
  });

  it("forwards ref to the DOM element", () => {
    const ref = React.createRef<HTMLElement>();
    render(
      <Typography variant="h1" ref={ref}>
        Heading with ref
      </Typography>,
    );
    expect(ref.current).not.toBeNull();
    if (ref.current) {
      expect(ref.current.tagName.toLowerCase()).toBe("h1");
    }
  });
});
