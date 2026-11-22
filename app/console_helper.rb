# frozen_string_literal: true

YES_ANSWER = 'yes'
NO_ANSWER = 'no'

def clear_console
  system('clear') || system('cls')
end

def ask_promt(text)
  puts text
  gets.chomp
end

def render_table(title, headings, rows)
  Terminal::Table.new do |t|
    t.title = title
    t.headings = headings
    t.rows = rows
  end
end
