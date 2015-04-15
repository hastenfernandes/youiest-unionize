
smite eval(s) 
W.before.insert (userId, doc) ->
  #smite eval(s),  arguments, 'before insert arguments'
  doc.createdAt = Date.now()
  if !doc.journey
      doc.journey = []

    doc.journey.push
      'serverCreated': new Date().getTime()
    smite doc, 'inserting this in hook', eval s
  return

# write to a jobs collection, that embeds all earlier versions of the doc into the new one, so there's no dupes

W.after.insert (userId, doc) ->
  #smite eval(s),  arguments , 'arguments after insert'
  unless WIFound doc.to
    smite 'no target nemo found', eval s
    WI.insert
      _id: doc.to

  WI.update
    _id: doc.to
  ,
    '$push':
      inbox: 
        from: doc.from
        to: doc.to
  smite WI.findOne , 'found this one in WI'
  return
@Unionize.field = {}
# are we voting on a known type that requires special treatment? like a follow? add it here
@unionize.field.from = {}
@Unionize.field.from.User = (modifier, userId, doc, inserted) ->
    # create a follow by $push the inserted #
    # the target.from would be 
    insertedW =  W.findOne 
      _id: inserted
      
    WI.update
      _id: userId
    ,
      follows: 
        '$push': insertedW

# when wiber votes on nicolson
# from:wiber to:nicolson owner:wiber
# on _id:nicolson there is an attribute from:user because when nicolson was created he was a user
# nicolson is from:user
# the hook sees that here above
# the hook adds your W to  wiber.follows (because wiber follows nicolson)
# then add $push wiber to nicolson.follows
# when change is synced back to client I can see you in those I follow
# next time i open the client i get my whole WI object, and the previous state of W.nicolson is in follows 
# this incluses src of profile image, from:user, etc etc so app doesn't need to check right away
# enough info is there to see face etc
# WI has arrays of W, or ids in some future cases
  
@modModifier = {}
modModifier.outbox = (modifier, userId, doc) ->

  
  #smite 'hit outbox in', modifier, eval s
  old_key = 'outbox'
  new_key = 'sending'
  if old_key != new_key
    smite modifier, 'needs a new agenda', eval s
    smite eval Object.defineProperty modifier.$push, new_key, Object.getOwnPropertyDescriptor(modifier.$push, old_key)
    smite eval delete modifier.$push[old_key], 'deleted key', eval s
  # hand off the inserts to an async function, process to update db without waiting

  
  # always copy in outputs when tricky..
  #  {"$push":{"sending":{"from":"picture1","to":"wiber1"}}}
  smite 'did we insert into W?'
  , modifier
  , modifier.$push
  , from = modifier.$push.sending.from
  , to = modifier.$push.sending.to
  , eval s
  inserted = W.insert
    to: to #modifier.$push.sending.to
    from: from #modifier.$push.sending.from
  smite inserted, 'how long did the insert hook take? usually 30ms', eval s
  # did we just vote on a facebook user? they are from:Facebook
  # does target of this connection have from:facebook
  
  # so if we have a Unionize.field.from.Facebook and this outbox target is from outbox
  # we have voted on a Facebook user
  target = W.findOne _id: to
  # let's get where the target is from, with a query, 
  #which can be optimized later by gathering this info when connect is called on client
  targetFrom = target.from
  
  if _.has(Unionize.field.from, targetFrom ) 
    # do we have a function for this type of connection? 
    # it would be in Unionize.field.from.Facebook = Function() if we do
    # Hashrepublic would be the default case, where user was created by this app
    # A different function is run in each case because this _.has calls the function with same name as
    # target is from, and therefore what 'type' it is.
    
    smite from, doc, 'spinning Unionize.field.from', eval s
    # modify the modifier so the update is redirected before hitting db
    smite modifier = Unionize.field.from[targetFrom] modifier, doc, userId , inserted
  
  # "s" "fwDjXokYCLDkG2w9J" "did we insert into W?" 
  # {"$push":{"sending":{"from":"picture1","to":"wiber1"}}} 
  # null # this is the issue, wht is push undefined?
  # "wiber1" 
  # "server.coffee:39:48), <anonymous> 1422"
  return modifier

@generateRecommend = (i) ->
  to: user+i
  from: recFrom+i
  journey: [
    feed: new Date().getTime()
  ]



modModifier.feed = (modifier, doc, userId) ->
  smite doc, 'modModifier.feed doc', eval s
  unless doc.feed instanceof Array
    unless modifier.feed instanceof Array 
      smite modifier, doc, 'modifier, doc', eval s
      # "s" {"feed":"nothing"} {"_id":"wiber","sending":[{"from":"picture5","to":"wiber5"},{"from":"picture5","to":"wiber5"}]} "modifier, userId" "server.coffee:83:59)
      modifier.feed = []

afterModifier = {}
# feed balancing etc happens after the original update hits the db to let the db work
#TODO remove test feed function
@feedMe = (docId) ->
  fed = []
  for i in 'abcdefghiklmo'
    fed.push(generateRecommend i)
  one = WI.update
    _id: docId
  ,
    '$pushAll': 
      'feed': fed
  smite one, 'oneoneone done', eval s

afterModifier.feed = (modifier, doc, userId) ->
  docId = arguments[1]._id
  smite arguments, docId, doc.feed.length, 'doc afterModifier', eval s
  if !stackSize 
    stackSize = 5

  unless doc.feed.length >= stackSize
    ### WI.find({_id:'wiber'}).fetch()[0].feed # works
    unless afterModifier[docId] 
      afterModifier[docId] = _.throttle feedMe(docId), 250
      setTimeout (->
        delete afterModifier[docId]
      ), 300
    ###
    userObject = WI.findOne 
      _id: docId
    smite userObject,  userObject.feed.length, 'almost userObject', eval s
    unless userObject.feed.length >= stackSize
      smite feedMe(docId), 'feedMe(docId)', eval s

  # continue with the feed update call to db and go call the method async while waiting  
  #Meteor.call 'stackBalance', userId, doc, (res, err) ->
  # {"feed":"nothing"} null "modifier, userId" "server.coffee:68:52)

WI.before.update (userId, doc, fieldNames, modifier, options) ->

  for fieldName in fieldNames
    # do we have a function for this fieldname? 
    if _.has(modModifier, fieldName, doc) 
      smite fieldName, doc, 'spinning modModifier', eval s
      # modify the modifier so the update is redirected before hitting db
      smite modifier = modModifier[fieldName] modifier, doc, userId
  

#smite modifier, doc, fieldNames, Meteor.default_server.method_handlers,'fieldname calling method', eval s
#smite eval(s), doc, doc.outbox, modifier, 'got before updated WI! on server! is last arg correctly modifier?' 
 

WIAfterUpdate = WI.after.update (userId, doc, fieldNames, modifier, options) ->

  for fieldName in fieldNames
    # do we have a function for this fieldname? 

    if _.has(afterModifier, fieldName) 

      smite fieldName, 'spinning afterModifier', eval s
      # modify the modifier so the update is redirected before hitting db
      modifier = afterModifier[fieldName] modifier, doc, userId


  
  
  

Meteor.publish(null,()->
  return W.find({});
);

Meteor.publish(null,()->
  return WI.find({});
);
