editable('sample_time','delay_time','test1_match_time','test1_nonmatch_time','test1_nonmatch_rand','delay2_time','test2_time','num_rewards','reward_dur', 'iti_dur');

wait_for_touch = 8000;
sample_time = 650;
delay_time = 400;
test1_match_time = 1000;
test1_nonmatch_time = 1000;
test1_nonmatch_rand = 0;
delay2_time = 175;        %Changed from 75 on 8/17/2012
test2_time = 1000;
initial_fast_RT_window = 75;
num_rewards = 1;
reward_dur = 200;
iti_dur = 1000


set_iti(iti_dur);

% 
% hotkey('r', 'goodmonkey(100);');
% %hotkey('-', 'reward_dur = reward_dur - 10');
% %hotkey('=', 'reward_dur = reward_dur + 10');

ismatchtrial = length(TaskObject)==2;  % has a value of 1 if it's a match trial

[ontarget, rt] = eyejoytrack('acquiretouch', [1], [3.0],wait_for_touch);

if ~ontarget,
    trialerror(1); %no touch
    rt=NaN;
    return
end

eventmarker(7);  % bar down (hold)

toggleobject(1,'eventmarker',23); % turn on sample stim

[ontarget, rt] = eyejoytrack('holdtouch', [1], [3.0], sample_time);

if ~ontarget,
    eventmarker(4); %bar up (release)
    trialerror(5); %early
    toggleobject(1,'eventmarker',24);  % if error, turn off sample
    rt=NaN;
    return
end

toggleobject(1,'eventmarker',24);  % if monkey holds lever long enough, turn off sample

% begin delay period
[ontarget, rt] = eyejoytrack('holdtouch', [1], [3.0], delay_time); % monkey must hold lever during delay

if ~ontarget,
    eventmarker(4); %bar up (release) during delay
    trialerror(5); %early
    rt=NaN;
    return
end

toggleobject(2,'eventmarker',25);  % turn on test1

if ismatchtrial, % if this is a match trial

    [ontarget, rt] = eyejoytrack('holdtouch', [1], [3.0], initial_fast_RT_window); %cant release bar during inital time window

    if ~ontarget,
        eventmarker(4); %bar up (release) during initial RT window
        trialerror(5); %early
        toggleobject(2,'eventmarker',26);  % if error, turn off test1
        rt=NaN;
        return
    end

    [ontarget, rt] = eyejoytrack('holdtouch', [1], [3.0], test1_match_time-initial_fast_RT_window); %monkey has this long to release during green sq

    rt=rt+initial_fast_RT_window;

    if ontarget==0, % if monkey released bar in time
        eventmarker(4); % bar up (release)
        toggleobject(2,'eventmarker',26); % turn off test1
        trialerror(0); %correct
        eventmarker(96); % reward given
        goodmonkey(reward_dur);
    end

    if ontarget==1, % if monkey didn't release bar in time
        toggleobject(2,'eventmarker',26); %turn off test1
        trialerror(6); % monkey doesn't release bar during test 1 match trial.....Changed 8/17/2012
        rt=NaN;
        return
    end
end

if ~ismatchtrial, % if it's a nonmatch trial
    
    hold_time = ceil(test1_nonmatch_rand*rand())+test1_nonmatch_time;
    [ontarget, rt] = eyejoytrack('holdtouch', [1], [3.0], hold_time); %test1 (nonmatch)

    if ~ontarget,
        eventmarker(4); %bar up (release)
        trialerror(6); %incorrect response
        toggleobject(2,'eventmarker',26);  % if error, turn off test1
        rt=NaN;
        return
    end
    
    if ontarget,
        toggleobject(2,'eventmarker',26);  % turn off test1
    end
    
    [ontarget, rt] = eyejoytrack('holdtouch', [1], [3.0], delay2_time); %delay2 (nonmatch)

    if ~ontarget,
        eventmarker(4); %bar up (release)
        trialerror(5); %early
        rt=NaN;
        return
    end
    
    toggleobject(3,'eventmarker',27);  % turn on test2
    
    [ontarget, rt] = eyejoytrack('holdtouch', [1], [3.0], test2_time); %monkey has this long to release during test2

    if ontarget==0, % if monkey released bar in time
        eventmarker(4); % bar up (release)
        toggleobject(3,'eventmarker',28); % turn off test2
        trialerror(0); %correct
        eventmarker(96); % reward given
        goodmonkey(reward_dur);
    end

    if ontarget==1, % if monkey didn't release bar in time
        toggleobject(3,'eventmarker',28); %turn off test1
        trialerror(1); %no response
        rt=NaN;
        return
    end
end


    