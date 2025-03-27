import { cn } from "@/lib/utils";
import type React from "react";

type ContainerProps<T extends React.ElementType = "div"> = {
  /**
   * The component used for the root node. Either a string to use an HTML element or a component.
   * @default "div"
   */
  component?: T;
  /**
   * If `true`, the left and right padding is removed.
   * @default false
   */
  disableGutters?: boolean;
  /**
   * If `true`, the container will be fixed at the screen width.
   * @default false
   */
  fluid?: boolean;
  /**
   * Override or extend the styles applied to the component.
   */
  className?: string;
  /**
   * The content of the component.
   */
  children: React.ReactNode;
} & Omit<React.ComponentPropsWithRef<T>, "className" | "children">;

export default function Container<T extends React.ElementType = "div">({
  ref,
  className,
  component,
  disableGutters = false,
  fluid = false,
  children,
  ...other
}: ContainerProps<T>) {
  const Component = component || "div";

  return (
    <Component
      ref={ref}
      className={cn(
        "mx-auto px-4",
        disableGutters && "px-0",
        fluid ? "max-w-full" : "max-w-screen-lg",
        className,
      )}
      {...other}
    >
      {children}
    </Component>
  );
}
