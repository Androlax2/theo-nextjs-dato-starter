import { getPathname } from "@/i18n/navigation";
import { getBaseUrl, getLocalizedUrl } from "@/lib/url";

jest.mock("@/i18n/navigation", () => ({
  getPathname: jest.fn(),
}));

const mockedGetPathname = getPathname as jest.MockedFunction<
  typeof getPathname
>;

describe("URL Utilities", () => {
  const ORIGINAL_ENV = process.env;

  beforeEach(() => {
    jest.resetModules();
    process.env = { ...ORIGINAL_ENV, SITE_URL: "https://example.com" };
    mockedGetPathname.mockClear();
  });

  afterAll(() => {
    process.env = ORIGINAL_ENV;
  });

  describe("getBaseUrl", () => {
    test("returns base URL without path", () => {
      expect(getBaseUrl()).toBe("https://example.com");
    });

    test("returns base URL with appended path", () => {
      expect(getBaseUrl("/about")).toBe("https://example.com/about");
    });

    test("uses SITE_URL if set", () => {
      process.env.SITE_URL = "https://example.org";
      expect(getBaseUrl()).toBe("https://example.org");
    });

    test('it remove trailing "/" from the generated URL', () => {
      process.env.SITE_URL = "https://example.org/";
      expect(getBaseUrl()).toBe("https://example.org");
    });

    test('it can put a path without a leading "/"', () => {
      process.env.SITE_URL = "https://example.org";
      expect(getBaseUrl("about")).toBe("https://example.org/about");
    });

    test("uses localhost if SITE_URL is not set", () => {
      process.env.SITE_URL = undefined;
      expect(getBaseUrl()).toBe("http://localhost:3000");
    });
  });

  describe("getLocalizedUrl", () => {
    test("generates localized URL", () => {
      mockedGetPathname.mockReturnValue("/en/contact");

      const url = getLocalizedUrl("/contact", "en");

      expect(mockedGetPathname).toHaveBeenCalledWith({
        locale: "en",
        href: "/contact",
      });
      expect(url).toBe("https://example.com/en/contact");
    });

    test("uses SITE_URL if set", () => {
      process.env.SITE_URL = "https://example.org";
      mockedGetPathname.mockReturnValue("/en/contact");

      const url = getLocalizedUrl("/contact", "en");

      expect(url).toBe("https://example.org/en/contact");
    });

    test("uses localhost if SITE_URL is not set", () => {
      process.env.SITE_URL = undefined;
      mockedGetPathname.mockReturnValue("/en/contact");

      const url = getLocalizedUrl("/contact", "en");

      expect(url).toBe("http://localhost:3000/en/contact");
    });

    test('it remove trailing "/" from the generated URL', () => {
      process.env.SITE_URL = "https://example.org/";
      mockedGetPathname.mockReturnValue("/en/contact");

      const url = getLocalizedUrl("/contact", "en");

      expect(url).toBe("https://example.org/en/contact");
    });

    test('it can put a path without a leading "/"', () => {
      process.env.SITE_URL = "https://example.org";
      mockedGetPathname.mockReturnValue("/en/contact");

      const url = getLocalizedUrl("contact", "en");

      expect(url).toBe("https://example.org/en/contact");
    });
  });
});
