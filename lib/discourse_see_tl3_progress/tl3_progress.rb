module DiscourseSeeTl3Progress
  class TL3Stats
    def initialize(user)
      @user = user
      @reqs = TrustLevel3Requirements.new(user)
    end

    def stats
      # TODO: Set user_id to @user.id
      # notification_level = 0 : muted
      num_posts_in_muted_categories = DB.query_single(<<~SQL, @user.id).first || 0
          SELECT COUNT(p.id)
          FROM posts p
          JOIN topics t ON t.id = p.topic_id
          JOIN category_users cu ON cu.category_id = t.category_id
          WHERE cu.notification_level = 0
            AND cu.user_id = ?
            AND p.deleted_at IS NULL
        SQL

      num_topics_in_muted_categories = DB.query_single(<<~SQL, @user.id).first || 0
          SELECT COUNT(t.id)
          FROM topics t
          JOIN category_users cu ON cu.category_id = t.category_id
          WHERE cu.notification_level = 0
            AND cu.user_id = ?
            AND t.deleted_at IS NULL
        SQL

      {
        time_period: SiteSetting.tl3_time_period,
        on_grace_period: @reqs.on_grace_period,
        num_posts_in_muted_categories: num_posts_in_muted_categories,
        num_topics_in_muted_categories: num_topics_in_muted_categories,
        silenced: @user.silenced?,
        suspended: @user.suspended?,
        penalty_counts: @reqs.penalty_counts,
        days_visited: {
          value: @reqs.days_visited,
          req: @reqs.min_days_visited,
        },
        num_topics_replied_to: {
          value: @reqs.num_topics_replied_to,
          req: @reqs.min_topics_replied_to,
        },
        topics_viewed: {
          value: @reqs.topics_viewed,
          req: @reqs.min_topics_viewed,
        },
        posts_read: {
          value: @reqs.posts_read,
          req: @reqs.min_posts_read,
        },
        num_flagged_posts: {
          value: @reqs.num_flagged_posts,
          req: @reqs.max_flagged_posts,
          max: true,
        },
        num_flagged_by_users: {
          value: @reqs.num_flagged_by_users,
          req: @reqs.max_flagged_by_users,
          max: true,
        },
        topics_viewed_all_time: {
          value: @reqs.topics_viewed_all_time,
          req: @reqs.min_topics_viewed_all_time,
        },
        posts_read_all_time: {
          value: @reqs.posts_read_all_time,
          req: @reqs.min_posts_read_all_time,
        },
        likes_given: {
          value: @reqs.num_likes_given,
          req: @reqs.min_likes_given,
        },
        likes_received: {
          value: @reqs.num_likes_received,
          req: @reqs.min_likes_received,
        },
        num_likes_received_users: {
          value: @reqs.num_likes_received_users,
          req: @reqs.min_likes_received_users,
        },
        num_likes_received_days: {
          value: @reqs.num_likes_received_days,
          req: @reqs.min_likes_received_days,
        },
      }
    end
  end
end