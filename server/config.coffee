fs = Npm.require 'fs'
path = Npm.require 'path'
__dirname = path.resolve '../../../../../'

Accounts.config
    sendVerificationEmail: true,
    forbidClientAccountCreation: false

Meteor.publish "tasks", () ->
    return Tasks.find {}

Meteor.publish "lists", () ->
    return Lists.find {}

Meteor.Router.add '/manifest.webapp', 'GET', () ->
  return [200,
    {
       'Content-type': 'application/x-web-app-manifest+json'
    }, fs.readFileSync( __dirname + '/manifest.webapp' )]
