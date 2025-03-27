import type { Meta, StoryObj } from "@storybook/react";
import Container from "./Container";

const meta = {
  title: "Components/Container",
  component: Container,
  argTypes: {
    ref: { table: { disable: true } },
    children: { table: { disable: true } },
    component: { table: { disable: true } },
    className: { table: { disable: true } },
  },
} satisfies Meta<typeof Container>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Overview: Story = {
  args: {
    disableGutters: false,
    fluid: false,
    children: (
      <div
        style={{
          backgroundColor: "#3B82F6",
          color: "white",
          padding: "1rem",
          width: "100%",
          height: "400px",
        }}
      >
        This is a container box.
      </div>
    ),
  },
};
