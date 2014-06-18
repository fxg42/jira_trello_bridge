# Copyright (C) 2014  CODE3 Coopérative de solidarité
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

_ = require 'underscore'
async  = require 'async'
program = require 'commander'
Trello = require 'node-trello'
{JiraApi} = require 'jira'

JIRA_USERNAME = process.env.JIRA_USERNAME
JIRA_PASSWORD = process.env.JIRA_PASSWORD
TRELLO_API_KEY = process.env.TRELLO_API_KEY
TRELLO_WRITE_ACCESS_TOKEN = process.env.TRELLO_WRITE_ACCESS_TOKEN

program
  .version '0.0.1'
  .option '-b, --trello_board <value>', 'Trello board id or short id'
  .option '-l, --trello_issue_list <value>', 'Trello list id to create new cards in'
  .option '-h, --jira_host <value>', 'JIRA host'
  .option '-p, --jira_project <value>', 'JIRA projet id'
  .parse process.argv

TRELLO_BOARD_ID = program.trello_board
TRELLO_NEW_ISSUES_LIST_ID = program.trello_issue_list
JIRA_HOST = program.jira_host
JIRA_PROJECT = program.jira_project

trello = new Trello(TRELLO_API_KEY, TRELLO_WRITE_ACCESS_TOKEN)
jira = new JiraApi('https', JIRA_HOST, 443, JIRA_USERNAME, JIRA_PASSWORD, '2')

findIssuePage = (startAt, maxResults, acc, callback) ->
  jira.searchJira "project=#{JIRA_PROJECT} and status in ('Closed', 'Resolved')", {startAt, maxResults}, (err, results) ->
    if err
      callback(err)
    else
      issues = acc.concat(results.issues)
      if issues.length < results.total
        findIssuePage(results.startAt + results.maxResults, maxResults, issues, callback)
      else
        callback(null, issues)

findAllIssues = (callback) ->
  findIssuePage(0, 1000, [], callback)

cardName = (issue) ->
  "[#{issue.key}] (#{issue.fields.status.name}) #{issue.fields.summary}"

cardDesc = (issue) ->
  "https://#{JIRA_HOST}/browse/#{issue.key}\n\n#{issue.fields.description}"

createCard = (issue, callback) ->
  payload =
    name: cardName(issue)
    desc: cardDesc(issue)
    labels: 'yellow'
    idList: TRELLO_NEW_ISSUES_LIST_ID
    due: null
    urlSource: null
  trello.post '/1/cards', payload, callback

archiveCard = (card, callback) ->
  trello.put "/1/cards/#{card.id}/closed", {value:true}, callback

createThenArchive = async.compose(archiveCard, createCard)

findAllIssues (err, issues) ->
  throw err if err
  for issue in issues
    createThenArchive(issue, ->)
