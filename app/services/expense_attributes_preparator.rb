# frozen_string_literal: true

class ExpenseAttributesPreparator
  def initialize
    @username_to_id_mapping = {}
  end

  def prepare(params = {})
    params = swap_username_for_id(params.symbolize_keys, :user, :user_id)
    swap_username_for_id(params, :created_by, :created_by_id)
  end

private

  def swap_username_for_id(params, source_key, dest_key)
    params[dest_key] = id_for_username(params[source_key])
    params.delete(source_key)
    params
  end

  def id_for_username(username)
    @username_to_id_mapping[username] ||= User.find_by_username(username)&.id
  end
end
