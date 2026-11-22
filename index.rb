# frozen_string_literal: true

require_relative 'app/require'

I18n.load_path += Dir["#{File.expand_path('config/locales', __dir__)}/*.yml"]
I18n.available_locales = %i[en ua]
I18n.default_locale = :en

def run
  print_main_menu
  puts "\n"
  user_action = gets.chomp
  case user_action
  when '1'
    login
  when '2'
    sign_up
  when '3'
    toggle_language
    clear_console
  when '4'
    do_exit
  else
    clear_console
  end
end

def toggle_language
  I18n.locale = (I18n.locale == :en ? :ua : :en)
end

def login
  clear_console
  user = log_in
  return 'user_not_found' if user.nil?

  case user['role']
  when USER_ROLES[:user]
    clear_console
    run_store_menu(user['phone'])
  when USER_ROLES[:admin]
    admin_greeting(user)
    loop do
      admin_panel_result = run_admin_panel(user)
      break if admin_panel_result == MOVE_TO_PREV_PANEL
    end
  else
    puts I18n.t('system.unknown_role')
    exit
  end
  nil
end

def do_exit
  clear_console
  puts I18n.t('system.exit_message')
  exit
end

def print_main_menu
  puts I18n.t('user.main')
end

def print_user_not_found
  puts I18n.t('system.user_not_found')
end

def admin_greeting(user)
  clear_console
  puts I18n.t('admin.greeting', name: user['name'])
end

loop do
  result = run

  print_user_not_found if result == 'user_not_found'
end
