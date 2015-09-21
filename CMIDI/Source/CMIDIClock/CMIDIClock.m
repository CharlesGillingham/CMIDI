//
//  CClock.m
//  Squeeze Box
//
//  Created by Charles Gillingham on 5/23/13.
//  Copyright (c) 2013 Squeeze Box. All rights reserved.

#import <CoreAudio/CoreAudio.h>
#import "CMIDIClock.h"
#import "CMIDITimer.h"
#import "CMIDIMessage+MetaMessage.h"
#import "CTimeMap.h"
#import "CTimeMap+TimeString.h"
#import "CMIDITempoMeter.h"


@interface CMIDIClock () <CMIDITimerReceiver>
@end


@implementation CMIDIClock {
    CMIDITimer       * _timer;
    CMIDINanoseconds   _nanosecondsPerTick;
    CMIDIClockTicks    _currentTick;
    CMIDINanoseconds   _hostTimeOfCurrentTick;
    BOOL               _isRunning;
    
    // These flags are set and are only cleared after notificiations have been sent. (All notifications are sent on the high prioirity thread, so that there's no chance of them getting sent out of order.
    BOOL               _tempoNeedsNotify; // Set by setNanosecondsPerTick:
    BOOL               _tickNeedsNotify;  // Set by setCurrentTick:
    BOOL               _startNeedsNotify; // Set by start:.
    BOOL               _tickReset;        // Set by setCurrentTick:, cleared in timeDone:
    
    // Support for the time map.
    CMIDITempoMeter  * _timeMap;
    CMIDIClockTicks    _ticksPerBeat;
    NSUInteger         _currentTimePeriodInTempoMap;
    CMIDINanoseconds   _timeOfNextTempoChange;
}
@dynamic    currentTick;
@dynamic    timeOfCurrentTick;
@dynamic    nanosecondsPerTick;
@dynamic    isRunning;
@synthesize receivers;

- (id) init
{
    if (self = [super init]) {
        // Representation of the current time.
        _hostTimeOfCurrentTick = AudioConvertHostTimeToNanos(AudioGetCurrentHostTime());
        _currentTick           = 0;
  
        _isRunning             = NO;
        
        // Relationsh
        receivers              = [NSMutableArray new];
        _timer                 = [CMIDITimer timerWithReceiver:self];
        
        _tempoNeedsNotify      = NO;
        _startNeedsNotify      = NO;
        _tickNeedsNotify       = NO;
        _tickReset             = YES; // We have "reset" to zero at start.
        
        // Sets _ticksPerBeat and _nanosecondsPerTick
        self.timeMap           = [[CMIDITempoMeter alloc] initWithTicksPerBeat:24];
    }
    return self;
}



- (void) dealloc
{
    // Notify downstream units that the clock is stopped. (We know they still exist, because we have a pointer to them). The sync locks will ensure that all operations are finished before we deallocate the clock.
    // Also does a "flush output" to the timer, which should prevent the timer from sending any more messages to this object (I hope).
    [self stop];
    
    // If you are seeing this, then there are no retain cycles with the clock.
    printf("CLOCK DEALLOCATED\n");
    
}



// -----------------------------------------------------------------------------
#pragma mark                        isRunning
// -----------------------------------------------------------------------------

- (BOOL) isRunning {
    @synchronized(self) {
        return _isRunning;
    }
}


- (void) setIsRunning:(BOOL)isRunning
{
    if (!_isRunning && isRunning) {
        [self start];
    } else if (_isRunning && !isRunning) {
        [self stop];
    }
}


- (void) start {
   @synchronized(self) {
        if (_isRunning) return;
       
       // No typically necessary, but just in case there is something in the system because of a rapid stop/start; make sure it's cleaned out.
       [_timer deleteMessagesInProgress];

        CMIDINanoseconds now = AudioConvertHostTimeToNanos(AudioGetCurrentHostTime());

        _isRunning = YES;
        _hostTimeOfCurrentTick = now;
        _startNeedsNotify = YES;
       
        // Get the timer to send the tick immediately.
        [_timer sendMessageAtHostTime:AudioConvertNanosToHostTime(now)];
    }
    
    // All notifications are sent on the high-priority thread.
}


// Called on the high prioity thread.
- (void) notifyStart
{
    _startNeedsNotify = NO;
    for (NSObject <CMIDITimeReceiver> * receiver in receivers) {
        if ([receiver respondsToSelector:@selector(clockStarted:)]) {
            [receiver clockStarted:self];
        }
    }
    [self willChangeValueForKey:@"isRunning"];
    [self didChangeValueForKey:@"isRunning"];
}



- (void) stop  {
    @synchronized(self) {
        if (!_isRunning) return;
        [_timer deleteMessagesInProgress];
        _isRunning = NO;
    }
    
    [self notifyStop];
}


- (void) notifyStop
{
    for (NSObject <CMIDITimeReceiver> * receiver in receivers) {
        if ([receiver respondsToSelector:@selector(clockStopped:)]) {
            [receiver clockStopped: self];
        }
    }
    
    [self willChangeValueForKey:@"isRunning"];
    [self didChangeValueForKey:@"isRunning"];
}



