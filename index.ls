require! {
  bluebird: p
  leshdash: { push, pop, assign, pick, mapKeys, mapValues, assign, omit, map, curry, times, tail, reduce }
  util
}


# loading empty data error
coreActions = (resourceName) ->
  # action without side effects, just a message for a state update
  passThroughAction = (actionName) -> "#{actionName}": -> (if it? then { data: it } else {}) <<< type: "resource_#{resourceName}_#{actionName}"
  
  actions = {}
  
  assign actions, reduce do
    <[ loading empty data error ]>
    (memo, name) -> assign memo, passThroughAction name
    {}
  
  actions



coreReducers = (resourceName) ->
  do
   "@@INIT": { state: 'init' }
   "resource_#{resourceName}_loading": { state: 'loading' }
   "resource_#{resourceName}_empty": { state: 'empty' }
   "resource_#{resourceName}_error": { state: 'error', error: action.error }
   "resource_#{resourceName}_data": { state: 'data', data: action.data }

RESTReducers = (resourceName) ->
  coreReducers(resourceName) <<< do
    "resource_#{resourceName}_add": assign {}, state, data: assign { "#{action.data.id}": action.data }, state.data
    "resource_#{resourceName}_remove": assign {}, state, data: [ action.data ...state.data ]
    "resource_#{resourceName}_update": assign {}, state, data: [ action.data ...state.data ]

RESTSyncReducers = (resourceName) ->
  remoteResourceReducers(resourceName) <<< do
    "resource_#{resourceName}_remoteAdd": assign {}, state, data: assign { "#{action.data.id}": action.data }, state.data
    "resource_#{resourceName}_remoteDelete": assign {}, state, data: [ action.data ...state.data ]
    "resource_#{resourceName}_remoteUpdate": assign {}, state, data: [ action.data ...state.data ]



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

REST = (io, resourceName) --> 
 remoteResource resourceName, do
    create: (data) -> io.socket.post "/api/rest/#{resourceName}", data
    update: (id, data) -> io.socket.post "/api/rest/#{resourceName}/#{id}", data
    remove: (id) -> io.socket.delete "/api/rest/#{resourceName}/#{id}"
    find: -> new p (resolve,reject) ~> resolve true
    findOne: -> new p (resolve,reject) ~> resolve true

RESTsync = (io, resourceName) -->
  actions = assign REST resourceName, do
    remoteUpdate: -> true
    remoteAdd: -> true
    remoteDelete: -> true
  
  io.socket.on resourceName, (event) ->
    switch event.verb
      | "updated" => store.dispatch actions.remoteUpdate event.id, event.data
      | "created" => store.dispatch actions.remoteCreate event.data
      | otherwise => console.warn "UNKNOWN CHANNEL EVENT #{resourceName}", event

  actions

#util.inspect remoteResource "bla", get: -> new p (resolve,reject) ~> resolve true
util.inspect REST "bla", get: -> new p (resolve,reject) ~> resolve true

# api_user_require 87sad98gsadg98dsa
# api_user_get 87sad98gsadg98dsa
# api_user_loading 87sad98gsadg98dsa
