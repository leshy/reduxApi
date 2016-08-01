require! {
  bluebird: p
  leshdash: { push, pop, assign, pick, mapKeys, mapValues, assign, omit, map, curry, times, tail, reduce }
  util
}


CRUD = do
  findOne: true
  find: true
  create: true
  remove: true
  update: true

remoteResource = (CRUD, modelName) ->
  passThroughAction = (actionName) -> "#{actionName}": -> (if it? then { data: it } else {}) <<< type: "api_#{modelName}_#{actionName}"

  actions = {}
  
  assign actions, reduce do
    <[ loading empty update remove add error ]>
    (memo, name) -> assign memo, passThroughAction name
    {}


  crudAction = (actionName) ->
    "#{actionName}": ({id}: args)->
      dispatch actions.loading id
      crud[actionName] ...
    
    
  assign actions, reduce CRUD,
    (memo, f, name) ->
      assign memo,"#{name}": ( {id: id}: data ) ->
        dispatch actions.loading id
                
        CRUD[name] data
        .catch -> dispatch actions.error it
        .then -> switch name
          | "findOne" => dispatch actions.add it
          | "find" => each it, -> dispatch actions.add it
          | "update" => dispatch actions.update it
          | "create" => dispatch actions.add it
          | "remove" => dispatch actions.remove it

    
  assign actions, do
    get: (id) ->
      (dispatch, getState) ->
        dispatch actions.loading id
        
        CRUD.get name, id
        .then -> dispatch actions.data it
        .catch -> dispatch actions.error it

        
    need: (id) ->
      (dispatch, getState) ->
        state = getState!
        if not state.resources[name][id]? then dispatch actions.get id


  actions

# api_user_require 87sad98gsadg98dsa
# api_user_get 87sad98gsadg98dsa
# api_user_loading 87sad98gsadg98dsa


util.inspect remoteResource "bla"