// -----------------------------------------------------------------------------
#pragma mark                   Tempo
// -----------------------------------------------------------------------------

- (CMIDINanoseconds)nanosecondsPerTick {
    @synchronized (self) {
        return _nanosecondsPerTick;
    }
}


- (void) setNanosecondsPerTick: (CMIDINanoseconds) tempo
{
    @synchronized(self) {
        [_timer deleteMessagesInProgress];
        
        _nanosecondsPerTick = tempo;
        _tempoNeedsNotify = YES;

        CMIDINanoseconds nextTick = _hostTimeOfCurrentTick + _nanosecondsPerTick;

        [self eraseTimeMap];
        
        // If the tempo becomes significantly faster and we are getting towards the end of this tick, the time of the next tick may now be a moment in the PAST. If so we should send the next tick immediately. Otherwise, send the next tick at the right distance from the previous tick. (Don't wait till the next tick to change the tempo, otherwise the tempo may not speed up as much as the caller would like. In extreme cases, it would almost seem to hang as we waited for the old, slow tempo to finally getting around to sending the next tick.)
        // Question: will the timer handle this automatically? If a time is earlier than the current time, does it send a tick NOW?
        CMIDINanoseconds now = AudioConvertHostTimeToNanos(AudioGetCurrentHostTime());
        if (nextTick < now) {
            nextTick = now;
        }
        
        [_timer sendMessageAtHostTime:AudioConvertNanosToHostTime(nextTick)];
    }
    
    // Notifications are sent on the high priority thread when we are running.
    if (!_isRunning) {
        [self notifyTempoChange];
    }
}



- (void) notifyTempoChange
{
    if (_tempoNeedsNotify) {
        _tempoNeedsNotify = NO;
        for (NSObject <CMIDITimeReceiver> * receiver in receivers) {
            if ([receiver respondsToSelector:@selector(clockTempoSet:)]) {
                [receiver clockTempoSet:self];
            }
        }
    
        // While this technically incorrect, there are too many ways for these notifications to get mismatched between the two threads, unless I send both of them from the same thread at the same time.
        [self willChangeValueForKey:@"nanosecondsPerTick"];
        [self didChangeValueForKey:@"nanosecondsPerTick"];
    }
}



// -----------------------------------------------------------------------------
#pragma mark                currentTick
// -----------------------------------------------------------------------------


- (CMIDIClockTicks) currentTick {
    @synchronized (self) {
        return _currentTick;
    }
}



- (void) setCurrentTick: (CMIDIClockTicks) t
{
    @synchronized(self) {
        // Do this first, so that we're unlike to have tick waiting when we exit the sync lock.
        [_timer deleteMessagesInProgress];
        
        _currentTick = t;
        _tickReset = YES;        // The high priority thread clears this.
        _tickNeedsNotify = YES;  // [notifyTimeChanged] clears this.
   
        // Ask the time map if there is a tempo change on this tick.
       _tempoNeedsNotify = (_tempoNeedsNotify && [self checkTempoChangeForNewTick]);
        
        if (_isRunning) {
            CMIDINanoseconds now = AudioConvertHostTimeToNanos(AudioGetCurrentHostTime());
            _hostTimeOfCurrentTick = now;
            
            // Always do this last, to avoid (admittedly unlikely) sync problems
            [_timer sendMessageAtHostTime:AudioConvertNanosToHostTime(now)];
        }
    }

    if (!_isRunning) {
        [self notifyTimeChanged];
        [self notifyTempoChange];
    }
}



- (void) notifyTimeChanged
{
    if (_tickNeedsNotify) {
       _tickNeedsNotify = NO;
       
        for (NSObject <CMIDITimeReceiver> * receiver in receivers) {
            if ([receiver respondsToSelector:@selector(clockTimeSet:)]) {
                [receiver clockTimeSet:self];
            }
        }
        [self willChangeValueForKey:@"currentTick"];
        [self didChangeValueForKey:@"currentTick"];
    }
}


// -----------------------------------------------------------------------------
#pragma mark                timerDone: High priority thread
// -----------------------------------------------------------------------------
// The high priority thread does all the notifying while we are running; otherwise, we will run into serious difficulties trying to get these notifications to be sent in the right order, as new clock ticks interrupt the notificiations from the client's changes.

