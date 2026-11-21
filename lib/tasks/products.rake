namespace :products do
  desc 'Load the temporary pharmacy sample catalog into an account: rake products:seed_sample[ACCOUNT_ID]'
  task :seed_sample, [:account_id] => :environment do |_task, args|
    account = args[:account_id] ? Account.find(args[:account_id]) : Account.first
    products = Products::SampleCatalog.seed!(account)
    puts "Loaded #{products.size} sample products into account #{account.id}"
  end
end
