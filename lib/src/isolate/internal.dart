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
  static int add(List handleToken, SendPort port, int signals) {
    return manager.addWatch(handleToken, port, signals);
  }

  static int remove(List handleToken) {
    return manager.removeWatch(handleToken);
  }

  static Future<int> close(List handleToken, {bool wait: false}) {
    return manager.closeWatch(handleToken, wait);
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
  static void addOpenHandle(List handleToken, {String description}) {
    // TODO(floitsch): implement.
  }

  static void removeOpenHandle(Object handleToken) {
    // TODO(floitsch): implement.
  }

  static bool reportOpenHandles() {
    // TODO(floitsch): implement.
    return true;
  }

  static bool setDescription(List handleToken, String description) {
    // TODO(floitsch): implement.
    return true;
  }

  static int registerFinalizer(Object eventSubscription, List handleToken) {
    // Do nothing.
    return MojoResult.kOk;
  }

  static int close(List handleToken) {
    return manager.close(handleToken);
  }

  static List wait(List handleToken, int signals, int deadline) {
    return manager.wait(handleToken, signals, deadline);
  }

  static List waitMany(
      List<Object> handleTokens, List<int> signals, int deadline) {
    return manager.waitMany(handleTokens, signals, deadline);
  }
}

class MojoMessagePipeNatives {
  static List MojoCreateMessagePipe(int flags) {
    return manager.createPipe();
  }

  static int MojoWriteMessage(Object handleToken, ByteData data, int numBytes,
      List<Object> handleTokens, int flags) {
    return manager.writeMessage(
        handleToken, data, numBytes, handleTokens, flags);
  }

  static List MojoReadMessage(Object handleToken, ByteData data, int numBytes,
      List<Object> handleTokens, int flags) {
    return manager.readMessage(
        handleToken, data, numBytes, handleTokens, flags);
  }

  static void MojoQueryAndReadMessage(
      Object handleToken, int flags, List result) {
    return manager.queryAndReadMessage(handleToken, flags, result);
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