- (void) timerDone: (CMIDINanoseconds) hostTime
{
 
    @synchronized(self) {
        // Can happen, if the tick arrives while we are stop's sync lock. The timer thread will be waiting here when stop lets go of the lock and will execute immediately.
        if (!_isRunning) return;
        
        _hostTimeOfCurrentTick = hostTime;
        
        // Don't increment the tick if it has been reset.
        if (_tickReset) {
            _tickReset = NO; // Clear the flag.
        } else {
            _currentTick++;
            if (_currentTick >= _timeOfNextTempoChange) {
                _tempoNeedsNotify = (_tempoNeedsNotify  && [self checkTempoChangeForNextTick]);
            }
         }
        
        // Always do this last, to avoid (admittedly unlikely) sync problems
        [_timer sendMessageAtHostTime:AudioConvertNanosToHostTime(_hostTimeOfCurrentTick + _nanosecondsPerTick)];
    }
    
    // Trying to send these in a reasonable order.
    if (_startNeedsNotify) {
        [self notifyStart];
    }

    if (_tickNeedsNotify) {
        [self notifyTimeChanged];
    }
    
    for (NSObject <CMIDITimeReceiver> * receiver in receivers) {
        [receiver clockTicked:self];
    }
    
    if (_tempoNeedsNotify) {
        [self notifyTempoChange];
    }
    
    [self willChangeValueForKey:@"currentTick"];
    [self didChangeValueForKey:@"currentTick"];
}



// -----------------------------------------------------------------------------
#pragma mark                        Return the time
// -----------------------------------------------------------------------------
// Time of current tick is not KVO compliant if the time is reset when the clock is stopped.

- (CMIDINanoseconds) timeOfCurrentTick
{
    // If the client sets the current tick while the clock was stopped, then we are stopped ON the tick. Whenever the clock starts again, THAT will be the time of the current tick. We don't know what that is, but we can tell them what it WOULD be if the clock started now.
    if (!_isRunning) {
        return AudioConvertHostTimeToNanos(AudioGetCurrentHostTime());
    }
    return _hostTimeOfCurrentTick;
}



// -----------------------------------------------------------------------------
#pragma mark                   Time Map
// -----------------------------------------------------------------------------

@dynamic timeMap;

- (CMIDITempoMeter *) timeMap
{
    return _timeMap;
}

- (void) setTimeMap:(CMIDITempoMeter *)tm
{
    @synchronized(self) {
        _timeMap = tm;
        
        // Get the new time period
        _currentTimePeriodInTempoMap = [tm timePeriodOfTime:_currentTick timeLine:CMIDITimeLine_Ticks];
        [self updateTempoFromTimeMap];
    }
}

// Called from "setNanosecondsPerTick" inside the @sync
- (void) eraseTimeMap
{
    [_timeMap setBranchCount:_nanosecondsPerTick atLevel:CMIDITimeLine_Nanos];
    _currentTimePeriodInTempoMap = 0;
    _timeOfNextTempoChange = CTime_Max;
}

// Called from "timerDone" inside the @sync
- (BOOL) checkTempoChangeForNextTick
{
    _currentTimePeriodInTempoMap = _currentTimePeriodInTempoMap+1;
    return [self updateTempoFromTimeMap];
}

// Called from "setCurrentTick" inside the @sync
- (BOOL) checkTempoChangeForNewTick
{
    // Get the new time period
    _currentTimePeriodInTempoMap = [_timeMap timePeriodOfTime:_currentTick timeLine:CMIDITimeLine_Ticks];
    return [self updateTempoFromTimeMap];
}


// Returns "YES" if there was a tempo change
- (BOOL) updateTempoFromTimeMap
{
    CMIDINanoseconds currentTempo = _nanosecondsPerTick;
    CTimeHierarchy * th = [_timeMap hierarchyDuringTimePeriod:_currentTimePeriodInTempoMap];
    CMIDINanoseconds nextTimeInNanos = [_timeMap endOfTimePeriod:_currentTimePeriodInTempoMap];
    _ticksPerBeat       = [th AsPerB: CMIDITimeLine_Ticks : CMIDITimeLine_Beats];
    _nanosecondsPerTick = [th AsPerB: CMIDITimeLine_Nanos : CMIDITimeLine_Ticks];
    _timeOfNextTempoChange = nextTimeInNanos/_nanosecondsPerTick;
    return currentTempo != _nanosecondsPerTick;
}


//-----------------------------------------------------------------------------
#pragma mark                   Some other formats
// -----------------------------------------------------------------------------
@dynamic beatsPerMinute;
@dynamic timeInSecondsOfCurrentTick;

#define nanosecondsPerMinute (60000000000.0)
#define nanosecondsPerSecond ( 1000000000.0)

- (void) setBeatsPerMinute:(Float64)BPM
{
    self.nanosecondsPerTick = nanosecondsPerMinute / (BPM * _ticksPerBeat);
}

- (Float64) beatsPerMinute
{
    return nanosecondsPerMinute / (self.nanosecondsPerTick * _ticksPerBeat);
}


- (Float64) timeInSecondsOfCurrentTick {
    return (((Float64)_currentTick) * _nanosecondsPerTick)/nanosecondsPerSecond;
}

- (void) setTimeInSecondsOfCurrentTick:(Float64)timeInSecondsOfCurrentTick
{
    self.currentTick = (nanosecondsPerSecond * timeInSecondsOfCurrentTick) / _nanosecondsPerTick;
}

//-----------------------------------------------------------------------------
#pragma mark                   Private access for testing only.
// -----------------------------------------------------------------------------
#ifdef DEBUG
- (void) disableTimer
{
    _timer = nil;
}
#endif

@end




