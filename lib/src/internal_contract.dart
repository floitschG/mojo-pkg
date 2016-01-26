// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:isolate' show SendPort;
import 'dart:typed_data' show ByteData;

/// The MojoHandleWatcher sends a stream of events to application isolates that
/// register Mojo handles with it.
class MojoHandleWatcher {
  /// Starts watching for events on the given [mojoHandle].
  ///
  /// Returns an integer, encoding the result as specified in the [MojoResult]
  /// class. In particular, a successful operation returns [MojoResult.kOk].
  ///
  /// Instructs the MojoHandleWatcher isolate to add [mojoHandle] to the set of
  /// handles it watches, and to notify the calling isolate only for the events
  /// specified by [signals] using the send port [port].
  ///
  /// The [mojoHandle] is a token that identifies the mojo-handle (but is
  /// usually not an instance of `MojoHandle`).
  ///
  /// The filtering [signals] are encoded as specified in the
  /// [MojoHandleSignals] class. For example, setting [signals] to
  /// [MojoHandleSignals.kPeerClosedReadable] instructs to notify, when the
  /// handle becomes readable (that is, has data available for reading), or
  /// when it is closed.
  static int add(Object mojoHandle, SendPort port, int signals) {
    throw new UnsupportedError("MojoHandleWatcher.add on contract");
  }

  /// Stops watching the given [mojoHandle].
  ///
  /// Returns an integer, encoding the result as specified in the [MojoResult]
  /// class. In particular, a successful operation returns [MojoResult.kOk].
  ///
  /// Instructs the MojoHandleWatcher isolate to remove [mojoHandle] from the
  /// set of handles it watches. This allows the application isolate
  /// to, for example, pause the stream of events.
  ///
  /// The [mojoHandle] is a token that identifies the mojo-handle (but is
  /// usually not an instance of `MojoHandle`).
  static int remove(Object mojoHandle) {
    throw new UnsupportedError("MojoHandleWatcher.remove on contract");
  }

  /// Stops watching and closes the given [mojoHandle].
  ///
  /// Returns an integer, encoding the result as specified in the [MojoResult]
  /// class. In particular, a successful operation returns [MojoResult.kOk].
  ///
  /// Notifies the HandleWatcherIsolate that a handle it is
  /// watching should be removed from its set and closed.
  ///
  /// The [mojoHandle] is a token that identifies the mojo-handle (but is
  /// usually not an instance of `MojoHandle`).
  ///
  /// If [wait] is true, returns a future that resolves only after the handle
  // has actually been closed by the handle watcher. Otherwise, returns a
  // future that resolves immediately.
  static Future<int> close(Object mojoHandle, {bool wait: false}) {
    throw new UnsupportedError("MojoHandleWatcher.close on contract");
  }

  /// Requests a ping on the given [port] at [deadline].
  ///
  /// Returns an integer, encoding the result as specified in the [MojoResult]
  /// class. In particular, a successful operation returns [MojoResult.kOk].
  ///
  /// The [deadline] is in milliseconds relative to
  /// [MojoCoreNatives.timerMillisecondClock].
  ///
  /// If the given [port] was already registered for a timer, then the old
  /// value is discarded.
  ///
  /// A negative [deadline] is used to remove a port. That is, a negative value
  /// is ignored after any existing value for the port has been discarded.
  static int timer(Object ignored, SendPort port, int deadline) {
    throw new UnsupportedError("MojoHandleWatcher.timer on contract");
  }
}

class MojoCoreNatives {
  /// Returns the time, in microseconds, since some undefined point in the past.
  ///
  /// The values are only meaningful relative to other values that were obtained
  /// from the same device without an intervening system restart. Such values
  /// are guaranteed to be monotonically non-decreasing with the passage of real
  /// time.
  ///
  /// Although the units are microseconds, the resolution of the clock may vary
  /// and is typically in the range of ~1-15 ms.
  static int getTimeTicksNow() {
    throw new UnsupportedError("MojoCoreNatives.getTimeTicksNow on contract");
  }

