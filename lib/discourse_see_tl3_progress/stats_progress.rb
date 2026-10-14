# frozen_string_literal: true

module DiscourseSeeTl3Progress
  class StatsProgress
    def initalize(user)
      @user = user
      @promotion = Promotion.new(user)
      @stat = user.user_stat
    end

    def stats
      if @user.trust_level + 1 == 1 then
        return tl1_stats()
      elsif @user.trust_level + 1 == 2 then
        return tl2_stats()
      elsif @user.trust_level + 1 == 3 then
        return tl3_stats()
      else
        return {}
      end
    end

    # TL0 -> TL1
    def tl1_stats
      {
        tl1_met: @promotion.tl1_met,
        topics_entered: {
          value: @stat.topics_entered,
          req: SiteSetting.tl1_requires_topics_entered
        },
        posts_read: {
          value: @stat.posts_read_count,
          req: SiteSetting.tl1_requires_read_posts
        },
        time_read: {
          value: @stat.time_read / 60,
          req: SiteSetting.tl1_requires_time_spent_mins
        },
        account_existed_time: {
          value: (Time.now - @user.created_at) / 60,
          req: SiteSetting.tl1_requires_time_spent_mins
        },
      }
    end

    # TL1 -> TL2
    def tl2_stats
      {
        tl2_met: @promotion.tl2_met,
        days_visited: {
          value: @stat.days_visited,
          req: SiteSetting.tl2_requires_days_visited
        },
        topics_entered: {
          value: @stat.topics_entered,
          req: SiteSetting.tl2_requires_topics_entered
        },
        posts_read: {
          value: @stat.posts_read_count,
          req: SiteSetting.tl2_requires_read_posts
        },
        time_read: {
          value: @stat.time_read / 60,
          req: SiteSetting.tl2_requires_time_spent_mins
        },
        account_existed_time: {
          value: (Time.now - @user.created_at) / 60,
          req: SiteSetting.tl2_requires_time_spent_mins
        },
        likes_given: {
          value: @stat.likes_given,
          req: SiteSetting.tl2_requires_likes_given
        },
        likes_received: {
          value: @stat.likes_received,
          req: SiteSetting.tl2_requires_likes_received
        },
        min_topics_replied_to: {
          value: @stat.calc_topic_reply_count!,
          req: SiteSetting.tl2_requires_topic_reply_count
        }
      }
    end

    # TL2 -> TL3
    def tl3_stats
      {
        tl3_met: @promotion.tl3_met
      }.merge(DiscourseSeeTl3Progress::TL3Stats.new(user).stats)
    end
  end
end
