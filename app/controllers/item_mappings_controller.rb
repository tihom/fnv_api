class ItemMappingsController < ApplicationController
  before_action :set_item_mapping, only: [:show, :edit, :update,  :destroy]

  # GET /item_mappings
  # GET /item_mappings.json
  def index
    @item_mappings = ItemMapping.find_by_crawler_id(params[:crawler_id]).includes(:suppliers_item)
  end

  # def dropdown_options
  #   # using includes as all items do not have varieties
  #   @items =  Item.joins(:units).includes(:items_varieties).select("units.unit_id AS unit_id ,units.unit_name AS unit_name, items.item_id, items.item_name").
  #             group_by{|x| x.item_id}.
  #             sort_by{|k,v| v.first.item_name}
  #   @items = @items.map do |k,v|
  #     {
  #       id: k,
  #       name: v.first.item_name,
  #       units: v.uniq{|x| x.unit_id}.map{|x| {id: x.unit_id, name: x.unit_name}},
  #       varieties: v.first.items_varieties.map{|x| {id: x.item_variety_id, name: x.item_variety_name}}
  #     }
  #   end

  # end

  # GET /item_mappings/1
  # GET /item_mappings/1.json
  def show
    @item_mapping.update_price(true) if params[:update_price]
    respond_to do |format|
      if @item_mapping.errors.blank?
        format.html { redirect_to @item_mapping, notice: 'Item mapping was successfully updated.' }
        format.json { render action: 'show', status: :accepted, location: @item_mapping }
      else
        format.html { render action: 'edit' }
        format.json { render json: @item_mapping.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /item_mappings/new
  def new
    @item_mapping = ItemMapping.new
  end

  # GET /item_mappings/1/edit
  def edit
  end

  # POST /item_mappings
  # POST /item_mappings.json
  def create
    #puts item_mapping_params.to_yaml
    @item_mapping = ItemMapping.new(item_mapping_params)

    respond_to do |format|
      if @item_mapping.save
        format.html { redirect_to @item_mapping, notice: 'Item mapping was successfully created.' }
        format.json { render action: 'show', status: :created, location: @item_mapping }
      else
        format.html { render action: 'new' }
        format.json { render json: {error: @item_mapping.errors}, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /item_mappings/1
  # PATCH/PUT /item_mappings/1.json
  def update
    # puts item_mapping_params.to_yaml
    @item_mapping.update(item_mapping_params)
    #@item_mapping.update_price  if params[:update_price]
    respond_to do |format|
      if @item_mapping.errors.blank?
        format.html { redirect_to @item_mapping, notice: 'Item mapping was successfully updated.' }
        format.json { render action: 'show', status: :accepted, location: @item_mapping }
      else
        format.html { render action: 'edit' }
        format.json { render json: @item_mapping.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /item_mappings/1
  # DELETE /item_mappings/1.json
  def destroy
    @item_mapping.destroy
    respond_to do |format|
      format.html { redirect_to item_mappings_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item_mapping
      @item_mapping = ItemMapping.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_mapping_params
      params.require(:item_mapping).permit(:id, :remark,:item_id, :item_variety_id, :unit_id, :supplier_id, :identifier, :unit_conversion, :update_price)
    end
end
