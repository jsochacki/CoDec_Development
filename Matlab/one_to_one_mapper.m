function [mapped_stream]=one_to_one_mapper(unmapped_stream,mapping_from,mapping_to)

trn_UMS=0;
if size(unmapped_stream,1) < size(unmapped_stream,2), trn_UMS=1; unmapped_stream=unmapped_stream.';, end;
if size(mapping_from,1) < size(mapping_from,2), trn_MF=1; mapping_from=mapping_from.';, end;
if size(mapping_to,1) < size(mapping_to,2), trn_MT=1; mapping_to=mapping_to.';, end;

mapped_stream=[];
% Precomputed for speed
size_mapping_from = size(mapping_from,1);
repeat_vector = ones(size_mapping_from,1);
size_unmapped_stream = size(unmapped_stream,2);
% Saves a very small amount of time
% Pre allocating makes it 4 x faster
mapped_stream = zeros(size(unmapped_stream, 1), size(mapping_to,2));
for nn=1:1:size(unmapped_stream,1)
    mapped_stream(nn,:) = ...
        sum((sum((repeat_vector * unmapped_stream(nn,:)) == mapping_from,2) == size_unmapped_stream).' * mapping_to,1);
end

if trn_UMS, mapped_stream=mapped_stream.';, end;

end