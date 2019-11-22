desc "configure indices and upload data"
task "dmon:initialize" => :environment do
  Rake::Task["dmon:configure"].invoke
  Rake::Task["dmon:reindex"].invoke
end

desc "configure dmon index settings"
task "dmon:configure" => :environment do
  dmon_configure_users
  dmon_configure_posts
  dmon_configure_tags
  dmon_configure_map
end

desc "reindex everything to dmon"
task "dmon:reindex" => :environment do
  dmon_reindex_users
  dmon_reindex_posts
  dmon_reindex_tags
end

desc "reindex users in dmon"
task "dmon:reindex_users" => :environment do
  dmon_reindex_users
end

desc "reindex posts in dmon"
task "dmon:reindex_posts" => :environment do
  dmon_reindex_posts
end

desc "reindex tags in dmon"
task "dmon:reindex_tags" => :environment do
  dmon_reindex_tags
end

def dmon_configure_users
  puts "[Starting] Cleaning users index to Dmon"
  DiscourseDmon::DmonHelper.clean_indices(DiscourseDmon::DmonHelper::USERS_INDEX)
  puts "[Finished] Successfully configured users index in Dmon"
end

def dmon_configure_posts
  puts "[Starting] Cleaning posts index to Dmon"
  DiscourseDmon::DmonHelper.clean_indices(DiscourseDmon::DmonHelper::POSTS_INDEX)
  puts "[Finished] Successfully configured posts index in Dmon"
end

def dmon_configure_tags
  puts "[Starting] Cleaning tags index to Dmon"
  DiscourseDmon::DmonHelper.clean_indices(DiscourseDmon::DmonHelper::TAGS_INDEX)
  puts "[Finished] Successfully configured tags index in Dmon"
end

def dmon_configure_map
  puts "[Starting] Creating mapping to Dmon"
  DiscourseDmon::DmonHelper.create_mapping
end

def dmon_reindex_users

  puts "[Starting] Pushing users to Dmon"
  User.all.each do |user|
    #user_records << DiscourseDmon::DmonHelper.to_user_record(user)
    puts user.id
    user_record = DiscourseDmon::DmonHelper.index_user(user.id, '')
    puts user_record
  end
end

def dmon_reindex_posts
  puts "[Starting] Pushing posts to Dmon"
  post_records = []
  Post.all.includes(:user, :topic).each do |post|
    if DiscourseDmon::DmonHelper.should_index_post?(post)
      post_records << DiscourseDmon::DmonHelper.to_post_records(post)
    end
  end
  post_records.flatten!
  puts "[Progress] Gathered posts from Discourse"
  post_records.each_slice(100) do |slice|
    DiscourseDmon::DmonHelper.add_dmon_posts(
      DiscourseDmon::DmonHelper::POSTS_INDEX, slice.flatten)
    puts "[Progress] Pushed #{slice.length} post records to Dmon"
  end
  puts "[Finished] Successfully pushed #{post_records.length} posts to Dmon"
end


def dmon_reindex_tags
  puts "[Starting] Pushing tags to Dmon"
  tag_records = []
  Tag.all.each do |tag|
    if DiscourseDmon::DmonHelper.should_index_tag?(tag)
      tag_records << DiscourseDmon::DmonHelper.to_tag_record(tag)
    end
  end
  puts "[Progress] Gathered tags from Discourse"
  DiscourseDmon::DmonHelper.add_dmon_tags(
    DiscourseDmon::DmonHelper::TAGS_INDEX, tag_records)
  puts "[Finished] Successfully pushed #{tag_records.length} tags to Dmon"
end
