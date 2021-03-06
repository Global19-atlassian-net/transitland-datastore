namespace :db do
  namespace :recompute do
    desc 'Recompute operator geometries as convex hulls around stops ([0]: just create changeset, [1]: also apply changeset)'
    task :operator_geometries, [:mode] => [:environment] do |t, args|
      args.with_defaults(mode: 0)
      mode = args[:mode].to_i
      operators_with_updated_geometries = []
      puts "Recomputing operator geometries"
      progress_bar = ProgressBar.create(
        title: "Operators",
        total: Operator.count
      )
      log_messages = []
      Operator.find_each do |existing_operator|
        if existing_operator.stops.count > 0
          convex_hull = existing_operator.recompute_convex_hull_around_stops
        else
          log_messages << "#{existing_operator.name} has no stops -- skipped"
          progress_bar.increment
          next
        end
        if existing_operator.geometry == convex_hull
          log_messages << "#{existing_operator.name} does not need to be updated -- skipped"
        else
          updated_operator = Operator.new(
            onestop_id: existing_operator.onestop_id,
            geometry: convex_hull,
          )
          updated_operator.tags = nil # no need for a tags hash
          operators_with_updated_geometries << updated_operator
        end
        progress_bar.increment
      end
      puts log_messages.join("\n")
      if operators_with_updated_geometries.length == 0
        puts "No operators need to be updated."
      else
        changeset = Changeset.create(
          notes: 'Recomputing operator convex hulls using `db:recompute:operator_geometries` rake task'
        )
        puts "Created changeset ##{changeset.id}"
        changeset.create_change_payloads(operators_with_updated_geometries)
        puts "New geometries computed for #{operators_with_updated_geometries.count} operator(s)"
        if mode == 1
          puts "Applying changeset ##{changeset.id}"
          changeset.apply!
        else
          puts "New geometries are in changeset ##{changeset.id}, which you can now review and manually apply"
        end
      end
      puts "Done."
    end
  end
end
