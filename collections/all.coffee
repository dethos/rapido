#
# Collections ( Except users )
#
@Tasks = new Meteor.Collection("tasks")
@Lists = new Meteor.Collection("lists")


Meteor.methods
    addTask: (newTask) ->
        newTask.comments[0].date = new Date()
        return Tasks.insert(newTask)
    addComment: (comment) ->
        user = Meteor.user()
        if user
            new_com = {name:user.username, content:comment.content, pic_hash: comment.hash, date:new Date()}
        else
            new_com = {name:"Anonymous", content:comment.content, pic_hash: "", date:new Date()}
        return Tasks.update({_id:comment.task}, {$push:{comments:new_com}})
    newList: (list_name) ->
        return Lists.insert({name: list_name, user_id: [], date:new Date().getTime() })
    newListName: (list_id, list_name) ->
        return Lists.update({_id:list_id}, {$set:{name: list_name}})
    saveList: (list_id) ->
        return Lists.update({_id:list_id}, {$push:{user_id: Meteor.user()._id}})
    editTask: (task_id, new_content) ->
        return Tasks.update({_id:task_id}, {$set:{name: new_content}})
    removeTask: (task_id) ->
        return Tasks.remove({_id:task_id})
    markTask: (task_id, status) ->
        return Tasks.update({_id:task_id}, {$set:{status: status}})
    removeList: (list_id) ->
        Tasks.remove({list_id:list_id})
        return Lists.remove({_id:list_id})
    addEvent: (task_id, new_event) ->
        new_com = {name: "", content:new_event, date: new Date()}
        return Tasks.update({_id:task_id}, {$push:{comments: new_com}})
    changePriority: (task_id, inc) ->
        return Tasks.update({_id:task_id}, {$inc:{priority: inc}})
    checkList: (list_id) ->
        return Lists.findOne({_id:list_id})
