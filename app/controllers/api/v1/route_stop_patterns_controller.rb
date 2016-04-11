class Api::V1::RouteStopPatternsController < Api::V1::BaseApiController
  include JsonCollectionPagination
  include DownloadableCsv
  include AllowFiltering
  include Geojson
  GEOJSON_ENTITY_PROPERTIES = Proc.new { |properties, entity|
    # properties for GeoJSON simple style spec
    properties[:title] = "Route stop pattern #{entity.onestop_id}"
    properties[:stroke] = "##{entity.route.color}" if entity.route.color.present?

    properties[:route_onestop_id] = entity.route.onestop_id
    properties[:stop_pattern] = entity.stop_pattern
    properties[:stop_distances] = entity.stop_distances
    properties[:is_generated] = entity.is_generated
    properties[:is_modified] = entity.is_modified
    properties[:color] = entity.route.color
  }

  before_action :set_route_stop_pattern, only: [:show]

  # GET /route_stop_patterns
  include Swagger::Blocks
  swagger_path '/route_stop_patterns' do
    operation :get do
      key :tags, ['route']
      key :name, :tags
      key :summary, 'Returns all route stop patterns with filtering and sorting'
      key :produces, ['application/json']
      # parameter do
      #   key :name, :servedBy
      #   key :in, :query
      #   key :description, 'operator Onestop ID(s) to filter by'
      #   key :required, false
      #   key :type, :string
      # end
      response 200 do
        # key :description, 'stop response'
        schema do
          key :type, :array
          items do
            key :'$ref', :ScheduleStopPair
          end
        end
      end
    end
  end
  def index
    @rsps = RouteStopPattern.where('')

    @rsps = AllowFiltering.by_onestop_id(@rsps, params)
    @rsps = AllowFiltering.by_tag_keys_and_values(@rsps, params)
    @rsps = AllowFiltering.by_identifer_and_identifier_starts_with(@rsps, params)
    @rsps = AllowFiltering.by_updated_since(@rsps, params)

    if params[:bbox].present?
      @rsps = @rsps.geometry_within_bbox(params[:bbox])
    end

    if params[:traversed_by].present?
      @rsps = @rsps.where(route: Route.find_by_onestop_id!(params[:traversed_by]))
    end

    if params[:trips].present?
      @rsps = @rsps.with_trips(params[:trips])
    end

    if params[:stops_visited].present?
      @rsps = @rsps.with_stops(params[:stops_visited])
    end

    if params[:import_level].present?
      @rsps = @rsps.where_import_level(AllowFiltering.param_as_array(params, :import_level))
    end

    @rsps = @rsps.includes{[
      route,
      imported_from_feeds,
      imported_from_feed_versions
    ]}

    respond_to do |format|
      format.json do
        render paginated_json_collection(
          @rsps,
          Proc.new { |params| api_v1_route_stop_patterns_url(params) },
          params[:sort_key],
          params[:sort_order],
          params[:offset],
          params[:per_page],
          params[:total],
          params.slice(
            :onestop_id,
            :traversed_by,
            :trip,
            :bbox,
            :stop_visited
          )
        )
      end
      format.geojson do
        render json: Geojson.from_entity_collection(@rsps, &GEOJSON_ENTITY_PROPERTIES)
      end
    end
  end

  # GET /route_stop_patterns/{onestop_id}
  include Swagger::Blocks
  swagger_path '/route_stop_patterns/{onestop_id}' do
    operation :get do
      key :tags, ['route']
      key :name, :tags
      key :summary, 'Returns one route stop pattern by its Onestop ID'
      key :produces, ['application/json']
      parameter do
        key :name, :onestop_id
        key :in, :path
        key :description, 'Onestop ID of the route stop pattern'
        key :required, true
        key :type, :string
      end
      response 200 do
        # key :description, 'stop response'
        schema do
          key :'$ref', :RouteStopPattern
        end
      end
    end
  end
  def show
    respond_to do |format|
      format.json do
        render json: @route_stop_pattern
      end
      format.geojson do
        render json: Geojson.from_entity(@route_stop_pattern, &GEOJSON_ENTITY_PROPERTIES)
      end
    end
  end

  private

  def set_route_stop_pattern
    @route_stop_pattern = RouteStopPattern.find_by_onestop_id!(params[:id])
  end
end
