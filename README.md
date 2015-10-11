#CMIDI
An Objective-C library for MIDI messages, data streams, files and sequences

##Usage

####CMIDIMessage
CMIDIMessage stores the message as raw MIDI data in the NSData property "data". Convenience constructors and properties are available in "CMIDIMessage+ChannelMessage.h", "CMIDIMessage+SystemMessage.h" and "CMIDIMessage+MetaMessage.h". Some of these properties are trivial, but others can be very convoluted. Two examples of constructors would be:<pre>
	msg1 = [CMIDIMessage messageWithNoteOn: MIDINote_MiddleC velocity: 78 channel: 2];
	msg2 = [CMIDIMessage messageWithBeatsPerBar: 4 eightsPerBeat: 2];  // 4/4 Tempo message.</pre>

The convenience properties that are relevant are:<pre>
	msg1.type == MIDIMessage_NoteOn
	msg1.channel == 2
	msg1.note = MIDINote_MiddleC
	msg1.velocity = 78
	msg2.type = MIDIMessage_System
	msg2.systemMessageType == MIDISystemMsg_Meta
	msg2.metaMessageType == MIDIMeta_TimeSignature
	msg2.beatsPerBar == 4
	msg2.eightsPerBeat == 2</pre>
	
When a message is received it's normal to switch on the type. The convenience properties will fail unless the type supports the property.<pre>
	switch (msg.type) {
		case MIDIMessage_NoteOn: {
			note = msg.note;	...
		}
		...
		case MIDIMessage_System:
			switch (msg.systemMessageType) {
				case MIDISystemMsg_Meta: {
					switch (msg.metaMessageType) {
						case MIDIMeta_TimeSignature: {
							bpb = msg.beatsPerBar; ...
						}
						...
					}
				}
				...
			}
		}
		...
	}</pre>
	
Clients who are familiar with MIDI data may create the data directly or modify individual bytes using the convenience properties status, byte1, byte2. This code creates the same two messages as above:<pre>
	Byte buf1[3] = {MIDIMessage_NoteOn | (2 - 1), MIDINote_MiddleC, 78};
 	msg1 = [[CMIDIMessage alloc] initWithData:[NSData dataWithBytes:buf1 length:3]];
	Byte buf2[7] = {MIDISystemMsg_Meta, MIDIMeta_TimeSignature, 4, 4, 2, 24, 8};
	msg2 = [[CMIDIMessage alloc] initWithData:[NSData dataWithBytes:buf2 length:7]];</pre>

####CMIDIFile
*todo*
####CMIDIClock
*todo*
####CMIDIReceiver / CMIDISender (MIDI signal processing chains)
*todo*
####CMIDISequencer <CMIDISender>
When given a list of time-stamped messages and attached to a clock, a CMIDISequencer will send the messages at the appropriate times to it's outputUnit.
####CMIDIEndpoint
*todo*

##Todo

####Urgent todo
Nothing more todo at the moment.

####Bugs

CMIDITransport
-	BPM is not bound properly; it’s not receiving updates from the clock. KVC looks right. I’m sure this is a trivial problem.

####Possible issues
These are not bugs, but may be confusing for the client.

CMIDIClock 
- 	If a "CMIDIReciever" keeps a pointer to the clock, there is a potential retain cycle.  Don't keep a pointer to the clock; you shouldn't need it until it calls you -- use the pointer inside the receiver, don't retain it. 
- 	Receiver list is not thread-safe and should not be modified when the clock is running.


####Low priority todo
These are nits or missing features that would effect the current project. Don’t need to do these at all.

CMIDITransport
-	MouseDown. Should allow the caller to drag the current time. Need to capture MouseDown/MouseUp. Code to do this is in one of the back up versions of SqueezeBox
-	Set the current time in various formats. Complicated, because we’re not bound to anything; we have to get the string and parse it. 

CMIDIMessage+Description
-	Files for strings. Should we just save the arrays? See what this looks like, see if it’s editable.
-	Indent strings. We need to divide and indent long strings, perhaps with \. We need to respect the “indent” parameter in that CMIDIIndent routine.

CMIDIMessage 
-	NSCopying 
	
