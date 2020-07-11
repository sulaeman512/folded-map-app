# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


BlockPair.create!([
  {name: "w_9_7" ,ew_max: 3600, ns_max: 2800},
])

Block.create!([
  {name: "nw_9_7", block_pair_id: 1},
  {name: "sw_9_7", block_pair_id: 1}
])

User.create!([
  {email: "carlh@gmail.com", password_digest: "$2lknewtkjbers.kjn", first_name: "Carl", last_name: "Hauck", birthday: DateTime.new(1987,8,12), street_num: 2737, street_direction: "N", street: "Central Park Ave", zip_code: "60647", block_id: 1, image_url: "carlpic.jpg", how_i_got_here: "How did I come to live here? Let me tell you.", what_i_like: "Here's what I like about where I live.", what_i_would_change: "Here's what I'd change about where I live."},
  {email: "hughj@gmail.com", password_digest: "ajghaghge;invavh;", first_name: "Hugh", last_name: "Jelefant", birthday: DateTime.new(1982,6,5), street_num: 2737, street_direction: "S", street: "Central Park Ave", zip_code: "60623", block_id: 2, image_url: "hughpic.jpg", how_i_got_here: "Blah blah blah.", what_i_like: "Bleh bleh bleh.", what_i_would_change: "Bluh bluh bluh."},
  {email: "pattym@gmail.com", password_digest: "$%aj;ahg*", first_name: "Patty", last_name: "Mayonnaise", birthday: DateTime.new(1990,4,23), street_num: 2749, street_direction: "N", street: "Central Park Ave", zip_code: "60647", block_id: 1, image_url: "pattypic.jpg", how_i_got_here: "Hum hum hum.", what_i_like: "Heh heh heh.", what_i_would_change: "Huh huh huh."},
])

Conversation.create!([
  {sender_id: 3, recipient_id: 1, map_twin: true},
  {sender_id: 2, recipient_id: 1, map_twin: false},
  {sender_id: 3, recipient_id: 2, map_twin: false}
])

Message.create!([
  {conversation_id: 1, text: "Hey", user_id: 1},
  {conversation_id: 1, text: "Hi, nice to meet you!", user_id: 3},
  {conversation_id: 1, text: "Blah.", user_id: 1},
  {conversation_id: 2, text: "Hello there.", user_id: 1},
  {conversation_id: 1, text: "Blah?", user_id: 3},
  {conversation_id: 2, text: "Hello there yourself.", user_id: 2},
  {conversation_id: 3, text: "Hi", user_id: 2}
])

Post.create!([
  {block_pair_id: 1, user_id: 2, text: "Anyone interested in a cookout next Sat?"},
  {block_pair_id: 1, user_id: 3, text: "Just read Natalie Moore's book. So good. Has anyone else read it?", image_url: "https://media1.fdncms.com/chicago/imager/u/original/21538258/anc_lit-thesouthside-nataliemoore-magnum.jpg"}
])

Comment.create!([
  {post_id: 1, user_id: 1, text: "Yup, I'll bring the BBQ sauce."},
  {post_id: 1, user_id: 3, text: "I'll bring a salad."},
  {post_id: 2, user_id: 2, text: "Agreed! Have you read The Color of Law?"},
  {post_id: 1, user_id: 2, text: "Why not put BBQ sauce on the salad?"}
])