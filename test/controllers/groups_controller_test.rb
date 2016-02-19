# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  test 'show breadcrumb path 1 if user is on index of groups' do
    login_as (:bob)
    team1 = teams(:team1)

    get :index, team_id: team1
    assert_select '.breadcrumb', text: 'Teamsteam1'
    assert_select '.breadcrumb a', count: 1
    assert_select '.breadcrumb a', text: 'Teams'
    assert_select '.breadcrumb a', text: 'team1', count: 0
  end

  test 'show breadcrump path 2 if user is on edit of groups' do
    login_as (:bob)

    team1 = teams(:team1)
    group1 = groups(:group1)

    get :edit, id: group1, team_id: team1
    assert_select '.breadcrumb', text: 'Teamsteam1group1'
    assert_select '.breadcrumb a', count: 2
    assert_select '.breadcrumb a', text: 'Teams'
    assert_select '.breadcrumb a', text: 'team1'
    assert_select '.breadcrumb a', text: 'group1', count: 0
  end

  test 'update group name and description' do
    login_as(:alice)
    group = groups(:group1)
    team = teams(:team1)

    update_params = { name: 'new_name', description: 'new_description' }
    put :update, team_id: team, id: group, group: update_params

    group.reload

    assert_equal 'new_name', group.name
    assert_equal 'new_description', group.description
  end
end
