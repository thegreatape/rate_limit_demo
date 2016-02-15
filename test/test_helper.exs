ExUnit.start

Mix.Task.run "ecto.create", ~w(-r RateLimitDemo.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r RateLimitDemo.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(RateLimitDemo.Repo)

