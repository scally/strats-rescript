# strats-rescript
Lightweight standup calendar

This is an experiment building the same micro-app in multiple languages for a bake-off.

This app is the rescript version. There will also be one each for [F#](https://github.com/scally/strats-fsharp)/[Ocaml](https://github.com/scally/strats-ocaml), which are other ML descendants.

## build

First, install node. Then, 

```sh
npm install
```

Finally, `npm run build`

## run

```sh
node src/Demo.bs.js
```

## api

The API is located at http://localhost:3000 by default, and offers these endpoints:

`/today` view today's schedule

`/day/:day` view schedule for day N

`/schedule` view yearly schedule

`/liveness` health check

`/config` view configuration
