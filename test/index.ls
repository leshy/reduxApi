require! {
  assert
  chai: { expect }
  leshdash: { head, rpad, lazy, union, assign, omit, map, curry, times, keys, first, wait, head }
  bluebird: p
  util
}

describe 'reduxApi', ->
  before -> new p (resolve,reject) ~> resolve!

                  