CMIDITempoMeter / CMIDIMessage+MetaMessage. 
-	Thirty-seconds per eights .... this is in the tempo message, but I doubt that it's correct in every case ... using this may cause more problems than it solves.
CMIDISequence.outputUnit 
-	Check thread safety. 
	
CMIDIFile
-	split “standardize” code into a separate.
	
Everywhere
- 	check that all #pragma marks are all 80 characters wide
-	check that headers all read the same.
-	check that NS_DESIGNATED_INITIALIZER is used correctly everywhere.
- 	check inspection tests have the same header format.


####Unsupported features 
These are all well outside the scope of my current project. To be fixed with someone else's help.

CMIDIMessage:
-	Meta sequence number is supported, but there are no accessors or description because the documentation I have for it is unclear.

-	MIDITimeCodeQuarterFrame is supported, but there are no accessors or description because the documentation I have for it is unclear.

-	Meta SequencerEvent isn't supported at all. CMIDI can't parse these. 

-	No support for SMPTE time, (solution: this is relatively simple in the current architecture; just create a SMPTETimeHierarchy, and all the properties should fall out easily. Handle messages appropriately. Drop frame 

-	No support for MTC, MSC, MMC. In the spirit of this interface these would each include a category (CMIDIMessage+MTC) and then client friendly constructors and parsers for these messages. This is outside the scope of my current project. MTC has it's OWN timeSignature, separate from the meta time signature -- this is unimplemented.)

CMIDIFile:
-	No support for XML MIDI files.
-	Can't read type 2 MIDI files (solution: create "CMIDISequence" -- type 2 file creates multiple sequences. Type 0 and Type 1 files create one sequence.)

CMIDIClock

-	Unlike CAClock, this clock currently has no synchronization features. It should be able to sync to (1) an AudioUint (2) system MIDI messages such as start, stop, songPosition (3) MTC messages (4) SMPTE?? (how do you do this?) (5) what else?
-	SMPTE. We can’t format the time as SMPTE or set the SMPTE offset. The right way to do this would be to have two time maps, or at least a second hierarchy that has the smite time. The nanoseconds and ticks would be shared (i.e. “ticks” = “subframes” but the higher levels would be different.) The branch counts in the SMPTE time hierarchy would not change for the life time of the application; the hierarchy may be able to work by staying in sync with “timeOfTheCurrentTick”.

CMIDIEndpoint
- 	Updating missing endpoints. The "endpoint" I start with can disappear, as when I unplug a keyboard. I'm suessing that my input port will be disconnected and nothing will be sent to it. If I replug in the keyboard, it's possible the system creates some new endpoint and my input port needs to be re-connected to it, if I intend to stay connected.

While the endpoint is disconnected, I need to fail gracefully when I receive MIDI while I wait for the system to fix itself.

When the endpoint reappears, I should rescan by NAME and reconnect the object. (1) keep a MIDINotifyProc in MIDIUnit (Resources) and track when endpoints appear and disappear. (2) Whenever an endpoint is added, check the list of instantiated sources to see if the endpoint matches a name. If it does, then reconnect the source endpoint to my input port.
	
Add a flag fOffline, and handle it appropriately in the MIDI data flow. When decoding and the object is not found, set the offline flag and set the name; assume the object is offline Keep a MIDINotifyProc  and track when endpoints appear and disappear. NOT DOING THIS NOW, because this is outside the scope of my application.

####Possible new features
These are not needed for the current project. I would need a strong motivation to implement these. 
-	CMIDIMonitor: should use some kind of matrix ... isn't there a matrix which goes property by property, lets you resize the rows, etc.? I.e, an NSArrayController, etc. Is this easier than it looks?? 
-	CMIDISequencer: At 480 ticks per beat, it seems like this is doing a lot of extra work. If tests show that we need this to be more efficient, there are several options: (1) Skip ahead to next msg? this would require the clock to have an interface something like dontNotifyUntilTick:, which would ask the timer to send a message on a later tick, skipping the intervening ticks. Step down the tick rate by checking strength before proceeding. This is what Squeezebox does. (2) Readjust the ticks per beat in the clock and the message list. This is just a matter of setting ticksPerBeat in the timeHierarchy (and clock) and also adjusting the tick in every message. (3)Possibly add a feature that uses permits micro timing.
- 	CMIDIDataParser+MIDIPacketList: time. Messages are not time stamped. They could easily be stamped with “host time” because the packet lists has this, but, unfortunately, CMIDITempoMeter doesn’t keep track of host time. 
-	CMIDITempoMeter:hostTime / CMIDIMessage:timeLine. We COULD add a layer to CMIDITempoMeter that allows the display of hostTime, but this would require CTime to handle offsets. (We might want CTime to handle offsets anyway, so that we can have a SMPTE offset.) We would also need to another field to CMIDIMessage “timeLine” and allow messages to be attached to particular time lines. This is veering toward making CTime into an object with an SInt64 and NSUinteger (time & timeline). I would need to have some stronger motivations for this before I commit because it is a more complex architecture. I like having CTime as a simple SInt64. 
-	CMIDIMessage+Verify. [CMIDIMessage check] would be useful as a last step in parsing, just to be sure messages are valid in files and streams. (Don't think it would be useful for real-time message streams because there's nowhere to put the NSError -- on the endpoint?   It would need to be rewritten without CDebugMessage and return error objects.)

####Untested, with code in place
- 	CMIDIEndpoint: Not sure if my internal end points can be properly used by other applications. I have reason to believe this probably doesn't work.

####Todo with someone's help
These should be fixed, but they require more research than I am willing to commit right now. Perhaps someone else knows how to do this easily.
-	CMIDITimer should go to the machine directly; this will help remove our dependency on CoreMIDI (which isn't available yet in iOS and may never be).
-	CMIDIFile, CMIDIDataParser: Error reporting in CMIDIFile & CMIDIDataParser. (1) Warnings are not returned properly. Would prefer to queue all the warnings. (2) Need to return an error code for regression testing. (3) Also, regression tests would be more elegant if we removed the current dependency on CDebugMessage.h 
-	Question: Is it possible that "TuneRequest" "SongPositionPointer" "MTCQuarterFrame" should be considered real time bytes? Apple ignores them when it is reading a sequence. 
-	CMIDIClock Retain loop in the UI. CMIDIClock is not deallocated if you press play once in CMIDITransport. CMIDIClock and CMIDTimer are deallocated in tests where nothing is bound to the transport.  CMIDITransport and NSDocument are deallocated in CMIDIClockTest, the clock isn’t. Because they are deallocated in tests with only my two objects, I don’t think this problem is in my code; it must have something to do with the bindings.

####Test bugs / bugs not worth fixing:
-	Apple's "RawData" messages does not match the System Exclusive messages I am finding in the files, but (with some discomfort), I think I am right and Apple is wrong at the moment.  Not really clear what Apple is doing here. For most examples, the block of raw data looks exactly like the system exclusive message I am reading, but, inexplicably, the "manufacturer ID" has been removed. It's also possible that I'm misunderstanding what my tests are showing me. This is unimportant to my current project -- call it a "possible issue". Apple will not read a system exclusive message with a three byte manufacturer ID (it just deletes them). Apple misreads the length of some of the system exclusive messages. For now, I strip these out of tests when Apple can't handle it at all, and when "DEBUG" is set, I don't use "manufacturer ID" to evaluate equality.
- 	CMIDITimer tests, fails -- as if CoreMIDI was doing nothing.  Timer works and is well tested from CMIDIClock; I'm sure this is some dumb problem with the test.

##Design notes
####CMIDIMessage

Requirements:

This was designed to make it possible to: 
- create MIDI messages with as little hassle as possible. 
- to identify and handle an arbitrary MIDI message with as little hassle as possible. 
- be able to efficiently read from a packetlist or file.
- be able to efficiently write out to a packetllst of file. 
- handle thread safety and memory management without too much hassle.

Conclusions:

Use CMIDIMessage object, rather than C struct or anything else
-	+ We get so much for free: ARC, thread safety (with help from ARC), NSCoding, KVO. Thread safety is the real deal breaker. With an object under ARC, if I have a pointer, then he object still exists, and I can use it regardless of what other threads are doing with the messages. 
-	- This does add some memory overhead, but this is not really a problem, because MIDI messages are tiny to start with and we can always compress a set of them into a MIDIPacket or NSData packet object, etc.

On storage: Store NSData with a valid message; parse the data to get client-friendly properties. This optimizes the message for reading and writing, but still provides client friendly construction, modification and access. I think reading/writing should be as fast as possible, because MIDI processors need to be able to pass data through, looking for the messages they are interested in. We need to get messages in and out of Objective-C as efficiently as possible. 

Use only one class with categories rather than several classes in a hierarchy.  For these reasons:
-	+ It helps with (2) because no cast is necessary to access the data in an arbitrary message. 
-	+ It helps with (3)  because we don't have to figure out which class to allocate when we are reading data.
-	+ It helps with both (1) and (2) because the user doesn't have to study my class hierarchy to get anything done. He just needs understand the way the various constants work, and switch on those. 
	? We lose the ability to do things like [CMIDIMetaTextMessage new], but this is a bad idea in any case, because this will be only a partial constructor. It may set the type fields, but there will still be properties that need to be set -- we're setting some in [init] but not all.  It's better to have a complete constructor for each message (or to let the user set all properties, including the type). Otherwise they have to study  my class hierarchy and try to figure out which properties are encoded as "classes" and which properties are not. 
	? We lose the ability to hide some properties all together -- such as message type. But this is not really a good thing, because message type is a very famous property and people need it to for (3), because you can't switch on the class. 

CMIDIMessage is should be immutable with client-friendly specialized constructors.  
We construct under three circumstances: (A) Reading from file or packetlist (where data may be invalid). (B) Client creates a message to send somewhere (set with user-friendly property values). (C) Internal constructor calls with valid data (i.e., internal convenience functions implemented for parsimony).

There are several basic ways to construct: 

(1) Constructor creates a valid message, message is immutable
-	+ valid property access does not have to allocate data (except variable sized messages, of course)
-	- can't change properties. It's unclear if there is an application where you really need to set the properties -- typically we just want to create a valid message and send it somewhere, or study a valid message you have received. If there is such an application (such a "transposer"), it's not hard to create a new message for these special applications.

(2) Set data, set data with bytes, validate if data is external.
-	+ we need this to read from files and packetlists. (Here we need to validate).		+ this creates a simple interface for internal constructors. buf[3] = {v,v,v}; [messageWithBytes:buf length:3]; 

(3) "new" and set all properties, setters are available
-	- the message is invalid before we begin setting the properties -- this creates a "modal" situation. We can't validate the "set" operations unless we know the type of the message, so the properties would have to be set in order -- so we have multiple "invalid modes" as we're trying to set them. It's not clear when we will have a chance to validate, unless this is separate state		- we can't allocate the memory yet because we don't know if this is a variable-length message, so we're in a situation where we don't know how much memory to allocate.	-	- there are some message (such as timeSignature) which really need a constructor -- the native MIDI is just too ugly. Thus, if we allow "new" and set all properties for some messages, we are inconsistent. It's not obvious to clients. If we implement setters and constructors for all messages requires twice as much testing. 
-	- properties must be set in order if we are going to check validity -- type must be set first, controller type must be set before value, etc. We need to verify that this is being done, which requires default values.
-	- requires a lot of typing and reveals ugly constants. Much more natural to build with static buffers as data.
-	- having setters AND constructors requires twice as much testing, untless y

(4) constructor creates a partial message, user sets properties for the rest. For example, the constructors takes the type, channel and the length of the variable data, to hide the status byte and allocate memory.
-	- has all the same problems as (3) above
-	- clients can't tell at glance which properties are set by the partial constructor and which properties they need to set. It's inconsistent. A specialized constructor asks for all the valid properties, but someone with some MIDI knowledge will be wondering exactly where they set each property. 

####CMIDIEndpoint

Requirements: 
The goal of this design is to allow clients to use MIDI endpoints simply, without needing to study the complexity of CoreMIDI and all of its objects and constructors. Thus, this interface hides all details except the most essential and implements only the simplest cases. If a client needs all the details of CoreMIDI, they should use CoreMIDI.

I divided the endpoints into three classes for clarity (see explanation in the header file). There is shared code, but none of the code is shared between all three types of end points. Two types might have some very similar code -- the <MIDISender>s share some code,  <MIDIReceiver>s share some code, external endpoints have similar "search" routines, all of them have some kind of port. This code is subtly different for each type of endpoint. I could have combined the shared code into the superclass, of course, but that would have these pluses and minuses:
-	- Combining the shared code would requires a really complicated system of inheritance that would have the thread jumping all around the hierarchy. I think the code for each endpoint is easier to understand if there is no inheritance at all and you can find all the code for each type of object inside that object. I think that future developers will start by analyzing one endpoint and trying to see how it works -- this will be easier for future developers to get an initial understanding of what's happening.
-	+ Not combining the code means that making an update or fixing a bug must often be done in two places, and it is easy to overlook one.
	
On the whole, this file chooses clarity over parsimony.

These classes obey what I call the "non-modal" principal: if the object exists, then it is valid and ready to operate. Any time between init and dealloc, the endpoint is fully capable of handling any method call whatsoever. With ARC, this means that if you have a valid pointer to the object then you are pointing to a fully functional object.

Thread safety: I keep persistent, fixed lists of all the endpoints in the CMIDIEndpointManager.  We only add to these lists and never remove objects from it. (While it's theoretically possible that this list could grow large if we never remove anything, I doubt this will ever be an issue in practice.)

Because of ARC, I know that no endpoint will be deallocated as long as the pointer in these lists exists. I also know that any endpoint is valid as long as it exists. The properties used here (endpointRef, port) can not be changed after initialization, and no one can have a pointer to this object until it is initialized.

A method that uses "outputUnit" is NOT thread safe, because the output unit may be changed while the routine is in progress. Always grab a synchronized pointer to the outputUnit in these routines and synchronize as well when a caller changes the output unit.

When CoreMIDI calls a MIDIReadProc, we need a pointer to "self". I can't place the pointer in the refcon, because ARC won't guarantee that this object is still valid. Thus I place an index into the lists held by CMIDIManager. This index is always valid and correct (because we only add to these lists and never remove from them).

####CMIDIClock

#####Requirements

- Invariant: "clockTicked" always sends every tick, in order, regardless of tempo changes or if the clock is started or stopped. Only setting the currentTick can break this principle.

- Invariant: clock.currentTick is the name of the time period between each tick, and we give this name at the start of each tick. Thus the "currentTick" property always returns the most recent tick sent. Between two clock ticks (even after the ClockTicked) messages have all been sent, the clock.currentTick must stay the same until the next tick.

- Invariant: while stopped, setCurrentTick = t, start. The next tick sent should be t. Suppose I'm using the transport, and I want it to start on a particular beat. The most natural thing in the world is to set the time to the exact tick that starts the bar, and then hit start. It should send the first tick of the bar.  

- Feature: after you stop, if you don't reset the "currentTick" it starts on (precisely) the next tick. 

#####Design notes

- Separated the functionality into two objects: CMIDITimer handles all the CoreMIDI calls. CClock handles all the conversions, client calls, and other details for complete functionality. This could be rebuilt with some other form of timer, if we can find one with an accuracy of about 1 millisecond. NSTimer is off by 200 microseconds.

- Store tempo as an integer because this prevents floating point errors. CMIDINanoseconds and CMIDIClockTicks are integers, and thus are not subject to floating-point errors. Ticks are also signed, which prevents another set of potential problems.

#####Thread safety notes

Each of the five entry points has a sync lock, and the code inside the sync lock does not leave the object. This guarantees that the clock's properties will never be out of sync with itself. There are three ways the thread safety can fail that I can see and all of them are extremely unlikely.

1) There is one tiny hole, between the @synchronized and the MIDIFlushOutput. This is only microseconds wide, and I don't think I need to worry about it.
	User initiates operation. 
	Operation hits "@synchronize". No lock it continues.
	CoreMIDI initiates tick on high priority thread before user thread calls MIDIFlushOutput 
	CoreMIDI thread hits the sync lock and stops. 
	Operation calls MIDIFlushOutput one line of code too late.
	Operation finishes, CoreMIDI thread is released.
	Erroneous tick is sent.  If an erroneous tick is sent, then we will have two sets of messages rolling through the system, slightly off each other.

Note that, outside this hole, nothing can happen:
	User initiates operation.
	CoreMIDI initiates tick on high priroity thread before operation hits @synchronized. 
	CoreMIDI threads runs into @synchronized in clockTicked. No lock, thread executes tick.
	User thread hits sync lock and waits until CoreMIDI finishes. This the operation happens "after" the tick, which is fine.	

I think this shows that, except for this hole, it is impossible that there is a tick waiting to execute when we exit an operation. Each operation sends the "nextTick" as the last step, and the next tick is typically more than 100 milliseconds away -- there is very little chance that the tick will come in and start doing anything before the operation has finished sending all it's messages (unless of course processing the messages takes more than 100 milliseconds, which is highly unlikely, and bad for lots of reasons.) So the messages at the end of an operation will always be sent in order.

Again, this is extremely unlikely, because the timer has to go off PRECISELY BETWEEN TWO LINES OF CODE. 

2) It is possible that an operation is waiting a sync lock for a tick to finish. In this case, it is theoretically possible for operation to send it's messages BEFORE the tick finishes sending it's messages. But this must be extremely unlikely, because two things must happen. 
CoreMIDI initiates a tick.
The tick passes the sync lock in "clockTicked".
*The user initiates an operation on a lower priority thread. It goes up to the sync lock and stops.
CoreMIDI exits the lock, but hasn't sent it's message yet.
*The lower priority thread starts again and passes through the lock, and then sends it's messages.
CoreMIDI thread continues and sends it's messages. This would be a tick message that WOULD have been correct if it was sent in the other order. Out of order messages would mean that some of my assumptions (for example, that "currentTick" is set correctly for these messages) will be wrong.

This would require two very unlikely (impossible?) operations where the high priority CoreMIDI thread yielded to the client thread, which is most likely a UI thread anyway. This COULD happen if the client thread was equally high priority, as when a MIDI message sets the tempo. In this case, the message will be a little weird, but note that they are only out of order by one, and I don't really think that this will have an effect. 

3) Dealloc has an exposure similar to (1), and it also requires that the timer go off precisely between two lines of code.
Dealloc starts.
Dealloc hits the first sync lock and continues.
CoreMIDI initiates a tick before "flushoutput" is called (note that it's called first)  interrupting dealloc.
CoreMIDI hits the first sync lock and stops. 
Dealloc finishes cleaning up and clears the lock
CoreMIDI continues into the sync lock, but now it is looking at bad information. 

####Notes on CAClock

CMIDIClock has been written to replace CAClock.  These are the problems I have with CAClock:

1) After stopping, it continues to send timing messages to the endpoints it is attached to. This is confusing, but (I am told) this is by design so that downstream units can keep syncing themselves even when the clock is stopped. In other words, it's a feature. However I need a clock that can be stopped and reset to a new position without losing ticks.

