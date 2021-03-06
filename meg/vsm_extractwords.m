function [tlck, stimdata] = vsm_extractwords(subject)

d           = vsm_dir();
savedir     = d.trf;
stimdata    = vsm_stimdata(subject);

ft_hastoolbox('cellfunction', 1);

if ischar(subject)
  meg         = fullfile(d.preproc, [subject '_lcmv-data.mat']);
  load(meg)
else
  data = subject;
end

% verify the number of trials
if ~(numel(data.trial)==numel(stimdata))
  error('the number of stories does not match');
end

for k = 1:numel(stimdata)
  
  tmp     = keepfields(data, {'label' 'grad' 'fsample'});
  tmp.time = (-14:75)./tmp.fsample;
  tmpstim = stimdata{k};
  
  % constrain the words to the ones that fit within the trial's time axis
  sel = [tmpstim.start_time]>data.time{k}(1) & [tmpstim.start_time]<data.time{k}(end);
  tmpstim = tmpstim(sel);
  
  start = [tmpstim.start_time];
  sel   = isfinite(start);
  start = start(sel);
  tmpstim = tmpstim(sel);
  nword = numel(tmpstim);
  trial = nan(nword,numel(tmp.label), 90);
  for m = 1:nword
    ix = nearest(data.time{k}, start(m));
    ix1 = max(1,ix-14);
    ix2 = min(numel(data.time{k}), ix+75);
    
    
    trial(m,:,1:(ix2-ix1+1)) = data.trial{k}(:,ix1:ix2); % this assumes that ix > 14 always
  end
  tmp.trial = trial;
  tmp.dimord = 'rpt_chan_time';
  
  tlck{k} = tmp;
  stimdata{k} = tmpstim;
  
  clear tmp;
end