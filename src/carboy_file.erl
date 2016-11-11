-module(carboy_file).
-export([get_fun/1]).

get_fun(FileName) ->
	OutputName = filename:join("./", filename:basename(FileName) ++ ".carboy"),
	{ok, File} = file:open(OutputName, [write]),
	fun({Msg, Opts, Colors}) ->
		{Format, Args} = case Msg:message() of
			{_,_} = M -> M;
			M -> {M, []}
		end,
		Text   = lager:safe_format_chop(Format, Args, 4096),
		Msg2   = setelement(7, Msg, Text),
		Output = lager_default_formatter:format(Msg2, Opts, Colors),
		file:write(File, Output)
	end.