#= require 'lib/angular'
#= require 'lib/angular-resource'

notes = angular.module('notes', ['ngResource'])

notes.config ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken

angular.module('notes').directive 'amulContenteditable', ->
  restrict: 'E'
  replace: true
  template: '<span contenteditable="true">{{model}}</span>'
  scope: {model: '=', onBlur: '&'}
  link: (scope, element, attrs) ->
    element.bind "blur", () ->
      scope.model = element.html()
      scope.$apply()
      scope.onBlur()

angular.module('notes').controller "NotesCtrl", ($scope, $resource) ->
  Note = $resource('/api/notes/:id', {id:'@id'}, {update: {method: 'PUT'}})

  $scope.notes = Note.query()

  $scope.addNote = ->
    note = {title: $scope.title, body: $scope.body}
    new Note(note: note).$save (noteFromServer) ->
      note.id = noteFromServer.id
    $scope.notes.push(note)
    $scope.title = ''
    $scope.body = ''

  $scope.updateNote = (note) ->
    new Note(note: note).$update(id: note.id)

  $scope.deleteNote = (note) ->
    new Note().$delete(id: note.id)
    $scope.notes.splice($scope.notes.indexOf(note), 1)
