#
# Accounts UI configuration  - Usersame + Email + Password
#
Accounts.ui.config
    passwordSignupFields: 'USERNAME_AND_EMAIL'

#
# Router - Handles changes in url
#
BackboneRouter = Backbone.Router.extend
    routes: {
        ":list_id": "main"
    },
    main: (list_id) ->
    ,
    setList: (list_id) ->
        this.navigate list_id, true

router = new BackboneRouter

#
# Data Binding to Template elements
#
Template.list_tasks.all = ->
    return Tasks.find { list_id: Session.get("list_id")}, {sort:{ status:-1, priority:-1 ,date:-1}}

Template.saved_lists.list = ->
    return if Meteor.user() then Lists.find {user_id: Meteor.user()._id} else []

Template.edit_list_name.current_name = ->
    list = Lists.findOne({ _id: Session.get("list_id")})
    return if list then list.name else "Loading..."

Template.task_info.selected = ->
    return if Session.equals("selected_task", this._id) then "ink-alert block info" else "ink-alert block"

Template.task_comments.all = ->
    if Session.get("selected_task") != null
        cursor = Tasks.findOne({_id: Session.get("selected_task")})
        if cursor
            comments = cursor.comments.sort (a, b) ->
                return b.date - a.date
        return comments

Template.share_modal.list_link = ->
    return window.location

Template.share_modal.list_id = ->
    return Session.get("list_id")

#
# AllUser intereaction events
#
Template.mobile_menu_button.events
    'click': ->
        if $('#topbar_menu').css('display') == 'block'
            $('#topbar_menu').css('display', 'none')
        else
            $('#topbar_menu').css('display', 'block')

Template.task_form.events
    'submit': (e, tmpl) ->
        e.preventDefault()
        user = Meteor.user()
        name = if user then user.username else "Anonymous"
        new_event = name + " created this tasks!"
        date = new Date()
        newTask =
            name: tmpl.find("#newtask").value,
            comments: [{name: "", content:new_event}],
            status: true,
            list_id: Session.get("list_id"),
            date: date.getTime(),
            priority: 0
        tmpl.find("#newtask").value = ""
        Meteor.call "addTask", newTask, (err, result) ->
            if err
                alert("Unable to save the task")

Template.comment_form.events
    'submit': (e, tmpl) ->
        e.preventDefault()
        task = Session.get("selected_task")
        if task
            user = Meteor.user()
            if user
                hash = md5 user.emails[0].address.trim().toLowerCase()
            else
                hash = ""

            newComment =
                content: tmpl.find("#newcomment").value,
                task: task,
                hash: hash

            tmpl.find("#newcomment").value = ""
            Meteor.call "addComment", newComment, (err, result) ->
                if err
                    alert "Unable to save the Comment"
        else
            alert "A task must be selected"

Template.task_info.events
    'click': ->
        Session.set "selected_task", this._id

Template.saved_lists.events
    'click': ->
        Session.set("list_id", this._id)
        router.setList this._id, true

Template.open.events
    'click': ->
        list_id = prompt "Insert the id of the desired list:"
        if list_id
            Meteor.call 'checkList', list_id, (err, result) ->
                if result
                    Session.set "list_id", result._id
                    router.setList result._id, true
                else
                    alert "A list with that id, does not exist."

Template.save.events
    'click': ->
        if Meteor.user()
            Meteor.call "saveList", Session.get("list_id"), (err, result) ->
                if not err
                    alert "List added to your items."
        else
            alert "You need to be logged in to save lists"

Template.new.events
    'click': ->
        Meteor.call "newList", "Set this ToDo List name.", (err, result) ->
            if err
                alert err
            Session.set "list_id", result
            router.setList result, true

Template.done.events
    'click': ->
        Meteor.call "markTask", this._id, false, (err, result) ->
        user = Meteor.user()
        name = if user then user.username else "Anonymous"
        new_event = name + " marked task as done!"
        Meteor.call "addEvent", this._id, new_event, (err, result) ->

Template.undo.events
    'click': ->
        Meteor.call "markTask", this._id, true, (err, result) ->
        user = Meteor.user()
        name = if user then user.username else "Anonymous"
        new_event = name + " unmarked task (its active again)!"
        Meteor.call "addEvent", this._id, new_event, (err, result) ->

Template.remove.events
    'click': ->
        Meteor.call "removeTask", this._id, (err, result) ->

Template.remove_list.events
    'click': ->
        Meteor.call "removeList", Session.get("list_id"), (err, result) ->
            if not err
                Meteor.call "newList", "Set this ToDo List name.", (err, result) ->
                    Session.set "list_id", result
                    router.setList result, true

Template.rename.events
    'click': ->
        new_name = prompt "New task description"
        if new_name
            Meteor.call "editTask", this._id, new_name, (err, result) ->
            user = Meteor.user()
            name = if user then user.username else "Anonymous"
            new_event = name + " edited task description!"
            Meteor.call "addEvent", this._id, new_event, (err, result) ->

Template.inc_priority.events
    'click': ->
        Meteor.call 'changePriority', this._id, 1, (err, result) ->

Template.dec_priority.events
    'click': ->
        Meteor.call 'changePriority', this._id, -1, (err, result) ->

Template.edit_list_name.events
    'click': ->
        new_name = prompt "Set a new name for this To Do List"
        if new_name
            Meteor.call "newListName", Session.get("list_id"), new_name, (err, result) ->

#
# At startup check url for list reference
#
Meteor.startup ->
  Backbone.history.start
    pushState: true
  Session.set "list_id", null
  if Backbone.history.fragment != ""
    Session.set "list_id", Backbone.history.fragment
  else
    Meteor.call "newList", "Set this ToDo List name.", (err, result) ->
      if err
        alert err
      Session.set "list_id", result
      router.setList result, true

  # Subscribed data from the server
  Meteor.subscribe "tasks"
  Meteor.subscribe "lists"
