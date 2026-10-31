import { describe, expect, it } from "vitest";
import { messagesForTest, t } from "./index.js";

describe("messages", () => {
  it("replaces placeholders", () => {
    expect(t("prediction.title.shuffleRound", { round: 3 })).toBe("Shuffle round 3/6: win?");
  });

  // Twitch title limit is not confirmed yet (see docs/open-questions.md).
  // 45 characters is the value from an unofficial source. Keep titles under it.
  it("keeps every prediction title at 45 characters or less", () => {
    for (const [key, value] of Object.entries(messagesForTest)) {
      if (key.startsWith("prediction.title.")) {
        expect(value.replace("{round}", "6").length, key).toBeLessThanOrEqual(45);
      }
    }
  });
});
