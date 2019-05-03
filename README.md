This repository contains the infrastructure of the Aerolith project. In order to run Aerolith on your machine, you should clone this repo and follow the instructions.

#### Components

Aerolith requires a number of components to run on your development machine.

- Webapp: `github.com/domino14/webolith`  (1)
    + This is the main Aerolith web app, written in Python + Django. It contains other apps within it besides Wordwalls: the old flashcards (Whitley Cards) and the new flashcards program (aerolith.org/cards)

- Macondo: `github.com/domino14/macondo`  (2)
    + This is a helper app that is used for blank bingo generation, build challenges, and finding word anagrams (in the flashcards app.) It is written in Go.

- Word DB server: `github.com/domino14/word_db_server`  (3)
    + Used to make the initial word databases / lexica from lexicon files. Whilst I cannot distribute the lexicon files myself due to copyright restrictions, these can be downloaded from several places, and `word_db_server` can create the lexica.

- Postgres: The postgres database (plain docker package)
- Redis: Used for Django Channels (plain docker package)
- Crosswords:  `github.com/domino14/liwords`  (4)
    + This is an app to play Crossword Game, written in Elixir + Phoenix. I didn't choose those technologies to be a hipster, they were chosen after a lot of hard thought and experience with other techs for real-time games, such as Django Channels, Socket.io, Sock.js, and finding these to be lacking in several ways. Elixir is really quite a great language and ecosystem.
- Webpack servers: We use one for the Aerolith "Webapp" codebase and one for the Crosswords codebase. Maybe we can combine these. These are used to build the front-end JS for these apps.
- Proxy: Used in order to have the Crosswords app easily get a JWT from the webapp within the same domain. Also, these will be on the same domain on prod. No, JWTs aren't bad if you're using them properly. I'm not using a regular session cookie because then I have to make the Elixir app understand unpickling of Django sessions (because I want to use my Django users for this app too), or log everyone out and rewrite those in JSON, but then I have to make it talk to the Django DB anyway to extend the expiry time of the session, etc etc. JWTs are fine. Mine expire after a few hours, stop making such a big deal about JWTs sucking.


#### Instructions

- Before running the `setup.sh` script, ensure you have the right lexicon files on your computer. I can't legally provide them, but there should be text files with the words and an optional definition:

```
AA some type of lava
AB an abdomen
AARDVARK a funny animal
```

Put these text files in the `lexica` directory. For now, they should be named `NWL18.txt`, `CSW15.txt`, `FISE2.txt`. You don't need all of them to have Aerolith run but it might be crippled if you try to select a lexicon you don't have.

- Download and install Docker for <Your operating system here>

- If you create a Docker Hub account, you must logout of it via the command line with `docker logout`. This is a bizarre issue with Docker: https://github.com/docker/hub-feedback/issues/1098
(You can't pull containers otherwise.)

- Run `setup.sh`. This will clone the 4 repos above, build your lexicon databases, install all required Javascript and initialize your postgres database, among other tasks.

- Add `vm.aerolith.org` to your `etc/hosts` file. The entry should look something like this, depending on your Docker settings.

```
127.0.0.1   localhost vm.aerolith.org
```

- Run `docker-compose up -d` in this directory
- You can now access the web app on your web browser at `vm.aerolith.org`

### Debugging

- Run `docker-compose logs -f app` to see the logs for app (the main webolith app). You can replace app with another component, like `crosswords`, `webpack_webolith`, etc.