require 'json'
module Jobs
  class UpdateDmonStats < Jobs::Scheduled
    every 60.seconds
    def execute(args)
      if SiteSetting.dmon_enabled?
        hjson = {}

        # Get admins
        res = DB.query('SELECT username FROM users WHERE admin = True;')
        liste = []
        res.each do |row|
          liste << "#{row.username}"
        end
        hjson["admin"] = liste

        # Get moderators
        res  = DB.query('SELECT username FROM users WHERE moderator = True;')
        liste = []
        res.each do |row|
          liste << "#{row.username}"
        end
        hjson["moderator"] = liste

        # Get top10 posts
        res  = DB.query('SELECT username, post_count FROM users, user_stats WHERE users.ID = user_stats.user_id ORDER BY post_count DESC LIMIT 10;')
        liste = []
        res.each do |row|
          liste << ["#{row.username}", "#{row.post_count}".to_i]
        end
        hjson["top10_posts"] = liste

        # Get top10 liked
        res  = DB.query('SELECT username, likes_received FROM users, user_stats WHERE users.ID = user_stats.user_id ORDER BY likes_received DESC LIMIT 10;')
        liste = []
        res.each do |row|
          liste << ["#{row.username}", "#{row.likes_received}".to_i]
        end
        hjson["top10_liked"] = liste

        # Popular topic
        res  = DB.query('SELECT title, like_count FROM topics ORDER BY like_count DESC LIMIT 10;')
        liste = []
        res.each do |row|
          liste << ["#{row.title}", "#{row.like_count}".to_i]
        end
        hjson["popular_topic"] = liste

        # Commented topic
        res  = DB.query('SELECT title, posts_count FROM topics ORDER BY posts_count DESC LIMIT 10;')
        liste = []
        res.each do |row|
          liste << ["#{row.title}", "#{row.posts_count}".to_i]
        end
        hjson["commented_topic"] = liste

        # Popular post
        res  = DB.query('SELECT p.post_number, p.topic_id, p.like_count, t.slug, t.id FROM posts p LEFT JOIN topics t ON t.id = p.topic_id ORDER BY p.like_count DESC LIMIT 10;')
        liste = []
        res.each do |row|
          str = ""
          liste << [str.concat("/t/", "#{row.slug}", "/", "#{row.topic_id}", "/", "#{row.post_number}"), "#{row.like_count}".to_i]
        end
        hjson["popular_post"] = liste

        # Forum stat
        res  = DB.query('SELECT COUNT(*) AS count_posts , ( SELECT COUNT(*) FROM users ) AS count_users  , ( SELECT COUNT(*) FROM topics ) AS count_topics  , ( SELECT COUNT(*) FROM categories ) AS count_categories  , ( SELECT COUNT(*) FROM groups ) AS count_groups  , ( SELECT COUNT(*) FROM tags ) AS count_tags   , ( SELECT COUNT(*) FROM anonymous_users ) AS count_anonymous_users FROM posts;')
        liste = []
        res.each do |row|
          liste << ['count_posts', "#{row.count_posts}".to_i]
          liste << ['count_users', "#{row.count_users}".to_i]
          liste << ['count_topics', "#{row.count_topics}".to_i]
          liste << ['count_categories', "#{row.count_categories}".to_i]
          liste << ['count_groups', "#{row.count_groups}".to_i]
          liste << ['count_tags', "#{row.count_tags}".to_i]
          liste << ['count_anonymous_users', "#{row.count_anonymous_users}".to_i]
        end
        hjson["forum_stats"] = liste

        # Total user uploads
        res  = DB.query('select count(*) from user_uploads;')
        liste = []
        res.each do |row|
          liste << ["#{row.count}"]
        end
        hjson["total_user_uploads"] = liste

        # top10 biggest uploaders
        res  = DB.query('SELECT users.username, count(user_uploads.id) FROM user_uploads, users WHERE user_uploads.user_id = users.id GROUP BY users.username ORDER BY count(user_uploads.id) DESC LIMIT 10;')
        liste = []
        res.each do |row|
          liste << ["#{row.username}", "#{row.count}".to_i]
        end
        hjson["top10_biggest_uploaders"] = liste

        # Total sent emails
        res  = DB.query('select count(*) from email_logs;')
        liste = []
        res.each do |row|
          liste << ["#{row.count}"]
        end
        hjson["total_sent_emails"] = liste

        # top10 user invites
        res  = DB.query('SELECT users.username, count(invites.invited_by_id) FROM invites, users WHERE invites.invited_by_id = users.id GROUP BY users.username ORDER BY count(invites.id) DESC LIMIT 10;')
        liste = []
        res.each do |row|
          liste << ["#{row.username}", "#{row.count}".to_i]
        end
        hjson["top10_user_invites"] = liste

        # top10 searchs
        res  = DB.query('SELECT distinct search_logs.term, count(search_logs.term) AS count_search FROM search_logs GROUP BY search_logs.term ORDER BY count_search DESC LIMIT 10;')
        liste = []
        res.each do |row|
          liste << ["#{row.term}", "#{row.count_search}".to_i]
        end
        hjson["top10_searchs"] = liste

        DiscourseDmon::DmonHelper.index_event_stats(hjson.to_json)
      end
    end
  end
end
