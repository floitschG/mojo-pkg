// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library internal.isolate;

import 'dart:async';
import 'dart:isolate' show SendPort;
import 'dart:math' show max;
import 'dart:typed_data' show ByteData;

import 'manager.dart';

import '../../core.dart' show MojoResult;

class MojoHandleWatcher {
  static int add(Endpoint endpoint, SendPort port, int signals) {
    return manager.addWatch(endpoint, port, signals);
  }

  static int remove(Endpoint endpoint) {
    return manager.removeWatch(endpoint);
  }

  static Future<int> close(Endpoint endpoint, {bool wait: false}) {
    return manager.closeWatch(endpoint, wait);
  }

  static int timer(Object ignored, SendPort port, int deadline) {
    int delta = max(0, deadline - MojoCoreNatives.timerMillisecondClock());
    new Timer(new Duration(milliseconds: delta), () {
      port.send(null);
    });
    return MojoResult.kOk;
  }
}

class MojoCoreNatives {
  static int getTimeTicksNow() => new DateTime.now().microsecondsSinceEpoch;

  static int timerMillisecondClock() =>
      new DateTime.now().millisecondsSinceEpoch;
}

class MojoHandleNatives {
  static void addOpenHandle(Endpoint endpoint, {String description}) {
    // TODO(floitsch): implement.
  }

  static void removeOpenHandle(Object handleToken) {
    // TODO(floitsch): implement.
  }

  static bool reportOpenHandles() {
    // TODO(floitsch): implement.
  }

  static bool setDescription(Endpoint endpoint, String description) {
    // TODO(floitsch): implement.
  }

  static int registerFinalizer(Object eventSubscription, Endpoint endpoint) {
    // Do nothing.
  }

  static int close(Endpoint endpoint) {
    return manager.close(endpoint);
  }

  /// Waits on the given [handleToken] for a signal.
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
  static List wait(Object handleToken, int signals, int deadline) {
    throw new UnsupportedError("MojoHandleNatives.woit on contract");
  }

  /// Waits on many handles at the same time.
  ///
  /// The returned value is similar to the result of [wait].
  ///
  /// Behaves as if [wait] was called on each of the [handleTokens] separately,
  /// completing when the first would complete.
  static List waitMany(
      List<Object> handleTokens, List<int> signals, int deadline) {
    throw new UnsupportedError("MojoHandleNatives.wainMany on contract");
  }
}

class MojoMessagePipeNatives {
  static List MojoCreateMessagePipe(int flags) {
    return manager.createPipe();
  }

  /// Writes a message into the endpoint [handleToken].
  ///
  /// Returns a result-integer, encoded as specified in [MojoResult]. In
  /// particular, [MojoResult.kOk] signals a successful write.
  ///
  /// The [handleToken] is a token that identifies the mojo-handle (but is
  /// usually not an instance of `MojoHandle`).
  ///
  /// A message is composed of [numBytes] bytes of [data], and a list of
  /// [handleTokens].
  ///
  /// The parameter [flags] is reserved for future use and should currently be
  /// set to [MojoMessagePipeEndpoint.WRITE_FLAG_NONE] (equal to 0).
  static int MojoWriteMessage(Object handleToken, ByteData data, int numBytes,
      List<Object> handleTokens, int flags) {
    throw new UnsupportedError(
        "MojoMessagePipeNatives.MojoWriteMessage on contract");
  }

  /// Reads a message from the endpoint [handleToken].
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
  /// The [handleToken] is a token that identifies the mojo-handle (but is
  /// usually not an instance of `MojoHandle`).
  ///
  /// Both [data], and [handleTokens] may be null. If [data] is null, then
  /// [numBytes] must be 0.
  ///
  /// A message is always read in its entirety. That is, if a message doesn't
  /// fit into [data] and/or [handleTokens], then the message is left in the
  /// pipe or discarded (see the description of [flags] below).
  ///
  /// If the message wasn't read because [data] or [handleTokens] was too small,
  /// the result-integer is set to [MojoResult.kResourceExhausted].
  ///
  /// The returned list *always* contains the size of the message (independent
  /// if it was actually read into [data] and [handleTokens]).
  /// A common pattern thus consists of invoking this method with
  /// [data] and [handleTokens] set to `null` to query the size of the next
  /// message that is in the pipe.
  ///
  /// The parameter [flags] may set to either
  /// [MojoMessagePipeEndpoint.READ_FLAG_NONE] (equal to 0) or
  /// [MojoMessagePipeEndpoint.READ_FLAG_MAY_DISCARD] (equal to 1). In the
  /// latter case messages that couldn't be read (for example, because the
  /// [data] or [handleTokens] wasn't big enough) are discarded.
  static List MojoReadMessage(Object handleToken, ByteData data, int numBytes,
      List<Object> handleTokens, int flags) {
    throw new UnsupportedError(
        "MojoMessagePipeNatives.MojoReadMessage on contract");
  }

  /// Reads a message from the endpoint [handleToken].
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
  /// The [handleToken] is a token that identifies the mojo-handle (but is
  /// usually not an instance of `MojoHandle`).
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
  static void MojoQueryAndReadMessage(
      Object handleToken, int flags, List result) {
    throw new UnsupportedError(
        "MojoMessagePipeNatives.MojoQueryAndReadMessage on contract");
  }
}

class MojoDataPipeNatives {
  static List MojoCreateDataPipe(
      int elementBytes, int capacityBytes, int flags) {
    return manager.createPipe();
  }

