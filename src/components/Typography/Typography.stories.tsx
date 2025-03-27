import type { Meta, StoryObj } from "@storybook/react";
import Typography, { typographyVariantMapping } from "./Typography";

const meta = {
  title: "Components/Typography",
  component: Typography,
  argTypes: {
    variant: {
      control: "select",
      options: Object.keys(typographyVariantMapping),
    },
    ref: { table: { disable: true } },
    children: { table: { disable: true } },
    component: { table: { disable: true } },
    className: { table: { disable: true } },
  },
} satisfies Meta<typeof Typography>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Overview: Story = {
  args: {
    children: "Typography component",
  },
};

export const AllTypographyVariants: StoryObj = {
  render: () => (
    <div
      style={{
        display: "grid",
        gap: "1rem",
      }}
    >
      {Object.keys(typographyVariantMapping).map((variant) => (
        <Typography
          key={variant}
          variant={variant as keyof typeof typographyVariantMapping}
        >
          {`This is a ${variant} variant`}
        </Typography>
      ))}
    </div>
  ),
  parameters: {
    controls: { disable: true },
  },
};
