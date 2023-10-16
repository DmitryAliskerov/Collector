alias Collector.Recordings

Recordings.clear_jobs()
Recordings.clear_users()
Recordings.clear_sources()
Recordings.clear_data()

Recordings.create_user(%{
  email: "dmitry.aliskerov@gmail-1.com",
  password: "qwe123qwe123"
})

Recordings.create_user(%{
  email: "dmitry.aliskerov@gmail-2.com",
  password: "qwe123qwe123"
})

#Recordings.create_source_n(%{
#  user_id: 1,
#  type: "URL",
#  value: "google.ru",
#  interval: "10"
#}, 100)
 
Recordings.create_source(%{
  user_id: 1,
  type: "URL",
  value: "google.ru",
  interval: "10"
})

Recordings.create_source(%{
  user_id: 1,
  type: "URL",
  value: "mail.ru",
  interval: "120"
})

Recordings.create_source(%{
  user_id: 1,
  type: "URL",
  value: "replit.ru",
  interval: "180"
})

Recordings.create_source(%{
  user_id: 2,
  type: "URL",
  value: "google.com",
  interval: "10"
})

Recordings.create_source(%{
  user_id: 2,
  type: "URL",
  value: "mail.com",
  interval: "120"
})

Recordings.create_source(%{
  user_id: 2,
  type: "URL",
  value: "replit.com",
  interval: "180"
})