  /// Returns the time, in milliseconds, since some undefined point in the past.
  ///
  /// This method is equivalent to `getTimeTicksNow() ~/ 1000`.
  static int timerMillisecondClock() {
    throw new UnsupportedError(
        "MojoCoreNatives.timerMillisecondClock on contract");
  }
}

class MojoHandleNatives {
  /// Puts the given [handle] with the given [description] into the set of
  /// open handles.
  ///
  /// The [handle] is a token that identifies the mojo-handle (but is
  /// usually not an instance of `MojoHandle`).
  ///
  /// This method is only used to report open handles (see [reportOpenHandles]).
  ///
  /// This method can be implemented without native support (by maintaining
  /// a [Set]).
  static void addOpenHandle(Object handle, {String description}) {
    throw new UnsupportedError("MojoHandleNatives.addOpenHandle on contract");
  }

  /// Removes the given [handle] from the set of open handles.
  ///
  /// The [handle] is a token that identifies the mojo-handle (but is
  /// usually not an instance of `MojoHandle`).
  ///
  /// This method is only used to report open handles (see [reportOpenHandles]).
  ///
  /// This method can be implemented without native support (by maintaining
  /// a [Set]).
  ///
  /// Handles are removed from the set when they are closed, but also, when they
  /// are serialized in the mojo encoder [codec.dart].
  static void removeOpenHandle(Object handle) {
    throw new UnsupportedError(
        "MojoHandleNatives.removeOpenHandle on contract");
  }

  /// Prints a list of all open handles.
  ///
  /// Returns `true` if there are no open handles. False otherwise.
  ///
  /// Prints all handles that have been added with [addOpenHandle] but haven't
  /// been removed with [removeOpenHandle].
  ///
  /// Programs should not have open handles when the program terminates.
  static bool reportOpenHandles() {
    throw new UnsupportedError(
        "MojoHandleNatives.reportOpenHandles on contract");
  }

  /// Updates the description of the given [handle] in the set of open handles.
  ///
  /// The [handle] is a token that identifies the mojo-handle (but is
  /// usually not an instance of `MojoHandle`).
  ///
  /// Does nothing, if the [handle] isn't in the set.
  static bool setDescription(Object handle, String description) {
    throw new UnsupportedError("MojoHandleNatives.setDescription on contract");
  }

  /// Registers a finalizer on [eventStream] to close the given [handle].
  ///
  /// Returns an integer, encoding the result as specified in the [MojoResult]
  /// class. In particular, a successful operation returns [MojoResult.kOk].
  ///
  /// When [eventStream] (currently an Instance of the EventStream class) dies,
  /// invokes [close] on the [handle].
  ///
  /// The [handle] is a token that identifies the mojo-handle (but is
  /// usually not an instance of `MojoHandle`). In particular they are often
  /// integers, which is why the finalizer can't be directly on the [handle].
  ///
  /// Well-behaving programs should close their handles themselves, and
  /// finalizers wouldn't be necessary in that case.
  static int registerFinalizer(Object eventStream, Object handle) {
    throw new UnsupportedError(
        "MojoHandleNatives.registerFinalizer on contract");
  }

  /// Closes the given [handle].
  ///
  /// Returns an integer, encoding the result as specified in the [MojoResult]
  /// class. In particular, a successful operation returns [MojoResult.kOk].
  ///
  /// The [handle] is a token that identifies the mojo-handle (but is
  /// usually not an instance of `MojoHandle`).
  static int close(Object handle) {
    throw new UnsupportedError("MojoHandleNatives.close on contract");
  }

