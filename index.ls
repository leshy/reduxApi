require! {
  bluebird: p
  leshdash: { push, pop, assign, pick, mapKeys, mapValues, assign, omit, map, curry, times, tail, reduce }
  util
}


# loading empty data error
coreActions = (resourceName) ->
  # action without sideeffects, just a message for a state update
  passThroughAction = (actionName) -> "#{actionName}": -> (if it? then { data: it } else {}) <<< type: "resource_#{resourceName}_#{actionName}"

  actions = {}
  
  assign actions, reduce do
    <[ loading empty data error ]>
    (memo, name) -> assign memo, passThroughAction name
    {}

  actions


# wraps different async fetchers so they trigger loading and data or error actions
remoteResource = (resourceName, fetchers) -> 
  actions = coreActions resourceName
  
  assign actions, reduce do
    fetchers
    (memo, fetcher, name) -> 
      memo <<< "#{name}": (...args) ->
          dispatch actions.loading
          fetcher.apply @, args
            .then -> actions.data it
            .error -> actions.error it
    {}

REST = (resourceName) ->
  remoteResource resourceName, do
    create: -> new p (resolve,reject) ~> resolve true
    update: -> new p (resolve,reject) ~> resolve true
    find: -> new p (resolve,reject) ~> resolve true
    findOne: -> new p (resolve,reject) ~> resolve true
    remove: -> new p (resolve,reject) ~> resolve true


RESTsync = (io, resourceName) ->
  actions = assign REST resourceName, do
    remoteUpdate: -> true
  
  io.socket.on resourceName, (event) ->
    switch event.verb
      | "updated" => store.dispatch actions.update event.id, event.data
      | "created" => store.dispatch actions.add event.data
      | otherwise => console.warn "UNKNOWN CHANNEL EVENT #{resourceName}", event

  actions

#util.inspect remoteResource "bla", get: -> new p (resolve,reject) ~> resolve true
util.inspect REST "bla", get: -> new p (resolve,reject) ~> resolve true

# api_user_require 87sad98gsadg98dsa
# api_user_get 87sad98gsadg98dsa
# api_user_loading 87sad98gsadg98dsa
