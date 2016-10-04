# == Schema Information
#
# Table name: current_route_stop_patterns
#
#  id                                 :integer          not null, primary key
#  onestop_id                         :string
#  geometry                           :geography({:srid geometry, 4326
#  tags                               :hstore
#  stop_pattern                       :string           default([]), is an Array
#  version                            :integer
#  is_generated                       :boolean          default(FALSE)
#  is_modified                        :boolean          default(FALSE)
#  trips                              :string           default([]), is an Array
#  identifiers                        :string           default([]), is an Array
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  created_or_updated_in_changeset_id :integer
#  route_id                           :integer
#  stop_distances                     :float            default([]), is an Array
#  edited_attributes                  :string           default([]), is an Array
#
# Indexes
#
#  c_rsp_cu_in_changeset                              (created_or_updated_in_changeset_id)
#  index_current_route_stop_patterns_on_identifiers   (identifiers)
#  index_current_route_stop_patterns_on_onestop_id    (onestop_id) UNIQUE
#  index_current_route_stop_patterns_on_route_id      (route_id)
#  index_current_route_stop_patterns_on_stop_pattern  (stop_pattern)
#  index_current_route_stop_patterns_on_trips         (trips)
#

class RouteStopPatternSerializer < CurrentEntitySerializer
  attributes :onestop_id,
             :route_onestop_id,
             :stop_pattern,
             :stop_distances,
             :geometry,
             :color,
             :is_generated,
             :is_modified,
             :created_at,
             :updated_at,
             :trips,
             :tags
   def route_onestop_id
     object.route.onestop_id
   end

   def color
     object.route.color
   end
end
