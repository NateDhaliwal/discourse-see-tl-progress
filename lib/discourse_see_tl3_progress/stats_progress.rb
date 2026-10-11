# frozen_string_literal: true

module DiscourseSeeTl3Progress
  class StatsProgress
    def initalize(user)
      @user = user
      @promotion = Promotion.new(user)
      @stat = user.user_stat
    end

    def tl1_stats
      {
        tl1_met: @promotion.tl1_met,
        topics_entered: @stat.topics_entered,
        posts_read: @stat.posts_read_count,
        time_read: @stat.time_read / 60,
        account_existed_time: (Time.now - @user.created_at) / 60
      }
    end

    def tl2_stats
      {
        tl2_met: @promotion.tl2_met,
        topics_entered: @stat.topics_entered,
        posts_read: @stat.posts_read_count,
        time_read: @stat.time_read / 60,
        account_existed_time: (Time.now - @user.created_at) / 60,
        days_visited: @stat.days_visited,
        likes_received: @stat.likes_received,
        likes_given: @stat.likes_given,
        min_topics_replied_to: stat.calc_topic_reply_count!
      }
    end

    def tl3_stats
      {
        tl3_met: @promotion.tl3_met
      }.merge(DiscourseSeeTl3Progress::TL3Stats.new(user).stats)
    end
  end
end
