-module(carboy_lib).

-export([process_file/2]).

process_file(Fun, FileName) ->
	{ok, File} = file:open(FileName, [read, binary]),
	process_terms(Fun, File),
	file:close(File).

process_terms(Fun, File) ->
	{ok, Data} = file:read(File, 4096),
	process_terms(Fun, File, Data).

process_terms(_, _, <<"">>) -> ok;
process_terms(Fun, File, Data) ->
	NewData = try
		Term = binary_to_term(Data),
		Fun(Term),
		Size = size(term_to_binary(Term)),
		<<_:Size/binary, Tail/binary>> = Data,
		case Tail of
			<<"">> ->
				read_data(File, Tail);
			_ -> Tail
		end
	catch
		error:badarg ->
			case read_data(File, Data) of
				Data -> <<"">>;
				Else -> Else
			end
	end,
	process_terms(Fun, File, NewData).
	
read_data(File, <<"">>) ->
	read_chunk(File);
read_data(File, Data) ->
	Chunk = read_chunk(File),
	<<Data/binary, Chunk/binary>>.

read_chunk(File) ->
	case file:read(File, 4096) of
		eof -> <<"">>;
		{ok, Chunk} -> Chunk
	end.
