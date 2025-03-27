import { cn } from "@/lib/utils";
import { type VariantProps, cva } from "class-variance-authority";
import type React from "react";

/**
 * Mapping of typography variants to their corresponding Tailwind CSS classes.
 *
 * Customize these classes to fit your design system.
 */
export const typographyVariantMapping = {
  h1: /** @tw */ "scroll-m-20 text-4xl font-extrabold tracking-tight text-black dark:text-black lg:text-5xl",
  h2: /** @tw */ "mt-10 scroll-m-20 pb-2 text-3xl font-bold tracking-tight text-black dark:text-black first:mt-0 lg:text-4xl",
  h3: /** @tw */ "mt-8 scroll-m-20 text-2xl font-semibold tracking-tight text-black dark:text-black",
  h4: /** @tw */ "mt-6 scroll-m-20 text-xl font-semibold tracking-tight text-black dark:text-black",
  p: /** @tw */ "text-base leading-relaxed text-black dark:text-black [&:not(:first-child)]:mt-4",
  large: /** @tw */ "text-lg font-medium text-black dark:text-black",
};

const typographyVariants = cva("", {
  variants: {
    variant: typographyVariantMapping,
  },
  defaultVariants: {
    variant: "p",
  },
});

type TypographyVariant = NonNullable<
  VariantProps<typeof typographyVariants>["variant"]
>;

/**
 * Mapping from typography variants to their default HTML element types.
 * This mapping determines which HTML element will be rendered for each variant.
 */
const defaultTypographyMapping: Record<TypographyVariant, React.ElementType> = {
  h1: "h1",
  h2: "h2",
  h3: "h3",
  h4: "h4",
  p: "p",
  large: "div",
};

type TypographyProps = {
  /**
   * The ref to the root element of the component.
   */
  ref?: React.Ref<HTMLElement>;
  /**
   * The component used for the root node. Either a string to use an HTML element or a component.
   * @default "p"
   */
  component?: React.ElementType;
  /**
   * Override or extend the styles applied to the component.
   */
  className?: string;
  /**
   * The content of the component.
   */
  children: React.ReactNode;
} & VariantProps<typeof typographyVariants> &
  Omit<
    // Typing the ref prop is a bit tricky, so we're using the `React.ElementType` type directly.
    React.ComponentPropsWithRef<React.ElementType>,
    "className" | "children"
  >;

export default function Typography({
  ref,
  className,
  component,
  variant,
  children,
  ...other
}: TypographyProps) {
  const resolvedVariant = variant ?? "p";
  const Component =
    component ||
    (defaultTypographyMapping[
      resolvedVariant as TypographyVariant
    ] as React.ElementType);

  return (
    <Component
      ref={ref}
      className={cn(typographyVariants({ variant }), className)}
      {...other}
    >
      {children}
    </Component>
  );
}
