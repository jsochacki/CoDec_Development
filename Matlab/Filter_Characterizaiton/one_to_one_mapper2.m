function [mapped_stream]=one_to_one_mapper2(unmapped_stream,mapping_from,mapping_to)

trn_UMS=0;
if size(unmapped_stream,1) < size(unmapped_stream,2), trn_UMS=1; unmapped_stream=unmapped_stream.';, end;
if size(mapping_from,2) < size(mapping_from,1), trn_MF=1; mapping_from=mapping_from.';, end;
if size(mapping_to,1) < size(mapping_to,2), trn_MT=1; mapping_to=mapping_to.';, end;

if sum(sum(mapping_from == 0,1),2)
    map_min = min(min(mapping_from));
	if abs(map_min)
        mapping_from = mapping_from + abs(map_min) + 1;
        unmapped_stream = unmapped_stream + abs(map_min) + 1;
    else
        mapping_from = mapping_from + 1;
        unmapped_stream = unmapped_stream + 1;
    end
end

% Precomputed for speed
mapping_from_conj = conj(mapping_from);
% Saves a very small amount of time
% Pre allocating makes it 4 x faster
mapped_stream = zeros(size(unmapped_stream, 1), size(mapping_to,2));
for nn=1:1:size(unmapped_stream,1)
    mapped_stream(nn,:) = ...
        ((unmapped_stream(nn,:) * mapping_from_conj) == (sum(mapping_from .* mapping_from_conj, 1))) * mapping_to;
end

if trn_UMS, mapped_stream=mapped_stream.';, end;

end