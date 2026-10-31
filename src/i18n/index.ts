import de from "./de.json" with { type: "json" };
import en from "./en.json" with { type: "json" };

export type Locale = "de" | "en";
export type MessageKey = keyof typeof en;

const catalogs: Record<Locale, Record<MessageKey, string>> = { de, en };

/** Returns the message for a key and replaces {name} placeholders with values. */
export function t(
  locale: Locale,
  key: MessageKey,
  values: Record<string, string | number> = {},
): string {
  const template = catalogs[locale][key];
  return template.replace(/\{(\w+)\}/g, (match, name: string) =>
    name in values ? String(values[name]) : match,
  );
}

export const catalogsForTest = catalogs;
