import { describe, expect, it } from "vitest";
import { catalogsForTest, t } from "./index.js";

describe("i18n", () => {
  it("has the same keys in every locale", () => {
    const de = Object.keys(catalogsForTest.de).sort();
    const en = Object.keys(catalogsForTest.en).sort();
    expect(de).toEqual(en);
  });

  it("replaces placeholders", () => {
    expect(t("en", "prediction.title.shuffleRound", { round: 3 })).toBe(
      "Shuffle round 3/6: win?",
    );
  });

  // Twitch title limit is not confirmed yet (see docs/open-questions.md).
  // 45 characters is the value from an unofficial source. Keep titles under it.
  it("keeps every prediction title at 45 characters or less", () => {
    for (const catalog of Object.values(catalogsForTest)) {
      for (const [key, value] of Object.entries(catalog)) {
        if (key.startsWith("prediction.title.")) {
          expect(value.replace("{round}", "6").length, key).toBeLessThanOrEqual(45);
        }
      }
    }
  });
});
