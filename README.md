This repository contains the infrastructure of the Aerolith project. In order to run Aerolith on your machine, you should clone this repo and follow the instructions.

#### Components

Aerolith requires a number of components to run on your development machine.

- Webapp: `github.com/domino14/webolith` (1)

  - This is the main Aerolith web app, written in Python + Django. It contains other apps within it besides Wordwalls: the old flashcards (Whitley Cards) and the new flashcards program (aerolith.org/cards)

- Word DB server: `github.com/domino14/word_db_server` (2)

  - Used to make the initial word databases / lexica from lexicon files. Whilst I cannot distribute the lexicon files myself due to copyright restrictions, these can be downloaded from several places, and this can can create the lexica.
  - Used for any word-related server functionality. This will include any word searches, anything related to words basically.

- Postgres: The postgres database (plain docker package)

- Webpack server: We use one for the Aerolith "Webapp" codebase.

- Proxy: proxy server for local development.

#### Instructions

- Before running the `setup.sh` script, ensure you have the right lexicon files on your computer. I can't legally provide them, but there should be text files with the words and an optional definition:

```
AA some type of lava
AB an abdomen
AARDVARK a funny animal
```

Put these text files in the `lexica` directory. For now, they should be named `NWL20.txt`, `CSW21.txt`, etc. You don't need all of them to have Aerolith run but it might be crippled if you try to select a lexicon you don't have.

- Download and install Docker for <Your operating system here>

- If you create a Docker Hub account, you must logout of it via the command line with `docker logout`. This is a bizarre issue with Docker: https://github.com/docker/hub-feedback/issues/1098
  (You can't pull containers otherwise.)

- Run `setup.sh`. This will clone the 4 repos above, build your lexicon databases, install all required Javascript and initialize your postgres database, among other tasks.

- Add `aerolith.localhost` to your `etc/hosts` file. The entry should look something like this, depending on your Docker settings.

```
127.0.0.1   localhost aerolith.localhost
```

- Run `docker-compose up -d` in this directory
- You can now access the web app on your web browser at `aerolith.localhost`

### Debugging

- Run `docker-compose logs -f app` to see the logs for app (the main webolith app). You can replace app with another component, like `webpack_webolith`, etc.
