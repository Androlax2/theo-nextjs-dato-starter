import { render } from "@testing-library/react";
import { axe, toHaveNoViolations } from "jest-axe";
import { createRef } from "react";
import Container from "./Container";

expect.extend(toHaveNoViolations);

describe("<Container />", () => {
  it("renders without crashing", () => {
    const { container } = render(<Container>Test Container</Container>);

    expect(container.firstChild).toBeInTheDocument();
  });

  it("has no accessibility violations", async () => {
    const { container } = render(<Container>Accessible Container</Container>);

    const results = await axe(container);

    expect(results).toHaveNoViolations();
  });

  it("applies fluid max-width class when fluid is true", () => {
    const { container } = render(<Container fluid>Fluid Container</Container>);

    expect(container.firstChild).toHaveClass("max-w-full");
  });

  it("applies fixed max-width class when fluid is false", () => {
    const { container } = render(
      <Container fluid={false}>Fixed Container</Container>,
    );

    expect(container.firstChild).toHaveClass("max-w-screen-lg");
  });

  it("applies horizontal padding by default", () => {
    const { container } = render(<Container>Container with Gutters</Container>);

    expect(container.firstChild).toHaveClass("px-4");
  });

  it("removes horizontal padding when disableGutters is true", () => {
    const { container } = render(
      <Container disableGutters>Container without Gutters</Container>,
    );

    expect(container.firstChild).toHaveClass("px-0");
  });

  it("forwards additional props to the rendered element", () => {
    const { container } = render(
      <Container data-testid="container" aria-label="container">
        With extra props
      </Container>,
    );
    const element = container.firstChild;
    expect(element).toHaveAttribute("data-testid", "container");
    expect(element).toHaveAttribute("aria-label", "container");
  });

  it("forwards the ref correctly", () => {
    const ref = createRef<HTMLDivElement>();

    render(<Container ref={ref}>Container with ref</Container>);

    expect(ref.current).not.toBeNull();
  });

  it("renders the correct element when component prop is provided", () => {
    const { container } = render(
      <Container component="section">Section Container</Container>,
    );

    expect(container.querySelector("section")).toBeInTheDocument();
  });

  it("merges additional class names", () => {
    const additionalClass = "custom-class";

    const { container } = render(
      <Container className={additionalClass}>
        Container with custom class
      </Container>,
    );

    expect(container.firstChild).toHaveClass(additionalClass);
  });
});
