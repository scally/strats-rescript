@module external express: 'a = "express"
@module external config: 'a = "./config.json"
@module external seedrandom: 'a = "seedrandom"
@module external getDayOfYear: Js.Date.t => int = "date-fns/getDayOfYear"

let app = express(.)

let get = (server, route, handler) => {
  server["get"](.route, (req, res) => {
    res["json"](. handler(req))
  })
}

// Monkey-patches JS's Math.random to enable seeding
seedrandom(. config["Seed"], {"global": true})

let all_candidates: array<string> = config["Candidates"]

let shuffle = l => l->Belt.List.sort((_, _) => Js.Math.random_int(-1, 2))

let build_year = candidates => {
  let year = ref(list{})
  while year.contents->List.length < 365 {
    year := Belt.List.concat(year.contents, candidates->shuffle)
  }
  year.contents
}

let all_schedules = {
  let s = Belt.HashMap.String.make(~hintSize=all_candidates->Array.length)
  let main: list<string> = all_candidates->Array.to_list->build_year
  Belt.HashMap.String.set(s, "main", main)

  Array.iter(c => {
    let without = all_candidates->Belt.Array.keep(x => c != x)
    Belt.HashMap.String.set(s, c, without->Array.to_list->build_year)
    ()
  }, all_candidates)

  s
}

let main_schedule = Belt.HashMap.String.get(all_schedules, "main")
let day = (schedule, index) => schedule->List.nth(index)
let dayWithAlternative = n => {
  let c = switch main_schedule {
  | Some(s) => day(s, n)
  | _ => "None"
  }
  let alt = switch Belt.HashMap.String.get(all_schedules, c) {
  | Some(s) => day(s, n)
  | _ => "None"
  }
  (c, alt)
}

app->get("/schedule", _ => {
  switch main_schedule {
  | Some(l) => l->Array.of_list
  | _ => []
  }
})
app->get("/day/:day", req => {
  let dayParam = req["params"]["day"]
  let (candidate, alternative) = dayWithAlternative(dayParam)
  {
    "Today": candidate,
    "Alternative": alternative,
  }
})
app->get("/today", _ => {
  let (candidate, alternative) = dayWithAlternative(getDayOfYear(Js.Date.make()))
  {
    "Today": candidate,
    "Alternative": alternative,
  }
})
app->get("/liveness", _ => {"Ok": "Ok"})
app->get("/config", _ => config)

app["listen"](. 8080)
