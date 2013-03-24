#= require mercury/core/view
#= require mercury/templates/statusbar

class Mercury.Statusbar extends Mercury.View

  logPrefix: 'Mercury.Statusbar:'
  className: 'mercury-statusbar'
  template: 'statusbar'

  events:
    'region:update': 'onRegionUpdate'
    'interface:hide': 'hide'
    'interface:show': 'show'

  elements:
    path: '.mercury-statusbar-path'


  build: ->
    @setPath()


  setPath: (path = []) ->
    @path.html("<b>#{@t('Path:')} </b>")
    for el in path
      @path.append(el)
      @path.append(' &raquo; ') unless el == path[path.length - 1]


  onRegionUpdate: (region) ->
    @setPath(path) if path = region.path?()


  hide: ->
    @el.css(bottom: -@el.height())


  show: ->
    @el.css(bottom: 0)