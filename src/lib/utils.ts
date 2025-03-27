import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Handles errors by throwing in development and logging in production.
 *
 * @param {string} message - The error message to display.
 * @throws {Error} Throws an error in development mode.
 */
export function handleError(message: string): void {
  if (process.env.NODE_ENV !== "production") {
    throw new Error(message);
  }

  console.error(message);
}
