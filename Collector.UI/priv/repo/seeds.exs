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

Recordings.create_source(%{
  user_id: 1,
  type: "URL",
  value: "google.ru",
  interval: "3600"
})

Recordings.create_source(%{
  user_id: 2,
  type: "URL",
  value: "google.com",
  interval: "3600"
})