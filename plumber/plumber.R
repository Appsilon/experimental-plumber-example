loaded_mods <- loadNamespace("box")$loaded_mods
rm(list = ls(loaded_mods), envir = loaded_mods)

logger::log_threshold(config::get("log_level"))

plumber::pr_run(plumber::pr(file = "api/main.R"), port = 8087)
