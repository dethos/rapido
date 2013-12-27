Accounts.config
    sendVerificationEmail: true,
    forbidClientAccountCreation: false

Meteor.publish "tasks", () ->
    return Tasks.find {}

Meteor.publish "lists", () ->
    return Lists.find {}
