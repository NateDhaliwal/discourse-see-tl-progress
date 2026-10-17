import shouldSkip from "./should-skip";

export function stepsDone(stats) {
  let steps = 0;
  for (const stat_key in stats) {
    if (!shouldSkip(stat_key)) {
      const stat = stats[stat_key];
      if (
        (stat.max && stat.req >= stat.value) ||
        (!stat.max && stat.value >= stat.req)
      ) {
        steps++;
      }
    }
  }
  return steps;
}

export function percentageDone(stats) {
  let total = 0;
  // const allReqs = [
  //   stats["penalty_counts"]["silenced"] > 0 || stats["silenced"] ? 0 : 1,
  //   stats["penalty_counts"]["suspended"] > 0 || stats["suspended"] ? 0 : 1,
  //   stats.days_visited >= stats.min_days_visited
  //     ? 1
  //     : stats.days_visited / stats.min_days_visited,
  //   stats.num_topics_replied_to >= stats.min_topics_replied_to
  //     ? 1
  //     : stats.num_topics_replied_to / stats.min_topics_replied_to,
  //   stats.topics_viewed >= stats.min_topics_viewed
  //     ? 1
  //     : stats.topics_viewed / stats.min_topics_viewed,
  //   stats.posts_read >= stats.min_posts_read
  //     ? 1
  //     : stats.posts_read / stats.min_posts_read,
  //   stats.max_flagged_posts === 0
  //     ? 1
  //     : stats.num_flagged_posts <= stats.max_flagged_posts
  //       ? (stats.max_flagged_posts - stats.num_flagged_posts) /
  //         stats.max_flagged_posts
  //       : 0,
  //   stats.max_flagged_by_users === 0
  //     ? 1
  //     : stats.num_flagged_by_users <= stats.max_flagged_by_users
  //       ? (stats.max_flagged_by_users - stats.num_flagged_by_users) /
  //         stats.max_flagged_by_users
  //       : 0,
  //   stats.topics_viewed_all_time >= stats.min_topics_viewed_all_time
  //     ? 1
  //     : stats.topics_viewed_all_time / stats.min_topics_viewed_all_time,
  //   stats.posts_read_all_time >= stats.min_posts_read_all_time
  //     ? 1
  //     : stats.posts_read_all_time / stats.min_posts_read_all_time,
  //   stats.num_likes_given >= stats.min_likes_given
  //     ? 1
  //     : stats.num_likes_given / stats.min_likes_given,
  //   stats.num_likes_received >= stats.min_likes_received
  //     ? 1
  //     : stats.num_likes_received / stats.min_likes_received,
  //   stats.num_likes_received_days >= stats.min_likes_received_days
  //     ? 1
  //     : stats.num_likes_received_days / stats.min_likes_received_days,
  //   stats.num_likes_received_users >= stats.min_likes_received_users
  //     ? 1
  //     : stats.num_likes_received_users / stats.min_likes_received_users,
  // ];

  // for (const req of allReqs) {
  //   total += req;
  // }

  for (const stat_key in stats) {
    if (!shouldSkip(stat_key)) {
      const stat = stats[stat_key];
      if (stat.max) {
        if (stat.req >= stat.value) {
          total += 1;
        } else {
          total += (stat.value - stat.req) / stat.value;
        }
      } else {
        if (stat.value >= stat.req) {
          total += 1;
        } else {
          total += (stat.req - stat.value) / stat.req;
        }
      }
    } else {
      const stat = stats[stat_key];
      if (stat["penalty_counts"]) {
        if (stat["penalty_counts"]["silenced"] === 0) {
          total += 1;
        }
        if (stat["penalty_counts"]["suspended"] === 0) {
          total += 1;
        }
      }
    }
  }

  return Math.round((total / 14) * 100);
}

export function doesQualify(stats) {
  return stats.tl1_met ?? stats.tl2_met ?? stats.tl3_met ?? false;
}

export function nextStatToGet(stats) {
  let min_stat_key = null;
  let min = Infinity;

  for (const stat_key in stats) {
    if (!shouldSkip(stat_key)) {
      const stat = stats[stat_key];
      // Skip the flag-related stats (the user can't do anything about them)
      if (stat.max) {
        continue;
      }
      if (stat.value < stat.req) {
        const diff = stat.req - stat.value;
        if (diff < min) {
          min = diff;
          min_stat_key = stat_key;
        }
      }
    }
  }

  return {
    key: min_stat_key,
    left: min === Infinity ? 0 : min,
  };
}

export function nextStatToLose(stats, site_settings) {
  let max_stat_key = null;
  let max = 0;

  for (const stat_key in stats) {
    if (!shouldSkip(stat_key)) {
      const stat = stats[stat_key];
      // Skip the flag-related stats (the user can't do anything about them)
      if (stat.max) {
        continue;
      }
      if (stat.value > stat.req) {
        const diff = stat.value - stat.req;
        if (diff >= site_settings.low_tl3_stats_minimum && diff > max) {
          max = diff;
          max_stat_key = stat_key;
        }
      }
    }
  }

  return {
    key: max_stat_key,
    left: max,
  };
}
