# # Place all the behaviors and hooks related to the matching controller here.
# # All this logic will automatically be available in application.js.
# # You can use CoffeeScript in this file: http://coffeescript.org/

# Backbone example http://blog.crowdint.com/2012/08/28/a-basic-rails-and-backbone-js-example.html
###########################
# MODELS
###########################
    class FnvApi.Models.Crawler extends Backbone.Model

    class FnvApi.Collections.Crawlers extends Backbone.Collection
      model: FnvApi.Models.Crawler
      url: '/crawlers'


    class FnvApi.Models.ItemMapping extends Backbone.Model
      paramRoot: 'item_mapping'
      item_name: ->
        #console.log parseInt(@get("item_id"))
        item =  FnvApi.items.get parseInt(@get("item_id"))
        return (if item then item.get("name") else null)
      item_variety_name: ->
        variety = FnvApi.item_varieties.get parseInt(@get("item_variety_id"))
        return (if variety then variety.get("name") else null)
      unit_name: ->
        unit = FnvApi.units.get parseInt(@get("unit_id"))
        return  (if unit then unit.get("name") else null)

      #  `serialize` is another common name for this
      for_template: ->
          j = @toJSON()
          j.item_name = @item_name()
          j.item_variety_name = @item_variety_name()
          j.unit_name = @unit_name()
          return j

    class FnvApi.Collections.ItemMappingsCollection extends Backbone.Collection
      model: FnvApi.Models.ItemMapping
      url: '/item_mappings'

    class FnvApi.Models.Option extends Backbone.Model

    class FnvApi.Collections.Options extends Backbone.Collection
      model: FnvApi.Models.Option
      url: '/item_mappings/dropdown_options'

    class FnvApi.Models.Item extends Backbone.Model

    class FnvApi.Collections.Items extends Backbone.Collection
      model: FnvApi.Models.Item
      url: '/items'

    class FnvApi.Models.ItemVariety extends Backbone.Model

    class FnvApi.Collections.ItemVarieties extends Backbone.Collection
      model: FnvApi.Models.ItemVariety
      url: '/item_varieties'

    class FnvApi.Models.Unit extends Backbone.Model

    class FnvApi.Collections.Units extends Backbone.Collection
      model: FnvApi.Models.Unit
      url: '/units'


    # class FnvApi.Models.NewItemName extends Backbone.Model

    # class FnvApi.Collections.NewItemNames extends Backbone.Collection
    #   model: FnvApi.Models.NewItemName
    #   update: ->
    #         @new_item_mappings = new  FnvApi.Collections.NewItemMappings
    #         @new_item_mappings.fetch
    #             success: ->
    #                 @reset(@collection.map (model) ->
    #                          model.get("name").toLowerCase()
    #                     )
    #             error: -> console.log "error in fetching new item mappings"

###########################
# ROUTERS
###########################

    class FnvApi.Routers.ItemMappingsRouter extends Backbone.Router
        routes:
            "index"       : "index"
            ":crawler_id/mappings"   : "getMappings"
            ".*"          : "index"

        index: ->
            #@view = new FnvApi.Views.ItemMappingsIndex
            return  
        getMappings: (crawler_id) ->
            console.log("in show action for: "+ crawler_id )

            console.log "initializing item mappings index view for  crawler:" + crawler_id
            @item_mappings = new FnvApi.Collections.ItemMappingsCollection
            #http://stackoverflow.com/questions/7567404/backbone-js-repopulate-or-recreate-the-view/7607853#7607853
            $("#posts").unbind()
            @view = new FnvApi.Views.ItemMappingsIndex(crawler_id: crawler_id, collection: @item_mappings)
            #FnvApi.AppView.closeView(@view)
            @item_mappings.fetch
                data: $.param({ crawler_id: crawler_id})
                reset: true
            return



