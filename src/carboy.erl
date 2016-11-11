-module(carboy).

-export([main/1]).

process_file(Mode, true, _, Directory) ->
	{ok, Files0} = file:list_dir(Directory),
	Files1 = [filename:absname(F, Directory) || F <- Files0],
	Files2 = [F || F <- Files1, not filelib:is_dir(F)],
	process_files(Mode, Files2);
process_file(Action, _, true, FileName) ->
	Fun = Action:get_fun(FileName),
	carboy_lib:process_file(Fun, FileName);

process_file(_, _, _, FileName) ->
	io:format("Unable to process ~s, skipping.\n", [FileName]).

process_files(Mode, Files) ->
	lists:foreach(
		fun(File) ->
			FileName = filename:absname(File),
			process_file(Mode, filelib:is_dir(FileName), filelib:is_file(FileName), FileName)
		end,
		Files
	).

main([Mode | Files]) ->
	Action = case Mode of
		"cli" -> carboy_cli;
		"file" -> carboy_file
	end,
	process_files(Action, Files),
	ok.