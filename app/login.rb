# frozen_string_literal: true

def log_in
  phone = ask_promt(I18n.t('auth.login.prompt_phone'))
  password = ask_promt(I18n.t('auth.login.prompt_password'))

  user = authenticate_user(phone, password)

  return nil if user.nil?

  return user if password_correct?(user, password)

  nil
end

def password_correct?(user, password)
  hash_from_db = user.nil? ? nil : user['password_digest']
  return false if hash_from_db.nil?

  verify_password(hash_from_db, password)
end

def authenticate_user(phone, _password)
  load_users.find { |user| user['phone'] == phone }
end
