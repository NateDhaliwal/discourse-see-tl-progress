export default function shouldSkip(key) {
  return ![
    "time_period",
    "on_grace_period",
    "num_posts_in_muted_categories",
    "num_topics_in_muted_categories",
    "silenced",
    "suspended",
    "penalty_counts",
    "tl1_met",
    "tl2_met",
    "tl3_met",
  ].includes(key);
}
