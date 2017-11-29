task :tile_export, [:tilepath, :thread_count, :feed_onestop_id] => [:environment] do |t, args|
  args.with_default(thread_count: 1, feed_onestop_id: nil)
  fail Exception.new('tilepath required') unless args[:tilepath].presence
  feeds = nil
  if args[:feed_onestop_id]
    feeds = [Feed.find_by_onestop_id!(args[:feed_onestop_id])]
  end
  TileExportService.export_tiles(args[:tilepath], thread_count: args[:thread_count].to_i, feeds: feeds)
end