  /// Waits on the given [handle] for a signal.
  ///
  /// Returns a list of two elements. The first entry is an integer, encoding
  /// if the operation was a success or not, as specified in the [MojoResult]
  /// class. In particular, a successful operation is signaled by
  /// [MojoResult.kOk]. The second entry is itself a List of 2 elements:
  /// an integer of satisfied signals, and an integer of satisfiable signals.
  /// Both entries are encoded as specified in [MojoHandleSignals].
  ///
  /// The [deadline] specifies how long the call should wait (if no signal is
  /// triggered). If the deadline passes, the returned result-integer is
  /// [MojoResult.kDeadlineExceeded]. If the deadline is 0, then the result
  /// is only [MojoResult.kDeadlineExceeded] if no other termination condition
  /// is already satisfied (see below).
  ///
  /// The [signals] integer encodes the signals this method should wait for.
  /// The integer is encoded as specified in [MojoHandleSignals].
  ///
  /// Waits on the given handle until one of the following happens:
  /// - A signal indicated by [signals] is satisfied.
  /// - It becomes known that no signal indicated by [signals] will ever be
  ///   satisfied (for example the handle has been closed on the other side).
  /// - Until [deadline] has passed.
  static List wait(Object handle, int signals, int deadline) {
    throw new UnsupportedError("MojoHandleNatives.woit on contract");
  }

  /// Waits on many handles at the same time.
  ///
  /// The returned value is similar to the result of [wait].
  ///
  /// Behaves as if [wait] was called on each of the [handles] separately,
  /// completing when the first would complete.
  static List waitMany(List<Object> handles, List<int> signals, int deadline) {
    throw new UnsupportedError("MojoHandleNatives.wainMany on contract");
  }
}

/// TODO(floitsch): Removed:MojoHandleWatcherNatives from the contract. It is
/// only used by the MojoHandleWatcher which is itself in the contract. I
/// believe that users shouldn't call this method by themselves.

class MojoMessagePipeNatives {

  /// Creates a message pipe represented by its two endpoints (handles).
  ///
  /// Returns a list with exactly 3 elements:
  /// - the result integer, encoded as specified in [MojoResult]. In particular,
  ///   [MojoResult.kOk] signals a successful creation.
  /// - the two endpoints of the message pipe. These tokens can be used in the
  ///   methods of [MojoHandleNatives].
  ///
  /// The parameter [flags] is reserved for future use and should currently be
  /// set to [MojoMessagePipe.FLAG_NONE] (equal to 0).
  static List MojoCreateMessagePipe(int flags) {
    throw new UnsupportedError(
        "MojoMessagePipeNatives.MojoCreateMessagePipe on contract");
  }

  /// Writes a message into the endpoint [handle].
  ///
  /// Returns a result-integer, encoded as specified in [MojoResult]. In
  /// particular, [MojoResult.kOk] signals a successful write.
  ///
  /// A message is composed of [numBytes] bytes of [data], and a list of
  /// [handles].
  ///
  /// The parameter [flags] is reserved for future use and should currently be
  /// set to [MojoMessagePipeEndpoint.WRITE_FLAG_NONE] (equal to 0).
  static int MojoWriteMessage(Object handle, ByteData data, int numBytes,
      List<Object> handles, int flags) {
    throw new UnsupportedError(
        "MojoMessagePipeNatives.MojoWriteMessage on contract");
  }

  /// Reads a message from the endpoint [handle].
  ///
  /// Returns `null` if the parameters are invalid. Otherwise returns a list of
  /// exactly 3 elements:
  /// 1. the result integer, encoded as specified in [MojoResult]. In
  /// particular, [MojoResult.kOk] signals a successful read.
  /// 2. the number of read bytes (or available bytes if the message couldn't
  ///   be read).
  /// 3. the number of read handles (or available handles if the message
  ///   couldn't be read).
  ///
  /// If no message is available, the result-integer is set to
  /// [MojoResult.kShouldWait].
  ///
  /// Both [data], and [handles] may be null. If [data] is null, then [numBytes]
  /// must be 0.
  ///
  /// A message is always read in its entirety. That is, if a message doesn't
  /// fit into [data] and/or [handles], then the message is left in the pipe or
  /// discarded (see the description of [flags] below).
  ///
  /// If the message wasn't read because [data] or [handles] was too small,
  /// the result-integer is set to [MojoResult.kResourceExhausted].
  ///
  /// The returned list *always* contains the size of the message (independent
  /// if it was actually read into [data] and [handles]).
  /// A common pattern thus consists of invoking this method with
  /// [data] and [handles] set to `null` to query the size of the next
  /// message that is in the pipe.
  ///
  /// The parameter [flags] may set to either
  /// [MojoMessagePipeEndpoint.READ_FLAG_NONE] (equal to 0) or
  /// [MojoMessagePipeEndpoint.READ_FLAG_MAY_DISCARD] (equal to 1). In the
  /// latter case messages that couldn't be read (for example, because the
  /// [data] or [handles] wasn't big enough) are discarded.
  static List MojoReadMessage(Object handle, ByteData data, int numBytes,
      List<Object> handles, int flags) {
    throw new UnsupportedError(
        "MojoMessagePipeNatives.MojoReadMessage on contract");
  }

