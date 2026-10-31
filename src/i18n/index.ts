import en from "./en.json" with { type: "json" };

export type MessageKey = keyof typeof en;

const messages: Record<MessageKey, string> = en;

/** Returns the message for a key and replaces {name} placeholders with values. */
export function t(key: MessageKey, values: Record<string, string | number> = {}): string {
  return messages[key].replace(/\{(\w+)\}/g, (match, name: string) =>
    name in values ? String(values[name]) : match,
  );
}

export const messagesForTest = messages;
