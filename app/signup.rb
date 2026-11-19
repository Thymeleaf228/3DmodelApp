# frozen_string_literal: true

require 'yaml'

require_relative 'console_helper.rb'
require_relative 'entities/user.rb'

def sign_up
  clear_console
  name = ask_promt(I18n.t('auth.signup.prompt_username'))
  phone = ask_promt(I18n.t('auth.signup.prompt_phone'))
  password = ask_promt(I18n.t('auth.signup.prompt_password'))
  clear_console

  users = load_users
  if users.any? { |user| user['phone'] == phone }
    puts I18n.t('auth.signup.phone_exists', phone: phone)
  else
    puts I18n.t('auth.signup.registering')
    create_user(users, name, phone, password)

    puts I18n.t('auth.signup.success', name: name)
  end
end