  /// Reads a message from the endpoint [handle].
  ///
  /// The result is returned in the provided list [result], which must have
  /// a length of at least 5.
  ///
  /// The elements in [result] are:
  /// 1. the result integer, encoded as specified in [MojoResult]. In
  ///   particular, [MojoResult.kOk] signals a successful read. This value is
  ///   only used as output.
  /// 2. the [ByteData] data array. This entry is used both as input and output.
  ///   If the array is non-null and big enough it is used to store the
  ///   byte-data of the message. Otherwise a new [ByteData] array of the
  ///   required length is allocated and stored in this slot.
  /// 3. a list, used to store handles. This entry is used both as input and
  ///   output. If the list is big enough it is filled with the read handles.
  ///   Otherwise, a new list of the required length is allocated and used
  ///   instead.
  /// 4. the size of the read byte data. Only used as output.
  /// 5. the number of read handles. Only used as output.
  ///
  /// The parameter [flags] may set to either
  /// [MojoMessagePipeEndpoint.READ_FLAG_NONE] (equal to 0) or
  /// [MojoMessagePipeEndpoint.READ_FLAG_MAY_DISCARD] (equal to 1). In the
  /// latter case messages that couldn't be read (for example, because the
  /// [data] or [handles] wasn't big enough) are discarded.
  ///
  /// Also see [MojoReadMessage].
  // TODO(floitsch): currently  'handles' is passed to the MojoReadMessage
  // call to query the size (in the C++ code). Unless I'm wrong this means that
  // with READ_FLAG_MAY_DISCARD the query would just drop the message...
  // TODO(floitsch): The return was never used and never set by the C++ code.
  // changed it to be void.
  static void MojoQueryAndReadMessage(Object handle, int flags, List result) {
    throw new UnsupportedError(
        "MojoMessagePipeNatives.MojoQueryAndReadMessage on contract");
  }
}

class MojoDataPipeNatives {
  /// Creates a (unidirectional) data-pipe represented by its two endpoints
  /// (handles).
  ///
  /// Returns a list with exactly 3 elements:
  /// 1. the result integer, encoded as specified in [MojoResult]. In particular,
  ///   [MojoResult.kOk] signals a successful creation.
  /// 2. the producer endpoint. A handle token.
  /// 3. the consumer endpoint. A handle token.
  ///
  /// The parameter [elementBytes] specifies the size of an element in bytes.
  /// All transactions and buffers consist of an integral number of elements.
  /// The integer [elementBytes] must be non-zero. The default should be
  /// [MojoDataPipe.DEFAULT_ELEMENT_SIZE] (equal to 1).
  ///
  /// The parameter [capacityBytes] specifies the capacity of the data-pipe, in
  /// bytes. The parameter must be a multiple of [elementBytes]. The data-pipe
  /// will always be able to queue *at least* this much data. If [capacityBytes]
  /// is set to zero, a system-dependent automatically-calculated capacity is
  /// used. The default should be [MojoDataPipe.DEFAULT_CAPACITY] (equal to 0).
  ///
  /// The parameter [flags] is reserved for future use and should currently be
  /// set to [MojoDataPipe.FLAG_NONE] (equal to 0).
  static List MojoCreateDataPipe(
      int elementBytes, int capacityBytes, int flags) {
    throw new UnsupportedError(
        "MojoDataPipeNatives.MojoCreateDataPipe on contract");
  }

