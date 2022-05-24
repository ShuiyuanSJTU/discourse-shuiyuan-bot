# frozen_string_literal: true

# name: discourse-shuiyuan-bot
# about: A bot for Shuiyuan forum
# version: 0.0.1
# authors: ShuiyuanSJTU
# url: https://github.com/ShuiyuanSJTU/discourse-shuiyuan-bot
# required_version: 2.7.0
# transpile_js: true

enabled_site_setting :shuiyuan_bot_enabled

after_initialize do
  class ::UsersController
    before_action :notify_user_when_check_email, only: [:check_emails]
      
    def notify_user_when_check_email
      user = fetch_user_from_params(include_inactive: true)
      if SiteSetting.shuiyuan_bot_enabled && SiteSetting.shuiyuan_bot_checkemail_notify && user != current_user 
        bot_user = User.find_by(username: SiteSetting.shuiyuan_bot_username)
        targets = SiteSetting.shuiyuan_bot_checkemail_cc.split("|").append(user.username)
        PostCreator.create!(
          bot_user? bot_user : Discourse.system_user,
          title: I18n.t("shuiyuan_bot.notify_pm_title"),
          raw: I18n.t("shuiyuan_bot.notify_pm_content", site_name: SiteSetting.title),
          skip_validations: true,
          archetype: Archetype.private_message,
          target_usernames: targets)
      end
    end
  end
end
