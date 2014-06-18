A script that synchronizes jira issues to a trello board.

## Setting up

### jira

Setting up the jira access is requires that the `JIRA_USERNAME` and
`JIRA_PASSWORD` environment variables be setup.

### trello

Setting up the trello access is a little more involved.

1. **Get your API key.** Log in to trello and go to the following URL:
   [https://trello.com/1/appKey/generate](https://trello.com/1/appKey/generate)
   Set the value of the `TRELLO_API_KEY` environment variable with the value of
   the "Key" field found at the top of the page.
1. **Get your access token.** We need to generate an everlasting access token
   with write privileges. Insert your API key in the following link as well as
   your application name (any name will do). Set the value of the `TRELLO_WRITE_ACCESS_TOKEN` with the value found on the
   resulting page.
   
```
https://trello.com/1/authorize?key=YOUR_API_KEY&scope=read%2Cwrite&name=SOME_NAME&expiration=never&response_type=token
```

### Finding the board and list ids

Run the following command to print all your trello boards and lists with their
ids:

    $ coffee board_lists.coffee -u YOUR_TRELLO_USERNAME

Use the chosen board and list id when running the command.

## Importing closed and resolved issues

Because the project management workflow and the debugging workflow aren't the
same, closing or resolving an issue in jira will not automatically archive the
corresponding trello card. However, when importing an existing jira project for
the first time, archiving all closed issues is time consuming. A seperate script
can be used to import only 'closed' and 'resolved' issues in trello and archive
them immediately.

    $ coffee import_closed.coffee \
          -b CHOSEN_TRELLO_BOARD_ID \
          -l CHOSEN_TRELLO_LIST_ID \
          -h JIRA_HOST (e.g. mycompagny.atlassian.net) \
          -p JIRA_PROJECT_KEY (e.g. ABC)

## Running the command

    $ coffee index.coffee \
          -b CHOSEN_TRELLO_BOARD_ID \
          -l CHOSEN_TRELLO_LIST_ID \
          -h JIRA_HOST (e.g. mycompagny.atlassian.net) \
          -p JIRA_PROJECT_KEY (e.g. ABC)