  /// Writes [numBytes] bytes from [data] into the produces handle.
  ///
  /// Returns an integer, encoding the result as specified in the [MojoResult]
  /// class. In particular, a successful operation returns [MojoResult.kOk].
  ///
  /// The argument [handle] must be a producer handle created through
  /// [MojoCreateDataPipe].
  ///
  /// The argument [numBytes] should be a multiple of the data-pipes
  /// element-size.
  ///
  /// The argument [flags] can be
  /// - [MojoDataPipeProducer.FLAG_NONE] (equal to 0), or
  /// - [MojoDataPipeProducer.FLAG_ALL_OR_NONE] (equal to 1).
  ///
  /// If [flags] is equal to [MojoDataPipeProducer.FLAG_ALL_OR_NONE], then
  /// either all data is written, or none is. If the data can't be written, then
  /// the result-integer is set to [MojoResult.kOutOfRange].
  ///
  /// If no data can currently be written to an open consumer (and [flags] is
  /// *not* set to [MojoDataPipeProducer.FLAG_ALL_OR_NONE]), then the
  /// result-integer is set to [MojoResult.kShouldWait].
  static List MojoWriteData(
      dynamic handle, ByteData data, int numBytes, int flags) {
    throw new UnsupportedError("MojoDataPipeNatives.MojoWriteData on contract");
  }

  /// Starts a two-phase write.
  ///
  /// Returns a List of exactly 2 elements:
  /// 1. the result integer, encoded as specified in [MojoResult]. In
  ///   particular, [MojoResult.kOk] signals a successful operation.
  /// 2. a [ByteData] object (when successful), or `null` (if unsuccessful).
  ///
  /// The argument [handle] must be a producer handle created through
  /// [MojoCreateDataPipe].
  ///
  /// A two-phase write consists of requesting a buffer to write to (this
  /// function), followed by a call to [MojoEndWriteData] to signal that the
  /// buffer has been filled with data and is ready to write.
  ///
  /// While the system waits for the [MojoEndWriteData], the underlying
  /// message-pipe is set to non-writable.
  ///
  /// A two-phase write is only started if the result integer (the first
  /// argument of the returned list) is equal to [MojoResult.kOk]. Otherwise,
  /// the underlying pipe stays writable (assuming it was before), and does not
  /// expect a call to [MojoEndWriteData].
  ///
  /// The result integer is equal to [MojoResult.kBusy] if the pipe is already
  /// executing a two-phase write.
  ///
  /// The parameter [flags] is reserved for future use and should currently be
  /// set to [MojoDataPipeProducer.FLAG_NONE] (equal to 0).
  // TODO(floitsch): according to the Mojo-documentation, the bufferBytes is
  // just an output variable. We shouldn't need to set it. Can we remove the
  // parameter?
  static List MojoBeginWriteData(Object handle, int bufferBytes, int flags) {
    throw new UnsupportedError(
        "MojoDataPipeNatives.MojoBeginWriteData on contract");
  }

  /// Finishes a two-phase write.
  ///
  /// Returns a result integer, encoded as specified in [MojoResult]. In
  /// particular, [MojoResult.kOk] signals a successful operation.
  ///
  /// The argument [handle] must be a producer handle created through
  /// [MojoCreateDataPipe] and must be the same that was given to a previous
  /// call to [MojoBeginWriteData].
  ///
  /// Writes [bytesWritten] bytes of the [ByteData] buffer provided by
  /// [MojoBeginWriteData] into the pipe. The parameter [bytesWritten] must be
  /// less or equal to the size of the [ByteData] buffer and must be a multiple
  /// of the data pipe's element size.
  static int MojoEndWriteData(Object handle, int bytesWritten) {
    throw new UnsupportedError(
        "MojoDataPipeNatives.MojoEndWriteData on contract");
  }

