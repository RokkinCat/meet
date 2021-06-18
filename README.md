# Meet

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Roadmap

- [x] Move the scheduler live view to its own view
- [ ] More dynamic processing of recurring events
- [x] Add live view to collect info from the person requesting the meeting (Subject, agenda, email address, name)
- [x] Live fetch calendar
- [x] Add bamboo or swoosh with postmark to send ICS file
- [x] Support for multiple calendar URLs
- [ ] Better email body
- [ ] Deployment
- [ ] Graceful support for multi-day events
- [ ] Use PubSub to dynamically remove events that get scheduled
- [ ] Update the cache periodically instead of on fetch so it is ready when a user loads the page 
