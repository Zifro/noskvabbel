# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'routes for Expenses', type: :routing do
  it 'routes GET /expenses to expenses#index' do
    expect(get: '/expenses').to route_to('expenses#index')
  end

  it 'routes GET /expenses/load_more to expenses#load_more' do
    expect(get: '/expenses/load_more').to route_to('expenses#load_more')
  end

  it 'routes GET /expenses/load_more with query params to expenses#load_more' do
    expect(get: '/expenses/load_more?mode=30_days&before=2026-11-16')
      .to route_to('expenses#load_more', mode: '30_days', before: '2026-11-16')
  end
end