  /// Reads up to [numBytes] from the given consumer [handle].
  ///
  /// Returns a list of exactly two elements:
  /// 1. the result integer, encoded as specified in [MojoResult]. In
  ///   particular, [MojoResult.kOk] signals a successful operation.
  /// 2. an integer `readBytes` (having different semantics depending on the
  ///   flags. See below for the different cases.
  ///
  /// The argument [handle] must be a consumer handle created through
  /// [MojoCreateDataPipe].
  ///
  /// The argument [numBytes] must be a multiple of the data pipe's element
  /// size.
  ///
  /// If [flags] has neither [MojoDataPipeConsumer.FLAG_DISCARD] (equal to 2),
  /// nor [MojoDataPipeConsumer.FLAG_QUERY] (equal to 4) set, tries to read up
  /// to [numBytes] bytes of data into the [data] buffer and set
  /// `readBytes` (the second element of the returned list) to the amount
  /// actually read.
  ///
  /// If [flags] has [MojoDataPipeConsumer.FLAG_ALL_OR_NONE] (equal to 1) set,
  /// either reads exactly [numBytes] bytes of data or none. Additionally, if
  /// [flags] has [MojoDataPipeConsumer.FLAG_PEEK] (equal to 8) set, the data
  /// read remains in the pipe and is available to future reads.
  ///
  /// If [flags] has [MojoDataPipeConsumer.FLAG_DISCARD] (equal to 2) set, it
  /// discards up to [numBytes] (which again must be a multiple of the element
  /// size) bytes of  data, setting `readBytes` to the amount actually
  /// discarded. If [flags] has [MojoDataPipeConsumer.FLAG_ALL_OR_NONE] (equal
  /// to 1), either discards exactly [numBytes] bytes of data or none. In this
  /// case, [MojoDataPipeConsumer.FLAG_QUERY] must not be set, and
  /// the [data] buffer is ignored (and should typically be set to
  /// null).
  ///
  /// If flags has [MojoDataPipeConsumer.FLAG_QUERY] set, queries the amount of
  /// data available, setting `readBytes` to the number of bytes available. In
  /// this case, [MojoDataPipeConsumer.FLAG_DISCARD] must not be set, and
  /// [MojoDataPipeConsumer.FLAG_ALL_OR_NONE] is ignored, as are [data] and
  /// [numBytes].
  static List MojoReadData(
      Object handle, ByteData data, int numBytes, int flags) {
    throw new UnsupportedError("MojoDataPipeNatives.MojoReadData on contract");
  }

  /// Starts a two-phase read.
  ///
  /// Returns a List of exactly 2 elements:
  /// 1. the result integer, encoded as specified in [MojoResult]. In
  ///   particular, [MojoResult.kOk] signals a successful operation.
  /// 2. a [ByteData] object (when successful), or `null` (if unsuccessful).
  ///
  /// The argument [handle] must be a consumer handle created through
  /// [MojoCreateDataPipe].
  ///
  /// A two-phase write consists of requesting a buffer to read from (this
  /// function), followed by a call to [MojoEndReadData] to signal that the
  /// buffer has been read.
  ///
  /// While the system waits for the [MojoEndReadData], the underlying
  /// message-pipe is set to non-readable.
  ///
  /// A two-phase read is only started if the result integer (the first
  /// argument of the returned list) is equal to [MojoResult.kOk]. Otherwise,
  /// the underlying pipe stays readable (assuming it was before), and does not
  /// expect a call to [MojoEndReadData].
  ///
  /// The result integer is equal to [MojoResult.kBusy] if the pipe is already
  /// executing a two-phase read.
  ///
  /// The result integer is equal to [MojoResult.kShouldWait] if the pipe has
  /// no data available.
  ///
  /// The parameter [flags] is reserved for future use and should currently be
  /// set to [MojoDataPipeConsumer.FLAG_NONE] (equal to 0).
  // TODO(floitsch): according to the Mojo-documentation, the bufferBytes is
  // just an output variable. We shouldn't need to set it. Can we remove the
  // parameter?
  static List MojoBeginReadData(Object handle, int bufferBytes, int flags) {
    throw new UnsupportedError(
        "MojoDataPipeNatives.MojoBeginReadData on contract");
  }

