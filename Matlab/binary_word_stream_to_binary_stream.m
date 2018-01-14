function [binary_stream]=binary_word_stream_to_binary_stream(word_stream,BITS_PER_WORD)
% TAKES A SINGLE ROW OF ANY TYPE OF DATA STREAM AND MAKES IT A COLUMN VECTOR
% WHERE EACH ROW IS A WORD MADE OF 'BITS_PER_WORD' BITS SUCH THAT
% IF 'BITS_PER_WORD'=LENGTH(data_stream) THEN WORD_STREAM IS EQUAL
% TO DATA_STREAM.  IF DATA_STREAM IS BINARY DATA THEN THIS WILL
% PROCESS BINARY DATA BUT IF DATA_STREAM IS DECIMAL SIMPLY MAKE
% BITS_PER_WORD=1 AND THIS WILL COLLUMIZE THE DECIMAL DATA FOR
% PROPER PROCESSING IN OTHER FUNCTION
trn=0;
binary_stream=[];
if size(word_stream,2) > BITS_PER_WORD, trn=1; word_stream=word_stream.';, end;
for nn=1:1:length(word_stream)
    binary_stream=[binary_stream word_stream(nn, :)];
end
if ~trn, binary_stream=binary_stream.';, end;
end