###########################
# VIEWS
###########################
    # http://lostechies.com/derickbailey/2011/09/15/zombies-run-managing-page-transitions-in-backbone-apps/
    # class FnvApi.AppView
    #     @closeView: (view) ->
    #         if @currentView
    #             @currentView.remove() 
    #             @currentView.unbind() 
    #         @currentView = view
    #         return


    class FnvApi.Views.ItemMappingsIndex extends Backbone.View
        el: "#posts"

        template: JST["backbone/templates/item_mappings/index"]

        events:
            "click #add-new-items" :  "newMapping"

        initialize: ->
            @crawler = FnvApi.crawlers.get(this.options.crawler_id)
            $("#home-tabs").find("a").attr("class", "inactive")
            $("#home-tabs").find('a[data-id="' + @crawler.id + '"]').attr("class", "active")
            # http://stackoverflow.com/questions/6582059/need-explanation-of-the-bindall-function-from-underscore-js/6582122#6582122
            # see the comment for an explanation of bindall and this
            _.bindAll this, "render", "addAll", "addOne"
            @listenTo @collection, "reset", @render
            @listenTo @collection, "add", @addOne

        addAll: ->
            console.log "index add ALL in item mappings index"
            @collection.forEach(@addOne, @)
            return

        addOne: (model) ->
            console.log("index add one")
            @view = new FnvApi.Views.ItemMappingShow({model: model})
            @$el.find('tbody').append @view.render().el

        render: ->
            console.log "index render"
            #console.log FnvApi.crawlers.get(this.options.crawler_id).toJSON()
            @$el.html @template(@crawler.toJSON())
            @addAll()

        newMapping: ->
            console.log "new mapping"
            # initliazie the new item mapping view
            @view = new FnvApi.Views.ItemMappingNew
                collection: @collection
                crawler: @crawler 
            #  Add the new item mapping row to the end of table
            @$el.find('tbody').append @view.render().el
            return    


    # existing mapping row
    class FnvApi.Views.ItemMappingShow extends Backbone.View
        tagName: "tr"

        template: JST["backbone/templates/item_mappings/show"]

        initialize: ->
            @listenTo @model, "change", @render

        events:
            "click .destroy-item"   : "destroyItem"
            'click .edit-button'    : "editItem"
            "click .cancel-edit"    : "cancelEdit" 
            "click .save-item"      : "saveItem" 
            "click .update-price"   : "updatePrice"

        destroyItem: () ->
            if confirm('Are you sure you want to delete?')  
                @model.destroy()
                this.unbind()
                this.remove()
            return false

        editStatus: (status) ->
            if status == "active"
                console.log "edit status active"
                @editControls.show()
                @editButton.hide()
                @inputs.attr("disabled", false)
            else if status == "inactive"
                console.log "edit status inactive"
                @editControls.hide()
                @editButton.show()
                @inputs.attr("disabled", true)

        saveStatus: (status) ->
            if status == "waiting"
                console.log "saving model"
                @loader.show()
                @editControls.hide()
                @editButton.hide()
            else if status == "success"
                console.log "success in saving"
                @loader.hide()
                @editStatus("inactive")   
            else if status == "error"
                console.log "error in saving"
                @loader.hide()
                @editStatus("active")  

        priceUpdateStatus: (status) ->
            if status == "updating"       
                console.log "Updating price"        
                @priceUpdateButton.hide()
                @priceUpdateLoader.show()
            else if  status == "updated"
                console.log "Updated price" 
                @priceUpdateButton.show()
                @priceUpdateLoader.hide()

        editItem: ->
            @editStatus("active")   


        saveItem: ->  
            @saveStatus("waiting")  
            hsh = {
                identifier: @identifierInput.val()
                unit_conversion: @unitConvInput.val()
            }
            
            that = this
            @model.save hsh,
                wait: true

                success: (model, response) ->
                    that.saveStatus("success")
                    # that.render()

                error: (model, response) ->
                    #console.log JSON.stringify(response)
                    that.saveStatus("error")
                    that.errorMessage.html JSON.stringify(response.responseJSON || "OOPS! something went wrong")


        cancelEdit: ->
            @editStatus("inactive")  
            @render()
              
        updatePrice: ->
            @priceUpdateStatus("updating") 
            # @priceUpdateStatus("updated") 
            that = this
            @model.fetch

                data: {update_price: true}
            
                wait: true

                success: (model, response) ->
                    that.priceUpdateStatus("updated")
                    that.render()

                error: (model, response) ->
                    that.priceUpdateStatus("updated")
                    that.priceUpdateErrorMessage.html JSON.stringify(response.responseJSON || "OOPS! something went wrong")




        render: ->
            @$el.html @template(@model.for_template())     
            @$el.attr "data-id", @model.id  
            
            @editControls = @$el.find(".edit-controls")
            @editButton = @$el.find(".edit-button")
            @errorMessage = @$el.find(".error-message")
            @priceUpdateErrorMessage = @$el.find(".price-update-error-message")
            @loader = @$el.find(".local-loader")
            @priceUpdateButton = @$el.find(".update-price")
            @priceUpdateLoader = @$el.find(".updating-price")

            @inputs = @$el.find("input")
            @identifierInput = @$el.find(".item-identifier:first")
            @unitConvInput =  @$el.find(".item-unit-conversion:first")

            @editStatus("inactive")
            return this



    # new mapping row
    class FnvApi.Views.ItemMappingNew extends Backbone.View        
        tagName: "tr"

        template: JST["backbone/templates/item_mappings/new"] 


        events:
            "click .supplier-item-row-cancel" : "destroy"
            "click .supplier-item-row-save"   : "save"
            "change .new-item-name": "setOptions"

        setOptions: (e) ->
            id = parseInt $(e.currentTarget).val() # @itemNameView.$el.val()
            console.log "item id selected: " + id
            # update the optiones for units and varieties according to the item selected
            unit_options = FnvApi.units.filter (model) ->
                return _.include(model.get('item_ids'), id) 

            @unitView.collection.reset unit_options #FnvApi.units.where({item_id: id}) 
            @varietyView.collection.reset FnvApi.item_varieties.where({item_id: id}) 
            
            @identifierInput.attr "disabled", false
            @unitConvInput.attr "disabled", false      
            return 

        saveStatus: (status) ->
            if status == "active"
                console.log "save status active"
                @loader.show()
                @editControls.hide()
            else if status == "inactive"
                console.log "save status inactive"
                @loader.hide()
                @editControls.show()

        destroy: () ->
            this.unbind()
            this.remove()
            return false

        save: () ->
            console.log "Saving a new item mapping"
            console.log @loader
            @saveStatus("active")

            hsh = {
                item_id: @itemNameView.$el.val()
                unit_id: @unitView.$el.val()
                item_variety_id: @varietyView.$el.val()
                identifier: @identifierInput.val()
                unit_conversion: @unitConvInput.val()
                supplier_id: @options.crawler.get("supplier").supplier_id               
            }

            console.log "input values hsh: " + JSON.stringify(hsh)
            model = new FnvApi.Models.ItemMapping hsh 
            that = this
            @options.collection.create model, 
                wait: true

                success: (model,response) ->
                    that.saveStatus("inactive")
                    console.log " response: " + JSON.stringify(response)
                    console.log "new mapping created"
                    that.errorMessage.empty()
                    that.destroy()

                error: (model,response) ->
                    that.saveStatus("inactive")
                    console.log " response: " + JSON.stringify(response)
                    console.log "Error in item mapping"
                    that.errorMessage.html JSON.stringify(response.responseJSON || "OOPS! something went wrong")
                        

        render: ->
            @$el.html @template(@options.crawler.toJSON())
            
            @loader = @$el.find(".local-loader")
            @editControls = @$el.find(".edit-controls")
            @errorMessage = @$el.find(".error-message")
            
            @identifierInput = @$el.find(".new-item-identifier:first")
            @unitConvInput =  @$el.find(".new-item-unit-conversion:first")
            @itemNameView = new FnvApi.Views.Options
                 el: @$el.find(".new-item-name:first")
                 collection: new FnvApi.Collections.Items

            # populate the item names dropdown with options
            @itemNameView.collection.reset(FnvApi.items.models)

            @unitView = new FnvApi.Views.Options
                el: @$el.find(".new-item-unit:first")
                collection: new FnvApi.Collections.Units
            @varietyView = new FnvApi.Views.Options
                el: @$el.find(".new-item-variety:first")
                collection: new FnvApi.Collections.ItemVarieties

            return this  

    
    class FnvApi.Views.Option extends Backbone.View
        tagName: "option"

        initialize: ->
            _.bindAll this, "render"
            return

        render: ->
            $(@el).attr("value", @model.get("id")).html @model.get("name")
            this


    class FnvApi.Views.Options extends Backbone.View
        initialize: ->
            _.bindAll this, "addOne", "addAll", "render"
            @collection.bind "reset", @addAll
            return

        addOne: (model) ->
            optionView = new FnvApi.Views.Option(model: model)
            @optionViews.push(optionView)
            # console.log "in add One with model" + model.get("id") +  model.get("name")
            # console.log optionView.render().el
            $(@el).append optionView.render().el
            return

        addAll: ->
            console.log "in add ALl"
            _.each @optionViews, (optionView) ->
                optionView.remove()
                return
            @optionViews = [];
            @collection.each @addOne
            $(@el).attr "disabled", false
            return

    class FnvApi.Views.Error extends Backbone.View
        tagName: "td"
        className: "error"

        render: (opts)->
            msg = opts.msg || "Oops something went wrong"
            @$el.html msg  
            opts.parent.append @el
            return this  


    # class FnvApi.Views.UnitDropdown extends FnvApi.Views.Options
    #     el: "#new-item-unit"


    # class FnvApi.Views.VarietyDropdown extends FnvApi.Views.Options
    #     el: "#new-item-variety"



    
    # # View Id : supplier-items-view 
    # # Show the supplier's items

    # class FnvApi.Views.SupplierItemsView extends Backbone.View
    #     el: $("body")

    #     events: 
    #         'click .supplier-item-edit-button': 'editItem'   # Click event on "Edit Item" button
    #         # "click #add-friend": "editItem"

    #     editItem: (e) ->
    #         console.log("I am editing")
    #         # Enable the textboxes & show the control buttons of the row; Hide the edit button
    #         parent_row = $(e.currentTarget).closest('tr')
    #         parent_row.find("input[type='text']").removeAttr('disabled')
    #         parent_row.find(".supplier-item-edit-controls").show()
    #         $(e.currentTarget).hide()
    #         return