  /// Finishes a two-phase read.
  ///
  /// Returns a result integer, encoded as specified in [MojoResult]. In
  /// particular, [MojoResult.kOk] signals a successful operation.
  ///
  /// The argument [handle] must be a consumer handle created through
  /// [MojoCreateDataPipe] and must be the same that was given to a previous
  /// call to [MojoBeginReadData].
  ///
  /// Consumes [bytesRead] bytes of the [ByteData] buffer provided by
  /// [MojoBeginReadData]. The parameter [bytesWritten] must be
  /// less or equal to the size of the [ByteData] buffer and must be a multiple
  /// of the data pipe's element size.
  static int MojoEndReadData(Object handle, int bytesRead) {
    throw new UnsupportedError(
        "MojoDataPipeNatives.MojoEndReadData on contract");
  }
}

class MojoSharedBufferNatives {
  /// Creates a shared buffer of [numBytes] bytes.
  ///
  /// Returns a List of exactly 2 elements:
  /// 1. the result integer, encoded as specified in [MojoResult]. In
  ///   particular, [MojoResult.kOk] signals a successful operation.
  /// 2. a handle.
  ///
  /// A shared buffer can be shared between applications (by duplicating the
  /// handle -- see [Duplicate] -- and passing it over a message pipe).
  ///
  /// A shared buffer can be accessed through by invoking [Map].
  ///
  /// The parameter [flags] is reserved for future use and should currently be
  /// set to [MojoSharedBuffer.createFlagNone] (equal to 0).
  static List Create(int numBytes, int flags) {
    throw new UnsupportedError("MojoSharedBufferNatives.Create on contract");
  }


  /// Duplicates the given [bufferHandle] so that it can be shared through a
  /// message pipe.
  ///
  /// Returns a list of exactly 2 elements:
  /// 1. the result integer, encoded as specified in [MojoResult]. In
  ///   particular, [MojoResult.kOk] signals a successful operation.
  /// 2. the duplicated handle.
  ///
  /// The [bufferHandle] must be a handle created by [Create].
  ///
  /// Creates another handle (returned as second element in the returned list)
  /// which can then be sent to another application over a message pipe, while
  /// retaining access to the [bufferHandle] (and any mappings that it may
  /// have).
  ///
  /// The parameter [flags] is reserved for future use and should currently be
  /// set to [MojoSharedBuffer.duplicateFlagNone] (equal to 0).
  static List Duplicate(Object bufferHandle, int flags) {
    throw new UnsupportedError("MojoSharedBufferNatives.Duplicate on contract");
  }

  /// Maps the given [bufferHandle] so that its data can be access through a
  /// [ByteData] buffer.
  ///
  /// Returns a list of exactly 2 elements:
  /// 1. the result integer, encoded as specified in [MojoResult]. In
  ///   particular, [MojoResult.kOk] signals a successful operation.
  /// 2. a [ByteData] buffer that maps to the data in the shared buffer.
  ///
  /// The [bufferHandle] must be a handle created by [Create].
  ///
  /// Maps [numBytes] of data, starting at offset [offset] into a [ByteData]
  /// buffer.
  ///
  /// Note: there is no `unmap` call, since this is supposed to happen via
  /// finalizers.
  ///
  /// The parameter [flags] is reserved for future use and should currently be
  /// set to [MojoSharedBuffer.mapFlagNone] (equal to 0).
  static List Map(Object bufferHandle, int offset, int numBytes, int flags) {
    throw new UnsupportedError("MojoSharedBufferNatives.Map on contract");
  }
}