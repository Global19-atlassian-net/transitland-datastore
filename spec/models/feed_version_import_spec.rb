# == Schema Information
#
# Table name: feed_version_imports
#
#  id                :integer          not null, primary key
#  feed_version_id   :integer
#  created_at        :datetime
#  updated_at        :datetime
#  success           :boolean
#  import_log        :text
#  exception_log     :text
#  validation_report :text
#
# Indexes
#
#  index_feed_version_imports_on_feed_version_id  (feed_version_id)
#

describe FeedVersionImport do
  context 'succeed or fail' do
    it '#failed' do
      feed_version_import = create(:feed_version_import)
      feed_version_import.failed('error')
      expect(feed_version_import.success).to eq(false)
      expect(feed_version_import.exception_log).to eq('error')
    end

    it '#succeeded' do
      feed_version_import = create(:feed_version_import)
      feed_version_import.succeeded
      expect(feed_version_import.success).to eq(true)
    end

    it '#succeeded updates last_imported_at / last_fetched_at of parent feed' do
      feed_version_import = create(:feed_version_import)
      feed_version_import.succeeded
      expect(feed_version_import.feed.last_imported_at).to eq(feed_version_import.updated_at)
    end
  end
end
