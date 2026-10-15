import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { service } from "@ember/service";
import { trustHTML } from "@ember/template";
import { and, eq, not, or } from "discourse/truth-helpers";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import { i18n } from "discourse-i18n";
import { doesQualify } from "../lib/calculate-stats";
import ProgressBar from "./progress-bar";

export default class Tl3ProgressModal extends Component {
  @service siteSettings;

  get stats() {
    return this.args.stats;
  }

  get suspended_before() {
    const logic =
      this.stats["penalty_counts"]["suspended"] > 0 || this.stats["suspended"];
    return {
      data: logic,
      style: `color: ${logic ? "var(--danger)" : "var(--success)"}`,
    };
  }

  get silenced_before() {
    const logic =
      this.stats["penalty_counts"]["silenced"] > 0 || this.stats["silenced"];
    return {
      data: logic,
      style: `color: ${logic ? "var(--danger)" : "var(--success)"}`,
    };
  }

  get doesQualify() {
    return doesQualify(this.stats);
  }

  get doesQualifyStyle() {
    return `color: ${this.doesQualify ? "var(--success)" : "var(--danger)"};`;
  }

  get timePeriodText() {
    return i18n("see_tl3_progress.time_period", {
      num_days: this.stats.time_period,
    });
  }

  showProgressBar(key) {
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

  <template>
    {{#if @stats}}
      <p class="inline-wrapper">
        <div style={{trustHTML this.suspended_before.style}}>
          {{dIcon (if this.suspended_before.data "xmark" "check")}}
        </div>

        {{i18n
          (if
            this.suspended_before.data
            "see_tl3_progress.suspended"
            "see_tl3_progress.not_suspended"
          )
        }}</p>

      <p class="inline-wrapper">
        <div style={{trustHTML this.silenced_before.style}}>
          {{dIcon (if this.silenced_before.data "xmark" "check")}}
        </div>

        {{i18n
          (if
            this.silenced_before.data
            "see_tl3_progress.silenced"
            "see_tl3_progress.not_silenced"
          )
        }}</p>

      <div class="all-progress-gauges">
        {{#each this.stat as |stat|}}
          {{#if (fn this.showProgressBar @key)}}{{/if}}
        {{/each}}
        {{!-- <ProgressBar
          @id="days_visited"
          @title="see_tl3_progress.days_visited"
          @total={{this.stats.min_days_visited}}
          @type="min"
          @value={{this.stats.days_visited}}
        />

        <ProgressBar
          @id="topics_replied_to"
          @title="see_tl3_progress.topics_replied_to"
          @total={{this.stats.min_topics_replied_to}}
          @type="min"
          @value={{this.stats.num_topics_replied_to}}
        />

        <ProgressBar
          @id="topics_viewed"
          @title="see_tl3_progress.topics_viewed"
          @total={{this.stats.min_topics_viewed}}
          @type="min"
          @value={{this.stats.topics_viewed}}
        />

        <ProgressBar
          @id="topics_viewed_all_time"
          @title="see_tl3_progress.topics_viewed_all_time"
          @total={{this.stats.min_topics_viewed_all_time}}
          @type="min"
          @value={{this.stats.topics_viewed_all_time}}
        />

        <ProgressBar
          @id="posts_read"
          @title="see_tl3_progress.posts_read"
          @total={{this.stats.min_posts_read}}
          @type="min"
          @value={{this.stats.posts_read}}
        />

        <ProgressBar
          @id="posts_read_all_time"
          @title="see_tl3_progress.posts_read_all_time"
          @total={{this.stats.min_posts_read_all_time}}
          @type="min"
          @value={{this.stats.posts_read_all_time}}
        />

        <ProgressBar
          @id="num_flagged_posts"
          @title="see_tl3_progress.flagged_posts"
          @total={{this.stats.max_flagged_posts}}
          @type="max"
          @value={{this.stats.num_flagged_posts}}
        />

        <ProgressBar
          @id="num_flagged_by_users"
          @title="see_tl3_progress.flagged_by_users"
          @total={{this.stats.max_flagged_by_users}}
          @type="max"
          @value={{this.stats.num_flagged_by_users}}
        />

        <ProgressBar
          @id="num_likes_given"
          @title="see_tl3_progress.likes_given"
          @total={{this.stats.min_likes_given}}
          @type="min"
          @value={{this.stats.num_likes_given}}
        />

        <ProgressBar
          @id="num_likes_received"
          @title="see_tl3_progress.likes_received"
          @total={{this.stats.min_likes_received}}
          @type="min"
          @value={{this.stats.num_likes_received}}
        />

        <ProgressBar
          @id="num_likes_received_users"
          @title="see_tl3_progress.likes_received_users"
          @total={{this.stats.min_likes_received_users}}
          @type="min"
          @value={{this.stats.num_likes_received_users}}
        />

        <ProgressBar
          @id="num_likes_received_days"
          @title="see_tl3_progress.likes_received_days"
          @total={{this.stats.min_likes_received_days}}
          @type="min"
          @value={{this.stats.num_likes_received_days}}
        /> --}}
      </div>

      <hr />

      <p class="inline-wrapper tl3-promotion-decision">
        {{!-- <div style={{trustHTML this.doesQualifyStyle}}>
          {{icon (if this.doesQualify "check" (if @is_locked "lock" "xmark"))}}
        </div> --}}
        {{#if this.doesQualify}}
          {{#if (and @is_locked (eq @locked_at_trust_level 2))}}
            {{dIcon "lock"}}
            {{i18n "see_tl3_progress.locked_will_not_be_promoted"}}
          {{else}}
            {{#if (eq @user.trust_level 2)}}
              {{dIcon "check"}}
              {{i18n "see_tl3_progress.qualifies"}}
              {{i18n "see_tl3_progress.will_be_promoted"}}
            {{else}}
              {{dIcon "check"}}
              {{i18n "see_tl3_progress.qualifies"}}
            {{/if}}
          {{/if}}
        {{else}}
          {{#if (eq @user.trust_level 3)}}
            {{#if (and @is_locked (eq @locked_at_trust_level 3))}}
              {{! User is TL3, and is locked at TL3 }}
              {{dIcon "lock"}}
              {{i18n "see_tl3_progress.locked_will_not_be_demoted"}}
            {{else}}
              {{#if @stats.on_grace_period}}
                {{dIcon "check"}}
                {{i18n "see_tl3_progress.on_grace_period"}}
              {{else}}
                {{dIcon "xmark"}}
                {{i18n "see_tl3_progress.will_be_demoted"}}
              {{/if}}
            {{/if}}
          {{else}}
            {{! User is TL2 }}
            {{dIcon "xmark"}}
            {{i18n "see_tl3_progress.does_not_qualify"}}
          {{/if}}
        {{/if}}
      </p>
    {{/if}}

    {{#if this.siteSettings.modal_bottom_text}}
      <hr />
      <p>{{trustHTML this.siteSettings.modal_bottom_text}}</p>
    {{/if}}
  </template>
}
