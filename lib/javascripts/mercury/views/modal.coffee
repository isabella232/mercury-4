#= require mercury/core/view
#= require mercury/views/modules/singleton
#= require mercury/views/modules/toolbar_focusable
#= require mercury/views/modules/scroll_propagation

class Mercury.Modal extends Mercury.View
  @include Mercury.View.Modules.Singleton
  @include Mercury.View.Modules.ToolbarFocusable
  @include Mercury.View.Modules.ScrollPropagation

  logPrefix: 'Mercury.Modal:'
  className: 'mercury-modal'
  template: 'modal'

  elements:
    overlay: '.mercury-modal-overlay'
    dialog: '.mercury-modal-dialog-positioner'
    content: '.mercury-modal-dialog-content'
    contentContainer: '.mercury-modal-dialog-content-container'
    titleContainer: '.mercury-modal-dialog-title'
    title: '.mercury-modal-dialog-title span'

  events:
    'click .mercury-modal-dialog-title em': 'release'
    'click .mercury-modal-overlay': 'release'
    'interface:hide': -> @hide(false)
    'interface:show': -> @show(false)

  constructor: (@options = {}) ->
    return instance if instance = @ensureSingleton(arguments...)
    super(options: @options)
    @show()


  build: ->
    @addClass('loading')
    @appendTo(Mercury.interface)
    $(window).on('resize', @resize)
    @preventScrollPropagation(@contentContainer)


  update: (options) ->
    return unless @visible
    @options = options if typeof(options) == 'object'
    @title.html(@options.title)
    @dialog.css(width: @options.width)
    content = @contentFromOptions()
    return if content == @lastContent
    @addClass('loading')
    @content.css(visibility: 'hidden', opacity: 0, width: @options.width).html(content)
    @lastContent = content
    @resize()


  resize: (noAnimation) =>
    clearTimeout(@showContentTimeout)
    @addClass('mercury-no-animation') if noAnimation
    @contentContainer.css(height: 'auto')
    titleHeight = @titleContainer.outerHeight()
    height = Math.min(@content.outerHeight() + titleHeight, $(window).height() - 10)
    @dialog.css(height: height)
    @contentContainer.css(height: height - titleHeight)
    if noAnimation
      @showContent(true)
    else
      @showContentTimeout = @delay(300, @showContent)
    @el.removeClass('mercury-no-animation')


  contentFromOptions: ->
    return @renderTemplate(@options.template) if @options.template
    return @options.content


  showContent: (noAnimation) ->
    clearTimeout(@contentOpacityTimeout)
    @el.removeClass('loading')
    @content.css(visibility: 'visible', width: 'auto')
    if noAnimation
      @content.css(opacity: 1)
    else
      @contentOpacityTimeout = @delay(50, -> @content.css(opacity: 1))


  show: (update = true) ->
    clearTimeout(@visibilityTimout)
    @visible = true
    @el.show()
    @visibilityTimout = @delay 50, ->
      @el.css(opacity: 1)
      @update() if update


  hide: (release = true) ->
    Mercury.trigger('focus')
    clearTimeout(@visibilityTimout)
    @visible = false
    @el.css(opacity: 0)
    @visibilityTimout = @delay 250, ->
      @el.hide()
      @release() if release


  release: ->
    return @hide(true) if @visible
    @constructor.instance = null
    $(window).off('resize', @resize)
    super