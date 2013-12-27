Meteor.startup ->
    #604 800 000 - 7 days in miliseconds
    Meteor.setInterval ->
        now = new Date()
        limit = now.getTime() - 8035200000 # 3 months
        Tasks.remove({date:{$lt:limit}})
        Lists.remove({date:{$lt:limit}})
    , 604800000