# Example from http://thomasdavis.github.io/2011/02/01/backbone-introduction.html
# (function ($) {
  
#   Friend = Backbone.Model.extend({
#     //Create a model to hold friend atribute
#     name: null
#   });
  
#   Friends = Backbone.Collection.extend({
#     //This is our Friends collection and holds our Friend models
#     initialize: function (models, options) {
#       this.bind("add", options.view.addFriendLi);
#       //Listen for new additions to the collection and call a view function if so
#     }
#   });
  
#   AppView = Backbone.View.extend({
#     el: $("body"),
#     initialize: function () {
#       this.friends = new Friends( null, { view: this });
#       //Create a friends collection when the view is initialized.
#       //Pass it a reference to this view to create a connection between the two
#     },
#     events: {
#       "click #add-friend": "showPrompt",
#     },
#     showPrompt: function () {
#       var friend_name = prompt("Who is your friend?");
#       var friend_model = new Friend({ name: friend_name });
#       //Add a new friend model to our friend collection
#       this.friends.add( friend_model );
#     },
#     addFriendLi: function (model) {
#       //The parameter passed is a reference to the model that was added
#       $("#friends-list").append("<li>" + model.get('name') + "</li>");
#       //Use .get to receive attributes of the model
#     }
#   });
  
#   var appview = new AppView;
# })(jQuery);
