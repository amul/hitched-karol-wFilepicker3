#= require 'lib/angular'
#= require 'lib/angular-resource'

#angular config

posts = angular.module('posts', ['ngResource'])

posts.config ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken

angular.module('posts').directive 'amulContenteditable', ->
  restrict: 'E'
  replace: true
  template: '<span contenteditable="true">{{model}}</span>'
  scope: {model: '=', onBlur: '&'}
  link: (scope, element, attrs) ->
    element.bind "blur", () ->
      scope.model = element.html()
      scope.$apply()
      scope.onBlur()


angular.module('posts').controller "PostsCtrl", ($scope, $resource, $http) ->
  console.log("controller loaded!")
  Post = $resource('/api/posts/:id', {id:'@id'}, {update: {method: 'PUT'}})
  
  $scope.sortableOptions = disableSelection: false

  $scope.posts = Post.query()
  
  $scope.addPost = ->
    post = {title: $scope.title, body: $scope.body, filepicker_url: $scope.filepicker_url}
    post.filepicker_url = $(".fp-btn").val()
    new Post(post).$save()
    $scope.posts.push(post)
    $scope.title = ''
    $scope.body = ''
    $(".fp-btn").val("")
    $("#previmg").attr("src", "")
    
  $scope.deletePost = (post) ->
    new Post().$delete(id: post.id)
    $scope.posts.splice($scope.posts.indexOf(post), 1)
  
  $scope.updatePost = (post) ->
    new Post(post: post).$update(id: post.id)
    
  $scope.applySortable = () ->
    $("#sortable").sortable()
    
  $scope.destroySortable = () ->
    $("#sortable").sortable("destroy")    
  
  $scope.uploadWithFp = (obj, $event) ->
    #Get preview image.
    $img = $($event.target).closest(".changeFrame").find("img")
    filepicker.pick(
      mimetypes: ['image/*', 'text/plain']
      container: 'modal'
      (InkBlob) ->
        # To get DOM object, not jQuery object
        preview = $img[0]
        # Replace source.
        $img.attr("src", InkBlob.url)
        $("#filepicker_dialog_container").find("a").trigger('click')
    )
  
  $scope.editWithAviary = (obj, $event) ->
    #Get preview image.
    $img = $($event.target).closest(".changeFrame").find("img")
    #Aviary config for editing.
    imageEditor = new Aviary.Feather(
      apiKey: "7b5394cd74faf7b5"
      apiVersion: 3
      #Theme dark available too.
      theme: 'light'
      tools: 'all'
      appendTo: ''
      #onSave event
      onSave: (imageID, newURL) ->
        $img.attr("src", newURL)
        #close aviary.
        imageEditor.close()
        return false
      #Console log errors.  
      onError: (errorObj) ->
        console.log(errorObj.message)
    )
    #Launch Aviary
    imageEditor.launch(
      image: $img[0]
    )
  
  $scope.removeImage = (post, $event) ->
    #Remove src of preview img, so it can be undone with post.filepicker_url.
    $($event.target).closest(".changeFrame").find("img").attr("src", "")
    #Coffeescript returns last line by defaults
    #and Angular does not accept jquery object as return value.
    return true
  
  $scope.updatePostImg = (post, $event) ->
    #Get new image's url.
    post.filepicker_url = $($event.target).closest(".changeFrame").find("img").attr("src")
    #Update image.
    new Post(post: post).$update(id: post.id)
  
  $scope.restorePostImg = (post, $event) ->
    #Actual post image will come back without doing anything, since
    #post.filepicker_url was not changed by removeImage function.
    #We are getting back preview image.
    $($event.target).closest(".changeFrame").find("img").attr("src", post.filepicker_url)
    return true    
     
  
$(document).ready ->
  #Text field with filepicker URL
  filepicker_field = $(".fp-btn")
  #Filepicker URL
  img_url = filepicker_field.val()
  #If there is already an URL, f.e. edit or show
  if img_url
    #Append preview image before "update" or "back" button.
    img = "<img id='previmg' src="+img_url+"></img>"
    $(".actions").before(img)
  
  #Aviary config
  featherEditor = new Aviary.Feather(
    apiKey: "7b5394cd74faf7b5"
    apiVersion: 3
    #Theme dark available too.
    theme: 'light'
    tools: 'all'
    appendTo: ''
    #onSave event
    onSave: (imageID, newURL) ->
      #Put URL in the filepicker text field
      $(".fp-btn").val(newURL)
      #Check if there already is an img
      previmg = $(".ng-scope").find("#previmg")
      #If it is, replace it - for example edit action.
      if(previmg.length != 0)
        previmg.attr("src", newURL)
      else
        #If not, create it and append it.
        img = "<img id='previmg' src="+newURL+"></img>"
        $(".actions").before(img)
      #close aviary.
      featherEditor.close()
      return false
    #Console log errors.  
    onError: (errorObj) ->
      console.log(errorObj.message)
  )
  #From registrated account on www.filepicker.io
  filepicker.setKey "AKt94EVqRoMCzu38zZICQz"

  #On button click.
  $('body').delegate '.fp-btn', 'click', (e) ->
    #Safety first.
    e.preventDefault()
    #Filepicker config.
    filepicker.pick(
      #Any image type or plain text
      mimetypes: ['image/*', 'text/plain']
      #Pop modal for user.
      container: 'modal'
      (InkBlob) ->
        #If file was successfully uploaded get pre-prepared img.
        preview = document.getElementById("preview")
        #And replace it's source.
        preview.src = InkBlob.url
        #Close filepicker by clicking X (official method).
        $("#filepicker_dialog_container").find("a").trigger('click')
        #Launch Aviary with file generated by filepicker.
        featherEditor.launch(
          #img element prepared earlier.
          image: preview
          #url from filepicker.
          url: InkBlob.url
        )
      #Console log errors.  
      (FPError) -> 
        console.log(FPError.toString())
    )