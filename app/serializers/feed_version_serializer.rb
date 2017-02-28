# == Schema Information
#
# Table name: feed_versions
#
#  id                     :integer          not null, primary key
#  feed_id                :integer
#  feed_type              :string
#  file                   :string
#  earliest_calendar_date :date
#  latest_calendar_date   :date
#  sha1                   :string
#  md5                    :string
#  tags                   :hstore
#  fetched_at             :datetime
#  imported_at            :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  import_level           :integer          default(0)
#  url                    :string
#  file_raw               :string
#  sha1_raw               :string
#  md5_raw                :string
#  file_feedvalidator     :string
#
# Indexes
#
#  index_feed_versions_on_earliest_calendar_date  (earliest_calendar_date)
#  index_feed_versions_on_feed_type_and_feed_id   (feed_type,feed_id)
#  index_feed_versions_on_latest_calendar_date    (latest_calendar_date)
#

class FeedVersionSerializer < ApplicationSerializer
  attributes :sha1,
             :earliest_calendar_date,
             :latest_calendar_date,
             :md5,
             :tags,
             :fetched_at,
             :imported_at,
             :import_level,
             :created_at,
             :updated_at,
             :feed_version_imports,
             :feed_version_imports_url,
             :import_level,
             :is_active_feed_version,
             :changesets_imported_from_this_feed_version,
             :url,
             :download_url,
             :feedvalidator_url

  has_many :issues, if: :has_issues

  def feed_version_imports
    object.feed_version_imports.map(&:id)
  end

  def feed_version_imports_url
    api_v1_feed_version_imports_url({
      feed_onestop_id: object.feed.onestop_id,
      feed_version_sha1: object.sha1
    })
  end

  def is_active_feed_version
    object.is_active_feed_version
  end

  def changesets_imported_from_this_feed_version
    object.changesets_imported_from_this_feed_version.map(&:id)
  end

  def has_issues
    !!scope && !!scope[:embed_issues]
  end
end