2) It continues to move "media time" forward after a stop, even though the media time should be halted. This adds another layer of confusion. Also, it's impossible to query the system to know where, exactly, it is stopped on the media timeline.

3) "stop" sends a time of zero (this is okay, I suppose, because it means "immediately", but it would be more consistent to tell me what TIME it stopped).

4) After stopping, "start" does not begin at the next tick -- it may jump forward or backward several ticks. This is bad for an application that assumes it will receive every tick; in a sequence it may skip downbeats and note-off points.

5) It seems to always send a "move" just before it starts. This may be related to the previous; it could be a way of telling the downstream units that we're not continuing with exactly the same tick. Nevertheless, my downstream routines would prefer to know that this is not a "real" move, i.e. one that was generated by a user command or some client operation.

7) When the clock is initialized, but not yet started, CATranslateTime returns the same real-time for all media times. This is odd, and I suppose the behavior under these circumstances is "undefined". However, I would like to be make calculations about media time values without necessarily starting the clock (such as tempo calculations), so I would prefer that this behaved in the same way it does when it is stopped: by assuming some fixed starting point and calculating the real values from that.

8) Can't set the time while the clock is running; returns an error.

9) Conversion routines don't make a clear enough distinction between media time and host time -- approach to these conversions is inconsistent in any case. (see (2) above). 

10) Tempo map seems to do nothing. What is the tempo map used for? Am I still setting it wrong?

10.1) The MIDI clock ticks do not change tempo with tempo map.

10.2) "CATranslateTime" does seem to take into account the tempo map.

11) Can't seem to use an object with SMPTE time; can't get SMPTE from beats, can't get beats from SMPTE. SMPTE not currently supported; I'm sure there's something I don't know. (This is not fixed in CMIDIClock.) 

As far as I can see, the only features of CAClock that I don’t support are 
1) Synchronization
2) SMPTE (offset, etc.)



