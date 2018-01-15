This repository contains the infrastructure of the Aerolith project. In order to run Aerolith on your machine, you should clone this repo and follow the instructions.

#### Components

Aerolith requires a number of components to run on your development machine. 

- Webapp: `github.com/domino14/webolith`  (1)
    + This is the main Aerolith web app, written in Python + Django. It contains other apps within it besides Wordwalls: the old flashcards (Whitley Cards) and the new flashcards program (aerolith.org/cards)

- Macondo: `github.com/domino14/macondo`  (2)
    + This is a helper app that is used for blank bingo generation, build challenges, and finding word anagrams (in the flashcards app.) It is written in Go.

- Word DB maker: `github.com/domino14/word_db_maker`  (3)
    + Used to make the initial word databases / lexica from lexicon files. Whilst I cannot distribute the lexicon files myself due to copyright restrictions, these can be downloaded from several places, and `word_db_maker` can create the lexica.

- Postgres: The postgres database (plain docker package)
- Redis: Used for Django Channels (plain docker package)
- Crosswords:  `github.com/domino14/liwords`  (4)
    + This is an app to play Crossword Game, written in Elixir + Phoenix. I didn't choose those technologies to be a hipster, they were chosen after a lot of hard thought and experience with other techs for real-time games, such as Django Channels, Socket.io, Sock.js, and finding these to be lacking in several ways. Elixir is really quite a great language and ecosystem.
- Webpack servers: We use one for the Aerolith "Webapp" codebase and one for the Crosswords codebase. Maybe we can combine these. These are used to build the front-end JS for these apps.
- Proxy: Used in order to have the Crosswords app easily get a JWT from the webapp within the same domain. Also, these will be on the same domain on prod. No, JWTs aren't bad if you're using them properly. I'm not using a regular session cookie because then I have to make the Elixir app understand unpickling of Django sessions (because I want to use my Django users for this app too), or log everyone out and rewrite those in JSON, but then I have to make it talk to the Django DB anyway to extend the expiry time of the session, etc etc. JWTs are fine. Mine expire after a few hours, stop making such a big deal about JWTs sucking.


#### Instructions

- For now, you must clone the 4 repos above (labeled 1 - 4) to your computer. I may automate this later. Ideally put them within this folder, or you can also symlink them here. The paths must match what's in the docker compose file:
    + webolith
    + macondo
    + word_db_maker
    + liwords
- Download Docker for <Your operating system here>
- Add `vm.aerolith.org` to your `etc/hosts` file. The entry should look something like this, depending on your Docker settings.

```
127.0.0.1   localhost vm.aerolith.org
```

- Run `docker-compose up -d`.
- You can now access the web app on your web browser at `vm.aerolith.org`