  /// Writes [numBytes] bytes from [data] into the produces handle.
  ///
  /// Returns an integer, encoding the result as specified in the [MojoResult]
  /// class. In particular, a successful operation returns [MojoResult.kOk].
  ///
  /// The argument [handleToken] must be a producer handle created through
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
      Object handleToken, ByteData data, int numBytes, int flags) {
    throw new UnsupportedError("MojoDataPipeNatives.MojoWriteData on contract");
  }

  /// Starts a two-phase write.
  ///
  /// Returns a List of exactly 2 elements:
  /// 1. the result integer, encoded as specified in [MojoResult]. In
  ///   particular, [MojoResult.kOk] signals a successful operation.
  /// 2. a [ByteData] object (when successful), or `null` (if unsuccessful).
  ///
  /// The argument [handleToken] must be a producer handle created through
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
  static List MojoBeginWriteData(
      Object handleToken, int bufferBytes, int flags) {
    throw new UnsupportedError(
        "MojoDataPipeNatives.MojoBeginWriteData on contract");
  }

  /// Finishes a two-phase write.
  ///
  /// Returns a result integer, encoded as specified in [MojoResult]. In
  /// particular, [MojoResult.kOk] signals a successful operation.
  ///
  /// The argument [handleToken] must be a producer handle created through
  /// [MojoCreateDataPipe] and must be the same that was given to a previous
  /// call to [MojoBeginWriteData].
  ///
  /// Writes [bytesWritten] bytes of the [ByteData] buffer provided by
  /// [MojoBeginWriteData] into the pipe. The parameter [bytesWritten] must be
  /// less or equal to the size of the [ByteData] buffer and must be a multiple
  /// of the data pipe's element size.
  static int MojoEndWriteData(Object handleToken, int bytesWritten) {
    throw new UnsupportedError(
        "MojoDataPipeNatives.MojoEndWriteData on contract");
  }

  /// Reads up to [numBytes] from the given consumer [handleToken].
  ///
  /// Returns a list of exactly two elements:
  /// 1. the result integer, encoded as specified in [MojoResult]. In
  ///   particular, [MojoResult.kOk] signals a successful operation.
  /// 2. an integer `readBytes` (having different semantics depending on the
  ///   flags. See below for the different cases.
  ///
  /// The argument [handleToken] must be a consumer handle created through
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
      Object handleToken, ByteData data, int numBytes, int flags) {
    throw new UnsupportedError("MojoDataPipeNatives.MojoReadData on contract");
  }

  /// Starts a two-phase read.
  ///
  /// Returns a List of exactly 2 elements:
  /// 1. the result integer, encoded as specified in [MojoResult]. In
  ///   particular, [MojoResult.kOk] signals a successful operation.
  /// 2. a [ByteData] object (when successful), or `null` (if unsuccessful).
  ///
  /// The argument [handleToken] must be a consumer handle created through
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
  static List MojoBeginReadData(
      Object handleToken, int bufferBytes, int flags) {
    throw new UnsupportedError(
        "MojoDataPipeNatives.MojoBeginReadData on contract");
  }

  /// Finishes a two-phase read.
  ///
  /// Returns a result integer, encoded as specified in [MojoResult]. In
  /// particular, [MojoResult.kOk] signals a successful operation.
  ///
  /// The argument [handleToken] must be a consumer handle created through
  /// [MojoCreateDataPipe] and must be the same that was given to a previous
  /// call to [MojoBeginReadData].
  ///
  /// Consumes [bytesRead] bytes of the [ByteData] buffer provided by
  /// [MojoBeginReadData]. The parameter [bytesWritten] must be
  /// less or equal to the size of the [ByteData] buffer and must be a multiple
  /// of the data pipe's element size.
  static int MojoEndReadData(Object handleToken, int bytesRead) {
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

  /// Duplicates the given [bufferHandleToken] so that it can be shared through
  /// a message pipe.
  ///
  /// Returns a list of exactly 2 elements:
  /// 1. the result integer, encoded as specified in [MojoResult]. In
  ///   particular, [MojoResult.kOk] signals a successful operation.
  /// 2. the duplicated handle.
  ///
  /// The [bufferHandleToken] must be a handle created by [Create].
  ///
  /// Creates another handle (returned as second element in the returned list)
  /// which can then be sent to another application over a message pipe, while
  /// retaining access to the [bufferHandleToken] (and any mappings that it may
  /// have).
  ///
  /// The parameter [flags] is reserved for future use and should currently be
  /// set to [MojoSharedBuffer.duplicateFlagNone] (equal to 0).
  static List Duplicate(Object bufferHandleToken, int flags) {
    throw new UnsupportedError("MojoSharedBufferNatives.Duplicate on contract");
  }

  /// Maps the given [bufferHandleToken] so that its data can be access through
  /// a [ByteData] buffer.
  ///
  /// Returns a list of exactly 2 elements:
  /// 1. the result integer, encoded as specified in [MojoResult]. In
  ///   particular, [MojoResult.kOk] signals a successful operation.
  /// 2. a [ByteData] buffer that maps to the data in the shared buffer.
  ///
  /// The [bufferHandleToken] must be a handle created by [Create].
  ///
  /// Maps [numBytes] of data, starting at offset [offset] into a [ByteData]
  /// buffer.
  ///
  /// Note: there is no `unmap` call, since this is supposed to happen via
  /// finalizers.
  ///
  /// The parameter [flags] is reserved for future use and should currently be
  /// set to [MojoSharedBuffer.mapFlagNone] (equal to 0).
  static List Map(
      Object bufferHandleToken, int offset, int numBytes, int flags) {
    throw new UnsupportedError("MojoSharedBufferNatives.Map on contract");
  }
}
